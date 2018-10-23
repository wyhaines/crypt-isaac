# frozen_string_literal: true

begin
  require 'crypt/isaac/ext'
rescue LoadError
  require 'crypt/isaac/pure'
end

begin
  # Use a non-cryptographic alternative to the Mersenne Twister for an internal
  # pseudo-random source of numbers if the library is required to seed itself.
  # https://en.wikipedia.org/wiki/Xorshift
  require 'crypt/xorshift'
rescue LoadError
  # Fallback on an internal micro-implementation.
  require 'crypt/isaac/xorshift'
end
