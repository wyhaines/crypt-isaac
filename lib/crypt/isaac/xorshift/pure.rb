# A pure Ruby micro-implementation. Use crypt-xorshift if you want a complete implementation.

module Crypt
  class Xorshift64Star

    UINT32_C = 2**32
    UINT64_C = 2**64
    UINT64_Cf = UINT64_C.to_f

    def initialize( seed = new_seed )
      srand( seed )
      @old_seed = @seed
    end

    def new_seed
      n = Time.now
      @@counter ||= 0
      @@counter += 1
      [n.usec % 65536, n.to_i % 65536, $$ ^ 65536, @@counter % 65536 ].collect {|x| x.to_s(16)}.join.to_i(16)
    end

    def srand( seed = new_seed )
      @old_seed = @seed
      @seed = seed % UINT64_C
    end

    def rand( n = 0)
      @seed ^= @seed >> 12
      @seed ^= @seed << 25
      @seed ^= @seed >> 27
      if n < 1
        ( ( @seed * 2685821657736338717 ) % UINT64_C ) / UINT64_Cf
      else
        ( ( @seed * 2685821657736338717 ) % UINT64_C ) % Integer( n )
      end
    end

    def seed
      @old_seed
    end

    def ==(v)
      self.class == v.class && @old_seed == v.seed
    end

  end
end
