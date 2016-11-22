$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
if ENV['isaac_library_type'] == 'ext'
  require 'crypt/isaac/ext'
  require 'crypt/isaac/xorshift/ext'
elsif ENV['isaac_library_type'] == 'pure'
  require 'crypt/isaac/pure'
  require 'crypt/isaac/xorshift/pure'
else
  require 'crypt/isaac'
end

require 'minitest/autorun'
