with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;

package miller_rabin is
   function Miller_Rabin_Witness (N, A, S, D, N_Minus : Big_Num_Access) return Boolean;
   function Miller_Rabin_no_check (N : Big_Num_Access; Nb_Bits, Nb_Tests : Integer) return Boolean;
end miller_rabin;
