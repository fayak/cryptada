with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

with L3GD20;  use L3GD20;

package entropy_generator_gyro is
   pragma Elaborate_Body(entropy_generator_gyro);
   task Collect_Background_Entropy is
      --pragma Priority (10);
      end Collect_Background_Entropy;

   procedure init_entropy_collector;
   procedure collect_entropy(Minimum : Integer);

private
   Axes      : L3GD20.Angle_Rates;
   Last_Axes : L3GD20.Angle_Rates;
end entropy_generator_gyro;
