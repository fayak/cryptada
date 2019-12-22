
with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with STM32.Device; use STM32.Device;
with STM32.Board;  use STM32.Board;

with STM32.GPIO; use STM32.GPIO;
with STM32.EXTI; use STM32.EXTI;

with LCD_Std_Out;

with L3GD20;  use L3GD20;
package gyro_demo is

procedure Gyro_test ;
end gyro_demo;
