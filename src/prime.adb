with bn_h; use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings; use Interfaces.C;
with Prng;
with miller_rabin;
with usart;
with fermat;
with display; use display;
with State_Machine; use State_Machine;

package body prime is
   Line : Natural;
   Line_Offset : Natural := 8;
   
   procedure Give_Prime_Number(n : in out Big_Num_Access; Nb_Bits : in Integer) is
      Tmp : Big_Num_Access := new bn;
      Is_Prime : Boolean;
   begin
      Prng.Random(n, Nb_Bits);
      bignum_mod(n, Two, Tmp);
      if bignum_is_zero(Tmp) = 1 then
         bignum_inc(n);
      end if;
      
      Internal_State.Screen.Print((Line + Line_Offset, 0), "-: not Prime KO");
      Internal_State.Screen.Print((Line + Line_Offset + 1, 0), ".: Fermat OK");
      Internal_State.Screen.Print((Line + Line_Offset + 2, 0), "+: Miller-Rabin OK");
      Internal_State.Screen.Print((Line + Line_Offset + 3, 0), "*: Prime Found");
      
      loop
         <<Redo_Tests>>
         
         for i in First_Primes'Range loop
            bignum_mod(n, First_Primes(i), Tmp);
            if bignum_is_zero(Tmp) = 1 then
               bignum_inc(n); bignum_inc(n);
               Internal_State.Screen.Print_No_CRLF(Line, "-");
               goto Redo_Tests;
            end if;
         end loop;

         if not fermat.Pseudo_Prime(n, Two)   or else
            not fermat.Pseudo_Prime(n, Three) or else
            not fermat.Pseudo_Prime(n, Five)  or else
            not fermat.Pseudo_Prime(n, Seven)
         then
            bignum_inc(n); bignum_inc(n);
            goto Redo_Tests;
         end if;
         
         Internal_State.Screen.Print_No_CRLF(Line, ".");
         Is_Prime := miller_rabin.Miller_Rabin_no_check(n, Nb_Bits, 4);
         
         if not Is_Prime then
            bignum_inc(n); bignum_inc(n);
            Internal_State.Screen.Print_No_CRLF(Line, "-");
         else
            Internal_State.Screen.Print_No_CRLF(Line, "+");
            
            Is_Prime := miller_rabin.Miller_Rabin_no_check(n, Nb_Bits, (if Nb_Bits / 4 > 8 then 8 else Nb_Bits / 4));
            if Is_Prime then
               Internal_State.Screen.Print_No_CRLF(Line, "*");
               if Internal_State.screen.Col /= 0 then
                  Internal_State.screen.Row :=  Internal_State.screen.Row + 1;
                  Internal_State.screen.Col := 0;
               end if;
               Internal_State.screen.Row :=  Internal_State.screen.Row + 1;
            else
               bignum_inc(n); bignum_inc(n);
               Internal_State.Screen.Print_No_CRLF(Line, "-");
            end if;
         end if;
         
         exit when Is_Prime;
      end loop;
      Free_Bignum(Tmp);
   end Give_Prime_Number;

begin
   Line := display.Componant_Line(display.Prime);
     
   for i in First_Primes_Int'Range loop
      bignum_from_int(First_Primes(i), Interfaces.C.int(First_Primes_Int(i)));
   end loop;
  
   for i in First_Fermat_Int'Range loop
      bignum_from_int(First_Fermat(i), Interfaces.C.int(First_Fermat_Int(i)));
   end loop;
   
end prime;
