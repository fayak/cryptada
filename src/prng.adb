with bn_h; use bn_h;
with Interfaces.C;
use Interfaces.C;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;
with LCD_Std_Out; use LCD_Std_Out;


package body prng is

   function Feed (Entropy : Integer) return Integer is
      Actual_Entropy_Count : Integer;
      Ignore_RT : Interfaces.C.int;
   begin
      if Entropy = Last_Integer then
         return Integer(get_entropy_count(Entropy_Pool_State));
      end if;
      Last_Integer := Entropy;
      mix_pool(Interfaces.C.int(Entropy), Entropy_Pool_State);
      if Pool_Init < 32 then
         Pool_Init := Pool_Init + 1;
         -- Allow for the PRNG to be filled with initial values before considering increasing the entropy counter
      else
         Ignore_RT := credit_entropy(entropy_estimator(Interfaces.C.int(Entropy)), Entropy_Pool_State);
      end if;
      Actual_Entropy_Count := Integer(get_entropy_count(Entropy_Pool_State));
      LCD_Std_Out.Put (0, 14, "Entropy :=" & Actual_Entropy_Count'Img & "/" & Max_Pool_Entropy'Img);
      return Actual_Entropy_Count;
   end Feed;

      function get_entropy return Integer is
begin
   return Integer(get_entropy_count(Entropy_Pool_State));
   end get_entropy;
begin
   Entropy_Pool_State := new bn_h.entropy_pool;
   Entropy_Pool_State.i := 0;
   Entropy_Pool_State.rotate := 0;
   Entropy_Pool_State.entropy_count := 0;
end prng;
