package body Bignum is

   function One return Big_Num_Access is
   begin
      return bignum_one;
   end One;
   
   function Two return Big_Num_Access is
   begin
      return bignum_two;
   end Two;
   
   function Three return Big_Num_Access is
   begin
      return bignum_three;
   end Three;
   
   function Five return Big_Num_Access is
   begin
      return bignum_five;
   end Five;
   
   function Seven return Big_Num_Access is
   begin
      return bignum_seven;
   end Seven;
   
   function Miller_2047 return Big_Num_Access is
   begin
      return bignum_2047;
   end Miller_2047;
   
end Bignum;
