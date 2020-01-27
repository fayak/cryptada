#include "bn.h"
#include "miller.h"

#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    bignum_from_int(&one, 1);
    bignum_from_int(&two, 2);
    bignum_from_int(&three, 3);
    One = &one;
    Two = &two;
    Three = &three;
    srand(time(NULL));
    struct bn n;
    char buf[] = "10408607522886163411192465147334015174325017901510787091895957152987142017285554278418896457181559830763141008389583920790601819085885688670689286888080297";
    int nb = sizeof(buf) - 1;
    bignum_from_string(&n, buf, nb);

 //   printf("%d - %d\n", miller_rabin(&n, nb, 10), nb);
}
