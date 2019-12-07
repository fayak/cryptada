with bn_h;                  use bn_h;
with Ada.Unchecked_Deallocation;

package Bignum is
   type Big_Num_Access is access all bn;

   procedure Dummy_For_Package;

   One : Big_Num_Access := new bn;
   Two : Big_Num_Access := new bn;
   Three : Big_Num_Access := new bn;
   Five : Big_Num_Access := new bn;
   Seven : Big_Num_Access := new bn;
   Miller_11 : Big_Num_Access := new bn;
   Miller_13 : Big_Num_Access := new bn;
   Miller_17 : Big_Num_Access := new bn;
   Miller_31 : Big_Num_Access := new bn;
   Miller_73 : Big_Num_Access := new bn;
   Miller_2047 : Big_Num_Access := new bn;
   Miller_1373653 : Big_Num_Access := new bn;
   Miller_9080191 : Big_Num_Access := new bn;
   Miller_341550071728321 : Big_Num_Access := new bn;

   procedure Free_Bignum is new Ada.Unchecked_Deallocation
     (Object => bn, Name => Big_Num_Access);

end Bignum;
