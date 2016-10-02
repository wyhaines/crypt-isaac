begin
  require 'crypt/isaac/xorshift/ext'
rescue LoadError
  require 'crypt/isaac/xorshift/pure'
end
