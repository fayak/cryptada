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
with LCD_Std_Out;

with Interfaces.C.Strings;
with bn_h;                  use bn_h;

procedure Main
is

   type Ball_Speed_Type is record
      X, Y: Integer;
   end record;

   type Big_Num_Access is access bn;
   Big_Num_A : Big_Num_Access := new bn;
   Big_Num_B : Big_Num_Access := new bn;
   Big_Num_C : Big_Num_Access := new bn;
   Res : Interfaces.C.Strings.chars_ptr;

   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Ball_Pos   : Point := (120, 160);
   Ball_Speed : Ball_Speed_Type := (2, 3);
   Board_Size : Point := (240, 320);
begin

   Res := Interfaces.C.Strings.New_String("01234567890123456789");
   bignum_from_int(Big_Num_A, 42);
   bignum_from_int(Big_Num_B, 1000);
   bignum_mul(Big_Num_A, Big_Num_B, Big_Num_C);
   bignum_to_string(Big_Num_C, Res, 20);

   --  Initialize LCD
   Display.Initialize;
   Display.Initialize_Layer (1, ARGB_8888);

   --  Initialize touch panel
   Touch_Panel.Initialize;

   --  Initialize button
   User_Button.Initialize;

   LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
   LCD_Std_Out.Current_Background_Color := BG;

   --  Clear LCD (set background)
   Display.Hidden_Buffer (1).Set_Source (BG);
   Display.Hidden_Buffer (1).Fill;

   LCD_Std_Out.Clear_Screen;
   Display.Update_Layer (1, Copy_Back => True);

   loop
      if User_Button.Has_Been_Pressed then
         BG := HAL.Bitmap.Dark_Orange;
      end if;

      Display.Hidden_Buffer (1).Set_Source (BG);
      Display.Hidden_Buffer (1).Fill;

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Blue);
      Display.Hidden_Buffer (1).Fill_Circle (Ball_Pos, 10);


      declare
         State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      begin
         case State'Length is
            when 1 =>
               Ball_Pos := (State (State'First).X, State (State'First).Y);
            when others => null;
         end case;
      end;

      if Ball_Pos.X + Ball_Speed.X >= Board_Size.X or Ball_Pos.X + Ball_Speed.X <= 0 then
         Ball_Speed.X := -Ball_Speed.X;
      end if;

      if Ball_Pos.Y + Ball_Speed.Y >= Board_Size.Y or Ball_Pos.Y + Ball_Speed.Y <= 0 then
        Ball_Speed.Y := -Ball_Speed.Y;
      end if;

      Ball_Pos := (Ball_Pos.X + Ball_Speed.X, Ball_Pos.Y + Ball_Speed.Y);

      --  Update screen
      Display.Update_Layer (1, Copy_Back => True);

   end loop;
end Main;