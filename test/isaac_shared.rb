require 'test_isaac_helper'
require 'benchmark'

describe Crypt::ISAAC::DEFAULT do
  it "Crypt::ISAAC::DEFAULT.srand and Crypt::ISAAC::DEFAULT.rand" do
    comparison_depth = 10000
    old_seed = Crypt::ISAAC::DEFAULT.srand
    old_seed.length.must_equal 256

    random_seed = ::Random.rand( 4294967296 )

    Crypt::ISAAC::DEFAULT.srand( random_seed )
    series_a = []
    comparison_depth.times { series_a << Crypt::ISAAC::DEFAULT.rand }

    Crypt::ISAAC::DEFAULT.srand( random_seed )
    series_b = []
    comparison_depth.times { series_b << Crypt::ISAAC::DEFAULT.rand }

    ( series_a == series_b ).must_equal true


    random_array_seed = []
    256.times { random_array_seed << ::Random.rand( 4294967296 ) }
    
    Crypt::ISAAC::DEFAULT.srand( random_array_seed )
    series_a = []
    comparison_depth.times { series_a << Crypt::ISAAC::DEFAULT.rand }

    Crypt::ISAAC::DEFAULT.srand( random_array_seed )
    series_b = []
    comparison_depth.times { series_b << Crypt::ISAAC::DEFAULT.rand }

    ( series_a == series_b ).must_equal true
  end

end

describe Crypt::ISAAC do
  before do
    GC.start
    @generator = Crypt::ISAAC.new
  end

  it "Crypt::ISAAC.new_seed" do
    new_seed = Crypt::ISAAC.new_seed

    new_seed.length.must_equal 256
    new_seed.each { |s| s.must_be_kind_of Integer }
  end

  it "generates integers when called with an integer argument" do
    mynum = @generator.rand(1000000)
    mynum.must_be_kind_of Integer
    mynum.must_be :>, 0
    mynum.must_be :<, 1000000
  end

  it "the default generator exists, and it works" do
    mynum = Crypt::ISAAC.rand(1000000)
    mynum.must_be_kind_of Integer
    mynum.must_be :>, 0
    mynum.must_be :<, 1000000
  end

  it "generates floats when called with no argument" do
    mynum = @generator.rand()
    mynum.must_be_kind_of Float
    mynum.must_be :>=, 0
    mynum.must_be :<, 1
  end

  it "generates integers even when called with a float argument" do
    mynum = @generator.rand(10.0)
    mynum.must_be_kind_of Integer
    mynum.must_be :>=, 0
    mynum.must_be :<, 10
  end

  it "generates random numbers in the proscribed range when called with a range argument" do
    mynum = @generator.rand(3..12)
    mynum.must_be_kind_of Integer
    mynum.must_be :>=, 3
    mynum.must_be :<, 12
  end

  it "generates sequences of random bytes" do
    buffer = @generator.bytes(64)
    buffer.length.must_equal 64
    buffer = @generator.bytes(67)
    buffer.length.must_equal 67
    buffer = @generator.bytes(2)
    buffer.length.must_equal 2
  end

  it "performs as expected when generating a large quantity of numbers" do
    count = 0
    x = nil
    puts "\n"
    100000.times do
      count += 1
      x = @generator.rand(4294967295)
      print [x].pack('V').unpack('H8') if count % 1000 == 0
      if (count % 7000) == 0
        print "\n"
      else
        print " " if count % 1000 == 0
      end
    end
    puts "\n"
  end

  it "multiple discrete number streams can be separately generated" do
    first_generator = Crypt::ISAAC.new
    second_generator = Crypt::ISAAC.new
    first_generator.wont_be_same_as second_generator
    series_a = []
    series_b = []
    1000.times do
      series_a << first_generator.rand(4294967295)
      series_b << second_generator.rand(4294967295)
    end

    ( series_a == series_b ).must_equal false  
  end

  it "seeding works correctly" do
    first_generator = Crypt::ISAAC.new(123)
    second_generator = Crypt::ISAAC.new(123)

    ( first_generator == second_generator ).must_equal true

    10.times { first_generator.rand.must_equal second_generator.rand }

    first_generator.seed.must_equal second_generator.seed

    first_generator = Crypt::ISAAC.new(123)
    second_generator = Crypt::ISAAC.new(124)

    ( first_generator == second_generator ).must_equal false
  end

  it "benchmark" do
    puts "\nBenchmark integer prng generation"
    start = Time.now
    Benchmark.bm {|bm| bm.report { 1000000.times { @generator.rand(4294967295) } } }
    finish = Time.now
    puts "1000000 numbers generated in #{(finish - start)} seconds; #{1000000 / (finish - start)} per second"

    puts "\nBenchmark float prng generation"
    start = Time.now
    Benchmark.bm {|bm| bm.report { 1000000.times { @generator.rand } } }
    finish = Time.now
    puts "1000000 numbers generated in #{(finish - start)} seconds; #{1000000 / (finish - start)} per second\n"

    puts "\nBenchmark ranged prng generation"
    start = Time.now
    Benchmark.bm {|bm| bm.report { 1000000.times { @generator.rand(3..12) } } }
    finish = Time.now
    puts "1000000 numbers generated in #{(finish - start)} seconds; #{1000000 / (finish - start)} per second\n"
  end

  it "marshal_dump && marshal_load works correctly" do
    marshalled_generator = Marshal.dump( @generator )
    copy = Marshal.load( marshalled_generator )

    ( @generator == copy ).must_equal true
    @generator.rand.must_equal copy.rand
  end

  it "dup() works" do
    comparison_depth = 10000
    second_generator = @generator.dup

    # They should have the same state, now, but still be independent generators.
    series_a = []
    comparison_depth.times { series_a << @generator.rand }

    series_b = []
    comparison_depth.times { series_b << second_generator.rand }

    ( series_a == series_b ).must_equal true
  end

end
