------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board;           use STM32.Board;
with HAL.Bitmap;            use HAL.Bitmap;
pragma Warnings (Off, "referenced");
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with STM32.User_Button;     use STM32;
with BMP_Fonts;

with Interfaces.C.Strings;
with bn_h;                  use bn_h;
with LCD_Std_Out;

with bignum; use bignum;

with miller_rabin;
use miller_rabin;

procedure Main
is

   type Ball_Speed_Type is record
      X, Y: Integer;
   end record;


   Big_Num_A : Big_Num_Access := new bn;
   Big_Num_B : Big_Num_Access := new bn;
   Big_Num_C : Big_Num_Access := new bn;
   Tmp : Big_Num_Access := new bn;

   Res : Interfaces.C.Strings.chars_ptr;
   Test : Boolean;

   Pute : String(1..STR_DEST_SIZE) := (others => '0');


   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Ball_Pos   : Point := (120, 160);
   Ball_Speed : Ball_Speed_Type := (2, 3);
   Board_Size : Point := (240, 320);
begin

   Res := Interfaces.C.Strings.New_String(Pute);
   --Test := Interfaces.C.Strings.New_String(Pute2);
   bignum_init(Big_Num_A);
   bignum_init(Big_Num_B);
   bignum_init(Big_Num_C);
   bignum_init(Tmp);

   bignum_from_int(Big_Num_A, 42);
   bignum_from_int(Big_Num_B, 4);
   --bignum_mul(Big_Num_A, Big_Num_B, Big_Num_C);
   --bignum_mul(Big_Num_C, Big_Num_B, Big_Num_A);
   --bignum_mul(Big_Num_A, Big_Num_B, Big_Num_C);
   --bignum_to_string(Big_Num_C, Res, STR_DEST_SIZE);



   --  Initialize LCD
   Display.Initialize;
   Display.Initialize_Layer (1, ARGB_8888);

   --  Initialize touch panel
   Touch_Panel.Initialize;

   --  Initialize button
   User_Button.Initialize;

   LCD_Std_Out.Set_Font (BMP_Fonts.Font12x12);
   LCD_Std_Out.Current_Background_Color := BG;

   --  Clear LCD (set background)
   Display.Hidden_Buffer (1).Set_Source (BG);
   Display.Hidden_Buffer (1).Fill;

   LCD_Std_Out.Clear_Screen;
   Display.Update_Layer (1, Copy_Back => True);
   LCD_Std_Out.Clear_Screen;


   LCD_Std_Out.Put_Line("pute ?");
   --LCD_Std_Out.Put_Line(Interfaces.C.Strings.Value(Res));
   LCD_Std_Out.Put_Line("Pute");
   Test := Miller_Rabin_Witness (Big_Num_A, Big_Num_B);
   if Test then
      LCD_Std_Out.Put_Line("Prime");
   else
      LCD_Std_Out.Put_Line("Composite");
   end if;
   loop
         Display.Update_Layer (1, Copy_Back => True);
   end loop;

end Main;
