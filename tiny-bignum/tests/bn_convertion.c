#include "bn.h"
#include <string.h>
#include <stdio.h>

#define BEFORE printf("Running      : %s\n", __func__)
#define AFTER  printf("Test succeed : %s\n", __func__)


void test_from_string(void)
{
    BEFORE;
    struct bn a;
    bignum_from_string(&a, "0", 1);
    assert(bignum_to_int(&a) == 0);
    bignum_from_string(&a, "5", 1);
    assert(bignum_to_int(&a) == 5);
    bignum_from_string(&a, "10", 2);
    assert(bignum_to_int(&a) == 10);
    bignum_from_string(&a, "12357", 5);
    assert(bignum_to_int(&a) == 12357);
    bignum_from_string(&a, "-12357", 6);
    assert(bignum_to_int(&a) == -12357);
    bignum_from_string(&a, "-0", 2);
    assert(bignum_to_int(&a) == 0);
    AFTER;
}

void test_bitwise(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn res;

    bignum_from_int(&a, 001230123);
    bignum_from_int(&b, 002310123);

    bignum_or(&a, &b, &res);
    assert(bignum_to_int(&res) == (001230123 | 002310123));

    bignum_and(&a, &b, &res);
    assert(bignum_to_int(&res) == (001230123 & 002310123));

    bignum_xor(&a, &b, &res);
    assert(bignum_to_int(&res) == (001230123 ^ 002310123));

    AFTER;
}

void test_inc(void)
{
    BEFORE;

    struct bn a;
    bignum_from_int(&a, -10);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == -9);

    bignum_from_int(&a, -14);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == -13);

    bignum_from_int(&a, -0x1000);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == -0xfff);

    bignum_from_int(&a, -1);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == 0);

    bignum_from_int(&a, 5);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == 6);

    bignum_from_int(&a, 0xffff);
    bignum_inc(&a);
    assert(bignum_to_int(&a) == 0x10000);

    AFTER;
}

void test_dec(void)
{
    BEFORE;

    struct bn a;
    bignum_from_int(&a, 10);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == 9);

    bignum_from_int(&a, 14);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == 13);

    bignum_from_int(&a, 0x1000);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == 0xfff);

    bignum_from_int(&a, 0);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == -1);

    bignum_from_int(&a, -5);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == -6);

    bignum_from_int(&a, -0xffff);
    bignum_dec(&a);
    assert(bignum_to_int(&a) == -0x10000);

    AFTER;
}

void test_shifts(void)
{
    BEFORE;
    struct bn a;
    struct bn b;

    bignum_from_int(&a, 11);
    bignum_lshift(&a, &b, 1);
    assert(bignum_to_int(&b) == (11 << 1));

    bignum_from_int(&a, 0);
    bignum_lshift(&a, &b, 1);
    assert(bignum_to_int(&b) == (0 << 1));

    bignum_from_int(&a, 120034);
    bignum_lshift(&a, &b, 7);
    assert(bignum_to_int(&b) == (120034 << 7));

    bignum_from_int(&a, 120034);
    bignum_lshift(&a, &b, 0);
    assert(bignum_to_int(&b) == (120034 << 0));

    bignum_from_int(&a, 120034);
    bignum_lshift(&a, &b, 21);
    assert(bignum_to_int(&b) == (120034U << 21));



    bignum_from_int(&a, 11);
    bignum_rshift(&a, &b, 1);
    assert(bignum_to_int(&b) == (11 >> 1));

    bignum_from_int(&a, 0);
    bignum_rshift(&a, &b, 1);
    assert(bignum_to_int(&b) == (0 >> 1));

    bignum_from_int(&a, 120034);
    bignum_rshift(&a, &b, 7);
    assert(bignum_to_int(&b) == (120034 >> 7));

    bignum_from_int(&a, 120034);
    bignum_rshift(&a, &b, 0);
    assert(bignum_to_int(&b) == (120034 >> 0));

    bignum_from_int(&a, 120034);
    bignum_rshift(&a, &b, 21);
    assert(bignum_to_int(&b) == (120034 >> 21));

    AFTER;
}

void test_bignum_to_string(void)
{
    BEFORE;
    struct bn a;
    char pute[32] = {0};
    bignum_from_int(&a, 0);
    bignum_to_string(&a, pute, 32);
    assert(strcmp(pute, "0") == 0);

    bignum_from_int(&a, 5);
    bignum_to_string(&a, pute, 32);
    assert(strcmp(pute, "5") == 0);

    bignum_from_int(&a, 10);
    bignum_to_string(&a, pute, 32);
    assert(strcmp(pute, "10") == 0);

    bignum_from_int(&a, 12357);
    bignum_to_string(&a, pute, 32);
    assert(strcmp(pute, "12357") == 0);

    bignum_from_int(&a, 12357);
    bignum_to_string(&a, pute, 3);
    assert(strcmp(pute, "@7") == 0);

    bignum_from_string(&a, "12357", 5);
    assert(bignum_to_int(&a) == 12357);
    bignum_to_string(&a, pute, 6);
    assert(strcmp(pute, "12357") == 0);

    bignum_from_string(&a, "-12357", 6);
    assert(bignum_to_int(&a) == -12357);
    bignum_to_string(&a, pute, 7);
    assert(strcmp(pute, "-12357") == 0);

    bignum_from_string(&a, "-0", 2);
    assert(bignum_to_int(&a) == 0);
    bignum_to_string(&a, pute, 7);
    assert(strcmp(pute, "0") == 0);
    AFTER;
}

void test_from_to_int(void)
{
    BEFORE;
    struct bn a;
    bignum_from_int(&a, 0);
    assert(bignum_to_int(&a) == 0);
    bignum_from_int(&a, 10);
    assert(bignum_to_int(&a) == 10);
    bignum_from_int(&a, 5);
    assert(bignum_to_int(&a) == 5);
    bignum_from_int(&a, 12357);
    assert(bignum_to_int(&a) == 12357);
    AFTER;
}

void test_cmp(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    bignum_from_int(&a, 0);
    bignum_from_int(&b, 1);
    assert(bignum_cmp(&a, &b) == SMALLER);
    assert(bignum_cmp(&b, &a) == BIGGER);
    assert(bignum_cmp(&a, &a) == EQUAL);
    assert(bignum_cmp(&b, &b) == EQUAL);
    bignum_from_int(&b, -1);
    assert(bignum_cmp(&a, &b) == BIGGER);
    assert(bignum_cmp(&b, &a) == SMALLER);
    assert(bignum_cmp(&b, &b) == EQUAL);
    bignum_from_int(&a, 12357);
    bignum_from_int(&b, 12358);
    assert(bignum_cmp(&a, &b) == SMALLER);
    assert(bignum_cmp(&b, &a) == BIGGER);
    assert(bignum_cmp(&a, &a) == EQUAL);
    assert(bignum_cmp(&b, &b) == EQUAL);
    bignum_from_int(&a, -12357);
    bignum_from_int(&b, 12358);
    assert(bignum_cmp(&a, &b) == SMALLER);
    assert(bignum_cmp(&b, &a) == BIGGER);
    assert(bignum_cmp(&a, &a) == EQUAL);
    assert(bignum_cmp(&b, &b) == EQUAL);
    AFTER;
}

void test_sub(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn c;
    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  9999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == 2358);
    bignum_sub(&a, &a, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  -9999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == -2358);
    bignum_sub(&a, &a, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  -9999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == 22356);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  9999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == -22356);

    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  99999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == -87642);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  -99999);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == 87642);

    bignum_from_int(&a, 0);
    bignum_from_int(&b, 1);
    bignum_sub(&b, &a, &c);
    assert(bignum_to_int(&c) == 1);
    bignum_sub(&a, &b, &c);
    assert(bignum_to_int(&c) == -1);
    AFTER;
}

void test_add(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn c;
    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  9999);
    bignum_add(&a, &b, &c);
    assert(bignum_to_int(&c) == 22356);
    bignum_add(&b, &a, &c);
    assert(bignum_to_int(&c) == 22356);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  -9999);
    bignum_add(&a, &b, &c);
    assert(bignum_to_int(&c) == -22356);
    bignum_add(&b, &a, &c);
    assert(bignum_to_int(&c) == -22356);

    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  -9999);
    bignum_add(&a, &b, &c);
    assert(bignum_to_int(&c) == 2358);
    bignum_add(&b, &a, &c);
    assert(bignum_to_int(&c) == 2358);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  9999);
    bignum_add(&a, &b, &c);
    assert(bignum_to_int(&c) == -2358);
    bignum_add(&b, &a, &c);
    assert(bignum_to_int(&c) == -2358);

    bignum_from_int(&a, 0);
    bignum_from_int(&b,  9999);
    bignum_add(&a, &b, &c);
    assert(bignum_to_int(&c) == 9999);
    bignum_add(&b, &a, &c);
    assert(bignum_to_int(&c) == 9999);

    AFTER;
}

void test_mul(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn c;
    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  9999);
    bignum_mul(&a, &b, &c);
    assert(bignum_to_int(&c) == 123557643);
    bignum_mul(&b, &a, &c);
    assert(bignum_to_int(&c) == 123557643);

    bignum_from_int(&a, -12357);
    bignum_from_int(&b,  -9999);
    bignum_mul(&a, &b, &c);
    assert(bignum_to_int(&c) == 123557643);
    bignum_mul(&b, &a, &c);
    assert(bignum_to_int(&c) == 123557643);

    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  -9999);
    bignum_mul(&a, &b, &c);
    assert(bignum_to_int(&c) == -123557643);
    bignum_mul(&b, &a, &c);
    assert(bignum_to_int(&c) == -123557643);

    bignum_from_int(&a, 0);
    bignum_from_int(&b,  9999);
    bignum_mul(&a, &b, &c);
    assert(bignum_to_int(&c) == 0);
    bignum_mul(&b, &a, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, 0);
    bignum_from_int(&b,  0);
    bignum_mul(&a, &b, &c);
    assert(bignum_to_int(&c) == 0);
    bignum_mul(&b, &a, &c);
    assert(bignum_to_int(&c) == 0);

    AFTER;
}

void test_div(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn c;
    bignum_from_int(&a, 1);
    bignum_from_int(&b,  1);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 1);

    bignum_from_int(&a, 2);
    bignum_from_int(&b,  1);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 2);

    bignum_from_int(&a, 25);
    bignum_from_int(&b,  5);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 5);
    bignum_div(&b, &a, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, 12357);
    bignum_from_int(&b,  999);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 12);
    bignum_div(&b, &a, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, 0);
    bignum_from_int(&b,  9999);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 0);

    bignum_from_int(&a, 10);
    bignum_from_int(&b,  5);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == 2);

    bignum_from_int(&a, 10);
    bignum_from_int(&b,  -5);
    bignum_div(&a, &b, &c);
    assert(bignum_to_int(&c) == -2);

    AFTER;
}

void test_nb_bits(void)
{
    BEFORE;
    struct bn a;
    bignum_from_int(&a, 0);
    assert(bignum_nb_bits(&a) == 0);
    bignum_from_int(&a, 1);
    assert(bignum_nb_bits(&a) == 1);
    bignum_from_int(&a, 2);
    assert(bignum_nb_bits(&a) == 2);
    bignum_from_int(&a, 4);
    assert(bignum_nb_bits(&a) == 3);
    bignum_from_int(&a, 8);
    assert(bignum_nb_bits(&a) == 4);
    bignum_from_int(&a, 9);
    assert(bignum_nb_bits(&a) == 4);
    bignum_from_int(&a, 126);
    assert(bignum_nb_bits(&a) == 7);
    bignum_from_int(&a, 255);
    assert(bignum_nb_bits(&a) == 8);
    AFTER;
}

void test_pow(void)
{
    BEFORE;
    struct bn a;
    struct bn b;
    struct bn c;
    bignum_from_int(&a, 2);
    bignum_from_int(&b, 4);
    bignum_pow(&a, &a, &c);
    assert(bignum_to_int(&c) == 4);
    bignum_pow(&a, &b, &c);
    assert(bignum_to_int(&c) == 16);
    bignum_from_int(&a, 3);
    bignum_from_int(&b, 7);
    bignum_pow(&a, &a, &c);
    assert(bignum_to_int(&c) == 27);
    bignum_pow(&a, &b, &c);
    assert(bignum_to_int(&c) == 2187);
    AFTER;
}

void print_pool(struct entropy_pool *pool)
{
    printf("Internal pool state : ");
    for (uint8_t i = 0; i < POOL_SIZE; ++i)
    {
        printf("%4x", pool->pool[i]);
    }
    printf("\n");
}

void test_random(void)
{
    struct entropy_pool pool = {0};
    int entropy = 0x12357;
    for (int i = 0; i < 16; ++i)
        mix_pool(&entropy, &pool);
    print_pool(&pool);
    entropy = 0xfdf661a;
    for (int i = 0; i < 16; ++i)
        mix_pool(&entropy, &pool);
    print_pool(&pool);
}

int main(void)
{
    test_from_to_int();
    test_from_string();
    test_nb_bits();
    test_cmp();
    test_dec();
    test_inc();
    test_sub();
    test_add();
    test_bitwise();
    test_mul();
    test_shifts();
    test_div();
    test_bignum_to_string();
    test_pow();
    test_random();
}
