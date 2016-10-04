# Crypt::Isaac

ISAAC is a cryptographically secure PRNG for generating high quality random numbers.  Detailed information about the algorithm can be found at:

http://burtleburtle.net/bob/rand/isaac.html

This library combines a pure Ruby implementation with a C implementation bound to ruby as an extension. The C extension implementation currently runs many times faster than the pure ruby implementation.

When originally written, running on Ruby 1.8.2 under a venerable 800Mhz PIII Linux system, it could do 15000 to 16000 numbers per second. On Ruby 2.3.1, testing via an Ubuntu shell session on a Windows 10 system running a 2.3Ghz Intel i5 processor, the library will generate over ten million floats per second, or almost nine million integers per second:

```
Benchmark integer prng generation
       user     system      total        real
   1.130000   0.000000   1.130000 (  1.138785)
10000000 numbers generated in 1.1393164 seconds; 8777193 per second

Benchmark float prng generation
       user     system      total        real
   0.950000   0.000000   0.950000 (  0.967220)
10000000 numbers generated in 0.967398 seconds; 10337007 per second
```

Ruby uses the Mersenne Twister as its PRNG. This algorithm is used by many languages because it is relatively fast, and has a long period. It, however, is not cryptographically strong; observing a window of as few as 624 generated values is enough to establish the state of the generator and to predict all future numbers. Nor is it well suited to Monte Carlo type simulations unless the seeds are quite different (generators with similar keys tend to produce number sequences that are the same for quite a long time before diverging), and the generators are ran for a while to ensure strong divergence.

ISAAC is very fast. This implementation is currently very comparable to Random's performance for both floats and for integers. ISAAC has strong statistical properties, like the Mersenne Twister, but it is also cryptographically strong, and different generators produce completely unique streams of numbers, even if seeded with similar seeds (though the seed size is substantial, so good seeding should make it difficult for two generators to be similarly seeded).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crypt-isaac'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crypt-isaac

## Usage

```ruby
require 'crypt/isaac'

rng = Crypt::ISAAC.new
```
ISAAC will seed itself, by default, using /dev/urandom, if the device exists on the system being used. This is the same as:

```ruby
rng = Crypt::ISAAC.new( true )
```

If one wants to use /dev/random instead (though there is really no reason to do so), pass false instead:

```ruby
rng = Crypt::ISAAC.new( false )
```

If /dev/urandom is not available, or nil is specifically passed, then Crypt::ISAAC will use Crypt::Xorshift, if it is installed, or a bundled microimplementation of Crypt::Xorshift64Star to generate a series of high quality pseudorandom numbers which will in turn be used to seed the ISAAC generator, as it produces better streams of numbers than the Mersenne Twister, in a very simple implementation.

```ruby
rng = Crypt::ISAAC.new( nil )
```

Finally, ISAAC may be seeded deterministically by passing an integer seed into it. Any ISAAC generator seeded with the same value will produce the same sequence of random numbers.

```ruby
rng = Crypt::ISAAC.new(17773845992) # New ISAAC object, seeded from a deterministic point.
```

TODO: One should be able to seed an ISAAC PRNG with an array of seed values, as well.

```ruby
r1 = rng.rand() # returns a floating point number between 0 and 1
r2 = rng.rand(10.57) # returns a floating point number between 0 and 10.57
r2 = rnd.rand(1000) # returns an integer between 0 and 999
r3 = rnd.rand(3..12) # returns an integer between 3 and 12
noise = rng.bytes(1024) # return a 1k string of random bytes
```

Crypt::ISAAC should provide the same API as the Ruby 2.2 version of Random.

This implementation returns 32 bit values. TODO is to add support for the 64 bit version of ISAAC.

Enjoy it.  Let me know if you find anything that can be improved or that
needs to be fixed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wyhaines/crypt-isaac. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

