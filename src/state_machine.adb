package body State_Machine is

      procedure Init (self: in out State) is
      begin
         self.Screen.Init;
      end Init;

end State_Machine;
