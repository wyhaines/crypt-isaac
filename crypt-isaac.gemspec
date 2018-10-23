# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crypt/isaac/version'

def setup_authorship(spec)
  spec.name = 'crypt-isaac'
  spec.version = Crypt::Isaac::VERSION
  spec.authors = ['Kirk Haines']
  spec.email = ['wyhaines@gmail.com']
  spec.homepage = 'http://github.com/wyhaines/crypt-isaac'
  spec.license = 'MIT'
end

def setup_descriptions(spec)
  spec.summary = <<~ESUMMARY
    An implementation of the fast, cryptographically secure ISAAC PRNG
  ESUMMARY

  spec.description = <<~EDESCRIPTION
    ISAAC is a fast, cryptographically secure pseudo random number generator
    with strong statistical properties. This gem provides both a pure Ruby and
    a C extension based implementation which conforms to the Ruby 2 api for
    Random, with some enhancements. So, you should be able to use it as a drop
    in replacement for Ruby's (Mersenne Twister based) PRNG.
  EDESCRIPTION
end

Gem::Specification.new do |spec|
  setup_authorship spec
  setup_descriptions spec

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems >= 2.0 is required.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extensions =
    %w[ext/crypt/isaac/xorshift/extconf.rb ext/crypt/isaac/extconf.rb]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake', '~> 11.0'
end
