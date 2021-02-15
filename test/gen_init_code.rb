#!/usr/bin/env ruby

binary = ARGV[0]

magic_no = File.read(binary, 6, mode: 'rb')
raise "Not an ELF file" if magic_no[0,4] != "\x7FELF"
raise "Not 32-bit ELF file" if magic_no[4].ord != 1
raise "Not little-endian ELF file" if magic_no[5].ord != 1

def byteswap16(bytes, index)
  bytes[index].ord + (bytes[index+1].ord << 8)
end
def byteswap32(bytes, index)
  byteswap16(bytes, index) + (byteswap16(bytes, index+2) << 16)
end

elfhdr = File.read(binary, 52, mode: 'rb')
secthdr_size   = byteswap16(elfhdr, 46)
secthdr_n      = byteswap16(elfhdr, 48)
secthdr_offset = byteswap32(elfhdr, 32)
secthdr_strtab = byteswap16(elfhdr, 50)

secthdrs = File.read(binary, secthdr_size * secthdr_n, secthdr_offset, mode: 'rb')

strtab = secthdrs[secthdr_strtab * secthdr_size, secthdr_size]
strtab_offset = byteswap32(strtab, 16)
strtab_size   = byteswap32(strtab, 20)
sect_names    = File.read(binary, strtab_size, strtab_offset, mode: 'rb')

def null_terminated_str(bytes, index)
  _end = bytes.index("\x00", index)
  bytes[index..._end]
end

sect_types = {
  0 => "SHT_NULL",
  1 => "SHT_PROGBITS",
  2 => "SHT_SYMTAB",
  3 => "SHT_STRTAB",
  4 => "SHT_RELA",
  5 => "SHT_HASH",
  6 => "SHT_DYNAMIC",
  7 => "SHT_NOTE",
  8 => "SHT_NOBITS",
  9 => "SHT_REL",
  10 => "SHT_SHLIB",
  11 => "SHT_DYNSYM",
  12 => "SHT_INIT_ARRAY",
  13 => "SHT_FINI_ARRAY",
  14 => "SHT_PREINIT_ARRAY",
  15 => "SHT_GROUP",
  16 => "SHT_SYMTAB_SHNDX",
  1879048195 => "RISCV_ATTRIBUTE"
}

sections = {}

0.step(secthdrs.length-1, secthdr_size) do |i|
  secthdr    = secthdrs[i, secthdr_size]
  sectname   = null_terminated_str(sect_names, byteswap32(secthdr, 0))
  secttype   = sect_types[byteswap32(secthdr, 4)]
  sectflags  = byteswap32(secthdr, 8)
  sectaddr   = byteswap32(secthdr, 12)
  sectoffset = byteswap32(secthdr, 16)
  sectsize   = byteswap32(secthdr, 20)

  sections[sectname] = {type: secttype, flags: sectflags, address: sectaddr, offset: sectoffset, size: sectsize}
end

def hex(value)
  "0x#{value.to_s(16).rjust(8, '0')}"
end

$offset = 0

puts "# generated by gen_init_code.rb"
puts
puts ".section .text"
puts ".globl init_globals"
puts "init_globals:"

def init_section(name, bytes, size)
  return if size == 0
  puts
  puts "# initialize #{name} section"
  puts "la t1, _data+#{$offset}"
  $offset += size
  0.step(size-1, 4) do |i|
    value = bytes[i].ord + (bytes[i+1].ord << 8) + (bytes[i+2].ord << 16) + (bytes[i+3].ord << 24)
    puts "li t2, #{hex(value)}"
    puts "sw t2, #{i}(t1)"
  end
end

def init_data_section(name, section, binary)
  bytes = File.read(binary, section[:size], section[:offset], mode: 'rb')
  init_section(name, bytes, bytes.length)
end

if data = sections['.data']
  init_data_section('.data', data, binary)
end
if sdata = sections['.sdata']
  init_data_section('.sdata', sdata, binary)
end

def zero_section(name, size)
  return if size == 0
  puts
  puts "# initialize #{name} section"
  puts "la t1, _data+#{$offset}"
  $offset += size
  0.step(size-1, 4) do |i|
    puts "sw x0, #{i}(t1)"
  end
end

def init_bss_section(name, section)
  zero_section(name, section[:size])
end

if bss = sections['.bss']
  init_bss_section('.bss', bss)
end
if sbss = sections['.sbss']
  init_bss_section('.sbss', sbss)
end

puts "ret"
