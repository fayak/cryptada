with bn_h; use bn_h;
with Interfaces.C;
with Interfaces; use Interfaces;

package body prng is
   procedure Random (dst : Big_Num_Access; nb_Bit : in out Integer) is
      Rng : Float := 0.0;
      val : Natural := 0;
      tmp : Big_Num_Access := new bn;
      res : Big_Num_Access := new bn;
   begin
      bignum_init(dst);
      bignum_init(res);
      while nb_Bit > Natural'Size loop
         Rng := Ada.Numerics.Float_Random.Random(gen);
         val := Natural(Rng * Float(Natural'Last)) mod Natural'Last;
         
         bignum_init(tmp);
         bignum_from_int(tmp, C.unsigned(val));
         
         bignum_add(res, tmp, dst);
         bignum_lshift(dst, dst, Natural'Size);
         bignum_assign(res, dst);
         
         nb_Bit := nb_Bit - Natural'Size;
      end loop;
      
      if not (nb_Bit = 0) then
         Rng := Ada.Numerics.Float_Random.Random(gen);
         val := Natural(Shift_Left(Unsigned_32(1), nb_Bit));
         val := Natural(Rng * Float(val)) mod val;
         
         bignum_init(tmp);
         bignum_from_int(tmp, C.unsigned(val));
         
         bignum_add(res, tmp, dst);
         bignum_assign(res, dst);
      end if;
      
      Free_Bignum(tmp);
      Free_Bignum(res);
   end Random;
   
begin
   Ada.Numerics.Float_Random.Reset(gen);
end prng;
