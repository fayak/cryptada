extern "C" {
    #include "bn.h"
    #include "tests/miller.h"
}

#include <benchmark/benchmark.h>

void BM_Miller(benchmark::State& st)
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

    KARATSUBA_MIN = st.range(0);
    for (auto _ : st) {
        miller_rabin(&n, nb, 10);
    }
}

BENCHMARK(BM_Miller)
    ->Unit(benchmark::kMillisecond)
    ->Arg(2)
    ->Arg(3)
    ->Arg(4)
    ->Arg(5)
    ->Arg(6)
    ->Arg(7)
    ->Arg(8)
    ->Arg(9)
    ->Arg(10)
    ->Arg(11)
    ->Arg(12)
    ->Arg(13)
    ->Arg(14)
    ->Arg(15)
    ->Arg(16)
    ->Arg(17)
    ->Arg(18)
    ->Arg(19)
    ->Arg(20);

BENCHMARK_MAIN();
