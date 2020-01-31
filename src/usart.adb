
   ------------------------------------------------------------------------------
--                                                                          --
--                 Copyright (C) 2015-2017, AdaCore                         --
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

-- Adapted and modified by DUVAL Cyril and MOUNIER Julien

with STM32;                        use STM32;
with STM32.GPIO;                   use STM32.GPIO;
with STM32.USARTs;                 use STM32.USARTs;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings;
with STM32.Device;                 use STM32.Device;

with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with Peripherals;                  use Peripherals;
with Serial_Port;                  use Serial_Port;

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
with LCD_Std_Out; use LCD_Std_Out;
with Ada.Strings; use Ada.Strings;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Unbounded;

package body usart is

   Outgoing : aliased Message (Physical_Size => 2048);
   Mutex : Mutual_Exclusion;

procedure Get_Message(Message_Final : in out Ada.Strings.Unbounded.Unbounded_String) is
      Received : aliased Message (Physical_Size => 1024);
begin
      Received.Terminator := ASCII.CR;
      LCD_Std_Out.Put_Line(Ada.Strings.Unbounded.To_String(Message_Final));
      Peripherals.COM.Start_Receiving (Received'Unchecked_Access);
      Suspend_Until_True (Received.Reception_Complete);

      Message_Final := Ada.Strings.Unbounded.To_Unbounded_String(As_String(Received));
      Ada.Strings.Unbounded.Head(Source => Message_Final, Count => Ada.Strings.Unbounded.Length(Message_Final) - 1);

      Set (Outgoing, To => "Received: " & Ada.Strings.Unbounded.To_String(Message_Final) & ASCII.CR & ASCII.LF);
      Peripherals.COM.Start_Sending (Outgoing'Unchecked_Access);
      Suspend_Until_True (Outgoing.Transmission_Complete);
end Get_Message;

   procedure Send_Message(Message : String) is
   begin
      Send_Message_No_CRLF(Message & ASCII.CR & ASCII.LF);
   end Send_Message;
   procedure Send_Message_No_CRLF(Message : String) is
   begin
      Mutex.Seize;
      Set (Outgoing, To => Message);
      Peripherals.COM.Start_Sending (Outgoing'Unchecked_Access);
      Suspend_Until_True (Outgoing.Transmission_Complete);
      Mutex.Release;
  end Send_Message_No_CRLF;

procedure Init_USART is

   procedure Initialize_STMicro_UART;
   procedure Initialize;

   -----------------------------
   -- Initialize_STMicro_UART --
   -----------------------------

   procedure Initialize_STMicro_UART is
   begin
      Enable_Clock (Transceiver);
      Enable_Clock (RX_Pin & TX_Pin);

      Configure_IO
        (RX_Pin & TX_Pin,
         (Mode           => Mode_AF,
          AF             => Transceiver_AF,
          Resistors      => Pull_Up,
          AF_Output_Type => Push_Pull,
          AF_Speed       => Speed_50MHz));
   end Initialize_STMicro_UART;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin

      Disable (Transceiver);

      Set_Baud_Rate    (Transceiver, 115_200);
      Set_Mode         (Transceiver, Tx_Rx_Mode);
      Set_Stop_Bits    (Transceiver, Stopbits_1);
      Set_Word_Length  (Transceiver, Word_Length_8);
      Set_Parity       (Transceiver, No_Parity);
      Set_Flow_Control (Transceiver, No_Flow_Control);

      Enable (Transceiver);
   end Initialize;

begin
   Initialize_STMicro_UART;
   Initialize;
end Init_USART;
end usart;
