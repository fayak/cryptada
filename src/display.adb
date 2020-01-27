
with STM32.Board;           use STM32.Board;
with LCD_Std_Out; use LCD_Std_Out;
with usart;
with HAL.Bitmap;            use HAL.Bitmap;
pragma Warnings (Off, "referenced");
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with STM32.User_Button;     use STM32;
with BMP_Fonts;

package body display is

   Mutex : Mutual_Exclusion;
   
   procedure Init (self: in out Display) is
      Board_Size : Point := (240, 320);
      BG : Bitmap_Color := (Alpha => 255, others => 0);
   begin
      --  Initialize LCD
      STM32.Board.Display.Initialize;
      STM32.Board.Display.Initialize_Layer (1, ARGB_8888);
      
      --  Initialize touch panel
      Touch_Panel.Initialize;
      
      --  Initialize button
      User_Button.Initialize;
      
      LCD_Std_Out.Set_Font (BMP_Fonts.Font12x12);
      LCD_Std_Out.Current_Background_Color := BG;
      
      --  Clear LCD (set background)
      STM32.Board.Display.Hidden_Buffer (1).Set_Source (BG);
      STM32.Board.Display.Hidden_Buffer (1).Fill;
      
      LCD_Std_Out.Clear_Screen;
      STM32.Board.Display.Update_Layer (1, Copy_Back => True);
      LCD_Std_Out.Clear_Screen;
      
      --  Init USART
      usart.Init_USART;
            
   end Init;
   
   procedure Print (self: in out Display; Coord : Print_Coord; Txt : String; Send_USART : Boolean := True) is
   begin
      Mutex.Seize;
      LCD_Std_Out.Put(Coord.Col, Coord.Line * self.Line_Height, Txt);
      if Send_USART then
         usart.Send_Message(Txt);
      end if;
      Mutex.Release;
   end Print;
   
   procedure Print_No_CRLF(self: in out Display; Line : Natural; Txt : String) is
   begin
      Mutex.Seize;
      LCD_Std_Out.Put(self.col*self.Char_Width, Line * (self.Line_Height + self.row), Txt & " ");
      self.col := self.col + 1;
      if self.col > 20 then
         self.col := 0;
         self.row := self.row + 1;
            if self.row > 10 then
            self.row := 0;
         end if;
      end if;
      usart.Send_Message_No_CRLF(Txt);
      Mutex.Release;
   end Print_No_CRLF;


end display;
