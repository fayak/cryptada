pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with bits_stdint_uintn_h;
with bits_stdint_intn_h;
with Interfaces.C.Strings;

package bn_h is

   --  arg-macro: procedure likely (x)
   --    __builtin_expect(notnot(x), 1)
   --  arg-macro: procedure unlikely (x)
   --    __builtin_expect(notnot(x), 0)
   BN_ARRAY_SIZE : constant := 128;  --  bn.h:34
   STR_DEST_SIZE : constant := 256;  --  bn.h:35
   --  unsupported macro: require(p,msg) assert(p && #msg)

   BASE : constant := 256;  --  bn.h:39
   WORD_SIZE : constant := 8;  --  bn.h:40
   WORD_MASK : constant := 16#ff#;  --  bn.h:41

   KARATSUBA_MIN : constant := 6;  --  bn.h:44

   POOL_SIZE : constant := 64;  --  bn.h:99

   ENTROPY_SHIFT : constant := 3;  --  bn.h:133
   --  unsupported macro: MAX_ENTROPY (POOL_SIZE << (5 + ENTROPY_SHIFT))

   POOL_BIT_SHIFT : constant := (6 + 5);  --  bn.h:139
   --  arg-macro: function ENTROPY_COUNT (x)
   --    return (x) >> ENTROPY_SHIFT;

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

  -- MUST BE % 4 !
  -- Custom assert macro - easy to disable  
  --static uint8_t KARATSUBA_MIN = 6;
  -- Data-holding structure: array of DTYPEs  
   type anon887_c_array_array is array (0 .. 127) of aliased bits_stdint_uintn_h.uint8_t;
   type bn is record
      c_array : aliased anon887_c_array_array;  -- bn.h:49
      size : aliased bits_stdint_uintn_h.uint32_t;  -- bn.h:50
      neg : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:51
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:47

  -- Tokens returned by bignum_cmp() for value comparison  
  -- Initialization functions:  
   procedure bignum_init (n : access bn)  -- bn.h:58
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_init";

   procedure bignum_from_int (n : access bn; i : bits_stdint_intn_h.int32_t)  -- bn.h:59
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_int";

   function bignum_to_int (n : access bn) return int  -- bn.h:60
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_int";

   procedure bignum_from_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      nbytes : bits_stdint_uintn_h.uint32_t)  -- bn.h:61
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_string";

   procedure bignum_to_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      maxsize : bits_stdint_uintn_h.uint32_t)  -- bn.h:62
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_string";

  -- Basic arithmetic operations:  
  -- c = a + b  
   procedure bignum_add
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:65
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_add";

  -- c = a - b  
   procedure bignum_sub
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:66
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_sub";

  -- c = a * b  
   procedure bignum_mul
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:67
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mul";

  -- c = a / b  
   procedure bignum_div
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:68
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_div";

  -- c = a % b  
   procedure bignum_mod
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:69
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mod";

  --    void bignum_divmod(struct bn* a, struct bn* b, struct bn* c, struct bn* d); /* c = a/b, d = a%b  
   procedure bignum_powmod
     (a : access bn;
      b : access bn;
      n : access bn;
      res : access bn)  -- bn.h:71
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_powmod";

  --    /* Bitwise operations:  
  -- c = a & b  
   procedure bignum_and
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:74
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_and";

  -- c = a | b  
   procedure bignum_or
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:75
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_or";

  -- c = a ^ b  
   procedure bignum_xor
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:76
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_xor";

  -- b = a << nbits  
   procedure bignum_lshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:77
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_lshift";

  -- b = a >> nbits  
   procedure bignum_rshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:78
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_rshift";

  --    /* Special operators and comparison  
  -- Compare: returns LARGER, EQUAL or SMALLER  
   function bignum_cmp (a : access bn; b : access bn) return int  -- bn.h:81
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_cmp";

  -- For comparison with zero  
   function bignum_is_zero (n : access bn) return int  -- bn.h:82
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_is_zero";

  -- Increment: add one to n  
   procedure bignum_inc (n : access bn)  -- bn.h:83
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_inc";

  -- Decrement: subtract one from n  
   procedure bignum_dec (n : access bn)  -- bn.h:84
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_dec";

  -- Calculate a^b -- e.g. 2^10 => 1024  
   procedure bignum_pow
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:85
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_pow";

  --    void bignum_isqrt(struct bn* a, struct bn* b);             /* Integer square root -- e.g. isqrt(5) => 2 
  -- Copy src into dst -- dst := src  
   procedure bignum_assign (dst : access bn; src : access bn)  -- bn.h:87
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_assign";

   function bignum_nb_bits (n : access bn) return bits_stdint_uintn_h.uint32_t  -- bn.h:90
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_nb_bits";


end bn_h;
