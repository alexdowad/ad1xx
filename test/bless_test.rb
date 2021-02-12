#!/usr/bin/env ruby

# Used after manually verifying that the output of a test script is as expected
# Runs the test, captures the output, then saves it for use as a regression test later

testfile = ARGV[0]

output = `vvp #{__dir__}/#{testfile}.vvp`
File.open("#{__dir__}/expect/#{testfile}", 'w') { |f| f.write(output) }

puts output
