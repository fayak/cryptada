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

        Return_Value : Boolean := True;
    begin
        bignum_powmod(A, D, N, Tmp2);

        if bignum_cmp(Tmp2, One) = 0 then
            Return_Value := False;
            goto exit_dealloc;
        end if;

        bignum_from_int(I, 0);

        while bignum_cmp(I, S) <= 0 loop
            delay 0.0;
            bignum_pow(Two, I, Tmp);
            bignum_mul(Tmp, D, Tmp2);
            bignum_powmod(A, Tmp2, N, Tmp);

            if bignum_cmp(Tmp, N_Minus) = 0 then
                Return_Value := False;
                goto exit_dealloc;
            end if;

            bignum_inc(I);
        end loop;

        <<exit_dealloc>>

        Free_Bignum(I);
        Free_Bignum(Tmp);
        Free_Bignum(Tmp2);
        return Return_Value;

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


        for i in 1..Nb_Tests loop
            delay 0.0;
            Prng.Random_Unsafe(Witness, Nb_Bits + Nb_Bits / 2);
            bignum_mod(Witness, N_Minus_4, Tmp);
            bignum_add(Tmp, Two, Witness);

            if Miller_Rabin_Witness(N, Witness, S, D, N_Minus) then
                Free_Bignum(D); Free_Bignum(S); Free_Bignum(N_Minus); Free_Bignum(N_Minus_4); Free_Bignum(Tmp); Free_Bignum(Witness);
                return False;
            end if;

        end loop;
        Free_Bignum(D); Free_Bignum(S); Free_Bignum(N_Minus); Free_Bignum(N_Minus_4); Free_Bignum(Tmp); Free_Bignum(Witness);
        return True;
    end Miller_Rabin_no_check;

end miller_rabin;
