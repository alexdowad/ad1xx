# Unconditional jump

.section .text
.globl _start
_start:

li x12, 0x100000
j label

li x12, 0x333333

label:
addi x12, x12, 0x234
