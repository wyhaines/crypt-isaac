module Crypt

  # ISAAC is a fast, cryptographically secure pseudo-random number generator.
  # Details on the algorithm can be found here:
  # http://burtleburtle.net/bob/rand/isaac.html
  # This provides a consistent and capable algorithm for producing
  # independent streams of quality random numbers.

  class ISAAC

    attr_accessor :randrsl, :randcnt
    attr_accessor :mm, :aa, :bb, :cc

    # When a Crypt::ISAAC object is created, it needs to be seeded for
    # random number generation.  If the system has a /dev/urandom file,
    # that will be used to do the seeding by default.  If false is explictly
    # passed when creating the object, it will instead use /dev/random to
    # generate its seeds.  Be warned that this may make for SLOW
    # initialization - if there isn't enough entropy in the system, reads from
    # /dev/random will block while waiting for more entropy, causing
    # initialization to wait, as well.
    # If the requested source (/dev/urandom or /dev/random) do not exist,
    # the system will fall back to a simplistic initialization mechanism
    # using a pseudo-random number generator. By default, it will use an
    # xorshift* generator, but anything that responds to #rand can be passed
    # as a seed.

    def initialize(seed = true)
      @mm = []

      self.srand( seed )
    end

    # If seeded with an integer, use that to seed a standard Ruby Mersenne Twister
    # PRNG, and then use that to generate seed value for ISAAC. This is mostly useful
    # for producing repeated, deterministic results, which may be needed for testing.
    def srand(seed = true)
      rnd_source = nil
      rnd_source = seed ? '/dev/urandom' : '/dev/random' if ( ( seed == true ) || ( seed == false ) )
      if rnd_source && ( FileTest.exist? rnd_source )
        @randrsl = []
        File.open( rnd_source, 'r' ) do |r|
          256.times do |t|
            z = r.read(4)
            x = z.unpack('V')[0]
            @randrsl[t] = x
          end
        end
        randinit( true )
      else
        seed = nil if rnd_source

        @randrsl = []
        if seed.respond_to?( :rand )
          seed_prng = seed
        else
          seed_prng = Crypt::Xorshift64Star.new( seed )
        end

        256.times do |t|
          @randrsl[t] = seed_prng.rand(4294967296)
        end
        randinit(true)
      end
    end

    # Works just like the standard rand() function.  If called with an
    # integer argument, rand() will return positive random number in
    # the range of 0 to (argument - 1).  If called without an integer
    # argument, rand() returns a positive floating point number less than 1.
    # If called with a Range, returns a number that is in the range.

    def rand(arg = nil)
      if (@randcnt == 1)
        isaac
        @randcnt = 256
      end
      @randcnt -= 1
      if arg.nil?
        ( @randrsl[@randcnt] / 536870912.0 ) % 1
      elsif Integer === arg || Float === arg
        @randrsl[@randcnt] % arg
      elsif Range === arg
        arg.min + @randrsl[@randcnt] % (arg.max - arg.min)
      else
        @randrsl[@randcnt] % Integer(arg)
      end
    end

    def seed
      @seed.respond_to?(:seed) ? @seed.seed : @seed
    end

    def state
      @randrsl + [@randcnt]
    end

    def ==(gen)
      self.state == gen.state
    end

    def bytes(size)
      buffer = ""
      ( size / 4 ).times { buffer << [rand(4294967295)].pack("L").unpack("aaaa").join }

      if size % 4 != 0
        buffer << [rand(4294967295)].pack("L").unpack("aaaa")[0..(size % 4 - 1)].join
      end

      buffer
    end

    def isaac
      i = 0
      x = 0
      y = 0

      @cc += 1
      @bb += @cc
      @bb & 0xffffffff

      while (i < 256) do
        x = @mm[i]
        @aa = (@mm[(i + 128) & 255] + (@aa^(@aa << 13)) ) & 0xffffffff
        @mm[i] = y = (@mm[(x>>2)&255] + @aa + @bb ) & 0xffffffff
        @randrsl[i] = @bb = (@mm[(y>>10)&255] + x ) & 0xffffffff
        i += 1

        x = @mm[i]
        @aa = (@mm[(i+128)&255] + (@aa^(0x03ffffff & (@aa >> 6))) ) & 0xffffffff
        @mm[i] = y = (@mm[(x>>2)&255] + @aa + @bb ) & 0xffffffff
        @randrsl[i] = @bb = (@mm[(y>>10)&255] + x ) & 0xffffffff
        i += 1

        x = @mm[i]
        @aa = (@mm[(i + 128)&255] + (@aa^(@aa << 2)) ) & 0xffffffff
        @mm[i] = y = (@mm[(x>>2)&255] + @aa + @bb ) & 0xffffffff
        @randrsl[i] = @bb = (@mm[(y>>10)&255] + x ) & 0xffffffff
        i += 1

        x = @mm[i]
        @aa = (@mm[(i+128)&255] + (@aa^(0x0000ffff & (@aa >> 16))) ) & 0xffffffff
        @mm[i] = y = (@mm[(x>>2)&255] + @aa + @bb ) & 0xffffffff
        @randrsl[i] = @bb = (@mm[(y>>10)&255] + x ) & 0xffffffff
        i += 1
      end
    end

    def randinit(flag)
      i = 0
      a = 0
      b = 0
      c = 0
      d = 0
      e = 0
      f = 0
      g = 0
      @aa = @bb = @cc = 0
      a = b = c = d = e = f = g = h = 0x9e3779b9

      while (i < 4) do
        a ^= b<<1; d += a; b += c
        b ^= 0x3fffffff & (c>>2); e += b; c += d
        c ^= d << 8; f += c; d += e
        d ^= 0x0000ffff & (e >> 16); g += d; e += f
        e ^= f << 10; h += e; f += g
        f ^= 0x0fffffff & (g >> 4); a += f; g += h
        g ^= h << 8; b += g; h += a
        h ^= 0x007fffff & (a >> 9); c += h; a += b
        i += 1
      end

      i = 0
      while (i < 256) do
        if (flag)
          a+=@randrsl[i  ].to_i; b+=@randrsl[i+1].to_i;
          c+=@randrsl[i+2]; d+=@randrsl[i+3];
          e+=@randrsl[i+4]; f+=@randrsl[i+5];
          g+=@randrsl[i+6]; h+=@randrsl[i+7];
        end

        a^=b<<11; d+=a; b+=c;
        b^=0x3fffffff & (c>>2);  e+=b; c+=d;
        c^=d<<8;  f+=c; d+=e;
        d^=0x0000ffff & (e>>16); g+=d; e+=f;
        e^=f<<10; h+=e; f+=g;
        f^=0x0fffffff & (g>>4);  a+=f; g+=h;
        g^=h<<8;  b+=g; h+=a;
        h^=0x007fffff & (a>>9);  c+=h; a+=b;
        @mm[i]=a;@mm[i+1]=b; @mm[i+2]=c; @mm[i+3]=d;
        @mm[i+4]=e; @mm[i+5]=f; @mm[i+6]=g; @mm[i+7]=h;
        i += 8
      end

      if flag
        i = 0
        while (i < 256)
          a+=@mm[i  ]; b+=@mm[i+1]; c+=@mm[i+2]; d+=@mm[i+3];
          e+=@mm[i+4]; f+=@mm[i+5]; g+=@mm[i+6]; h+=@mm[i+7];
          a^=b<<11; d+=a; b+=c;
          b^=0x3fffffff & (c>>2);  e+=b; c+=d;
          c^=d<<8;  f+=c; d+=e;
          d^=0x0000ffff & (e>>16); g+=d; e+=f;
          e^=f<<10; h+=e; f+=g;
          f^=0x0fffffff & (g>>4);  a+=f; g+=h;
          g^=h<<8;  b+=g; h+=a;
          h^=0x007fffff & (a>>9);  c+=h; a+=b;
          @mm[i  ]=a; @mm[i+1]=b; @mm[i+2]=c; @mm[i+3]=d;
          @mm[i+4]=e; @mm[i+5]=f; @mm[i+6]=g; @mm[i+7]=h;
          i += 8
        end
      end

      isaac()
      @randcnt=256;        # /* prepare to use the first set of results */
    end
  end
end