with bn_h;                  use bn_h;

package Bignum is

   type Big_Num_Access is access all bn;

   function Two : Big_Num_Access;
   pragma Inline;
   function One : Big_Num_Access;
   pragma Inline;
   function Three : Big_Num_Access;
   pragma Inline;
   function Five : Big_Num_Access;
   pragma Inline;
   function Seven : Big_Num_Access;
   pragma Inline;
   function Miller_2047 : Big_Num_Access;
   pragma Inline;

end Bignum;
