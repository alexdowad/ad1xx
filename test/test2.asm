# Register-to-register moves

.section .text
.globl _start
_start:

li x1, 0x12344321
mv x2, x1
mv x3, x2
mv x4, x3
li x0, 0x12341234
mv x5, x0
