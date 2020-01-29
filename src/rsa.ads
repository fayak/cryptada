with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
with Prng;

package rsa is
procedure GCD (a, b : in Big_Num_Access; res : out Big_Num_Access);
   procedure Gen_RSA (Nb_Bits : in Integer; n, d , e : in out Big_Num_Access) with Pre => (Nb_Bits > 0), Post => (n /= null and e /= null and d /= null);
   function Find_Mod_Inverse (a, m : in Big_Num_Access) return Big_Num_Access with Pre => (a /= null and m /= null), Post => (Find_Mod_Inverse'Result /= null);

end rsa;
