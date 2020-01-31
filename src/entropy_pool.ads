with Interfaces.C; use Interfaces.C;
with bits_stdint_uintn_h; use bits_stdint_uintn_h;
with Interfaces.C.Strings;

-- *  Cryptographic PRNG
-- *
-- *  Based on linux random.c
-- *

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


function entropy_estimator (x : int) return int  -- bn.h:146
    with Import => True,
    Convention => C,
    External_Name => "entropy_estimator";

    private

    type anon908_pool_array is array (0 .. 63) of aliased bits_stdint_uintn_h.uint32_t;
    type anon908_chacha20_state_array is array (0 .. 15) of aliased bits_stdint_uintn_h.uint32_t;
    type anon908_output_array is array (0 .. 1) of aliased bits_stdint_uintn_h.uint32_t;

    type entropy_pool is record
        pool : aliased anon908_pool_array;  -- bn.h:105
        entropy_count : aliased bits_stdint_uintn_h.uint32_t := 0;  -- bn.h:106
        i : aliased bits_stdint_uintn_h.uint8_t := 0;  -- bn.h:109
        rotate : aliased int := 0;  -- bn.h:110
        j : aliased bits_stdint_uintn_h.uint8_t := 0;  -- bn.h:113
        chacha20_state : aliased anon908_chacha20_state_array;  -- bn.h:114
        chacha20_init : aliased bits_stdint_uintn_h.uint8_t;  -- bn.h:115
        output : aliased anon908_output_array;  -- bn.h:116
        remaining_extracted : aliased bits_stdint_uintn_h.uint8_t := 0;  -- bn.h:117

    end record
    with Convention => C_Pass_By_Copy;  -- bn.h:104

    -- P(X) = X^128 + X^104 + X^76 + X^51 + X^25 + X + 1
    -- Q(X) = alpha^3 (P(X) - 1) + 1 with alpha^3 compute using twist_table
    -- Mix some entropy in the entropy pool
    procedure mix_pool (entropy : int; pool : access entropy_pool)  -- bn.h:130
        with Import => True,
        Convention => C,
        External_Name => "mix_pool";

        -- Credit the entropy pool for a given amount of bits of entropy
        function credit_entropy (nb_bits : int; pool : access entropy_pool) return int  -- bn.h:144
            with Import => True,
            Convention => C,
            External_Name => "credit_entropy";

            -- Return the amount of bits of entropy in the pool
            function get_entropy_count (pool : access entropy_pool) return bits_stdint_uintn_h.uint32_t  -- bn.h:149
                with Import => True,
                Convention => C,
                External_Name => "get_entropy_count";

                -- Extract a random byte from the entropy pool. Does not check if the pool has
                -- enough entropy to do so, so be advised.
                -- When it needs to extract entropy from the pool, it requires 64 bits of entropy.
                -- One must assert (pool->remaining_extracted > 0 || pool->entropy_count >= 64) before calling get_random
                function get_random (pool : access entropy_pool) return bits_stdint_uintn_h.uint8_t  -- bn.h:157
                    with Import => True,
                    Convention => C,
                    External_Name => "get_random";

end entropy_pool;
