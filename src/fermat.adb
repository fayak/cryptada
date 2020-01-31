with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings; with Interfaces.C; use Interfaces.C;
with usart;

package body fermat is
    function Pseudo_Prime(N, Base : Big_Num_Access) return Boolean is
        N_m1, Tmp : Big_Num_Access := new bn;

        Buffer : Interfaces.C.Strings.chars_ptr;
        String_Base : String(1..STR_DEST_SIZE) := (others => '0');
    begin
        Buffer := Interfaces.C.Strings.New_String(String_Base);

        bignum_sub(N, One, N_m1);
        bignum_powmod(Base, N_m1, N, Tmp);

        Free_Bignum(N_m1);
        if bignum_cmp(Tmp, One) = 0 then
            Free_Bignum(Tmp);
            return True;
        end if;
        Free_Bignum(Tmp);
        return False;
    end Pseudo_Prime;

end fermat;
