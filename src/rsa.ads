with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
with Prng;

package rsa is
   type RSA_Key is tagged record
      n : Big_Num_Access;
      d : Big_Num_Access;
      e : Big_Num_Access;
      q : Big_Num_Access;
      pm1 : Big_Num_Access;
      qm1 : Big_Num_Access;
   end record;

   procedure GCD (a, b : in Big_Num_Access; res : out Big_Num_Access);
   procedure Gen_RSA (Nb_Bits : in Integer; n, d , e, p, q, pm1, qm1 : in out Big_Num_Access)
     with Pre => (Nb_Bits > 0),
     Post => (n /= null and e /= null and d /= null and p /= null and pm1 /= null and qm1 /= null);
   function Find_Mod_Inverse (a, m : in Big_Num_Access) return Big_Num_Access
     with Pre => (a /= null and m /= null),
     Post => (Find_Mod_Inverse'Result /= null);
   procedure Print_UART_ASN1_Conf(n, d, e, p, q, pm1, qm1 : in Big_Num_Access)
     with Pre => (n /= null and e /= null and d /= null and p /= null and pm1 /= null and qm1 /= null);
end rsa;
