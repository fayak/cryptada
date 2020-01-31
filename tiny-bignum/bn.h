#ifndef __BIGNUM_H__
#define __BIGNUM_H__

#ifdef __cplusplus
extern "C" {
#endif
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

#define likely(x)       __builtin_expect(!!(x), 1)
#define unlikely(x)     __builtin_expect(!!(x), 0)

// MUST BE % 4 !
#define BN_ARRAY_SIZE    128
#define STR_DEST_SIZE    256
/* Custom assert macro - easy to disable */
#define require(p, msg) assert(p && #msg)

#define BASE 256
#define WORD_SIZE 8
#define WORD_MASK 0xff

//static uint8_t KARATSUBA_MIN = 6;
#define KARATSUBA_MIN 8

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


#ifdef __cplusplus
}
#endif

#endif /* #ifndef __BIGNUM_H__ */
