with bn_h; use bn_h;
with Interfaces.C;
use Interfaces.C;
with Interfaces; use Interfaces;

package body prng is
   function Rol32(N : Unsigned_32) return Unsigned_32 is
   begin
      Input_Rotate := (Input_Rotate + 7) mod 31;
      return (Shift_Left(N, (Input_Rotate and Rotate_Max))) or Shift_Right(N, ((Rotate_Max - Input_Rotate) and Rotate_Max));
   end Rol32;
   
   procedure Feed (Entropy : Integer) is
   begin
      if Entropy = Last_Integer then
         return;
      end if;
      Last_Integer := Entropy;
   end Feed;
end prng;
