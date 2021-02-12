# Conditional branches

.section .text
.globl _start
_start:

li x1, 2
li x2, -1
beq x0, x1, fail
bne x0, x1, step2
j fail

step2:
blt x1, x0, fail
blt x2, x1, step3
j fail

step3:
bge x0, x1, fail
bge x1, x2, step4
j fail

step4:
bltu x1, x2, step5
j fail

step5:
bgeu x2, x1, step6
j fail

step6:
li x10, 0x11112222
j loop

fail:
li x10, -1
loop:
j loop
