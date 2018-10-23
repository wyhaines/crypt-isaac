# frozen_string_literal: true

require 'test_xorshift_helper'
require 'benchmark'

# rubocop: disable Metrics/BlockLength
describe Crypt::Xorshift64Star do
  before do
    @generator = Crypt::Xorshift64Star.new
  end

  it 'generates integers when called with an integer argument' do
    10.times do
      mynum = @generator.rand(1_000_000)
      mynum.must_be_kind_of Integer
      mynum.must_be :>, 0
      mynum.must_be :<, 1_000_000
    end
  end

  it 'generates floats when called with no argument' do
    10.times do
      mynum = @generator.rand
      mynum.must_be_kind_of Float
      mynum.must_be :>=, 0
      mynum.must_be :<, 1
    end
  end

  it 'generates integers even when called with a float argument' do
    10.times do
      mynum = @generator.rand(10.0)
      mynum.must_be_kind_of Integer
      mynum.must_be :>=, 0
      mynum.must_be :<, 10
    end
  end

  it 'seeding works correctly' do
    first_generator = Crypt::Xorshift64Star.new(123)
    second_generator = Crypt::Xorshift64Star.new(123)

    (first_generator == second_generator).must_equal true

    10.times { first_generator.rand.must_equal second_generator.rand }

    first_generator.seed.must_equal second_generator.seed

    first_generator = Crypt::Xorshift64Star.new(123)
    second_generator = Crypt::Xorshift64Star.new(124)

    (first_generator == second_generator).must_equal false
  end
end
# rubocop: enable Metrics/BlockLength
