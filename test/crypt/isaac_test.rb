# frozen_string_literal: true

ENV['isaac_library_type'] = 'ext'
child = fork do
  puts "\n*****\nTesting Crypt::ISAAC C extension implementation\n*****\n\n"
  load 'isaac_shared.rb'
end

Process.wait child

ENV['isaac_library_type'] = 'pure'
child = fork do
  puts "\n*****\nTesting Crypt::ISAAC pure Ruby implementation\n*****\n\n"
  load 'isaac_shared.rb'
end

Process.wait child
