with bignum; use bignum;
with Ada.Numerics.Float_Random;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;


package Prng is
   type Entropy_Pool_Access is access all entropy_pool;
   function Feed (Entropy : Integer) return Integer;
   
   function get_entropy return Integer;
   procedure Random(N : in out Big_Num_Access; Nb_Bits : Integer);
   Max_Pool_Entropy : Integer := POOL_SIZE * 32;
private
   Entropy_Pool_State : Entropy_Pool_Access;
   Last_Integer : Integer := 0;
   Pool_Init : Integer := 0;
end Prng;
