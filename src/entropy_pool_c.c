#include <assert.h>
#include <stdint.h>
#include "entropy_pool.h"

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
