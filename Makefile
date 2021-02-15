ad100_src = ad100.v ad100_cpu.v alu.v program_counter.v register_file.v
asm_tests = test/test_asm1.vvp test/test_asm2.vvp test/test_asm3.vvp \
            test/test_asm4.vvp test/test_asm5.vvp test/test_asm6.vvp \
            test/test_asm7.vvp
c_tests   = test/test_c8.vvp test/test_c9.vvp test/test_c10.vvp

test/test%.vvp: $(ad100_src) test/test%_rom.v test/test%_bench.v
	iverilog -o $@ $^

test/test_asm%_rom.v: test/test%.asm
	$(eval TMP := $(shell mktemp -d))
	riscv-as -march=rv32i -o $(TMP)/test0.o $<
	riscv-ld -Ttext=FF000000 -o $(TMP)/test1.o $(TMP)/test0.o
	riscv-objcopy -O binary $(TMP)/test1.o $(TMP)/test.bin
	test/gen_test_rom.rb $(TMP)/test.bin >$@

test/test_c%_rom.v: test/test%.c c_startup.asm
	$(eval TMP := $(shell mktemp -d))
	riscv-gcc -c -o $(TMP)/main.o $<
	riscv-as -march=rv32i -o $(TMP)/startup.o c_startup.asm
	test/gen_init_code.rb $(TMP)/main.o >$(TMP)/init.asm
	riscv-as -march=rv32i -o $(TMP)/init.o $(TMP)/init.asm
	riscv-ld -T ad100.ld -o $(TMP)/test.o $(TMP)/main.o $(TMP)/startup.o $(TMP)/init.o
	riscv-objcopy --dump-section .text=$(TMP)/test.bin $(TMP)/test.o
	test/gen_test_rom.rb $(TMP)/test.bin >$@

test: $(asm_tests) $(c_tests) FORCE
	test/run_tests.rb
FORCE:
