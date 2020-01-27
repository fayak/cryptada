with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

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
with Prng;
with Rsa;

with entropy_generator_gyro;
with usart;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main
is
      --pragma Priority (0);


   n, d ,e : Big_Num_Access := new bn;

   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Board_Size : Point := (240, 320);

   Nb_Bit : Integer := 256;

   Epoch : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;

begin

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

   usart.Init_USART;
   usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));
   rsa.Gen_RSA(Nb_Bit, n, d, e);
   usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));

   loop
      delay 1.0;
   end loop;


end Main;
