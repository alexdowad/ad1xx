ad100_src = ad100.v ad100_cpu.v alu.v program_counter.v register_file.v
asm_tests = test/test_asm1.vvp test/test_asm2.vvp test/test_asm3.vvp \
            test/test_asm4.vvp test/test_asm5.vvp test/test_asm6.vvp \
            test/test_asm7.vvp
c_tests   = test/test_c8.vvp test/test_c9.vvp

test/test%.vvp: $(ad100_src) test/test%_rom.v test/test%_bench.v
	iverilog -o $@ $^

test/test_asm%_rom.v: test/test%.asm
	$(eval TMP := $(shell mktemp -d))
	riscv-as -march=rv32i -o $(TMP)/test0.o $<
	riscv-ld -Ttext=FF000000 -o $(TMP)/test1.o $(TMP)/test0.o
	riscv-objcopy -O binary $(TMP)/test1.o $(TMP)/test.bin
	test/gen_test_rom.rb $(TMP)/test.bin >$@

test/test_c%_rom.v: test/test%.c test/c_stub.asm
	$(eval TMP := $(shell mktemp -d))
	# C code should be located starting at 0xFF000014, since 0xFF000000-10 will be
	# occupied by startup code from c_stub.asm
	# (Which just sets up the stack pointer before calling `main`)
	riscv-gcc -o $(TMP)/test.o -nostdlib -Wl,-Ttext=FF000014 -Wl,--entry=main $<
	riscv-objcopy -O binary $(TMP)/test.o $(TMP)/test.bin
	# Look at binary emitted by GCC and see which address it put `main` at
	# The startup code in c_stub.asm will jump there
	MAIN=$$(test/entryaddr.rb $(TMP)/test.o); \
		riscv-as -march=rv32i --defsym MAIN=0x$$MAIN -o $(TMP)/stub0.o test/c_stub.asm
	riscv-ld -Ttext=FF000000 -o $(TMP)/stub1.o $(TMP)/stub0.o
	riscv-objcopy -O binary $(TMP)/stub1.o $(TMP)/c_stub.bin
	test/gen_test_rom.rb $(TMP)/c_stub.bin $(TMP)/test.bin >$@

test: $(asm_tests) $(c_tests) FORCE
	test/run_tests.rb
FORCE:
