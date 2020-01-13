with LCD_Std_Out; use LCD_Std_Out;
with usart;

package body display is

   Mutex : Mutual_Exclusion;
   
   procedure Print(Line : Print_Pos; Txt : String; Send_USART : Boolean := True; Col : Integer := 0) is
   begin
      Mutex.Seize;
      LCD_Std_Out.Put(Col, Print_Pos'Pos(Line) * 14, Txt);
      if Send_USART then
         usart.Send_Message(Txt);
      end if;
      Mutex.Release;
   end Print;
   
   procedure Print_No_CRLF(Line : Print_Pos; Txt : String) is
   begin
      Mutex.Seize;
      LCD_Std_Out.Put(col*12, Print_Pos'Pos(Line) * 14, Txt & " ");
      col := col + 1;
      if col > 18 then
         col := 0;
      end if;
      usart.Send_Message_No_CRLF(Txt);
      Mutex.Release;
   end Print_No_CRLF;
begin
   col := 0;
end display;
