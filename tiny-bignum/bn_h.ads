pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with bits_stdint_uintn_h;
with bits_stdint_intn_h;
with Interfaces.C.Strings;

package bn_h is

   BN_ARRAY_SIZE : constant := 64;  --  bn.h:27
   STR_DEST_SIZE : constant := 32;  --  bn.h:28
   --  unsupported macro: require(p,msg) assert(p && #msg)

   BASE : constant := 256;  --  bn.h:32
   WORD_SIZE : constant := 8;  --  bn.h:33
   WORD_MASK : constant := 16#ff#;  --  bn.h:34

   POOL_SIZE : constant := 64;  --  bn.h:88

   ENTROPY_SHIFT : constant := 3;  --  bn.h:113
   --  arg-macro: function ENTROPY_BITS (r)
   --    return (r) >> ENTROPY_SHIFT;
   --  unsupported macro: MAX_ENTROPY (POOL_SIZE * 8)

   POOL_BIT_SHIFT : constant := (6 + 2);  --  bn.h:118

  --Big number library - arithmetic on multiple-precision unsigned integers.
  --This library is an implementation of arithmetic on arbitrarily large integers.
  --The difference between this and other implementations, is that the data structure
  --has optimal memory utilization (i.e. a 1024 bit integer takes up 128 bytes RAM),
  --and all memory is allocated statically: no dynamic allocation for better or worse.
  --Primary goals are correctness, clarity of code and clean, portable implementation.
  --Secondary goal is a memory footprint small enough to make it suitable for use in
  --embedded applications.
  --The current state is correct functionality and adequate performance.
  --There may well be room for performance-optimizations and improvements.
  -- 

  -- Custom assert macro - easy to disable  
  -- Data-holding structure: array of DTYPEs  
   type anon887_c_array_array is array (0 .. 63) of aliased bits_stdint_uintn_h.uint8_t;
   type bn is record
      c_array : aliased anon887_c_array_array;  -- bn.h:39
      size : aliased bits_stdint_uintn_h.uint32_t;  -- bn.h:40
      neg : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:41
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:37

  -- Tokens returned by bignum_cmp() for value comparison  
  -- Initialization functions:  
   procedure bignum_init (n : access bn)  -- bn.h:48
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_init";

   procedure bignum_from_int (n : access bn; i : bits_stdint_intn_h.int32_t)  -- bn.h:49
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_int";

   function bignum_to_int (n : access bn) return int  -- bn.h:50
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_int";

   procedure bignum_from_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      nbytes : bits_stdint_uintn_h.uint32_t)  -- bn.h:51
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_string";

   procedure bignum_to_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      maxsize : bits_stdint_uintn_h.uint32_t)  -- bn.h:52
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_string";

  -- Basic arithmetic operations:  
  -- c = a + b  
   procedure bignum_add
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:55
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_add";

  -- c = a - b  
   procedure bignum_sub
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:56
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_sub";

  -- c = a * b  
   procedure bignum_mul
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:57
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mul";

  -- c = a / b  
   procedure bignum_div
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:58
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_div";

  -- c = a % b  
   procedure bignum_mod
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:59
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mod";

  --    void bignum_divmod(struct bn* a, struct bn* b, struct bn* c, struct bn* d); /* c = a/b, d = a%b  
   procedure bignum_powmod
     (a : access bn;
      b : access bn;
      n : access bn;
      res : access bn)  -- bn.h:61
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_powmod";

  --    /* Bitwise operations:  
  -- c = a & b  
   procedure bignum_and
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:64
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_and";

  -- c = a | b  
   procedure bignum_or
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:65
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_or";

  -- c = a ^ b  
   procedure bignum_xor
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:66
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_xor";

  -- b = a << nbits  
   procedure bignum_lshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:67
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_lshift";

  -- b = a >> nbits  
   procedure bignum_rshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:68
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_rshift";

  --    /* Special operators and comparison  
  -- Compare: returns LARGER, EQUAL or SMALLER  
   function bignum_cmp (a : access bn; b : access bn) return int  -- bn.h:71
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_cmp";

  -- For comparison with zero  
   function bignum_is_zero (n : access bn) return int  -- bn.h:72
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_is_zero";

  -- Increment: add one to n  
   procedure bignum_inc (n : access bn)  -- bn.h:73
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_inc";

  -- Decrement: subtract one from n  
   procedure bignum_dec (n : access bn)  -- bn.h:74
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_dec";

  -- Calculate a^b -- e.g. 2^10 => 1024  
   procedure bignum_pow
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:75
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_pow";

  --    void bignum_isqrt(struct bn* a, struct bn* b);             /* Integer square root -- e.g. isqrt(5) => 2 
  -- Copy src into dst -- dst := src  
   procedure bignum_assign (dst : access bn; src : access bn)  -- bn.h:77
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_assign";

   function bignum_nb_bits (n : access bn) return bits_stdint_uintn_h.uint32_t  -- bn.h:79
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_nb_bits";

  -- *  Cryptographic PRNG
  -- *
  -- *  Based on linux random.c
  -- *  

   function rol32 (n : bits_stdint_uintn_h.uint32_t; nb : unsigned) return bits_stdint_uintn_h.uint32_t  -- bn.h:91
   with Import => True, 
        Convention => C, 
        External_Name => "rol32";

   type anon908_pool_array is array (0 .. 63) of aliased bits_stdint_uintn_h.uint32_t;
   type entropy_pool is record
      pool : aliased anon908_pool_array;  -- bn.h:94
      i : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:95
      rotate : aliased int;  -- bn.h:96
      entropy_count : aliased bits_stdint_uintn_h.uint32_t;  -- bn.h:97
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:93

   twist_table : aliased array (0 .. 7) of aliased bits_stdint_uintn_h.uint32_t  -- bn.h:100
   with Import => True, 
        Convention => C, 
        External_Name => "twist_table";

   taps : aliased array (0 .. 5) of aliased bits_stdint_uintn_h.uint32_t  -- bn.h:104
   with Import => True, 
        Convention => C, 
        External_Name => "taps";

  -- P(X) = X^128 + X^104 + X^76 + X^51 + X^25 + X + 1
  -- Q(X) = alpha^3 (P(X) - 1) + 1 with alpha^3 compute using twist_table
  -- Mix some entropy in the entropy pool
   procedure mix_pool (entropy : int; pool : access entropy_pool)  -- bn.h:110
   with Import => True, 
        Convention => C, 
        External_Name => "mix_pool";

  -- log(POOL_SIZE) + 2
  -- Used for faster division by bitshift
  -- = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};
   ENTROPY_POOL_COUNT_TXT : array (0 .. 15) of Interfaces.C.Strings.chars_ptr  -- bn.h:121
   with Import => True, 
        Convention => C, 
        External_Name => "ENTROPY_POOL_COUNT_TXT";

  -- Credit the entropy pool for a given amount of bits of entropy
   function credit_entropy (nb_bits : int; pool : access entropy_pool) return int  -- bn.h:123
   with Import => True, 
        Convention => C, 
        External_Name => "credit_entropy";

   function entropy_estimator (x : int) return int  -- bn.h:125
   with Import => True, 
        Convention => C, 
        External_Name => "entropy_estimator";

end bn_h;
