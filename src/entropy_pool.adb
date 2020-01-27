package body entropy_pool is
   protected body entropy_pool_obj is

      procedure init is
      begin
         pool := new entropy_pool;
         pool.i := 0;
         pool.j := 0;
         pool.rotate := 0;
         pool.entropy_count := 0;
      end init;

      procedure mix_pool (entropy : int) is
      begin
         mix_pool(pool => pool, entropy => entropy);
      end mix_pool;

      function credit_entropy (nb_bits : int) return int is
      begin
         return credit_entropy(pool => pool, nb_bits => nb_bits);
      end credit_entropy;

      function get_entropy_count return bits_stdint_uintn_h.uint32_t is
      begin
         return get_entropy_count(pool => pool);
      end get_entropy_count;

      function get_random return bits_stdint_uintn_h.uint8_t is
      begin
         return get_random(pool => pool);
      end get_random;

      function remaining_extracted return bits_stdint_uintn_h.uint8_t is
      begin
         return pool.remaining_extracted;
      end;

   end entropy_pool_obj;
end entropy_pool;
