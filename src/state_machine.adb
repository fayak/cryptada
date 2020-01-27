package body State_Machine is

      procedure Init (self: in out State) is
      begin
         self.state := Menu;
         self.screen.Init;
      end Init;

end State_Machine;
