with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
use Interfaces.C;
with Prng;
with miller_rabin;
with usart;

package body prime is
   procedure Give_Prime_Number(n : in out Big_Num_Access; Nb_Bits : in Integer) is
      Tmp : Big_Num_Access := new bn;
      Is_Prime : Boolean;
   begin
      Prng.Random(n, Nb_Bits);
      bignum_mod(n, Two, Tmp);
      if bignum_is_zero(Tmp) = 1 then
         bignum_inc(n);
      end if;
      loop
         <<Redo_Tests>>
         
         for i in First_Primes'Range loop
            bignum_mod(n, First_Primes(i), Tmp);
            if bignum_is_zero(Tmp) = 1 then
               bignum_inc(n); bignum_inc(n);
               usart.Send_Message_No_CRLF("-");
               goto Redo_Tests;
            end if;
         end loop;
         
         usart.Send_Message_No_CRLF(".");
         Is_Prime := miller_rabin.Miller_Rabin_no_check(n, Nb_Bits, 4);
         
         if not Is_Prime then
            bignum_inc(n); bignum_inc(n);
         else
            usart.Send_Message_No_CRLF("+");
            
            Is_Prime := miller_rabin.Miller_Rabin_no_check(n, Nb_Bits, (if Nb_Bits / 4 > 8 then 8 else Nb_Bits / 4));
            if Is_Prime then
               usart.Send_Message_No_CRLF("+*");
            end if;
         end if;
         
         exit when Is_Prime;
      end loop;
   end Give_Prime_Number;
   
   begin
   for i in First_Primes_Int'Range loop
      bignum_from_int(First_Primes(i), Interfaces.C.int(First_Primes_Int(i)));
      end loop;
end prime;
