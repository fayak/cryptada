with bn_h;                  use bn_h;

package Bignum is
   type Big_Num_Access is access all bn;

   function test return Boolean;

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
end Bignum;
