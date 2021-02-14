# For C programs which need to run 'bare metal', with no OS and no libc

.section .text
.globl _start
_start:

# Set the stack pointer 8K past the beginning of RAM
# The stack will grow downwards
li sp, 0x70001FFF

# MAIN must be defined using --defsym CLI argument
call MAIN

# And after it returns... we don't have a 'halt' instruction or anything, so:
loop:
j loop

