with Interfaces.C.Strings;

package body Bignum is
   procedure Dummy_For_Package is
   begin
      null;
   end Dummy_For_Package;
begin
   bignum_init(Zero);
   bignum_from_int(Two, 2);
   bignum_from_int(One, 1);
   bignum_from_int(Three, 3);
   bignum_from_int(Five, 5);
   bignum_from_int(Seven, 7);
   bignum_from_int(Miller_11, 11);
   bignum_from_int(Miller_13, 13);
   bignum_from_int(Miller_17, 17);
   bignum_from_int(Miller_19, 19);
   bignum_from_int(Miller_23, 23);
   bignum_from_int(Miller_29, 29);
   bignum_from_int(Miller_31, 31);
   bignum_from_int(Miller_73, 73);
   bignum_from_int(Miller_2047, 2047);
   bignum_from_int(Miller_1373653, 1373653);
   bignum_from_int(Miller_9080191, 9080191);
   
   bignum_from_string(Miller_341550071728321, Interfaces.C.Strings.New_String("341550071728321"), 16);
end Bignum;
