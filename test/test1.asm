# Try loading immediate values into registers

.section .text
.globl _start
_start:

li x1, 0x12345678
li x2, 0x98765432
li x0, 0x11111111
