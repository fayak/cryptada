#ifndef __ENTROPY_POOL_H__
#define __ENTROPY_POOL_H__

#ifdef __cplusplus
extern "C" {
#endif

#define likely(x)       __builtin_expect(!!(x), 1)
#define unlikely(x)     __builtin_expect(!!(x), 0)

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
        uint32_t entropy_count;

        // Entropy mixing
        uint8_t i; // Where to put the created entropy. Init it to 0, and don't touch
        int rotate; // Number of rol32 rotation to perform

        // Entropy extraction
        uint8_t j; // Where to get the last 16 bytes of entropy to XOR. Init it to 0, and don't touch
        uint32_t chacha20_state[16];
        uint8_t chacha20_init; // Is chacha20_state initialized ?
        uint32_t output[2]; // Contains (remaining_extracted) random bytes to be given to the user
        uint8_t remaining_extracted;
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

    // Allow us to take into account fractions of bits of entropy
#define ENTROPY_SHIFT 3
    // Maximum of entropy in the pool, taking account of partial bits of entropy.
    // shift << 5 is for 32 (since there are 32 bits in a uint32_t
#define MAX_ENTROPY (POOL_SIZE << (5 + ENTROPY_SHIFT))
    // log(POOL_SIZE) + 5
    // Used for faster division by bitshift
#define POOL_BIT_SHIFT (6 + 5)

    enum { EMPTY = 0, LOW = 1, MEDIUM = 2, FILLED = 3, FULL = 4 };
    extern const char* ENTROPY_POOL_COUNT_TXT[16]; // = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};
    // Credit the entropy pool for a given amount of bits of entropy
    int credit_entropy(int nb_bits, struct entropy_pool *pool);

    int entropy_estimator(int x);

    // Return the amount of bits of entropy in the pool
    uint32_t get_entropy_count(struct entropy_pool *pool);
#define ENTROPY_COUNT(x) ((x) >> ENTROPY_SHIFT)

    // Extract a random byte from the entropy pool. Does not check if the pool has
    // enough entropy to do so, so be advised.
    //
    // When it needs to extract entropy from the pool, it requires 64 bits of entropy.
    // One must assert (pool->remaining_extracted > 0 || pool->entropy_count >= 64) before calling get_random
    uint8_t get_random(struct entropy_pool *pool);

#ifdef __cplusplus
}
#endif

#endif
