with bignum; use bignum;
with Ada.Numerics.Float_Random;

package Prng is

   procedure Random (dst: Big_Num_Access; nb_Bit: in out Integer);
   
private
   gen: Ada.Numerics.Float_Random.Generator;
end Prng;
