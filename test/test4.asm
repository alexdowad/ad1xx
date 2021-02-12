# Function call

.section .text
.globl _start
_start:

li a0, 0x1000
call increment
loop:
j loop

increment:
addi a0, a0, 1
jalr x0, ra, 0
