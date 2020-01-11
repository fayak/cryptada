/*

   Big number library - arithmetic on multiple-precision unsigned integers.

   This library is an implementation of arithmetic on arbitrarily large integers.

   The difference between this and other implementations, is that the data structure
   has optimal memory utilization (i.e. a 1024 bit integer takes up 128 bytes RAM),
   and all memory is allocated statically: no dynamic allocation for better or worse.

   Primary goals are correctness, clarity of code and clean, portable implementation.
   Secondary goal is a memory footprint small enough to make it suitable for use in
   embedded applications.


   The current state is correct functionality and adequate performance.
   There may well be room for performance-optimizations and improvements.

*/

#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include "bn.h"

/* Functions for shifting number in-place. */
static void _lshift_one_bit(struct bn* a);
static void _rshift_one_bit(struct bn* a);
static void _lshift_word(struct bn* a, uint32_t nwords);
static void _rshift_word(struct bn* a, uint32_t nwords);

/* Array and bignum getter/setter helper */
#define ARRAY_TAIL(array, size, offset) ((array)[(size) - (offset) - 1])
#define BIGNUM_TAIL(bn, offset) (ARRAY_TAIL(((bn)->array), (BN_ARRAY_SIZE), (offset)))
static void bignum_push(struct bn *n, uint8_t val)
{
    if (n->size < BN_ARRAY_SIZE)
        BIGNUM_TAIL(n, n->size++) = val;
}

/* Public / Exported functions. */
void bignum_init(struct bn* n)
{
    require(n, "n is null");

    uint32_t i;
    for (i = 0; i < BN_ARRAY_SIZE; ++i)
    {
        n->array[i] = 0;
    }
    n->size = 0;
    n->neg = 0;
}


void bignum_from_int(struct bn* n, int32_t i)
{
    require(n, "n is null");

    bignum_init(n);

    if (i < 0)
    {
        i *= -1;
        n->neg = 1;
    }

    for (uint32_t j = 0; i != 0; ++j)
    {
        n->size++;
        BIGNUM_TAIL(n, j) = i % BASE;
        i /= BASE;
    }
}


int bignum_to_int(struct bn* n)
{
    require(n, "n is null");

    int ret = 0;

    for (uint32_t i = 0; i < n->size; ++i)
    {
        ret *= BASE;
        ret += n->array[BN_ARRAY_SIZE - n->size + i];
    }

    if (n->neg)
        ret *= -1;

    return ret;
}

void remove_zeros(struct bn* n)
{
    uint32_t old = n->size;
    for (uint32_t i = 0; i < old; i++)
    {
        if (unlikely(n->array[BN_ARRAY_SIZE - old + i] != 0)) // Unlikely since this condition breaks the loop -> Even if it's more likely, the pipeline will stall anyway
            break;
        n->size--;
    }
    if (n->size == 0)
        n->neg = 0;
}

void bignum_from_string(struct bn* n, char* str, uint32_t nbytes)
{
    require(n, "n is null");
    require(str, "str is null");
    require(nbytes > 0, "nbytes must be positive");

    bignum_init(n);

    uint8_t is_neg = 0;
    if (str[0] == '-')
    {
        is_neg = 1;
        nbytes--;
        str++;
    }

    struct bn digit = { 0 };
    struct bn ten = { 0 };
    struct bn tmp = { 0 };

    bignum_from_int(&ten, 10);

    for (uint32_t i = 0; i < nbytes; ++i)
    {
        bignum_mul(n, &ten, &tmp);
        bignum_from_int(&digit, str[i] - '0');
        bignum_add(&tmp, &digit, n);
    }

    n->neg = is_neg;
}


void bignum_to_string(struct bn* n, char* str, uint32_t nbytes)
{
    require(n, "n is null");
    require(str, "str is null");
    require(nbytes > 1, "nbytes must be positive");

    if (bignum_is_zero(n))
    {
        str[0] = '0';
        str[1] = 0;
        return;
    }

    if (n->neg)
    {
        str[0] = '-';
        str++;
        nbytes--;
    }

    struct bn tmp = { 0 };
    struct bn ten = { 0 };
    struct bn res = { 0 };
    bignum_from_int(&ten, 10);
    bignum_assign(&tmp, n);

    tmp.neg = 0;

    ARRAY_TAIL(str, nbytes, 0) = 0;
    uint32_t i = 1;
     while (i < nbytes && !bignum_is_zero(&tmp))
     {
         bignum_mod(&tmp, &ten, &res);
         ARRAY_TAIL(str, nbytes, i++) = bignum_to_int(&res) + '0';
         bignum_div(&tmp, &ten, &res);
         bignum_assign(&tmp, &res);
     }

    if (!bignum_is_zero(&tmp))
    {
        str[0] = '@';
        return;
    }

    uint8_t shift = nbytes - i;
    if (shift == 0)
        return;
    for (uint32_t i = 0; i < nbytes - shift; ++i)
    {
        str[i] = str[i + shift];
    }
}


void bignum_dec(struct bn* n)
{
    require(n, "n is null");

    if (bignum_is_zero(n))
    {
        n->size = 1;
        n->neg = 1;
        BIGNUM_TAIL(n, 0) = 1;
        return;
    }

    if (n->neg)
    {
        uint8_t carry = 1;
        for (uint32_t i = 0; carry && i < n->size; ++i)
        {
            uint32_t tmp = BIGNUM_TAIL(n, i) + carry;
            BIGNUM_TAIL(n, i) = tmp % BASE;
            carry = tmp >= BASE;
        }
        if (carry)
            bignum_push(n, 1);
        return;
    }

    uint8_t carry = 1;
    for (uint32_t i = 0; carry && i < n->size; ++i)
    {
        int32_t tmp = BIGNUM_TAIL(n, i) - carry;
        carry = tmp < 0;
        if (unlikely(tmp < 0))
            tmp += BASE;
        BIGNUM_TAIL(n, i) = tmp;
    }
    remove_zeros(n);
}


void bignum_add(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    if (unlikely(a->neg && !b->neg)) // (-a) + b -> b + (-a)
    {
        bignum_add(b, a, c);
        return;
    }
    if (!a->neg && b->neg) // a + (-b) -> a - b
    {
        b->neg = 0;
        bignum_sub(a, b, c);
        b->neg = 1;
        return;
    }

    bignum_init(c);

    int32_t tmp;
    uint8_t carry = 0;
    c->neg = a->neg;
    uint32_t max = a->size > b->size ? a->size : b->size;
    for (uint32_t i = 0; i < max; ++i)
    {
        tmp = BIGNUM_TAIL(a, i) + BIGNUM_TAIL(b, i) + carry;
        carry = tmp >= BASE;
        if (unlikely(carry)) // 45% des cas
            bignum_push(c, tmp - BASE);
        else
            bignum_push(c, tmp);
    }
    if (carry)
        bignum_push(c, 1);
}

inline static int _ubignum_cmp(struct bn* a, struct bn* b)
{
    if (a->size > b->size)
        return BIGGER;
    if (a->size < b->size)
        return SMALLER;

    for (uint32_t i = 0; i < a->size; ++i)
    {
        if (a->array[BN_ARRAY_SIZE - a->size + i] > b->array[BN_ARRAY_SIZE - a->size + i])
            return BIGGER;
        if (a->array[BN_ARRAY_SIZE - a->size + i] < b->array[BN_ARRAY_SIZE - a->size + i])
            return SMALLER;
    }
    return EQUAL;
}

int bignum_cmp(struct bn* a, struct bn* b)
{
    require(a, "a is null");
    require(b, "b is null");

    if (a->neg && !b->neg)
        return SMALLER;
    if (!a->neg && b->neg)
        return BIGGER;
    uint8_t neg = a->neg ? -1 : 1;

    return _ubignum_cmp(a, b) * neg;
}


void bignum_sub(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "b is null");

    if (unlikely(bignum_is_zero(b)))
    {
        bignum_assign(c, a);
        return;
    }
    if (unlikely(a->neg != b->neg))
    {
        b->neg = !b->neg;
        bignum_add(a, b, c);
        b->neg = !b->neg;
        return;
    }

    int8_t cmp = bignum_cmp(a, b);

    if ((cmp == SMALLER && !a->neg) || (cmp == BIGGER && a->neg))
    {
        bignum_sub(b, a, c);
        c->neg = !c->neg;
        return;
    }

    bignum_init(c);
    uint8_t carry = 0;
    for (uint32_t i = 0; i < a->size; ++i)
    {
        int16_t tmp = (int16_t)BIGNUM_TAIL(a, i) - (int16_t)BIGNUM_TAIL(b, i) - carry;
        if (likely(tmp >= 0))
        {
            BIGNUM_TAIL(c, i) = tmp;
            carry = 0;
        }
        else
        {
            BIGNUM_TAIL(c, i) = tmp + BASE;
            carry = 1;
        }
    }
    c->size = a->size;
    c->neg = a->neg;
    remove_zeros(c);
}


void bignum_inc(struct bn* n)
{
    require(n, "n is null");

    if (!n->neg)
    {
        uint32_t carry = 1;
        for (uint32_t i = 0; carry && i < n->size; ++i)
        {
            uint32_t tmp = BIGNUM_TAIL(n, i) + 1;
            carry = tmp >= BASE;
            BIGNUM_TAIL(n, i) = tmp % BASE;
        }
        if (unlikely(carry))
            bignum_push(n, 1);
        return;
    }

    if (n->size == 1 && BIGNUM_TAIL(n, 0) == 1)
    {
        n->size = 0;
        n->neg = 0;
        BIGNUM_TAIL(n, 0) = 0;
        return;
    }

    uint8_t carry = 1;
    for (uint32_t i = 0; carry && i < n->size; ++i)
    {
        int32_t tmp = BIGNUM_TAIL(n, i) - carry;
        carry = tmp < 0;
        if (unlikely(tmp < 0))
            tmp += BASE;
        BIGNUM_TAIL(n, i) = tmp;
    }
    remove_zeros(n);
}




void bignum_mul(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    struct bn row = { 0 };
    struct bn tmp = { 0 };
    struct bn res = { 0 };

    bignum_init(c);

    if (unlikely(bignum_is_zero(a) || bignum_is_zero(b)))
        return;

    for (uint32_t i = 0; i < a->size; ++i)
    {
        bignum_init(&row);

        for (uint32_t j = 0; j < b->size && i + j < BN_ARRAY_SIZE; ++j)
        {
            uint32_t intermediate = BIGNUM_TAIL(a, i)
                * BIGNUM_TAIL(b, j);
            bignum_from_int(&tmp, intermediate);
            _lshift_word(&tmp, i + j);
            bignum_add(&tmp, &row, &res);
            bignum_assign(&row, &res);
        }
        bignum_add(c, &row, &res);
        bignum_assign(c, &res);
    }
    c->neg = a->neg ^ b->neg;
}


uint32_t bignum_nb_bits(struct bn* n)
{
    uint32_t nb_bits = n->size * WORD_SIZE;
    if (nb_bits == 0)
        return 0;
    for (int i = WORD_SIZE - 1; i >= 0; --i)
    {
        if ((BIGNUM_TAIL(n, n->size - 1) >> i) & 1)
            break;
        nb_bits--;
    }
    return nb_bits;
}

static void _bignum_div(struct bn* a, struct bn* b, struct bn* q, struct bn* r)
{
    assert(!bignum_is_zero(b));

    struct bn tmp = {0};
    uint8_t b_neg = b->neg;
    b->neg = 0;

    for (int32_t i = bignum_nb_bits(a) - 1; i >= 0; --i)
    {
        _lshift_one_bit(r);
        BIGNUM_TAIL(r, 0) |= (BIGNUM_TAIL(a, (i / WORD_SIZE)) >> (i % WORD_SIZE)) & 1;
        r->size++;
        remove_zeros(r);
        if (_ubignum_cmp(r, b) >= EQUAL)
        {
            bignum_sub(r, b, &tmp);
            bignum_assign(r, &tmp);
            BIGNUM_TAIL(q, (i / WORD_SIZE)) |= 1 << (i % WORD_SIZE);
        }
    }
    b->neg = b_neg;
    q->size = BN_ARRAY_SIZE;
    remove_zeros(q);
    q->neg = a->neg ^ b->neg;
    r->neg = a->neg ^ b->neg;
}

void bignum_div(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "b is null");
    bignum_init(c);
    struct bn trash = { 0 };
    _bignum_div(a, b, c, &trash);
}

void bignum_lshift(struct bn* a, struct bn* b, uint32_t nbits)
{
    require(a, "a is null");
    require(b, "b is null");

    bignum_assign(b, a);
    /* Handle shift in multiples of word-size */
    int nwords = nbits / WORD_SIZE;
    if (nwords != 0)
    {
        _lshift_word(b, nwords);
        nbits %= WORD_SIZE;
    }

    for (uint32_t i = 0; i < nbits; ++i)
    {
        _lshift_one_bit(b);
    }
}


void bignum_rshift(struct bn* a, struct bn* b, uint32_t nbits)
{
    require(a, "a is null");
    require(b, "b is null");

    bignum_assign(b, a);
    /* Handle shift in multiples of word-size */
    int nwords = nbits / WORD_SIZE;
    if (nwords != 0)
    {
        _rshift_word(b, nwords);
        nbits %= WORD_SIZE;
    }

    for (uint32_t i = 0; i < nbits; ++i)
    {
        _rshift_one_bit(b);
    }
}


void bignum_mod(struct bn* a, struct bn* b, struct bn* c)
{
    /*
       Take divmod and throw away div part
       */
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    struct bn tmp = { 0 };
    bignum_init(c);
    if (a->neg)
    {
        while (a->neg)
        {
            bignum_add(a, b, c);
            bignum_assign(a, c);
        }
        return;
    }
    _bignum_div(a, b, &tmp, c);
}

void bignum_divmod(struct bn* a, struct bn* b, struct bn* c, struct bn* d)
{
    /*
       Puts a%b in d
       and a/b in c

       mod(a,b) = a - ((a / b) * b)

example:
mod(8, 3) = 8 - ((8 / 3) * 3) = 2
*/
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");
    require(d, "c is null");

    _bignum_div(a, b, c, d);
}


void bignum_and(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    uint32_t max = a->size > b->size ? a->size : b->size;
    for (uint32_t i = 0; i < BN_ARRAY_SIZE; ++i)
    {
        c->array[i] = WORD_MASK & (a->array[i] & b->array[i]);
    }

    c->size = max;
    c->neg = 0;
    remove_zeros(c);
}


void bignum_or(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    uint32_t max = a->size > b->size ? a->size : b->size;
    for (uint32_t i = 0; i < BN_ARRAY_SIZE; ++i)
    {
        c->array[i] = WORD_MASK & (a->array[i] | b->array[i]);
    }

    c->size = max;
    c->neg = 0;
    remove_zeros(c);
}


void bignum_xor(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    uint32_t max = a->size > b->size ? a->size : b->size;

    for (uint32_t i = 0; i < BN_ARRAY_SIZE; ++i)
    {
        c->array[i] = WORD_MASK & (a->array[i] ^ b->array[i]);
    }

    c->size = max;
    c->neg = 0;
    remove_zeros(c);
}


inline int bignum_is_zero(struct bn* n)
{
    return !n->size;
}


void bignum_powmod(struct bn* a, struct bn* b, struct bn* n, struct bn* res)
{
    bignum_from_int(res, 1); /* r = 1 */

    struct bn tmpa;
    struct bn tmpb;
    struct bn tmp;
    bignum_assign(&tmpa, a);
    bignum_assign(&tmpb, b);

    while (1)
    {
        if (BIGNUM_TAIL(&tmpb, 0) & 1)     /* if (b % 2) */
        {
            bignum_mul(res, &tmpa, &tmp);  /*   r = r * a % m */
            bignum_mod(&tmp, n, res);
        }
        bignum_rshift(&tmpb, &tmp, 1); /* b /= 2 */
        bignum_assign(&tmpb, &tmp);

        if (bignum_is_zero(&tmpb))
            break;

        bignum_mul(&tmpa, &tmpa, &tmp);
        bignum_mod(&tmp, n, &tmpa);
    }
}

void bignum_pow(struct bn* a, struct bn* b, struct bn* c)
{
    require(a, "a is null");
    require(b, "b is null");
    require(c, "c is null");

    struct bn tmp;

    bignum_init(c);

    if (bignum_cmp(b, c) == EQUAL)
    {
        /* Return 1 when exponent is 0 -- n^0 = 1 */
        bignum_inc(c);
    }
    else
    {
        struct bn bcopy;
        bignum_assign(&bcopy, b);

        /* Copy a -> tmp */
        bignum_assign(&tmp, a);

        bignum_dec(&bcopy);

        /* Begin summing products: */
        while (!bignum_is_zero(&bcopy))
        {

            /* c = tmp * tmp */
            bignum_mul(&tmp, a, c);
            /* Decrement b by one */
            bignum_dec(&bcopy);

            bignum_assign(&tmp, c);
        }

        /* c = tmp */
        bignum_assign(c, &tmp);
    }
}
//
//void bignum_isqrt(struct bn *a, struct bn* b)
//{
//    require(a, "a is null");
//    require(b, "b is null");
//
//    struct bn low, high, mid, tmp;
//
//    bignum_init(&low);
//    bignum_assign(&high, a);
//    bignum_rshift(&high, &mid, 1);
//    bignum_inc(&mid);
//
//    while (bignum_cmp(&high, &low) > 0) 
//    {
//        bignum_mul(&mid, &mid, &tmp);
//        if (bignum_cmp(&tmp, a) > 0) 
//        {
//            bignum_assign(&high, &mid);
//            bignum_dec(&high);
//        }
//        else 
//        {
//            bignum_assign(&low, &mid);
//        }
//        bignum_sub(&high,&low,&mid);
//        _rshift_one_bit(&mid);
//        bignum_add(&low,&mid,&mid);
//        bignum_inc(&mid);
//    }
//    bignum_assign(b,&low);
//}


void bignum_assign(struct bn* dst, struct bn* src)
{
    require(dst, "dst is null");
    require(src, "src is null");

    dst->neg = src->neg;
    dst->size = src->size;
    for (int i = 0; i < BN_ARRAY_SIZE; ++i)
    {
        dst->array[i] = src->array[i];
    }
}


/* Private / Static functions. */
static void _rshift_word(struct bn* a, uint32_t nwords)
{
    require(a, "a is null");

    if (!nwords)
        return;

    uint32_t i = 0;
    /* Shift whole words */
    for (; i < a->size && i + nwords <= BN_ARRAY_SIZE; ++i)
        BIGNUM_TAIL(a, i) = BIGNUM_TAIL(a, i + nwords);

    /* Zero pad shifted words. */
    for (; i < a->size; ++i)
        BIGNUM_TAIL(a, i) = 0;

    remove_zeros(a);
}


static void _lshift_word(struct bn* a, uint32_t nwords)
{
    require(a, "a is null");

    if (!nwords)
        return;

    uint32_t i = nwords > BN_ARRAY_SIZE - 1 - a->size
        ? BN_ARRAY_SIZE - 1
        : a->size + nwords;

    /* Shift whole words */
    for (; i >= nwords; --i)
        BIGNUM_TAIL(a, i) = BIGNUM_TAIL(a, i - nwords);

    /* Zero pad shifted words. */
    for (; i != 0; --i)
        BIGNUM_TAIL(a, i) = 0;
    BIGNUM_TAIL(a, i) = 0;

    /* update size */
    a->size = BN_ARRAY_SIZE < a->size + nwords
        ? BN_ARRAY_SIZE
        : a->size + nwords;

    remove_zeros(a);
}


static void _lshift_one_bit(struct bn* a)
{
    require(a, "a is null");

    a->size += !!(a->size != BN_ARRAY_SIZE);
    for (uint32_t i = a->size; i > 0; --i)
    {
        BIGNUM_TAIL(a, i) = WORD_MASK & ((BIGNUM_TAIL(a, i) << 1)
            | (BIGNUM_TAIL(a, i - 1) >> (WORD_SIZE - 1)));
    }
    BIGNUM_TAIL(a, 0) = WORD_MASK & (BIGNUM_TAIL(a, 0) << 1);

    remove_zeros(a);
}


static void _rshift_one_bit(struct bn* a)
{
    require(a, "a is null");

    a->size += !!(a->size != BN_ARRAY_SIZE);
    for (uint32_t i = 0; i < a->size - 1; ++i)
    {
        BIGNUM_TAIL(a, i) = WORD_MASK & ((BIGNUM_TAIL(a, i) >> 1)
                | (BIGNUM_TAIL(a, i + 1) << (WORD_SIZE - 1)));
    }
    BIGNUM_TAIL(a, a->size - 1) >>= 1;

    remove_zeros(a);
}

inline uint32_t rol32(uint32_t n, unsigned int nb)
{
    return (n >> (nb & 31)) | (n << ((-nb) & 31));
}

void mix_pool(int entropy, struct entropy_pool *pool)
{
    char *entropy_bytes = (void *)(&entropy);
    uint32_t w;
    for (uint8_t i = 0; i < sizeof(int); ++i)
    {
        char byte = entropy_bytes[i];
        w = rol32(byte, pool->rotate);
        pool->rotate = (pool->rotate + 7) & 31;
        pool->i = (pool->i - 1) & _WORD_MASK;

        for (uint8_t j = 0; j < 6; ++j)
            w ^= pool->pool[(pool->i + taps[j]) & _WORD_MASK];
        pool->pool[pool->i] = (w >> 3) ^ twist_table[w & 7];
    }
}

// entropy <- entropy + (MAX_ENTROPY - entropy) * 3/4 * add_entropy / MAX_ENTROPY
int credit_entropy(int nb_bits, struct entropy_pool *pool)
{
    int add_entropy = nb_bits << ENTROPY_SHIFT;

    if (unlikely(add_entropy > MAX_ENTROPY / 2))
    {
        // The given above formula is a faster approximation that cannot
        // work if add_entropy > MAX_ENTROPY / 2
        credit_entropy(nb_bits / 2, pool);
        return credit_entropy(nb_bits / 2, pool);
    }
    else if (likely(add_entropy > 0))
    {
        const int s = POOL_BIT_SHIFT + ENTROPY_SHIFT + 2; // +2 is the /4 in the above formula
        add_entropy = ((MAX_ENTROPY - pool->entropy_count) * add_entropy * 3) >> s;
    }
    int new_entropy_count = pool->entropy_count + add_entropy;
    if (new_entropy_count <= 0)
    {
        pool->entropy_count = 0;
        return EMPTY;
    }
    if (unlikely(new_entropy_count >= MAX_ENTROPY))
    {
        pool->entropy_count = MAX_ENTROPY;
        return FULL;
    }
    pool->entropy_count = new_entropy_count;
    return (int)(((float)new_entropy_count / (float)MAX_ENTROPY) * 3) + 1;
}

const char* ENTROPY_POOL_COUNT_TXT[16]  = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};

int entropy_estimator(int x)
{
    if (x < 8)
        return 0;
    if (x > 4096) // 2^12
        return 12;
    int cnt = 3;
    while (x > 8)
    {
        cnt++;
        x >>= 1;
    }
    return cnt - (x != 8);
}

// RFC 7539#2.3
// Performs n * 4 quarterrounds (aka chacha20 block if n = 20)
static void _chacha_iter(uint32_t *x, int n)
{
    assert((n & 0x1) == 0); // n even
    for (int i = 0; i < n; i += 2) { // 8 Quarter rounds per batch
        x[0]  += x[4];  x[12] = rol32(x[12] ^ x[0],  16);
        x[1]  += x[5];  x[13] = rol32(x[13] ^ x[1],  16);
        x[2]  += x[6];  x[14] = rol32(x[14] ^ x[2],  16);
        x[3]  += x[7];  x[15] = rol32(x[15] ^ x[3],  16);

        x[8]  += x[12]; x[4]  = rol32(x[4]  ^ x[8],  12);
        x[9]  += x[13]; x[5]  = rol32(x[5]  ^ x[9],  12);
        x[10] += x[14]; x[6]  = rol32(x[6]  ^ x[10], 12);
        x[11] += x[15]; x[7]  = rol32(x[7]  ^ x[11], 12);

        x[0]  += x[4];  x[12] = rol32(x[12] ^ x[0],   8);
        x[1]  += x[5];  x[13] = rol32(x[13] ^ x[1],   8);
        x[2]  += x[6];  x[14] = rol32(x[14] ^ x[2],   8);
        x[3]  += x[7];  x[15] = rol32(x[15] ^ x[3],   8);

        x[8]  += x[12]; x[4]  = rol32(x[4]  ^ x[8],   7);
        x[9]  += x[13]; x[5]  = rol32(x[5]  ^ x[9],   7);
        x[10] += x[14]; x[6]  = rol32(x[6]  ^ x[10],  7);
        x[11] += x[15]; x[7]  = rol32(x[7]  ^ x[11],  7);

        x[0]  += x[5];  x[15] = rol32(x[15] ^ x[0],  16);
        x[1]  += x[6];  x[12] = rol32(x[12] ^ x[1],  16);
        x[2]  += x[7];  x[13] = rol32(x[13] ^ x[2],  16);
        x[3]  += x[4];  x[14] = rol32(x[14] ^ x[3],  16);

        x[10] += x[15]; x[5]  = rol32(x[5]  ^ x[10], 12);
        x[11] += x[12]; x[6]  = rol32(x[6]  ^ x[11], 12);
        x[8]  += x[13]; x[7]  = rol32(x[7]  ^ x[8],  12);
        x[9]  += x[14]; x[4]  = rol32(x[4]  ^ x[9],  12);

        x[0]  += x[5];  x[15] = rol32(x[15] ^ x[0],   8);
        x[1]  += x[6];  x[12] = rol32(x[12] ^ x[1],   8);
        x[2]  += x[7];  x[13] = rol32(x[13] ^ x[2],   8);
        x[3]  += x[4];  x[14] = rol32(x[14] ^ x[3],   8);

        x[10] += x[15]; x[5]  = rol32(x[5]  ^ x[10],  7);
        x[11] += x[12]; x[6]  = rol32(x[6]  ^ x[11],  7);
        x[8]  += x[13]; x[7]  = rol32(x[7]  ^ x[8],   7);
        x[9]  += x[14]; x[4]  = rol32(x[4]  ^ x[9],   7);
    }
}

void *_memcpy(void *dest, const void *src, uint32_t len)
{
  char *d = dest;
  const char *s = src;
  while (len--)
    *d++ = *s++;
  return dest;
}

void chacha20(uint32_t *state, uint32_t *out)
{
    uint32_t x[16];
    _memcpy(x, state, 64);
    _chacha_iter(x, 20);
    for (uint8_t i = 0; i < 16; ++i)
        out[i] = state[i] + x[i];
    state[12]++; // increase block counter
    if (unlikely(!state[12]))
        state[13]++;
}

uint8_t _give_random_byte(struct entropy_pool *pool)
{
    uint8_t i = pool->remaining_extracted >= 4;
    uint8_t j = pool->remaining_extracted % 4;
    pool->remaining_extracted--;
    uint8_t random[4];
    _memcpy(random, pool->output + i, 4);
    return random[j];
}

uint8_t get_random(struct entropy_pool *pool)
{
    if (pool->remaining_extracted > 0)
        return _give_random_byte(pool);
    if (!pool->chacha20_init)
    {
        // Init chacha20 state from the entropy pool
        _memcpy(pool->chacha20_state, pool->pool, sizeof(uint32_t) * 16);
        for (uint8_t i = 16; i < POOL_SIZE; ++i)
            pool->chacha20_state[i % 16] ^= pool->pool[i];
        pool->chacha20_state[12] = 1; // Set the block counter
        pool->chacha20_state[13] = 0; // Set the block counter
        pool->chacha20_init = 1;
    }

    // Hash the whole entropy pool
    uint32_t hash_all[16] = {0};
    for (uint8_t i = 0; i < POOL_SIZE; i += 16)
    {
        uint32_t key_stream[16];
        chacha20(pool->chacha20_state, key_stream);
        for (uint8_t j = 0; j < 16; ++j)
        {
            if (unlikely(i == 0))
                hash_all[j]  = (key_stream[j] ^ pool->pool[i + j]);
            else
                hash_all[j] ^= (key_stream[j] ^ pool->pool[i + j]);
        }
    }

    uint32_t hash[4] = {0};
    // Fold the 64 bytes hash in a 16 bytes hash
    for (uint8_t i = 0; i < 4; ++i)
        hash[i]      = hash_all[i];
    for (uint8_t i = 4; i < 16; ++i)
        hash[i & 3] ^= hash_all[i];

    // Change some of the chacha20 state
    pool->chacha20_state[hash_all[0] % 12] ^= hash_all[1]; //uint32_t of the key
    pool->chacha20_state[(hash_all[2] & 1) + 14] ^= hash_all[3]; //uint32_t of the nonce

    //Mix the hash back in the pool
    for (uint8_t i = 0; i < 4; ++i)
    {
        int32_t val = hash[i];
        mix_pool(val & 0x000000FF, pool);
        mix_pool(val & 0x0000FF00, pool);
        mix_pool(val & 0x00FF0000, pool);
        mix_pool(val & 0xFF000000, pool);
    }

    uint32_t entropy_extract[4];
    _memcpy(entropy_extract, pool->pool + pool->j, 16);
    pool->j = (pool->j + 16) % POOL_SIZE;

    // Xor and fold
    pool->output[0] = (entropy_extract[0] ^ hash[0]) ^ (entropy_extract[2] ^ hash[2]);
    pool->output[1] = (entropy_extract[1] ^ hash[1]) ^ (entropy_extract[3] ^ hash[3]);
    pool->remaining_extracted = 8;
    credit_entropy(-64, pool);
    return _give_random_byte(pool);
}

uint32_t get_entropy_count(struct entropy_pool *pool)
{
    return pool->entropy_count >> ENTROPY_SHIFT;
}
