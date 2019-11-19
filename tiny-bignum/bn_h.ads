pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with bits_stdint_uintn_h;
with Interfaces.C.Strings;

package bn_h is

   WORD_SIZE : constant := 1;  --  bn.h:29
   --  unsupported macro: BN_ARRAY_SIZE (128 / WORD_SIZE)
   --  unsupported macro: DTYPE uint8_t
   --  unsupported macro: DTYPE_MSB ((DTYPE_TMP)(0x80))
   --  unsupported macro: DTYPE_TMP uint32_t

   SPRINTF_FORMAT_STR : aliased constant String := "%.02x" & ASCII.NUL;  --  bn.h:48
   SSCANF_FORMAT_STR : aliased constant String := "%2hhx" & ASCII.NUL;  --  bn.h:49
   --  unsupported macro: MAX_VAL ((DTYPE_TMP)0xFF)
   --  unsupported macro: require(p,msg) assert(p && #msg)

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

  -- This macro defines the word size in bytes of the array that constitues the big-number data structure.  
  -- Size of big-numbers in bytes  
  -- Here comes the compile-time specialization for how large the underlying array size should be.  
  -- The choices are 1, 2 and 4 bytes in size with uint32, uint64 for WORD_SIZE==4, as temporary.  
  -- Data type of array in structure  
  -- bitmask for getting MSB  
  -- Data-type larger than DTYPE, for holding intermediate results of calculations  
  -- sprintf format string  
  -- Max value of integer type  
  -- Custom assert macro - easy to disable  
  -- Data-holding structure: array of DTYPEs  
   type anon887_c_array_array is array (0 .. 127) of aliased bits_stdint_uintn_h.uint8_t;
   type bn is record
      c_array : aliased anon887_c_array_array;  -- bn.h:79
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:77

  -- Tokens returned by bignum_cmp() for value comparison  
  -- Initialization functions:  
   procedure bignum_init (n : access bn)  -- bn.h:90
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_init";

   procedure bignum_from_int (n : access bn; i : bits_stdint_uintn_h.uint32_t)  -- bn.h:91
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_int";

   function bignum_to_int (n : access bn) return int  -- bn.h:92
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_int";

   procedure bignum_from_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      nbytes : int)  -- bn.h:93
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_string";

   procedure bignum_to_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      maxsize : int)  -- bn.h:94
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_string";

  -- Basic arithmetic operations:  
  -- c = a + b  
   procedure bignum_add
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:97
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_add";

  -- c = a - b  
   procedure bignum_sub
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:98
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_sub";

  -- c = a * b  
   procedure bignum_mul
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:99
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mul";

  -- c = a / b  
   procedure bignum_div
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:100
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_div";

  -- c = a % b  
   procedure bignum_mod
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:101
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mod";

  -- c = a/b, d = a%b  
   procedure bignum_divmod
     (a : access bn;
      b : access bn;
      c : access bn;
      d : access bn)  -- bn.h:102
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_divmod";

  -- Bitwise operations:  
  -- c = a & b  
   procedure bignum_and
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:105
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_and";

  -- c = a | b  
   procedure bignum_or
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:106
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_or";

  -- c = a ^ b  
   procedure bignum_xor
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:107
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_xor";

  -- b = a << nbits  
   procedure bignum_lshift
     (a : access bn;
      b : access bn;
      nbits : int)  -- bn.h:108
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_lshift";

  -- b = a >> nbits  
   procedure bignum_rshift
     (a : access bn;
      b : access bn;
      nbits : int)  -- bn.h:109
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_rshift";

  -- Special operators and comparison  
  -- Compare: returns LARGER, EQUAL or SMALLER  
   function bignum_cmp (a : access bn; b : access bn) return int  -- bn.h:112
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_cmp";

  -- For comparison with zero  
   function bignum_is_zero (n : access bn) return int  -- bn.h:113
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_is_zero";

  -- Increment: add one to n  
   procedure bignum_inc (n : access bn)  -- bn.h:114
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_inc";

  -- Decrement: subtract one from n  
   procedure bignum_dec (n : access bn)  -- bn.h:115
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_dec";

  -- Calculate a^b -- e.g. 2^10 => 1024  
   procedure bignum_pow
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:116
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_pow";

  -- Integer square root -- e.g. isqrt(5) => 2 
   procedure bignum_isqrt (a : access bn; b : access bn)  -- bn.h:117
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_isqrt";

  -- Copy src into dst -- dst := src  
   procedure bignum_assign (dst : access bn; src : access bn)  -- bn.h:118
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_assign";

end bn_h;
