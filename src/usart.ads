with Ada.Strings.Unbounded;

package usart is

   procedure Init_USART;
   procedure Get_Message(Message_Final : in out Ada.Strings.Unbounded.Unbounded_String);
end usart;
