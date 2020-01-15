#pragma once

#include "bn.h"

typedef struct bn* BN;
#define true 1
#define false 0

struct bn one;
struct bn two;
struct bn three;
BN One;
BN Two;
BN Three;

int miller_rabin(BN N, int Nb_Bits, int Nb_Tests);
