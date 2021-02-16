#!/usr/bin/env ruby
# Usage: ruby gen_test_rom.rb input.bin >output.v

def hexword(s)
  n = (s[3].ord << 24) + (s[2].ord << 16) + (s[1].ord << 8) + s[0].ord
  n.to_s(16).rjust(8, '0')
end

puts "module ad100_rom(input [9:0] addr, output reg [31:0] read);"
puts "always @*"
puts "  case (addr)"

addr = 0

ARGF.binmode
binary = ARGF.read
0.step(binary.length-1, 4) do |offset|
  word = binary.byteslice(offset, 4)
  puts "    #{addr}: read = 32'h#{hexword(word)};"
  addr += 1
end

puts "    default: read = 0;"
puts "  endcase"
puts "endmodule"
