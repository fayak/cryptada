with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;

package miller_rabin is
    function Miller_Rabin_Witness (N, A, S, D, N_Minus : Big_Num_Access) return Boolean with Pre => (N /= null and A /= null and S /= null and D /= null and N_Minus /= null);
    function Miller_Rabin_no_check (N : Big_Num_Access; Nb_Bits, Nb_Tests : Integer) return Boolean with Pre => (N /= null and Nb_Bits > 0 and Nb_Tests > 0);
end miller_rabin;
