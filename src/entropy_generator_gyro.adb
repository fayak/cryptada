with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with STM32.Device; use STM32.Device;
with STM32.Board;  use STM32.Board;

with STM32.GPIO; use STM32.GPIO;
with STM32.EXTI; use STM32.EXTI;

with L3GD20; use L3GD20;
with Prng;

with State_Machine; use State_Machine;
with display; use display;

package body entropy_generator_gyro is

   X_Pos : Print_Coord;
   Y_Pos : Print_Coord;
   Z_Pos : Print_Coord;
   procedure init_entropy_collector is

      Entropy_Count : Integer;


      procedure Configure_Gyro;
      --  Configures the on-board gyro chip

      procedure Configure_Gyro_Interrupt;
      --  Configures the gyro's FIFO interrupt (interrupt #2) on the
      --  required port/pin for the F429 Discovery board. Enables the interrupt.
      --  See the F429 Disco User Manual, Table 6, pg 19, for the port/pin.

      --------------------
      -- Configure_Gyro --
      --------------------

      procedure Configure_Gyro is
      begin
         --  Init the on-board gyro SPI and GPIO. This is board-specific, not
         --  every board has a gyro. The F429 Discovery does, for example, but
         --  the F4 Discovery does not.
         STM32.Board.Initialize_Gyro_IO;

         STM32.Board.Gyro.Reset;

         STM32.Board.Gyro.Configure
           (Power_Mode       => L3GD20_Mode_Active,
            Output_Data_Rate => L3GD20_Output_Data_Rate_760Hz,
            Axes_Enable => L3GD20_Axes_Enable, Bandwidth => L3GD20_Bandwidth_1,
            BlockData_Update => L3GD20_BlockDataUpdate_Continous,
            Endianness       => L3GD20_Little_Endian,
            Full_Scale       => L3GD20_Fullscale_2000);

         STM32.Board.Gyro.Enable_Low_Pass_Filter;
      end Configure_Gyro;

      ------------------------------
      -- Configure_Gyro_Interrupt --
      ------------------------------

      procedure Configure_Gyro_Interrupt is
         --  This is the required port/pin configuration on STM32F429 Disco
         --  boards for interrupt 2 on the L3GD20 gyro. See the F429 Disco
         --  User Manual, Table 6, pg 19.
      begin
         Enable_Clock (MEMS_INT2);
         Configure_IO (MEMS_INT2, (Mode => Mode_In, Resistors => Floating));

         Configure_Trigger (MEMS_INT2, Interrupt_Rising_Edge);
      end Configure_Gyro_Interrupt;

   begin
      Configure_Gyro;

      Configure_Gyro_Interrupt;

      STM32.Board.Gyro.Set_FIFO_Mode (L3GD20_Stream_Mode);
      Internal_State.Screen.Print ((Componant_Line(display.Gyro), 0), "X/Y/Z", Send_USART => False);
      STM32.Board.Gyro.Get_Raw_Angle_Rates (Last_Axes);
      Entropy_Count := 0;
      while Entropy_Count < Prng.Max_Pool_Entropy / 16 loop
         STM32.Board.Gyro.Get_Raw_Angle_Rates (Axes);
         Internal_State.Screen.Print ((Componant_Line(display.Gyro), 0), "X/Y/Z", Send_USART => False);
         Internal_State.Screen.Print(X_Pos, Axes.X'Img & "  ", Send_USART => False);
         Internal_State.Screen.Print(Y_Pos, Axes.Y'Img & "  ", Send_USART => False);
         Internal_State.Screen.Print(Z_Pos, Axes.Z'Img & "  ", Send_USART => False);
         Entropy_Count := Prng.Feed (Integer (Last_Axes.X - Axes.X));
         Entropy_Count := Prng.Feed (Integer (Last_Axes.Y - Axes.Y));
         Entropy_Count := Prng.Feed (Integer (Last_Axes.Z - Axes.Z));
         Last_Axes := Axes;
      end loop;
   end init_entropy_collector;

   procedure collect_entropy(Minimum : Integer) is
      Entropy_Count : Integer;
   begin
      Entropy_Count := 0;
      while Entropy_Count < Minimum loop
         STM32.Board.Gyro.Get_Raw_Angle_Rates (Axes);
         Internal_State.Screen.Print ((Componant_Line(display.Gyro), 0), "X/Y/Z", Send_USART => False);
         Internal_State.Screen.Print(X_Pos, Axes.X'Img & "  ", Send_USART => False);
         Internal_State.Screen.Print(Y_Pos, Axes.Y'Img & "  ", Send_USART => False);
         Internal_State.Screen.Print(Z_Pos, Axes.Z'Img & "  ", Send_USART => False);
         Entropy_Count := Prng.Feed (Integer (Last_Axes.X - Axes.X));
         Entropy_Count := Prng.Feed (Integer (Last_Axes.Y - Axes.Y));
         Entropy_Count := Prng.Feed (Integer (Last_Axes.Z - Axes.Z));
         Last_Axes := Axes;
      end loop;
   end collect_entropy;

   task body Collect_Background_Entropy is

   begin
      delay 1.0;
      entropy_generator_gyro.init_entropy_collector;
      loop
         collect_entropy(2048);
      end loop;
   end Collect_Background_Entropy;

begin
   X_Pos := (Componant_Line(display.Gyro), 60);
   Y_Pos := (Componant_Line(display.Gyro), 120);
   Z_Pos  := (Componant_Line(display.Gyro), 180);
end entropy_generator_gyro;
