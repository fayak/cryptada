with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);

with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with STM32.Device; use STM32.Device;
with STM32.Board;  use STM32.Board;

with STM32.GPIO; use STM32.GPIO;
with STM32.EXTI; use STM32.EXTI;

with LCD_Std_Out;

with L3GD20; use L3GD20;
with Prng;

package body gyro_demo is

   procedure Gyro_test is

      Axes      : L3GD20.Angle_Rates;
      Last_Axes : L3GD20.Angle_Rates;

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

         Gyro.Reset;

         Gyro.Configure
           (Power_Mode       => L3GD20_Mode_Active,
            Output_Data_Rate => L3GD20_Output_Data_Rate_760Hz,
            Axes_Enable => L3GD20_Axes_Enable, Bandwidth => L3GD20_Bandwidth_1,
            BlockData_Update => L3GD20_BlockDataUpdate_Continous,
            Endianness       => L3GD20_Little_Endian,
            Full_Scale       => L3GD20_Fullscale_2000);

         Gyro.Enable_Low_Pass_Filter;
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

      Gyro.Set_FIFO_Mode (L3GD20_Stream_Mode);
      LCD_Std_Out.Put (0, 0, "X/Y/Z");
      Gyro.Get_Raw_Angle_Rates (Last_Axes);

      loop
         Gyro.Get_Raw_Angle_Rates (Axes);
         LCD_Std_Out.Put (60, 0, Axes.X'Img & "  ");
         LCD_Std_Out.Put (120, 0, Axes.Y'Img & "  ");
         LCD_Std_Out.Put (180, 0, Axes.Z'Img & "  ");
         Prng.Feed (Integer (Last_Axes.X - Axes.X));
         Prng.Feed (Integer (Last_Axes.Y - Axes.Y));
         Prng.Feed (Integer (Last_Axes.Z - Axes.Z));
         Last_Axes := Axes;
      end loop;
   end Gyro_test;

end gyro_demo;
