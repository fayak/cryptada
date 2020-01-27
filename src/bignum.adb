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

end Bignum;
