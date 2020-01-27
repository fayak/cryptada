with bn_h;                  use bn_h;
with Ada.Unchecked_Deallocation;

package Bignum is
   type Big_Num_Access is access all bn;

   procedure Dummy_For_Package;

   Zero : Big_Num_Access := new bn;
   One : Big_Num_Access := new bn;
   Two : Big_Num_Access := new bn;
   Three : Big_Num_Access := new bn;
   Five : Big_Num_Access := new bn;
   Seven : Big_Num_Access := new bn;

   procedure Free_Bignum is new Ada.Unchecked_Deallocation
     (Object => bn, Name => Big_Num_Access);

end Bignum;
