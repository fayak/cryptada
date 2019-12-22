#ifndef __BIGNUM_H__
#define __BIGNUM_H__
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

#include <stdint.h>
#include <assert.h>


#define BN_ARRAY_SIZE    64
#define STR_DEST_SIZE    32
/* Custom assert macro - easy to disable */
#define require(p, msg) assert(p && #msg)

#define BASE 256
#define WORD_SIZE 8
#define WORD_MASK 0xff

/* Data-holding structure: array of DTYPEs */
struct bn
{
  uint8_t array[BN_ARRAY_SIZE];
  uint32_t size;
  uint8_t neg;
};

/* Tokens returned by bignum_cmp() for value comparison */
enum { SMALLER = -1, EQUAL = 0, BIGGER = 1 };

/* Initialization functions: */
void bignum_init(struct bn* n);
void bignum_from_int(struct bn* n, int32_t i);
int  bignum_to_int(struct bn* n);
void bignum_from_string(struct bn* n, char* str, uint32_t nbytes);
void bignum_to_string(struct bn* n, char* str, uint32_t maxsize);

/* Basic arithmetic operations: */
void bignum_add(struct bn* a, struct bn* b, struct bn* c); /* c = a + b */
void bignum_sub(struct bn* a, struct bn* b, struct bn* c); /* c = a - b */
void bignum_mul(struct bn* a, struct bn* b, struct bn* c); /* c = a * b */
void bignum_div(struct bn* a, struct bn* b, struct bn* c); /* c = a / b */
void bignum_mod(struct bn* a, struct bn* b, struct bn* c); /* c = a % b */
//    void bignum_divmod(struct bn* a, struct bn* b, struct bn* c, struct bn* d); /* c = a/b, d = a%b */
void bignum_powmod(struct bn* a, struct bn* b, struct bn* n, struct bn* res);
//
//    /* Bitwise operations: */
void bignum_and(struct bn* a, struct bn* b, struct bn* c); /* c = a & b */
void bignum_or(struct bn* a, struct bn* b, struct bn* c);  /* c = a | b */
void bignum_xor(struct bn* a, struct bn* b, struct bn* c); /* c = a ^ b */
void bignum_lshift(struct bn* a, struct bn* b, uint32_t nbits); /* b = a << nbits */
void bignum_rshift(struct bn* a, struct bn* b, uint32_t nbits); /* b = a >> nbits */
//
//    /* Special operators and comparison */
int  bignum_cmp(struct bn* a, struct bn* b);               /* Compare: returns LARGER, EQUAL or SMALLER */
int  bignum_is_zero(struct bn* n);                         /* For comparison with zero */
void bignum_inc(struct bn* n);                             /* Increment: add one to n */
void bignum_dec(struct bn* n);                             /* Decrement: subtract one from n */
void bignum_pow(struct bn* a, struct bn* b, struct bn* c); /* Calculate a^b -- e.g. 2^10 => 1024 */
//    void bignum_isqrt(struct bn* a, struct bn* b);             /* Integer square root -- e.g. isqrt(5) => 2*/
void bignum_assign(struct bn* dst, struct bn* src);        /* Copy src into dst -- dst := src */

uint32_t bignum_nb_bits(struct bn* n);


/*
 *  Cryptographic PRNG
 *
 *  Based on linux random.c
 * */

#define POOL_SIZE 64
#define _WORD_MASK (POOL_SIZE - 1)

uint32_t rol32(uint32_t n, unsigned int nb);

struct entropy_pool {
    uint32_t pool[POOL_SIZE];
    uint8_t i;
    int rotate;
    uint32_t entropy_count;
};

static uint32_t const twist_table[8] = {
 0x00000000, 0x3b6e20c8, 0x76dc4190, 0x4db26158,
 0xedb88320, 0xd6d6a3e8, 0x9b64c2b0, 0xa00ae278 };

static uint32_t const taps[] = {
    128, 104, 76, 51, 25, 1
}; // P(X) = X^128 + X^104 + X^76 + X^51 + X^25 + X + 1

// Q(X) = alpha^3 (P(X) - 1) + 1 with alpha^3 compute using twist_table
// Mix some entropy in the entropy pool
void mix_pool(int entropy, struct entropy_pool *pool);


#define ENTROPY_SHIFT 3
#define ENTROPY_BITS(r) ((r) >> ENTROPY_SHIFT)
#define MAX_ENTROPY (POOL_SIZE * 8)
// log(POOL_SIZE) + 2
// Used for faster division by bitshift
#define POOL_BIT_SHIFT (6 + 2)

enum { EMPTY = 0, LOW = 1, MEDIUM = 2, FILLED = 3, FULL = 4 };
extern const char* ENTROPY_POOL_COUNT_TXT[16]; // = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};
// Credit the entropy pool for a given amount of bits of entropy
int credit_entropy(int nb_bits, struct entropy_pool *pool);

int entropy_estimator(int x);

#endif /* #ifndef __BIGNUM_H__ */
