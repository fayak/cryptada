with bn_h;                  use bn_h;

with bignum; use bignum;
with Interfaces.C.Strings;
use Interfaces.C;
with Prng;
with miller_rabin;
with LCD_Std_Out;

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
      
      
      String_Base : String(1..STR_DEST_SIZE) := (others => '0');
      Buffer : Interfaces.C.Strings.chars_ptr;
   begin
      Buffer := Interfaces.C.Strings.New_String(String_Base);
      
      -- bignum_to_string(bn_res, Buffer, STR_DEST_SIZE);
      -- LCD_Std_Out.Put(Interfaces.C.Strings.Value(Buffer));
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
         
         bignum_to_string(u1, Buffer, STR_DEST_SIZE);
         --LCD_Std_Out.Put(Interfaces.C.Strings.Value(Buffer));
         --LCD_Std_Out.Put(" ");
         bignum_to_string(v1, Buffer, STR_DEST_SIZE);
         --LCD_Std_Out.Put_Line(Interfaces.C.Strings.Value(Buffer));
         
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
   
   procedure Gen_RSA(Nb_Bits : in Integer; n, d , e : in out Big_Num_Access) is
      p, q : Big_Num_Access := new bn;
      Tmp : Big_Num_Access := new bn;
   begin
      LCD_Std_Out.Put(0, 42, "RSA: Init");
      loop
         Prng.Random(p, Nb_Bits);
         LCD_Std_Out.Put(0, 42, "RSA: Finding p");
         bignum_mod(p, Two, Tmp);
         if bignum_is_zero(Tmp) = 1 then
            bignum_inc(p);
         end if;
         exit when miller_rabin.Miller_Rabin_p(p);
      end loop;
      loop
         Prng.Random(q, Nb_Bits);
         LCD_Std_Out.Put(0, 56, "RSA: Finding q");
         bignum_mod(q, Two, Tmp);
         if bignum_is_zero(Tmp) = 1 then
            bignum_inc(q);
         end if;
         exit when miller_rabin.Miller_Rabin_p(q);
      end loop;
      LCD_Std_Out.Put(0, 70, "RSA: Computing priv.");
      bignum_mul(p, q, n);
      bignum_from_int(e, 65537);
      
   end Gen_RSA;

end rsa;
