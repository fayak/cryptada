with Interfaces.C.Strings;

package body Bignum is
   function test return Boolean is
      begin
      return True;
      end test;
begin
   bignum_init(Two);
   bignum_from_int(Two, 2);
   bignum_init(One);
   bignum_from_int(One, 1);
   bignum_init(Three);
   bignum_from_int(Three, 3);
   bignum_init(Five);
   bignum_from_int(Five, 5);
   bignum_init(Seven);
   bignum_from_int(Seven, 7);
   bignum_init(Miller_11);
   bignum_from_int(Miller_11, 11);
   bignum_init(Miller_13);
   bignum_from_int(Miller_13, 13);
   bignum_init(Miller_17);
   bignum_from_int(Miller_17, 17);
   bignum_init(Miller_31);
   bignum_from_int(Miller_31, 31);
   bignum_init(Miller_73);
   bignum_from_int(Miller_73, 73);
   bignum_init(Miller_2047);
   bignum_from_int(Miller_2047, 2047);
   bignum_init(Miller_1373653);
   bignum_from_int(Miller_1373653, 1373653);
   bignum_init(Miller_9080191);
   bignum_from_int(Miller_9080191, 9080191);
   
   bignum_init(Miller_341550071728321);
   bignum_from_string(Miller_341550071728321, Interfaces.C.Strings.New_String("000136A352B2C8C1"), 16);
end Bignum;
