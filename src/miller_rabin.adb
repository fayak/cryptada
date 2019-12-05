with bn_h;                  use bn_h;
with Interfaces.C.Strings;
use Interfaces.C;
with LCD_Std_Out;


package body miller_rabin is
   function Miller_Rabin_Witness (N, A : Big_Num_Access) return Boolean is
      D : Big_Num_Access := new bn;
      S : Big_Num_Access := new bn;
      X : Big_Num_Access := new bn;
   
      One : Big_Num_Access := new bn;
      Two : Big_Num_Access := new bn;
      I : Big_Num_Access := new bn;
      
      Tmp, Tmp2 : Big_Num_Access := new bn;
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
      Buffer : Interfaces.C.Strings.chars_ptr;

   begin
      Buffer := Interfaces.C.Strings.New_String(String_Base);
   
   
      bignum_from_int(One, 1);
      bignum_from_int(Two, 2);
      bignum_from_int(S, 0);
      bignum_assign(Tmp, N);
      bignum_sub(Tmp, One, D); -- D := N - 1
   
      bignum_mod(D, Two, Tmp);
      
      while bignum_is_zero(Tmp) = 1 loop
         bignum_div(D, Two, Tmp);
         bignum_assign(D, Tmp); -- D := D / 2

         bignum_inc(S);
      
         bignum_mod(D, Two, Tmp);
      end loop;
   
      bignum_to_string(S, Buffer, STR_DEST_SIZE);
      LCD_Std_Out.Put("S := ");
      LCD_Std_Out.Put_Line(Interfaces.C.Strings.Value(Buffer));
      bignum_to_string(D, Buffer, STR_DEST_SIZE);
      LCD_Std_Out.Put("D := ");
      LCD_Std_Out.Put_Line(Interfaces.C.Strings.Value(Buffer));
      
      bignum_pow(A, D, Tmp);
      bignum_mod(Tmp, N, X);
      
      bignum_from_int(I, 1);
      while bignum_cmp(I, S) >= 0 loop
         bignum_pow(Two, I, Tmp);
         bignum_mul(Tmp, D, Tmp2);
         bignum_pow(A, Tmp2, Tmp);
         bignum_mod(Tmp, N, Tmp2);
         
         bignum_sub(N, One, Tmp);
         if bignum_cmp(Tmp, Tmp2) = 0 then
            return False;
         end if;
         bignum_inc(I);
      end loop;
      return True;
   
   end Miller_Rabin_Witness;

end miller_rabin;
