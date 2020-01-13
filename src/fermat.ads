with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;


package fermat is

   function Pseudo_Prime(N, Base : Big_Num_Access) return Boolean;
     

end fermat;
