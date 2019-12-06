with bn_h;                  use bn_h;

with bignum; use bignum;

package miller_rabin is
   
   function Miller_Rabin_Witness (N, A : Big_Num_Access) return Boolean;

end miller_rabin;
