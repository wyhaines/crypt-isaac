require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

Rake::ExtensionTask.new "isaac" do |ext|
  ext.lib_dir = "lib/crypt/"
end

Rake::ExtensionTask.new "xorshift" do |ext|
  ext.lib_dir = "lib/crypt/xorshift"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test
