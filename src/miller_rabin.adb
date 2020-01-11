with bn_h;                  use bn_h;
with Interfaces.C.Strings;
use Interfaces.C;
with LCD_Std_Out;
with Prng;
with usart;

package body miller_rabin is
   
   function Miller_Rabin_Witness (N, A, S, D, N_Minus : Big_Num_Access) return Boolean is   
      
      I : Big_Num_Access := new bn;
      
      Tmp, Tmp2 : Big_Num_Access := new bn;

   begin
      bignum_powmod(A, D, N, Tmp2);

      if bignum_cmp(Tmp2, One) = 0 then
         return False;
      end if;
      
      bignum_from_int(I, 0);

      while bignum_cmp(I, S) <= 0 loop
         bignum_pow(Two, I, Tmp);
         bignum_mul(Tmp, D, Tmp2);
         bignum_powmod(A, Tmp2, N, Tmp);
         
         if bignum_cmp(Tmp, N_Minus) = 0 then
            return False;
         end if;

         bignum_inc(I);
      end loop;
      return True;
   
   end Miller_Rabin_Witness;
   
   function Miller_Rabin_no_check (N : Big_Num_Access; Nb_Bits, Nb_Tests : Integer) return Boolean is
      D : Big_Num_Access := new bn;
      S : Big_Num_Access := new bn;
      N_Minus, N_Minus_4, Tmp : Big_Num_Access := new bn;
      Witness : Big_Num_Access := new bn;
      
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
      Buffer : Interfaces.C.Strings.chars_ptr;
   begin
      Buffer := Interfaces.C.Strings.New_String(String_Base);
      bignum_from_int(S, 0);
      
      bignum_sub(N, One, D);
      bignum_mod(D, Two, Tmp);
      while bignum_is_zero(Tmp) = 1 loop
         bignum_rshift(D, D, 1);
         bignum_inc(S);
         bignum_mod(D, Two, Tmp);
      end loop;
      
      bignum_sub(N, One, N_Minus);
      bignum_sub(N_Minus, Three, N_Minus_4);
      
      if bignum_cmp(N, Miller_341550071728321) < 0 then
         return not (Miller_Rabin_Witness(N, Two, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Three, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Five, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Seven, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_11, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_13, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_17, S, D, N_Minus)
                    );
      end if;
      
            
      for i in 1..Nb_Tests loop
         Prng.Random_Unsafe(Witness, Nb_Bits + Nb_Bits / 2);
         bignum_mod(Witness, N_Minus_4, Tmp);
         bignum_add(Tmp, Two, Witness);
         
         if Miller_Rabin_Witness(N, Witness, S, D, N_Minus) then
            return False;
         end if;

      end loop;
      return True;
   end Miller_Rabin_no_check;
   
   function Miller_Rabin_p (N : Big_Num_Access) return Boolean is
      D : Big_Num_Access := new bn;
      S : Big_Num_Access := new bn;
      N_Minus : Big_Num_Access := new bn;
   
      I : Big_Num_Access := new bn;
      
      Tmp, Tmp2 : Big_Num_Access := new bn;
   begin      
      if bignum_cmp(N, One) = 0 or bignum_cmp(N, Two) = 0 or bignum_cmp(N, Three) = 0 then
         return True;
      end if;
      
      bignum_mod(N, Two, Tmp);
      if bignum_is_zero(Tmp) = 1 then
         return False;
      end if;
      
      bignum_mod(N, Three, Tmp);
      if bignum_is_zero(Tmp) = 1 then
         return False;
      end if;
      
      bignum_from_int(S, 0);
      bignum_assign(Tmp, N);
      bignum_sub(Tmp, One, D); -- D := N - 1
   
      bignum_mod(D, Two, Tmp);
      
      while bignum_is_zero(Tmp) = 1 loop
         bignum_rshift(D, D, 1);

         bignum_inc(S);
      
         bignum_mod(D, Two, Tmp);
      end loop;
   
      
      bignum_sub(N, One, N_Minus);
      
      if bignum_cmp(N, Miller_2047) < 0 then
         return not Miller_Rabin_Witness(N, Two, S, D, N_Minus);
      end if;
      if bignum_cmp(N, Miller_1373653) < 0 then
         return not (Miller_Rabin_Witness(N, Two, S, D, N_Minus) and Miller_Rabin_Witness(N, Three, S, D, N_Minus));
      end if;
      if bignum_cmp(N, Miller_9080191) < 0 then
         return not (Miller_Rabin_Witness(N, Miller_31, S, D, N_Minus) and Miller_Rabin_Witness(N, Miller_73, S, D, N_Minus));
      end if;
      if bignum_cmp(N, Miller_341550071728321) < 0 then
         return not (Miller_Rabin_Witness(N, Two, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Three, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Five, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Seven, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_11, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_13, S, D, N_Minus) and
                       Miller_Rabin_Witness(N, Miller_17, S, D, N_Minus)
                    );
      end if;
      
      return True;
   end Miller_Rabin_p;

end miller_rabin;
