#include "bn.h"
#include "miller.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static char buffer[128] = {0};

int miller_rabin_witness(BN n, BN s, BN a, BN d, BN n_minus)
{
    struct bn tmp2;
    struct bn tmp;
    struct bn i;
    BN I = &i;
    BN Tmp = &tmp;
    BN Tmp2 = &tmp2;


    bignum_powmod(a, d, n, Tmp2);

    if (bignum_cmp(Tmp2, One) == 0)
    {
        return false;
    }

    bignum_from_int(I, 0);

    while (bignum_cmp(I, s) <= 0)
    {
        bignum_pow(Two, I, Tmp);
        bignum_mul(Tmp, d, Tmp2);
        bignum_powmod(a, Tmp2, n, Tmp);

        if (bignum_cmp(Tmp, n_minus) == 0)
            return false;

        bignum_inc(I);
    }
    return true;
}

int miller_rabin(BN N, int Nb_Bits, int Nb_Tests)
{
    struct bn d;
    BN D = &d;
    struct bn s;
    BN S = &s;
    struct bn n_minus;
    struct bn n_minus_4;
    struct bn tmp;
    BN N_Minus = &n_minus;
    BN N_Minus_4 = &n_minus_4;
    BN Tmp = &tmp;
    struct bn witness;
    BN Witness = &witness;


     bignum_from_int(S, 0);

      bignum_sub(N, One, D);
      bignum_mod(D, Two, Tmp);
      bignum_init(S);
      while (bignum_is_zero(Tmp) == 1) {
         bignum_rshift(D, D, 1);
         bignum_inc(S);
         bignum_mod(D, Two, Tmp);
      }

      bignum_sub(N, One, N_Minus);
      bignum_sub(N_Minus, Three, N_Minus_4);

      for (int i = 0; i < Nb_Tests; ++i)
      {
          bignum_init(Witness);
          for (int j = 0; j < Nb_Bits + Nb_Bits / 2; j += 3)
          {
            struct bn prout;
            bignum_from_int(&prout, rand() % 1000);
            bignum_add(&prout, Witness, Tmp);
            bignum_assign(Witness, Tmp);
          }
         bignum_mod(Witness, N_Minus_4, Tmp);
         bignum_add(Tmp, Two, Witness);

         if (miller_rabin_witness(N, S, Witness, D, N_Minus))
            return false;

      }
      return true;
}
