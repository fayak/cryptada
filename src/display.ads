with GNAT.Semaphores; use GNAT.Semaphores;

package display is
   pragma Elaborate_Body(display);

   type Print_Coord is record
      Line : Natural;
      Col : Natural;
   end record;

   type Window_Type is (MENU, SIZE_SELECTOR);
   type Componant is (RSA, Entropy, Prime, Gyro, Log_Info);
   type Componant_To_Line_Map is array (Componant) of Natural;
   type Button_Type is (BUTTON_RSA, BUTTON_SIZE, BUTTON_PRINT, NONE);

   Componant_Line : constant Componant_To_Line_Map := (
                                                       Log_Info => 3,
                                                       RSA => 5,
                                                       Gyro => 0,
                                                       Entropy => 1,
                                                       Prime => 9
                                                      );

   subtype Mutual_Exclusion is Binary_Semaphore
     (Initially_Available => True,
      Ceiling             => Default_Ceiling);

   type Display is tagged record
      Col : Natural := 0;
      Row : Natural := 0;
      Line_Height : Natural := 14;
      Char_Width : Natural := 11;
   end record;

   procedure Init(self: in out Display);
   procedure Clear_Menu(self: in out Display);

   procedure Print(self: in out Display; Coord : Print_Coord; Txt : String; Send_USART : Boolean := True);
   procedure Print_No_CRLF(self: in out Display; Line : Natural; Txt : String);

   function Draw_Menu (self: in out Display) return Button_Type;
   procedure Draw_Size_Selector(self: in out Display; Window : in out Window_Type; Nb_Bits : in out Natural);

end display;
