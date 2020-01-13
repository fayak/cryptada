with GNAT.Semaphores; use GNAT.Semaphores;
 

package display is
  pragma Elaborate_Body(display);
   type Print_Pos is (Axis_Raw_Values, Entropy_Counter, Blank_1, Random_Generator_Status, Blank_2, RSA_1, RSA_2, RSA_3, RSA_4, Blank_3, Prime_Status);
   procedure Print(Line : Print_Pos; Txt : String; Send_USART : Boolean := True; Col : Integer := 0);
   procedure Print_No_CRLF(Line : Print_Pos; Txt : String);
   
subtype Mutual_Exclusion is Binary_Semaphore
    (Initially_Available => True,
     Ceiling             => Default_Ceiling);      
   col : Integer;
end display;
