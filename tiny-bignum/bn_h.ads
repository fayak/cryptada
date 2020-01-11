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
   BN_ARRAY_SIZE : constant := 128;  --  bn.h:30
   STR_DEST_SIZE : constant := 128;  --  bn.h:31
   --  unsupported macro: require(p,msg) assert(p && #msg)

   BASE : constant := 256;  --  bn.h:35
   WORD_SIZE : constant := 8;  --  bn.h:36
   WORD_MASK : constant := 16#ff#;  --  bn.h:37

   POOL_SIZE : constant := 64;  --  bn.h:91

   ENTROPY_SHIFT : constant := 3;  --  bn.h:125
   --  unsupported macro: MAX_ENTROPY (POOL_SIZE << (5 + ENTROPY_SHIFT))

   POOL_BIT_SHIFT : constant := (6 + 5);  --  bn.h:131
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

  -- Custom assert macro - easy to disable  
  -- Data-holding structure: array of DTYPEs  
   type anon887_c_array_array is array (0 .. 127) of aliased bits_stdint_uintn_h.uint8_t;
   type bn is record
      c_array : aliased anon887_c_array_array;  -- bn.h:42
      size : aliased bits_stdint_uintn_h.uint32_t;  -- bn.h:43
      neg : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:44
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:40

  -- Tokens returned by bignum_cmp() for value comparison  
  -- Initialization functions:  
   procedure bignum_init (n : access bn)  -- bn.h:51
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_init";

   procedure bignum_from_int (n : access bn; i : bits_stdint_intn_h.int32_t)  -- bn.h:52
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_int";

   function bignum_to_int (n : access bn) return int  -- bn.h:53
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_int";

   procedure bignum_from_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      nbytes : bits_stdint_uintn_h.uint32_t)  -- bn.h:54
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_from_string";

   procedure bignum_to_string
     (n : access bn;
      str : Interfaces.C.Strings.chars_ptr;
      maxsize : bits_stdint_uintn_h.uint32_t)  -- bn.h:55
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_to_string";

  -- Basic arithmetic operations:  
  -- c = a + b  
   procedure bignum_add
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:58
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_add";

  -- c = a - b  
   procedure bignum_sub
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:59
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_sub";

  -- c = a * b  
   procedure bignum_mul
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:60
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mul";

  -- c = a / b  
   procedure bignum_div
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:61
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_div";

  -- c = a % b  
   procedure bignum_mod
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:62
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_mod";

  --    void bignum_divmod(struct bn* a, struct bn* b, struct bn* c, struct bn* d); /* c = a/b, d = a%b  
   procedure bignum_powmod
     (a : access bn;
      b : access bn;
      n : access bn;
      res : access bn)  -- bn.h:64
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_powmod";

  --    /* Bitwise operations:  
  -- c = a & b  
   procedure bignum_and
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:67
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_and";

  -- c = a | b  
   procedure bignum_or
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:68
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_or";

  -- c = a ^ b  
   procedure bignum_xor
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:69
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_xor";

  -- b = a << nbits  
   procedure bignum_lshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:70
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_lshift";

  -- b = a >> nbits  
   procedure bignum_rshift
     (a : access bn;
      b : access bn;
      nbits : bits_stdint_uintn_h.uint32_t)  -- bn.h:71
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_rshift";

  --    /* Special operators and comparison  
  -- Compare: returns LARGER, EQUAL or SMALLER  
   function bignum_cmp (a : access bn; b : access bn) return int  -- bn.h:74
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_cmp";

  -- For comparison with zero  
   function bignum_is_zero (n : access bn) return int  -- bn.h:75
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_is_zero";

  -- Increment: add one to n  
   procedure bignum_inc (n : access bn)  -- bn.h:76
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_inc";

  -- Decrement: subtract one from n  
   procedure bignum_dec (n : access bn)  -- bn.h:77
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_dec";

  -- Calculate a^b -- e.g. 2^10 => 1024  
   procedure bignum_pow
     (a : access bn;
      b : access bn;
      c : access bn)  -- bn.h:78
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_pow";

  --    void bignum_isqrt(struct bn* a, struct bn* b);             /* Integer square root -- e.g. isqrt(5) => 2 
  -- Copy src into dst -- dst := src  
   procedure bignum_assign (dst : access bn; src : access bn)  -- bn.h:80
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_assign";

   function bignum_nb_bits (n : access bn) return bits_stdint_uintn_h.uint32_t  -- bn.h:82
   with Import => True, 
        Convention => C, 
        External_Name => "bignum_nb_bits";

  -- *  Cryptographic PRNG
  -- *
  -- *  Based on linux random.c
  -- *  

   function rol32 (n : bits_stdint_uintn_h.uint32_t; nb : unsigned) return bits_stdint_uintn_h.uint32_t  -- bn.h:94
   with Import => True, 
        Convention => C, 
        External_Name => "rol32";

   type anon908_pool_array is array (0 .. 63) of aliased bits_stdint_uintn_h.uint32_t;
   type anon908_chacha20_state_array is array (0 .. 15) of aliased bits_stdint_uintn_h.uint32_t;
   type anon908_output_array is array (0 .. 1) of aliased bits_stdint_uintn_h.uint32_t;
   type entropy_pool is record
      pool : aliased anon908_pool_array;  -- bn.h:97
      entropy_count : aliased bits_stdint_uintn_h.uint32_t;  -- bn.h:98
      i : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:101
      rotate : aliased int;  -- bn.h:102
      j : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:105
      chacha20_state : aliased anon908_chacha20_state_array;  -- bn.h:106
      chacha20_init : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:107
      output : aliased anon908_output_array;  -- bn.h:108
      remaining_extracted : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:109
   end record
   with Convention => C_Pass_By_Copy;  -- bn.h:96

  -- Entropy mixing
  -- Where to put the created entropy. Init it to 0, and don't touch
  -- Number of rol32 rotation to perform
  -- Entropy extraction
  -- Where to get the last 16 bytes of entropy to XOR. Init it to 0, and don't touch
  -- Is chacha20_state initialized ?
  -- Contains (remaining_extracted) random bytes to be given to the user
   twist_table : aliased array (0 .. 7) of aliased bits_stdint_uintn_h.uint32_t  -- bn.h:112
   with Import => True, 
        Convention => C, 
        External_Name => "twist_table";

   taps : aliased array (0 .. 5) of aliased bits_stdint_uintn_h.uint32_t  -- bn.h:116
   with Import => True, 
        Convention => C, 
        External_Name => "taps";

  -- P(X) = X^128 + X^104 + X^76 + X^51 + X^25 + X + 1
  -- Q(X) = alpha^3 (P(X) - 1) + 1 with alpha^3 compute using twist_table
  -- Mix some entropy in the entropy pool
   procedure mix_pool (entropy : int; pool : access entropy_pool)  -- bn.h:122
   with Import => True, 
        Convention => C, 
        External_Name => "mix_pool";

  -- Allow us to take into account fractions of bits of entropy
  -- Maximum of entropy in the pool, taking account of partial bits of entropy.
  -- shift << 5 is for 32 (since there are 32 bits in a uint32_t
  -- log(POOL_SIZE) + 5
  -- Used for faster division by bitshift
  -- = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};
   ENTROPY_POOL_COUNT_TXT : array (0 .. 15) of Interfaces.C.Strings.chars_ptr  -- bn.h:134
   with Import => True, 
        Convention => C, 
        External_Name => "ENTROPY_POOL_COUNT_TXT";

  -- Credit the entropy pool for a given amount of bits of entropy
   function credit_entropy (nb_bits : int; pool : access entropy_pool) return int  -- bn.h:136
   with Import => True, 
        Convention => C, 
        External_Name => "credit_entropy";

   function entropy_estimator (x : int) return int  -- bn.h:138
   with Import => True, 
        Convention => C, 
        External_Name => "entropy_estimator";

  -- Return the amount of bits of entropy in the pool
   function get_entropy_count (pool : access entropy_pool) return bits_stdint_uintn_h.uint32_t  -- bn.h:141
   with Import => True, 
        Convention => C, 
        External_Name => "get_entropy_count";

  -- Extract a random byte from the entropy pool. Does not check if the pool has
  -- enough entropy to do so, so be advised.
  -- When it needs to extract entropy from the pool, it requires 64 bits of entropy.
  -- One must assert (pool->remaining_extracted > 0 || pool->entropy_count >= 64) before calling get_random
   function get_random (pool : access entropy_pool) return bits_stdint_uintn_h.uint8_t  -- bn.h:149
   with Import => True, 
        Convention => C, 
        External_Name => "get_random";

end bn_h;
