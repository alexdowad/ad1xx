# Storing and loading values to/from memory

.section .text
.globl _start
_start:

li x10, 0x88334455
li x1,  0x70000000
sw x10, 0(x1)
lw x11, 0(x1)

lb x2, 0(x1)
lb x3, 1(x1)
lb x4, 2(x1)
lb x5, 3(x1)

lbu x6, 0(x1)
lbu x7, 1(x1)
lbu x8, 2(x1)
lbu x9, 3(x1)

lh  x12, 0(x1)
lh  x13, 2(x1)
lhu x14, 0(x1)
lhu x15, 2(x1)

li x10, 0x99aabbcc
sb x10, 0(x1)
sh x10, 0(x1)
