# Arithmetic
# Try all the arithmetic and logical ops, both with immediate and register operands

.section .text
.globl _start
_start:

li x12, 0x12341000
addi x12, x12, 0x234 # x12 = 0x12341234
srli x12, x12, 16 # x12 = (x12 >> 16) => 0x1234
slli x12, x12, 16 # x12 = (x12 << 16) => 0x12340000

li x13, 0x80000000
li x14, 0x40000000
srai x13, x13, 8 # x13 = 0xFF800000; negative number is sign-extended
srai x14, x14, 8 # x14 = 0x00400000; positive number has high end filled with zeroes

sub x13, x13, x14 # x13 = x13 - x14 => 0xFF400000

xori x13, x13, 0xFF # x13 = x13 ^ 0xFF => 0xFF4000FF
andi x13, x13, 0xFF # clear bits => 0xFF
ori  x13, x13, 0x100 # set bits => 0x1FF

li x12, 0x1010
li x13, 0x2222
and x14, x12, x13 # x14 = x12 & x13 => 0
or  x14, x12, x13 # x14 = x12 | x13 => 0x3232
xor x14, x12, x13 # x14 = x12 ^ x13 => 0x3232

li x14, 0x323
slti x12, x14, 0x500 # x14 is less than 0x5000 => x12 = 1
slti x13, x14, 0x100 # x14 is not less than 0x1000 => x13 = 0
slti x14, x14, 0x323 # x14 is not less than 0x3232 => x14 = 0
slti x14, x14, -1     # zero is not less than -1 => x14 = 0
sltiu x14, x14, -1    # zero is less than 0xFFFFFFFF => x14 = 1

li x13, 0x122
sltiu x13, x13, 0x122 # x13 = 0

li x12, 0x1111
li x13, 0x2222
add x14, x12, x13 # x14 = x12 + x13 => 0x3333

li x12, 0x70000000
li x13, 0x80000000
slt x14, x12, x12 # x12 is not less than itself; x14 = 0
slt x14, x12, x13 # with signed comparison, x13 is less; x14 = 0
slt x14, x13, x12 # x14 = 1
sltu x14, x13, x12 # x14 = 0
sltu x14, x12, x13 # x14 = 1

li x12, 0x81234567
li x13, 12
srl x14, x12, x13 # x14 = 0x00081234
sll x14, x14, x13 # x14 = 0x81234000
sra x14, x12, x13 # x14 = 0xFFF81234

# Only bottom 5 bits of shift distance matter
li x13, 44
sra x14, x14, x13 # x14 = 0xFFFFFF81

loop:
j loop
