with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;

package miller_rabin is


   function Miller_Rabin_Witness (N, A, S, D, N_Minus : Big_Num_Access) return Boolean;
   function Miller_Rabin_p (N : Big_Num_Access) return Boolean;
end miller_rabin;
