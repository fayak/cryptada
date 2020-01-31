with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
use Interfaces.C;
with Prng;
with miller_rabin;
with LCD_Std_Out;
with usart;
with prime;
with display;
use display;
with State_Machine; use State_Machine;

package body rsa is

    procedure GCD (a, b : in Big_Num_Access; res : out Big_Num_Access) is
        tmp_a, tmp_b, tmp_res : Big_Num_Access := new bn;
    begin
        bignum_init(tmp_a);
        bignum_init(tmp_b);
        bignum_init(tmp_res);

        bignum_assign(tmp_a, a);
        bignum_assign(tmp_b, b);

        while bignum_is_zero(tmp_a) = 0 loop
            bignum_mod(tmp_b, tmp_a, tmp_res);
            bignum_assign(tmp_b, tmp_a);
            bignum_assign(tmp_a, tmp_res);
        end loop;

        res := new bn;
        bignum_assign(res, tmp_b);

        Free_Bignum(tmp_a);
        Free_Bignum(tmp_b);
        Free_Bignum(tmp_res);
    end GCD;

    function Find_Mod_Inverse (a, m : in Big_Num_Access) return Big_Num_Access is
        tmp1 : Big_Num_Access := null;
        u1, u2, u3 : Big_Num_Access := null;
        v1, v2, v3 : Big_Num_Access := null;
        tmp2, q : Big_Num_Access := null;
        res : Big_Num_Access := null;

    begin      
        GCD(a, m, tmp1);
        if bignum_cmp(tmp1, One) /= 0 then
            Free_Bignum(tmp1);
            Free_Bignum(tmp2);
            Free_Bignum(q);
            return res;
        end if;

        u1 := new bn;
        u2 := new bn;
        u3 := new bn;
        v1 := new bn;
        v2 := new bn;
        v3 := new bn;
        tmp2 := new bn;
        q := new bn;

        bignum_assign(u1, One);
        bignum_assign(u2, Zero);
        bignum_assign(u3, a);

        bignum_assign(v1, Zero);
        bignum_assign(v2, One);
        bignum_assign(v3, m);
        while bignum_is_zero(v3) = 0 loop
            bignum_div(u3, v3, q);

            -- v1, u1 := (u1 - q * v1), v1
            bignum_mul(q, v1, tmp1);
            bignum_sub(u1, tmp1, tmp2);
            bignum_assign(u1, v1);
            bignum_assign(v1, tmp2);

            -- v2, u2 := (u2 - q * v2), v2
            bignum_mul(q, v2, tmp1);
            bignum_sub(u2, tmp1, tmp2);
            bignum_assign(u2, v2);
            bignum_assign(v2, tmp2);

            -- v3, u3 := (u3 - q * v3), v3
            bignum_mul(q, v3, tmp1);
            bignum_sub(u3, tmp1, tmp2);
            bignum_assign(u3, v3);
            bignum_assign(v3, tmp2);
        end loop;
        res := new bn;

        bignum_mod(u1, m, res);

        Free_Bignum(tmp1);
        Free_Bignum(tmp2);
        Free_Bignum(q);
        Free_Bignum(u1);
        Free_Bignum(u2);
        Free_Bignum(u3);
        Free_Bignum(v1);
        Free_Bignum(v2);
        Free_Bignum(v3);
        return res;
    end Find_Mod_Inverse;

    procedure Print_UART_ASN1_Conf(n, d, e, p, q, pm1, qm1 : in Big_Num_Access) is
        e1, e2, coeff : Big_Num_Access := new bn;
        Buffer : Interfaces.C.Strings.chars_ptr;
        String_Base : String(1..STR_DEST_SIZE) := (others => '0');
    begin
        Buffer := Interfaces.C.Strings.New_String(String_Base);
        usart.Send_Message("asn1=SEQUENCE:rsa_key");
        usart.Send_Message("");
        usart.Send_Message("[rsa_key]");
        usart.Send_Message("version=INTEGER:0");
        bignum_to_string(n, Buffer, STR_DEST_SIZE);
        usart.Send_Message("modulus=INTEGER:" & Interfaces.C.Strings.Value(Buffer));
        bignum_to_string(e, Buffer, STR_DEST_SIZE);
        usart.Send_Message("pubExp=INTEGER:" & Interfaces.C.Strings.Value(Buffer));
        bignum_to_string(d, Buffer, STR_DEST_SIZE);
        usart.Send_Message("privExp=INTEGER:" & Interfaces.C.Strings.Value(Buffer));
        bignum_to_string(p, Buffer, STR_DEST_SIZE);
        usart.Send_Message("p=INTEGER:" & Interfaces.C.Strings.Value(Buffer)); 
        bignum_to_string(q, Buffer, STR_DEST_SIZE);
        usart.Send_Message("q=INTEGER:" & Interfaces.C.Strings.Value(Buffer));
        bignum_mod(d, pm1, e1);
        bignum_mod(d, qm1, e2);
        coeff := Find_Mod_Inverse(q, p);

        bignum_to_string(e1, Buffer, STR_DEST_SIZE);
        usart.Send_Message("e1=INTEGER:" & Interfaces.C.Strings.Value(Buffer)); 
        bignum_to_string(e2, Buffer, STR_DEST_SIZE);
        usart.Send_Message("e2=INTEGER:" & Interfaces.C.Strings.Value(Buffer)); 
        bignum_to_string(coeff, Buffer, STR_DEST_SIZE);
        usart.Send_Message("coeff=INTEGER:" & Interfaces.C.Strings.Value(Buffer)); 

    end Print_UART_ASN1_Conf;
    procedure Gen_RSA(Nb_Bits : in Integer; n, d , e, p, q, pm1, qm1 : in out Big_Num_Access) is
        pm1_qm1 : Big_Num_Access := new bn;
        Tmp : Big_Num_Access := new bn;
        String_Base : String(1..STR_DEST_SIZE) := (others => '0');
        Buffer : Interfaces.C.Strings.chars_ptr;
    begin
        Buffer := Interfaces.C.Strings.New_String(String_Base);
        Internal_State.Screen.Clear_Menu;
        Internal_State.Screen.Print((Componant_Line(display.RSA), 0), "RSA(" & Nb_Bits'Image & "bits)");
        Internal_State.Screen.Print((Componant_Line(display.RSA) + 1, 0), "RSA: Finding p", Send_USART => False);
        prime.Give_Prime_Number(p, (Nb_Bits / 2) + 1);
        Internal_State.Screen.Print((Componant_Line(display.RSA) + 1, 0), "RSA: Finding q", Send_USART => False);
        prime.Give_Prime_Number(q, (Nb_Bits / 2) + 1);

        Internal_State.Screen.Print((Componant_Line(display.RSA) + 1, 0), "RSA: Computing priv.", Send_USART => False);
        bignum_mul(p, q, n);

        bignum_sub(p, One, pm1);
        bignum_sub(q, One, qm1);
        bignum_mul(pm1, qm1, pm1_qm1);
        Internal_State.Screen.Print((Componant_Line(display.RSA) + 1, 0), "RSA: Computing D", Send_USART => False);

        for i in prime.First_Fermat'Range loop
            bignum_assign(e, prime.First_Fermat(i));
            d := Find_Mod_Inverse(e, pm1_qm1);
            exit when d /= null;
        end loop;

        Free_Bignum(pm1_qm1);
        Free_Bignum(Tmp);
        Internal_State.Screen.Print((Componant_Line(display.RSA) + 1, 0), "RSA: done !         ");
    end Gen_RSA;
end rsa;
