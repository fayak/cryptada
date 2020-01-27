with GNAT.Semaphores; use GNAT.Semaphores;

package display is
   pragma Elaborate_Body(display);

   type Print_Coord is record
      Line : Natural;
      Col : Natural;
   end record;

   type States is (Menu, RSA, Send_Key, Key_Size);
   type Componant is (RSA, Entropy, PRNG, Prime, Gyro);
   type Componant_To_Line_Map is array (Componant) of Natural;

   Componant_Line : constant Componant_To_Line_Map := (
                                                       RSA => 5,
                                                       Gyro => 0,
                                                       Entropy => 1,
                                                       PRNG => 3,
                                                       Prime => 9
                                                      );

   type Print_State is record
      State : States;
      Component : Componant;
   end record;

   type Print_Pos is (Axis_Raw_Values, Entropy_Counter, Blank_1, Random_Generator_Status, Blank_2, RSA_1, RSA_2, RSA_3, RSA_4, Blank_3, Prime_Status);

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

   procedure Print(self: in out Display; Coord : Print_Coord; Txt : String; Send_USART : Boolean := True);
   procedure Print_No_CRLF(self: in out Display; Line : Natural; Txt : String);
end display;
