with bn_h; use bn_h;
with Interfaces.C;
use Interfaces.C;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;
with LCD_Std_Out; use LCD_Std_Out;


package body prng is
   
   procedure Feed (Entropy : Integer) is
   begin
      if Entropy = Last_Integer then
         return;
      end if;
      Last_Integer := Entropy;
      mix_pool(Interfaces.C.int(Entropy), Entropy_Pool_State);
      if Pool_Init < 16 then
         Pool_Init := Pool_Init + 1;
      else
         LCD_Std_Out.Put(0, 42, Integer(credit_entropy(entropy_estimator(Interfaces.C.int(Entropy)), Entropy_Pool_State))'Img);
      end if;
      LCD_Std_Out.Put (0, 14, "'1 pool := " & Entropy_Pool_State.pool(1)'Img & "    ");
      LCD_Std_Out.Put (0, 28, "Entropy := " & Entropy_Pool_State.entropy_count'Img & "    ");
   end Feed;
begin
   Entropy_Pool_State := new bn_h.entropy_pool;
   Entropy_Pool_State.i := 0;
   Entropy_Pool_State.rotate := 0;
   Entropy_Pool_State.entropy_count := 0;
end prng;
