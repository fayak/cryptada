with bignum; use bignum;
with Ada.Numerics.Float_Random;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;
with entropy_pool; use entropy_pool;
package Prng is
    function Feed (Entropy : Integer) return Integer with Post => (Feed'Result > 0 and Feed'Result < Max_Pool_Entropy);

    function get_entropy return Integer with Post => (get_entropy'Result > 0 and get_entropy'Result < Max_Pool_Entropy) ;
    procedure Random(N : in out Big_Num_Access; Nb_Bits : Integer) with Pre => (N /= null), Post => (N /= null);
    procedure Random_Unsafe(N : in out Big_Num_Access; Nb_Bits : Integer) with Pre => (N /= null), Post => (N /= null);
    Max_Pool_Entropy : Integer := POOL_SIZE * 32;
private
    entropy_pool : entropy_pool_obj;
    Last_Integer : Integer := 0;
    Pool_Init : Integer := 0;

    MIN_SAFE_ENTROPY : Integer := 128;
end Prng;
