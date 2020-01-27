with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with bn_h; use bn_h;
with bignum; use bignum;

with entropy_generator_gyro;
with Prng;
with Rsa;

with State_Machine; use State_Machine;
with usart;
with Ada.Real_Time; use Ada.Real_Time;


procedure Main
is
   --pragma Priority (0);

   n, d ,e : Big_Num_Access := new bn;

   Nb_Bit : Integer := 256;

   Epoch : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;

begin

   --  Initialize
   Internal_State.init;


   --  Main loop

   usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));
   rsa.Gen_RSA(Nb_Bit, n, d, e);
   usart.Send_Message("timestamp=" & Duration'Image (Ada.Real_Time.To_Duration(Ada.Real_Time.Clock - Epoch)));

   loop
      delay 1.0;
   end loop;


end Main;
