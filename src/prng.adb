with bn_h; use bn_h;
with Interfaces.C;
use Interfaces.C;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;
with LCD_Std_Out; use LCD_Std_Out;
with Interfaces.C.Strings;
with bits_stdint_uintn_h;


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

   procedure Random(N : in out Big_Num_Access; Nb_Bits : Integer) is
      Nb_Bits_Work : Integer;
      Work_Byte : Integer := 0;
      Work_BN, Tmp_BN : Big_Num_Access := new bn;
      Buffer : Interfaces.C.Strings.chars_ptr;
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
   begin
      bignum_from_int(N, 0);
      Nb_Bits_Work := Nb_Bits;
      while Nb_Bits_Work > 0 loop
         while get_entropy < 10 and Entropy_Pool_State.remaining_extracted = 0 loop
            delay 0.1;
            LCD_Std_Out.Put (0, 28, "Wait. for more entr.");
         end loop;
         LCD_Std_Out.Put (0, 28,    "Creat. random number");
         Work_Byte := Integer(get_random(Entropy_Pool_State));
         bignum_from_int(Work_BN, Interfaces.C.Int(Work_Byte));
         bignum_lshift(N, Tmp_BN, 8);
         bignum_add(Work_BN, Tmp_BN, N);
         if Nb_Bits_Work >= 8 then
            Nb_Bits_Work := Nb_Bits_Work - 8;
         else
            bignum_rshift(N, Work_BN, 8 - Interfaces.C.unsigned(Nb_Bits_Work));
            bignum_assign(N, Work_BN);
            Nb_Bits_Work := 0;
         end if;
      end loop;
      Buffer := Interfaces.C.Strings.New_String(String_Base);
      bignum_to_string(N, Buffer, STR_DEST_SIZE);
      LCD_Std_Out.Put(0, 28, "Done: " & Interfaces.C.Strings.Value(Buffer) & "          ");
   end Random;

begin
   Entropy_Pool_State := new bn_h.entropy_pool;
   Entropy_Pool_State.i := 0;
   Entropy_Pool_State.j := 0;
   Entropy_Pool_State.rotate := 0;
   Entropy_Pool_State.entropy_count := 0;
   Entropy_Pool_State.remaining_extracted := 0;
end prng;
