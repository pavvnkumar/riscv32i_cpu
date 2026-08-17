RISCV_PREFIX = riscv32-unknown-elf

AS      = $(RISCV_PREFIX)-as
OBJCOPY = $(RISCV_PREFIX)-objcopy

PROGRAM = programs/cpu_test

RTL = rtl/pc.sv \
      rtl/regfile.sv \
      rtl/alu.sv \
      rtl/decoder.sv \
      rtl/instr_mem.sv \
      rtl/data_mem.sv \
      rtl/cpu.sv

PROGRAM_TB = tb/tb_cpu.sv

UNIT_TESTS = alu decoder instr_mem data_mem pc regfile

.PHONY: all program unit_tests sim test clean

all: test

program: $(PROGRAM).hex

$(PROGRAM).o: $(PROGRAM).S
	$(AS) -march=rv32i -mabi=ilp32 -o $@ $<

$(PROGRAM).hex: $(PROGRAM).o
	$(OBJCOPY) -O verilog $< $@

unit_tests:
	@set -e; \
	for tb in $(UNIT_TESTS); do \
		echo "========================================"; \
		echo " Running tb_$$tb"; \
		echo "========================================"; \
		verilator --binary --timing \
			--top-module tb_$$tb \
			--Mdir obj_dir_$$tb \
			$(RTL) tb/tb_$$tb.sv; \
		./obj_dir_$$tb/Vtb_$$tb; \
	done

sim: program
	verilator --binary --timing \
		--top-module tb_cpu \
		$(RTL) $(PROGRAM_TB)

test: program unit_tests sim
	./obj_dir/Vtb_cpu

clean:
	rm -rf obj_dir obj_dir_alu obj_dir_decoder obj_dir_instr_mem \
	       obj_dir_data_mem obj_dir_pc obj_dir_regfile
	rm -f $(PROGRAM).o
