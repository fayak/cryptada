with display; use display;

package State_Machine is

   type State is tagged record
      Screen : display.Display;
   end record;
   procedure Init (self: in out State);
     
   Internal_State : State;
end State_Machine;
