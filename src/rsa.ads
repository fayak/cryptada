with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
with Prng;

package rsa is

   procedure Gen_RSA (Nb_Bits : in Integer; n, d , e : in out Big_Num_Access);
   function Find_Mod_Inverse (a, m : in Big_Num_Access) return Big_Num_Access;

end rsa;
