#!/usr/bin/env ruby

# Print entry address of an ELF file in hex

ARGF.binmode
magic_no = ARGF.read(4)
raise "Not an ELF file" if magic_no != "\x7FELF"

ARGF.seek(24)
data = ARGF.read(4)
# Entry address is stored in little-endian order
addr = (data[3].ord << 24) + (data[2].ord << 16) + (data[1].ord << 8) + data[0].ord
puts addr.to_s(16).upcase.rjust(8, '0')
