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

.PHONY: all program \
        alu_test decoder_test instr_mem_test data_mem_test pc_test regfile_test \
        unit_tests sim test clean

all: test

program: $(PROGRAM).hex

$(PROGRAM).o: $(PROGRAM).S
	$(AS) -march=rv32i -mabi=ilp32 -o $@ $<

$(PROGRAM).hex: $(PROGRAM).o
	$(OBJCOPY) -O verilog $< $@

# ========================================
# Individual unit tests
# ========================================

alu_test:
	verilator --binary --timing \
		--top-module tb_alu \
		--Mdir obj_dir_alu \
		rtl/alu.sv tb/tb_alu.sv
	./obj_dir_alu/Vtb_alu

decoder_test:
	verilator --binary --timing \
		--top-module tb_decoder \
		--Mdir obj_dir_decoder \
		rtl/decoder.sv tb/tb_decoder.sv
	./obj_dir_decoder/Vtb_decoder

instr_mem_test:
	verilator --binary --timing \
		--top-module tb_instr_mem \
		--Mdir obj_dir_instr_mem \
		rtl/instr_mem.sv tb/tb_instr_mem.sv
	./obj_dir_instr_mem/Vtb_instr_mem

data_mem_test:
	verilator --binary --timing \
		--top-module tb_data_mem \
		--Mdir obj_dir_data_mem \
		rtl/data_mem.sv tb/tb_data_mem.sv
	./obj_dir_data_mem/Vtb_data_mem

pc_test:
	verilator --binary --timing \
		--top-module tb_pc \
		--Mdir obj_dir_pc \
		rtl/pc.sv tb/tb_pc.sv
	./obj_dir_pc/Vtb_pc

regfile_test:
	verilator --binary --timing \
		--top-module tb_regfile \
		--Mdir obj_dir_regfile \
		rtl/regfile.sv tb/tb_regfile.sv
	./obj_dir_regfile/Vtb_regfile


# ========================================
# All unit tests
# ========================================

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


# ========================================
# Full CPU simulation
# ========================================

sim: program
	verilator --binary --timing \
		--top-module tb_cpu \
		$(RTL) $(PROGRAM_TB)

test: program unit_tests sim
	./obj_dir/Vtb_cpu

clean:
	rm -rf obj_dir obj_dir_alu obj_dir_decoder \
	       obj_dir_instr_mem obj_dir_data_mem \
	       obj_dir_pc obj_dir_regfile
	rm -f $(PROGRAM).o