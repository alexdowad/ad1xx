/* Linker script to build C, etc. programs which we can process into a ROM image */

MEMORY
{
  /* 0xFF000000 is reserved for a jump instruction (going to entry point) */
  rom (RX) : ORIGIN = 0xFF000000, LENGTH = 0x1000
  ram (RW) : ORIGIN = 0x70000000, LENGTH = 0x1000
}

SECTIONS
{
  .text :
  {
    *startup*(.text*)
    *(.text*)
    *(.rodata*)
  } > rom

  .data :
  {
    _data = .;
    *(.data*)
    *(.sdata*)
  } > ram

  .bss (NOLOAD) :
  {
    *(.bss*)
    *(.sbss*)
  } > ram
}