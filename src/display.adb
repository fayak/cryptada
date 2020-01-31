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

    procedure Fill_BG(self: in out Display; BG : Bitmap_Color) is
    begin
        STM32.Board.Display.Hidden_Buffer (1).Set_Source (BG);
        STM32.Board.Display.Hidden_Buffer (1).Fill;
    end Fill_BG;

    procedure Clear_Menu(self: in out Display) is
        BG : Bitmap_Color := (Alpha => 255, others => 0);
    begin
        LCD_Std_Out.Clear_Screen;
        STM32.Board.Display.Hidden_Buffer (1).Set_Source (BG);
        STM32.Board.Display.Hidden_Buffer (1).Fill_Rect(((0, 5 * self.Line_Height), 240, 320));

        STM32.Board.Display.Update_Layer(1, Copy_Back => true);
    end Clear_Menu;

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
        self.Fill_BG(BG);

        LCD_Std_Out.Clear_Screen;
        STM32.Board.Display.Update_Layer (1, Copy_Back => True);

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
        LCD_Std_Out.Put(self.Col * self.Char_Width, Line * (self.Line_Height + self.Row), Txt & " ");
        self.Col := self.Col + 1;
        if self.Col > 20 then
            self.Col := 0;
            self.Row := self.Row + 1;
            if self.Row > 10 then
                self.Row := 0;
            end if;
        end if;
        usart.Send_Message_No_CRLF(Txt);
        Mutex.Release;
    end Print_No_CRLF;

    function Point_In_Rect (Pos : Point; Area : Rect) return Boolean is
    begin
        return Pos.X >= Area.Position.X and then Pos.X <= Area.Position.X + Area.Width
        and then Pos.Y >= Area.Position.Y and then Pos.Y <= Area.Position.Y + Area.Height;
    end Point_In_Rect;

    function Draw_Menu (self: in out Display) return Button_Type is
        Button_Color : Bitmap_Color := HAL.Bitmap.White_Smoke;
        Button_Height : Natural := 30;
        Button_Width : Natural := 70;
        Button_Spacer : Natural := 7;
        Button_Line : Natural := 8 * self.Line_Height;
        Print_Button : Rect := ((Button_Spacer, Button_Line), Button_Width, Button_Height);
        RSA_Button : Rect := ((Button_Width + 2 * Button_Spacer, Button_Line), Button_Width, Button_Height);
        Size_Button : Rect := ((2 * Button_Width + 3 * Button_Spacer, Button_Line), Button_Width, Button_Height);
    begin

        self.Clear_Menu;

        STM32.Board.Display.Hidden_Buffer (1).Set_Source (Button_Color);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => Print_Button);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => RSA_Button);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => Size_Button);

        LCD_Std_Out.Put(Button_Spacer + 5, Button_Line + 10, "Print");
        LCD_Std_Out.Put(Button_Width + 2 * Button_Spacer + 15, Button_Line + 10, "RSA");
        LCD_Std_Out.Put(2 * Button_Width + 3 * Button_Spacer + 10, Button_Line + 10, "Size");

        STM32.Board.Display.Update_Layer(1, Copy_Back => true);

        loop
            declare
                Touch_State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
                pos : Point;
            begin
                if Touch_State'Length = 1 then
                    pos := (Touch_State (1).X, Touch_State (1).Y);
                    if Point_In_Rect(pos, Print_Button) then
                        return BUTTON_PRINT;
                    elsif Point_In_Rect(pos, RSA_Button) then
                        return BUTTON_RSA;
                    elsif Point_In_Rect(pos, Size_Button) then
                        return BUTTON_SIZE;
                    end if;
                else
                    delay 0.0;
                end if;
            end;
        end loop;
    end Draw_Menu;

    procedure Draw_Size_Selector(self: in out Display; Window : in out Window_Type; Nb_Bits : in out Natural) is
        Button_Color : Bitmap_Color := HAL.Bitmap.White_Smoke;
        Button_Height : Natural := 30;
        Button_Width : Natural := 70;
        Button_Spacer : Natural := 7;
        Button_Line : Natural := 7 * self.Line_Height;
        OK_Line : Natural := 10 * self.Line_Height;
        Print_Button : Rect := ((Button_Spacer, Button_Line), Button_Width, Button_Height);
        RSA_Button : Rect := ((Button_Width + 2 * Button_Spacer, Button_Line), Button_Width, Button_Height);
        Size_Button : Rect := ((2 * Button_Width + 3 * Button_Spacer, Button_Line), Button_Width, Button_Height);
        OK_Button : Rect := ((Button_Width + 2 * Button_Spacer, OK_Line), Button_Width, Button_Height);
    begin

        self.Clear_Menu;

        STM32.Board.Display.Hidden_Buffer (1).Set_Source (Button_Color);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => Print_Button);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => RSA_Button);
        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => Size_Button);

        STM32.Board.Display.Hidden_Buffer(1).Draw_Rect (Area => OK_Button);

        LCD_Std_Out.Put(Button_Spacer + 5, Button_Line + 10, "256");
        LCD_Std_Out.Put(Button_Width + 2 * Button_Spacer + 15, Button_Line + 10, "512");
        LCD_Std_Out.Put(2 * Button_Width + 3 * Button_Spacer + 10, Button_Line + 10, "768");

        LCD_Std_Out.Put(Button_Width + 2 * Button_Spacer + 15, OK_Line + 10, "Done");

        STM32.Board.Display.Update_Layer(1, Copy_Back => true);

        loop
            LCD_Std_Out.Put(Button_Spacer + 5, Componant_Line (Log_Info) * self.Line_Height, "Key Size := " & Nb_Bits'Image & "           ");
            declare
                Touch_State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
                pos : Point;
            begin
                if Touch_State'Length = 1 then
                    pos := (Touch_State (1).X, Touch_State (1).Y);
                    if Point_In_Rect(pos, Print_Button) then
                        Nb_Bits := 256;
                    elsif Point_In_Rect(pos, RSA_Button) then
                        Nb_Bits := 512;
                    elsif Point_In_Rect(pos, Size_Button) then
                        Nb_Bits := 768;
                    elsif Point_In_Rect(pos, OK_Button) then
                        return;
                    end if;
                else
                    delay 0.0;
                end if;
            end;
        end loop;
    end Draw_Size_Selector;

end display;
