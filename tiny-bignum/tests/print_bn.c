#include <stdlib.h>
#include <stdio.h>

#include "bn.h"

int main(void)
{
    struct bn bn = { 0 };
    bignum_init(&bn);
    bignum_from_int(&bn, 42042);
    char *str = calloc(4, 1024);
    bignum_to_string(&bn, str, 4 * 1024);

    printf("%s\n", str);
    free(str);
}
