with bn_h;                  use bn_h;

package Bignum is

   type Big_Num_Access is access all bn;

   function Two return Big_Num_Access;
   function One return Big_Num_Access;
   function Three return Big_Num_Access;
   function Five return Big_Num_Access;
   function Seven return Big_Num_Access;
   function Miller_2047 return Big_Num_Access;

end Bignum;
