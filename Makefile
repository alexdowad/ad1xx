ad100_src = ad100.v ad100_cpu.v alu.v program_counter.v register_file.v
asm_tests = test/test_asm1.vvp test/test_asm2.vvp test/test_asm3.vvp \
            test/test_asm4.vvp test/test_asm5.vvp test/test_asm6.vvp \
            test/test_asm7.vvp

test/test_asm%.vvp: $(ad100_src) test/test%_rom.v test/test%_bench.v
	iverilog -o $@ $^

test/test%_rom.v: test/test%.asm
	test/gen_test_rom.rb $< >$@

test: $(asm_tests)
	test/run_tests.rb
