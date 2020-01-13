with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings; with Interfaces.C; use Interfaces.C;
with usart;

package body fermat is
   function Pseudo_Prime(N, Base : Big_Num_Access) return Boolean is
      N_m1, Tmp : Big_Num_Access := new bn;
     
      begin
      
      bignum_sub(N, One, N_m1);
      bignum_powmod(Base, N_m1, N, Tmp);

      if bignum_cmp(Tmp, One) = 0 then
         return True;
      end if;
      return False;
   end Pseudo_Prime;

end fermat;
