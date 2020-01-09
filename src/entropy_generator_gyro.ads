
with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with STM32.Device; use STM32.Device;
with STM32.Board;  use STM32.Board;

with STM32.GPIO; use STM32.GPIO;
with STM32.EXTI; use STM32.EXTI;

with LCD_Std_Out;

with L3GD20;  use L3GD20;

package entropy_generator_gyro is
   pragma Elaborate_Body(entropy_generator_gyro);
   task Collect_Background_Entropy;
procedure init_entropy_collector;
   procedure collect_entropy(Minimum : Integer);

private
   Axes      : L3GD20.Angle_Rates;
   Last_Axes : L3GD20.Angle_Rates;
end entropy_generator_gyro;
