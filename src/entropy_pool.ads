pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with bits_stdint_uintn_h;
with Interfaces.C.Strings;

package entropy_pool is

    type entropy_pool is private;

    protected type entropy_pool_obj is
    procedure init;
    procedure mix_pool (entropy : int);
    function credit_entropy (nb_bits : int) return int;
    function get_entropy_count return bits_stdint_uintn_h.uint32_t;
    function get_random return bits_stdint_uintn_h.uint8_t;
    function remaining_extracted return bits_stdint_uintn_h.uint8_t;

    private
    pool : access entropy_pool;

    end entropy_pool_obj;
   --  arg-macro: procedure likely (x)
   --    __builtin_expect(notnot(x), 1)
   --  arg-macro: procedure unlikely (x)
   --    __builtin_expect(notnot(x), 0)
   POOL_SIZE : constant := 64;  --  entropy_pool.h:19

   ENTROPY_SHIFT : constant := 3;  --  entropy_pool.h:53
   --  unsupported macro: MAX_ENTROPY (POOL_SIZE << (5 + ENTROPY_SHIFT))

   POOL_BIT_SHIFT : constant := (6 + 5);  --  entropy_pool.h:59
   --  arg-macro: function ENTROPY_COUNT (x)
   --    return (x) >> ENTROPY_SHIFT;

  --     *  Cryptographic PRNG
  --     *
  --     *  Based on linux random.c
  --     *  

   function rol32 (n : bits_stdint_uintn_h.uint32_t; nb : unsigned) return bits_stdint_uintn_h.uint32_t  -- entropy_pool.h:22
   with Import => True, 
        Convention => C, 
        External_Name => "rol32";

   type anon885_pool_array is array (0 .. 63) of aliased bits_stdint_uintn_h.uint32_t;
   type anon885_chacha20_state_array is array (0 .. 15) of aliased bits_stdint_uintn_h.uint32_t;
   type anon885_output_array is array (0 .. 1) of aliased bits_stdint_uintn_h.uint32_t;
   
   function entropy_estimator (x : int) return int  -- entropy_pool.h:66
   with Import => True, 
        Convention => C, 
        External_Name => "entropy_estimator";
   
private
   type entropy_pool is record
      pool : aliased anon885_pool_array;  -- entropy_pool.h:25
      entropy_count : aliased bits_stdint_uintn_h.uint32_t;  -- entropy_pool.h:26
      i : aliased bits_stdint_uintn_h.uint8_t;  -- entropy_pool.h:29
      rotate : aliased int;  -- entropy_pool.h:30
      j : aliased bits_stdint_uintn_h.uint8_t;  -- entropy_pool.h:33
      chacha20_state : aliased anon885_chacha20_state_array;  -- entropy_pool.h:34
      chacha20_init : aliased bits_stdint_uintn_h.uint8_t;  -- entropy_pool.h:35
      output : aliased anon885_output_array;  -- entropy_pool.h:36
      remaining_extracted : aliased bits_stdint_uintn_h.uint8_t;  -- entropy_pool.h:37
   end record
   with Convention => C_Pass_By_Copy;  -- entropy_pool.h:24

  -- Entropy mixing
  -- Where to put the created entropy. Init it to 0, and don't touch
  -- Number of rol32 rotation to perform
  -- Entropy extraction
  -- Where to get the last 16 bytes of entropy to XOR. Init it to 0, and don't touch
  -- Is chacha20_state initialized ?
  -- Contains (remaining_extracted) random bytes to be given to the user
   twist_table : aliased array (0 .. 7) of aliased bits_stdint_uintn_h.uint32_t  -- entropy_pool.h:40
   with Import => True, 
        Convention => C, 
        External_Name => "twist_table";

   taps : aliased array (0 .. 5) of aliased bits_stdint_uintn_h.uint32_t  -- entropy_pool.h:44
   with Import => True, 
        Convention => C, 
        External_Name => "taps";

  -- P(X) = X^128 + X^104 + X^76 + X^51 + X^25 + X + 1
  -- Q(X) = alpha^3 (P(X) - 1) + 1 with alpha^3 compute using twist_table
  -- Mix some entropy in the entropy pool
   procedure mix_pool (entropy : int; pool : access entropy_pool)  -- entropy_pool.h:50
   with Import => True, 
        Convention => C, 
        External_Name => "mix_pool";

  -- Allow us to take into account fractions of bits of entropy
  -- Maximum of entropy in the pool, taking account of partial bits of entropy.
  -- shift << 5 is for 32 (since there are 32 bits in a uint32_t
  -- log(POOL_SIZE) + 5
  -- Used for faster division by bitshift
  -- = {"EMPTY", "LOW", "MEDIUM", "FILLED", "FULL"};
   ENTROPY_POOL_COUNT_TXT : array (0 .. 15) of Interfaces.C.Strings.chars_ptr  -- entropy_pool.h:62
   with Import => True, 
        Convention => C, 
        External_Name => "ENTROPY_POOL_COUNT_TXT";

  -- Credit the entropy pool for a given amount of bits of entropy
   function credit_entropy (nb_bits : int; pool : access entropy_pool) return int  -- entropy_pool.h:64
   with Import => True, 
        Convention => C, 
        External_Name => "credit_entropy";

   

  -- Return the amount of bits of entropy in the pool
   function get_entropy_count (pool : access entropy_pool) return bits_stdint_uintn_h.uint32_t  -- entropy_pool.h:69
   with Import => True, 
        Convention => C, 
        External_Name => "get_entropy_count";

  -- Extract a random byte from the entropy pool. Does not check if the pool has
  -- enough entropy to do so, so be advised.
  -- When it needs to extract entropy from the pool, it requires 64 bits of entropy.
  -- One must assert (pool->remaining_extracted > 0 || pool->entropy_count >= 64) before calling get_random
   function get_random (pool : access entropy_pool) return bits_stdint_uintn_h.uint8_t  -- entropy_pool.h:77
   with Import => True, 
        Convention => C, 
        External_Name => "get_random";

end entropy_pool;
