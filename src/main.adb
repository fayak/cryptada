with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with bn_h; use bn_h;
with bignum; use bignum;

with entropy_generator_gyro;
with Prng;
with Rsa;

with State_Machine; use State_Machine;
with usart;
with Ada.Real_Time; use Ada.Real_Time;
with display; use display;
with rsa; use rsa;


procedure Main
is
   --pragma Priority (0);

   n, d , e, p, q, pm1, qm1 : Big_Num_Access := new bn;

   RSA_Computed : Boolean := False;

   Nb_Bit : Integer := 256;

   Epoch : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;

   Window : Display.Window_Type := Display.MENU;
begin

   --  Initialize
   Internal_State.init;

   --  Main loop
   loop
      if Window = Display.MENU then
         case Internal_State.Screen.Draw_Menu is
         when Display.BUTTON_RSA =>
            Internal_State.Screen.Col := 0;
            Internal_State.screen.Row := 0;
            usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));
            rsa.Gen_RSA(Nb_Bit, n, d, e, p, q, pm1, qm1);
            usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));
            Internal_State.Screen.Print((Display.Componant_Line(Display.Log_Info), 0), "RSA Key generated             ");
            RSA_Computed := True;

         when Display.BUTTON_SIZE =>
            Window := Display.SIZE_SELECTOR;

         when Display.BUTTON_PRINT =>
            if RSA_Computed then
               Internal_State.Screen.Print((Display.Componant_Line(Display.Log_Info), 0), "Printing Key to UART       ");
               Print_UART_ASN1_Conf(n, d, e, p, q, pm1, qm1);
               Internal_State.Screen.Print((Display.Componant_Line(Display.Log_Info), 0), "Done!                      ");
            else
               Internal_State.Screen.Print((Display.Componant_Line(Display.Log_Info), 0), "No RSA Key to Print        ");
               delay 0.0;
            end if;

         when Display.NONE =>
            delay 0.0;
         end case;
      elsif Window = Display.SIZE_SELECTOR then
         Internal_State.Screen.Draw_Size_Selector(Window, Nb_Bit);
         Window := Display.MENU;
         null;
      end if;
   end loop;


end Main;
