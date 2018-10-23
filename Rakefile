# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'

Rake::ExtensionTask.new 'isaac/ext' do |ext|
  ext.ext_dir = 'ext/crypt/isaac'
  ext.lib_dir = 'ext/crypt/'
end

Rake::ExtensionTask.new 'isaac/xorshift/ext' do |ext|
  ext.ext_dir = 'ext/crypt/isaac/xorshift'
  ext.lib_dir = 'ext/crypt/'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.libs << 'ext'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
