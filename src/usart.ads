with Ada.Strings.Unbounded;
with GNAT.Semaphores; use GNAT.Semaphores;

package usart is

   procedure Init_USART;
   procedure Get_Message(Message_Final : in out Ada.Strings.Unbounded.Unbounded_String);
   procedure Send_Message(Message : String);
   procedure Send_Message_No_CRLF(Message : String) with Pre => (Message'Length > 0);

   subtype Mutual_Exclusion is Binary_Semaphore
    (Initially_Available => True,
     Ceiling             => Default_Ceiling);
   col : Integer;
end usart;
