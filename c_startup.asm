# Prepare for execution of 'bare metal' C program, with no OS and no libc
# Set up stack pointer, initialize global/static variables, then jump to `main`

# This startup code will be placed just after the main program code in ROM
# The first instruction in ROM will be a jump to this code

.section .text
.globl _start
_start:

# Set the stack pointer 8K past the beginning of RAM
# The stack will grow downwards
li sp, 0x70001FFF

call init_globals
call main

# After `main` returns... we don't have a 'halt' instruction or anything, so:
loop:
j loop
