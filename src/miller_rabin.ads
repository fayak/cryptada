with bn_h;                  use bn_h;

with bignum; use bignum;

package miller_rabin is
   One : Big_Num_Access := new bn;
   Two : Big_Num_Access := new bn;
   Three : Big_Num_Access := new bn;
   Five : Big_Num_Access := new bn;
   Seven : Big_Num_Access := new bn;
   Miller_2047 : Big_Num_Access := new bn;
   Miller_1373653 : Big_Num_Access := new bn;
   function Miller_Rabin_Witness (N, A, S, D, N_Minus : Big_Num_Access) return Boolean;
   function Miller_Rabin_p (N : Big_Num_Access) return Boolean;
end miller_rabin;
