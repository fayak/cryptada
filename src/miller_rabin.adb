with bn_h;                  use bn_h;
with Interfaces.C.Strings;
use Interfaces.C;
with LCD_Std_Out;


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

   function Miller_Rabin_p (N : Big_Num_Access) return Boolean is
      D : Big_Num_Access := new bn;
      S : Big_Num_Access := new bn;
      N_Minus : Big_Num_Access := new bn;
   
      I : Big_Num_Access := new bn;
      
      Tmp, Tmp2 : Big_Num_Access := new bn;
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
      Buffer : Interfaces.C.Strings.chars_ptr;
   begin
      Buffer := Interfaces.C.Strings.New_String(String_Base);
      bignum_init(Tmp);
      
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
      return False;
   end Miller_Rabin_p;
begin
   bignum_init(Two);
   bignum_from_int(Two, 2);
   bignum_init(One);
   bignum_from_int(One, 1);
   bignum_init(Three);
   bignum_from_int(Three, 3);
   bignum_init(Five);
   bignum_from_int(Five, 5);
   bignum_init(Seven);
   bignum_from_int(Seven, 7);
   bignum_init(Miller_11);
   bignum_from_int(Miller_11, 11);
   bignum_init(Miller_13);
   bignum_from_int(Miller_13, 13);
   bignum_init(Miller_17);
   bignum_from_int(Miller_17, 17);
   bignum_init(Miller_31);
   bignum_from_int(Miller_31, 31);
   bignum_init(Miller_73);
   bignum_from_int(Miller_73, 73);
   bignum_init(Miller_2047);
   bignum_from_int(Miller_2047, 2047);
   bignum_init(Miller_1373653);
   bignum_from_int(Miller_1373653, 1373653);
   bignum_init(Miller_9080191);
   bignum_from_int(Miller_9080191, 9080191);
   
   bignum_init(Miller_341550071728321);
   bignum_from_string(Miller_341550071728321, Interfaces.C.Strings.New_String("341550071728321"), 15);
end miller_rabin;
