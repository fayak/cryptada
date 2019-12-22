with bignum; use bignum;
with Ada.Numerics.Float_Random;
with Interfaces; use Interfaces;

package Prng is

   procedure Feed (Entropy : Integer);
   
private
   Entropy_Pool : Integer := 0;
   Entropy_Count : Natural := 0;
   Last_Integer : Integer := 0;
   Input_Rotate : Integer := 0;
   Rotate_Max : Integer := 31;
end Prng;
