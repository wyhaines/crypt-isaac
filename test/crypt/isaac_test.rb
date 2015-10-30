require 'test_helper'
require 'benchmark'

describe Crypt::ISAAC do
  before do
    @generator = Crypt::ISAAC.new
  end

  it "generates integers when called with an integer argument" do
    mynum = @generator.rand(1000000)
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

  it "performs as expected when generating a large quantity of numbers" do
    count = 0
    x = nil
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
  end

  it "multiple discrete number streams can be separately generated" do
    first_generator = Crypt::ISAAC.new
    second_generator = Crypt::ISAAC.new
    first_generator.wont_be_same_as second_generator
    x = nil
    y = nil
    1000.times do
      first_generator.rand(4294967295)
      second_generator.rand(4294967295)
    end
  end

  it "benchmark" do
    generator = Crypt::ISAAC.new
    puts "Benchmark integer prng generation"
    start = Time.now
    Benchmark.bm {|bm| bm.report { 1000000.times { generator.rand(4294967295) } } }
    finish = Time.now
    puts "1000000 numbers generated in #{(finish - start)} seconds; #{1000000 / (finish - start)} per second"

    puts "\nBenchmark float prng generation"
    start = Time.now
    Benchmark.bm {|bm| bm.report { 1000000.times { generator.rand } } }
    finish = Time.now
    puts "1000000 numbers generated in #{(finish - start)} seconds; #{1000000 / (finish - start)} per second\n"
  end

end
