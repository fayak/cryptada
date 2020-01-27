with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
use Interfaces.C;
with Prng;

package prime is
   procedure Give_Prime_Number(n : in out Big_Num_Access; Nb_Bits : in Integer);
   
   type Prime_Integer_Array is array(Integer range <>) of Integer;
   type Prime_BN_Array is array(Integer range <>) of Big_Num_Access;
   First_Primes_Int : Prime_Integer_Array := (3, 5, 7, 11, 13, 17, 19, 23, 29,
                                              31, 37, 41, 43, 47, 53, 59, 61, 67,
                                              71, 73, 
                                              79);
                                              --79, 83, 89, 97);
   First_Fermat_Int : Prime_Integer_Array := (3, 65537);
   
   First_Primes : Prime_BN_Array(First_Primes_Int'Range) := (others => new bn);
   First_Fermat : Prime_BN_Array(First_Fermat_Int'Range) := (others => new bn);
end prime;
