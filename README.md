# Crypt::Isaac

ISAAC is a cryptographically secure PRNG for generating high quality random numbers.  Detailed information about the algorithm can be found at:

http://burtleburtle.net/bob/rand/isaac.html

This is a pure Ruby implementation of the algorithm, but it is reasonably fast.

When originally written, running on Ruby 1.8.2 under a venerable 800Mhz PIII Linux system, it could do 15000 to 16000 numbers per second. On Ruby 2.2.3, running on a basic Digital Ocean VM, it can generate almost a million random integers or floats per second.

Ruby uses the Mersenne Twister as its PRNG, and while this algorithm is a fast PRNG that produces highly random numbers with good stastical properties, it is not cryptographically strong. ISAAC is very fast, also has good statistical properties, and is cryptographically strong.

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

rng = Crypt::ISAAC.new # New ISAAC object, seeded using /dev/urandom or /dev/random, if available.
rng = Crypt::ISAAC.new(17773845992) # New ISAAC object, seeded from a deterministic point.

r1 = rng.rand() # returns a floating point number between 0 and 1
r2 = rng.rand(10.57) # returns a floating point number between 0 and 10.57
r2 = rnd.rand(1000) # returns an integer between 0 and 999
r3 = rnd.rand(3..12) # returns an integer between 3 and 12
noise = rng.bytes(1024) # return a 1k string of random bytes
```

Crypt::ISAAC should provide the same API as the Ruby 2.2 version of Random.

Enjoy it.  Let me know if you find anything that can be improved or that
needs to be fixed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wyhaines/crypt-isaac. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

