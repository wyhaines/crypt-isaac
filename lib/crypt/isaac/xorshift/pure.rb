# frozen_string_literal: true

require 'english'

module Crypt
  # A pure Ruby micro-implementation. Use crypt-xorshift if you want
  # a complete implementation.
  class Xorshift64Star
    UINT32_C = 2**32
    UINT64_C = 2**64
    UINT64_Cf = UINT64_C.to_f

    @counter = 0
    class << self
      attr_accessor :counter
    end

    def initialize(seed = new_seed)
      @seed = nil
      srand(seed)
      @old_seed = seed
    end

    def new_seed
      n = Time.now
      Xorshift64Star.counter += 1
      [n.usec % 65_536,
       n.to_i % 65_536,
       $PROCESS_ID ^ 65_536,
       Xorshift64Star.counter % 65_536].collect { |x| x.to_s(16) }.join.to_i(16)
    end

    def srand(seed = new_seed)
      @old_seed = @seed
      @seed = seed % UINT64_C
    end

    def rand(num = 0)
      @seed ^= @seed >> 12
      @seed ^= @seed << 25
      @seed ^= @seed >> 27
      if num < 1
        ((@seed * 2_685_821_657_736_338_717) % UINT64_C) / UINT64_Cf
      else
        ((@seed * 2_685_821_657_736_338_717) % UINT64_C) % Integer(num)
      end
    end

    def seed
      @old_seed
    end

    def ==(other)
      self.class == other.class && @old_seed == other.seed
    end
  end
end
