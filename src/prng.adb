with bn_h; use bn_h;
with Interfaces.C;
use Interfaces.C;
with Interfaces; use Interfaces;
with bn_h;                  use bn_h;
with LCD_Std_Out; use LCD_Std_Out;
with Interfaces.C.Strings;
with bits_stdint_uintn_h;
with display; use display;
with State_Machine; use State_Machine;


package body prng is

   function Feed (Entropy : Integer) return Integer

   is
      Actual_Entropy_Count : Integer;
      Ignore_RT : Interfaces.C.int;
   begin
      if Entropy = Last_Integer then
         return Integer(entropy_pool.get_entropy_count);
      end if;
      Last_Integer := Entropy;
      entropy_pool.mix_pool(Interfaces.C.int(Entropy));
      if Pool_Init < 32 then
         Pool_Init := Pool_Init + 1;
         -- Allow for the PRNG to be filled with initial values before considering increasing the entropy counter
      else
         Ignore_RT := entropy_pool.credit_entropy(entropy_estimator(Interfaces.C.int(Entropy)));
      end if;
      Actual_Entropy_Count := Integer(entropy_pool.get_entropy_count);
      Internal_State.Screen.Print((Componant_Line(display.Entropy), 0), "Entropy :=" & Actual_Entropy_Count'Img & "/" & Max_Pool_Entropy'Img, False);
      return Actual_Entropy_Count;
   end Feed;

   function get_entropy return Integer is
   begin
      return Integer(entropy_pool.get_entropy_count);
   end get_entropy;

   procedure Random_Internal(N : in out Big_Num_Access; Nb_Bits : Integer; Min_Entropy : Integer) is
      Nb_Bits_Work : Integer;
      Work_Byte : Integer := 0;
      Work_BN, Tmp_BN : Big_Num_Access := new bn;
      Buffer : Interfaces.C.Strings.chars_ptr;
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
   begin
      bignum_from_int(N, 0);
      Nb_Bits_Work := Nb_Bits;
      while Nb_Bits_Work > 0 loop
         while get_entropy < Min_Entropy and entropy_pool.remaining_extracted = 0 loop
            delay 0.1;
            Internal_State.Screen.Print((Componant_Line(display.PRNG), 0), "Wait. for more entr.", False);
         end loop;
         Internal_State.Screen.Print((Componant_Line(display.PRNG), 0), "Creat. random number", False);
         Work_Byte := Integer(entropy_pool.get_random);
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
      Internal_State.Screen.Print((Componant_Line(display.PRNG), 0), "Done: " & Interfaces.C.Strings.Value(Buffer) & "          ", False);
   end Random_Internal;
   procedure Random(N : in out Big_Num_Access; Nb_Bits : Integer) is
   begin
      Random_Internal(N, Nb_Bits, MIN_SAFE_ENTROPY);
   end Random;
   procedure Random_Unsafe(N : in out Big_Num_Access; Nb_Bits : Integer) is
   begin
      Random_Internal(N, Nb_Bits, -1);
   end Random_Unsafe;
begin
   entropy_pool.init;
end prng;
