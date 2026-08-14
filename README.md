# RV32I CPU in SystemVerilog

A hands-on implementation of a small **RISC-V RV32I processor** in SystemVerilog, developed from the ground up with Verilator simulation and module-level regression tests.

The goal of this repository is not simply to make instructions execute. It is to understand **what hardware each instruction requires, how data moves through the processor, and how the design grows from a simple single-cycle CPU toward a more complete RISC-V implementation.**

---

## 1. Project Status

Current checkpoint:

**RV32I ALU / immediate / comparison / shift instructions implemented and regression-tested.**

Implemented so far:

| Group | Instructions | Status |
|---|---|---|
| Register arithmetic | `ADD`, `SUB` | ✅ |
| Immediate arithmetic | `ADDI` | ✅ |
| Register logical | `AND`, `OR`, `XOR` | ✅ |
| Immediate logical | `ANDI`, `ORI`, `XORI` | ✅ |
| Signed comparison | `SLT` | ✅ |
| Signed immediate comparison | `SLTI` | ✅ |
| Unsigned comparison | `SLTU` | ✅ |
| Register shifts | `SLL`, `SRL`, `SRA` | ✅ |
| Load/store | `LW`, `SW` | Next |
| Branches | `BEQ`, `BNE`, ... | Later |
| Jumps | `JAL`, `JALR` | Later |
| Upper-immediate | `LUI`, `AUIPC` | Later |
| System instructions | Later | Later |

The project is intentionally built incrementally. Each architectural block is tested independently before being connected to the complete CPU.

---

# 2. What Are We Building?

At the highest level, we are building a processor that repeatedly performs:

```text
        ┌───────────────┐
        │ Program Counter│
        │      PC       │
        └───────┬───────┘
                │ address
                ▼
        ┌───────────────┐
        │ Instruction   │
        │    Memory     │
        └───────┬───────┘
                │ 32-bit instruction
                ▼
        ┌───────────────┐
        │    Decoder    │
        └───────┬───────┘
                │
        ┌───────┼─────────────────┐
        │       │                 │
        ▼       ▼                 ▼
      rs1/2     rd            control
        │       │                 │
        ▼       │                 ▼
   ┌─────────┐  │          ┌────────────┐
   │Register │  │          │    ALU     │
   │  File   │──┼─────────►│            │
   └────┬────┘  │          └─────┬──────┘
        │       │                │
        │       │                │ result
        │       │                ▼
        │       │          ┌────────────┐
        │       └──────────│ Write Back │
        │                  └────────────┘
        │
        └──────────── operands
```

The processor is currently being developed as a simple, understandable CPU rather than immediately optimizing for maximum performance.

---

# 3. RISC-V RV32I Fundamentals

## 3.1 What does RV32I mean?

`RV32I` can be understood as:

- `RV` → RISC-V
- `32` → 32-bit integer register architecture
- `I` → base Integer instruction set

The CPU has:

```text
32 general-purpose registers
Each register = 32 bits
```

They are named:

```text
x0, x1, x2, ... x31
```

`x0` is special:

```text
x0 = 0
```

It is hardwired to zero in the RISC-V architecture.

---

# 4. The Instruction

Every base RV32I instruction is:

```text
32 bits
```

A simplified view:

```text
31                                      0
┌──────────┬─────┬─────┬─────┬────────┬─────────┐
│   funct7 │ rs2 │ rs1 │funct3│   rd   │ opcode  │
└──────────┴─────┴─────┴─────┴────────┴─────────┘
```

Different instruction formats rearrange these fields.

Important fields:

```text
opcode → identifies the broad instruction type
rd     → destination register
rs1    → first source register
rs2    → second source register
funct3 → selects an operation/subtype
funct7 → further distinguishes some R-type operations
```

For example:

```text
ADD x5, x6, x7
```

means:

```text
x5 = x6 + x7
```

The decoder extracts:

```text
rs1 = 6
rs2 = 7
rd  = 5
```

and generates the control signals required by the datapath.

---

# 5. Instruction Execution Flow

For the current simple CPU, an instruction goes through this conceptual path:

```text
             FETCH
               │
               ▼
        ┌─────────────┐
        │ Instruction │
        │   Memory    │
        └──────┬──────┘
               │
               ▼
             DECODE
               │
               ▼
        ┌─────────────┐
        │   Decoder   │
        └──────┬──────┘
               │
       ┌───────┴────────┐
       │                │
       ▼                ▼
 Register File        Control
       │                │
       └───────┬────────┘
               ▼
             EXECUTE
               │
               ▼
        ┌─────────────┐
        │     ALU     │
        └──────┬──────┘
               │
               ▼
           WRITE BACK
               │
               ▼
          Register File
```

The CPU repeats this for every instruction.

---

# 6. Program Counter

The PC contains the address of the current instruction.

Because RV32I instructions are normally 32 bits = 4 bytes:

```text
PC = 0x00
PC = 0x04
PC = 0x08
PC = 0x0C
...
```

The basic flow is:

```text
       ┌──────┐
       │  PC  │
       └──┬───┘
          │
          ▼
   Instruction Memory
          │
          ▼
     instruction
          │
          │
          └──────────────┐
                         │
                         ▼
                    PC + 4
                         │
                         ▼
                       PC
```

Later, branches and jumps will change this simple `PC + 4` behavior.

---

# 7. Register File

The register file contains the processor's general-purpose registers.

Conceptually:

```text
                 ┌──────────────────┐
 rs1 ───────────►│                  │
 rs2 ───────────►│   REGISTER FILE  │
                 │                  │
                 │ x0  = 0          │
                 │ x1                │
                 │ x2                │
                 │ ...              │
                 │ x31              │
                 └───────┬──────────┘
                         │
                    read data
                         │
                         ▼
                       ALU
```

For an R-type instruction:

```text
ADD x5, x6, x7
```

the register file supplies:

```text
read_data1 = x6
read_data2 = x7
```

The ALU computes:

```text
x6 + x7
```

and the result is written into:

```text
x5
```

---

# 8. The ALU

The ALU performs the actual arithmetic, logical, comparison, and shift operations.

Our internal ALU control encoding is 4 bits:

```text
ALU_ADD = 0000
ALU_SUB = 0001
ALU_AND = 0010
ALU_OR  = 0011
ALU_XOR = 0100
ALU_SLT = 0101
...
```

This is an **internal hardware encoding**.

It is different from RISC-V's `funct3`, which is part of the instruction encoding.

For example:

```text
RISC-V instruction
       │
       ▼
    funct3
       │
       ▼
    Decoder
       │
       ▼
 internal ALU control
       │
       ▼
      ALU
```

This separation is useful because the instruction encoding and our internal datapath control encoding do not have to be identical.

---

# 9. ALU Operations Implemented

## Addition

```text
ADD  x5, x6, x7
x5 = x6 + x7
```

## Subtraction

```text
SUB x10, x6, x7
x10 = x6 - x7
```

## Logical operations

```text
AND
OR
XOR
```

These operate bit-by-bit.

Example:

```text
1010
1100
----
1000    AND
1110    OR
0110    XOR
```

## Immediate operations

Instructions such as:

```text
ADDI
ANDI
ORI
XORI
```

use an immediate value encoded inside the instruction instead of `rs2`.

The datapath becomes:

```text
                 ┌─────────────┐
 rs1 ───────────►│ Register    │
                 │    File     │
                 └──────┬──────┘
                        │
                        │ operand A
                        ▼
                    ┌───────┐
                    │  ALU  │◄──────── immediate
                    └───────┘
```

The `alu_src` control signal chooses the second ALU operand:

```text
alu_src = 0 → register rs2
alu_src = 1 → immediate
```

---

# 10. Immediate Sign Extension

Many RV32I instructions contain a 12-bit signed immediate.

For example:

```text
instruction[31:20]
```

contains the immediate.

The CPU extends it from:

```text
12 bits → 32 bits
```

by copying the sign bit:

```text
{{20{instruction[31]}}, instruction[31:20]}
```

Example:

```text
12-bit +10:

000000001010
```

becomes:

```text
00000000 00000000 00000000 00001010
```

For `-1`:

```text
12-bit:

111111111111
```

becomes:

```text
11111111 11111111 11111111 11111111
```

This preserves the signed value when the 12-bit number is used by the 32-bit ALU.

---

# 11. Comparison Instructions

## SLT

`SLT` means:

> Set Less Than, signed.

```text
SLT rd, rs1, rs2
```

Conceptually:

```text
if (rs1 < rs2)
    rd = 1;
else
    rd = 0;
```

Example:

```text
20 < 5 → false → 0
5 < 20 → true  → 1
```

## SLTU

`SLTU` performs an **unsigned** comparison.

The same 32-bit bit pattern can have different signed and unsigned interpretations.

For example:

```text
0xFFFFFFFF
```

as signed 32-bit:

```text
-1
```

as unsigned 32-bit:

```text
4294967295
```

Therefore:

```text
SLT  FFFFFFFF, 5 → 1
SLTU FFFFFFFF, 5 → 0
```

The bits did not change. Only the comparison interpretation changed.

---

# 12. Shift Instructions

A shift moves bits left or right.

## SLL — Shift Left Logical

```text
SLL rd, rs1, rs2
```

Example:

```text
5 << 3 = 40
```

Binary:

```text
00000101
    ↓ shift left 3
00101000
```

A left shift by `n` is closely related to multiplication by:

```text
2^n
```

when no significant bits are lost.

## SRL — Shift Right Logical

Zeros enter from the left:

```text
10000000
   ↓
01000000
```

## SRA — Shift Right Arithmetic

The sign bit is copied into the new high bits.

This allows signed negative values to preserve their sign during right shifts.

```text
negative value
      ↓
 arithmetic right shift
      ↓
sign bits remain 1
```

The shift amount for RV32 is effectively determined by the lower 5 bits of the shift operand because:

```text
2^5 = 32
```

so the possible shift amounts are:

```text
0 through 31
```

---

# 13. Why `valid` Exists

The decoder produces:

```text
valid
```

This indicates whether the decoder recognizes the instruction.

Conceptually:

```text
instruction
     │
     ▼
  Decoder
     │
     ├── valid = 1 → recognized instruction
     │
     └── valid = 0 → unsupported/unknown instruction
```

At the current stage, the CPU does not yet use `valid` for a complete exception mechanism.

It is a foundation for later:

```text
illegal instruction handling
exceptions
control-flow protection
```

---

# 14. Instruction Memory

The current instruction memory is a simple combinational lookup.

Conceptually:

```text
             address
                │
                ▼
       ┌─────────────────┐
       │ Instruction     │
       │     Memory      │
       └────────┬────────┘
                │
                ▼
          32-bit instruction
```

Current test program:

```text
Address   Instruction

0x00      ADDI
0x04      ADDI
0x08      ADD
0x0C      SUB
0x10      AND
0x14      OR
0x18      XOR
0x1C      XORI
0x20      ORI
0x24      ANDI
0x28      SLT
0x2C      SLTI
0x30      SLTU
0x34      SLTU
0x38      SLL
0x3C      SRL
0x40      SRA
```

This is currently a hard-coded test program, not yet a real RAM/ROM implementation.

---

# 15. Current CPU Datapath

The current design can be viewed as:

```text
                         ┌──────────────────┐
                         │ Instruction Mem  │
                         └────────┬─────────┘
                                  │
                                  ▼
PC ───────────────────────────► instruction
│                                 │
│                                 ▼
│                           ┌────────────┐
│                           │  Decoder   │
│                           └─────┬──────┘
│                                 │
│                    ┌────────────┼─────────────┐
│                    │            │             │
│                    ▼            ▼             ▼
│                  rs1/rs2        rd        control
│                    │
│                    ▼
│              ┌─────────────┐
│              │ Register    │
│              │    File     │
│              └──────┬──────┘
│                     │
│                ┌────┴────┐
│                │         │
│                ▼         ▼
│              ALU A     ALU B
│                          ▲
│                          │
│                    ┌─────┴─────┐
│                    │           │
│                  rs2       immediate
│
│                     ┌─────────┐
└────────────────────►│   ALU   │
                      └────┬────┘
                           │
                           ▼
                      ALU result
                           │
                           ▼
                     Register File
```

This is the core datapath we have built so far.

---

# 16. Verification Strategy

We are deliberately using two levels of verification.

## Module-level testing

Each important block has its own testbench:

```text
tb_alu
   ↓
 alu

tb_decoder
   ↓
 decoder

tb_instr_mem
   ↓
 instruction memory
```

This answers:

> Does this individual hardware block work?

## CPU-level regression

```text
tb_cpu
   ↓
 CPU
 ├── PC
 ├── instruction memory
 ├── decoder
 ├── register file
 └── ALU
```

This answers:

> Do all the blocks work together correctly?

Both are important.

A module test can find a local problem quickly.

A CPU regression proves the complete datapath works end-to-end.

---

# 17. Current Verification Results

The CPU regression currently verifies results such as:

```text
x5  = 30   ADDI
x8  = 19   ADDI -1
x9  = 25   ADD
x10 = 15   SUB
x11 = 4    AND
x12 = 21   OR
x13 = 17   XOR
x14 = 17   XORI
x15 = 21   ORI
x16 = 4    ANDI
x17 = 0    SLT
x18 = 1    SLTI
x19 = 0    SLTU
x21 = 0    SLTU
x22 = 640  SLL
x23 = 0    SRL
x24 = 0    SRA
```

The full regression passes.

This gives us a known-good checkpoint before introducing the memory datapath.

---

# 18. Why We Test Before Moving Forward

The project follows this pattern:

```text
Implement
    ↓
Understand
    ↓
Unit test
    ↓
Connect to CPU
    ↓
CPU regression
    ↓
Commit checkpoint
    ↓
Add next architectural feature
```

This prevents a large number of changes from becoming mixed together.

For example, when `LW` eventually fails, we should be able to determine whether the problem is:

```text
Data memory?
    ↓
Decoder?
    ↓
Immediate generation?
    ↓
ALU address calculation?
    ↓
CPU wiring?
    ↓
Register write-back?
```

rather than debugging everything simultaneously.

---

# 19. Next Architectural Step: Data Memory

The current processor can calculate values, but it cannot yet load or store data.

The next step introduces:

```text
LW — Load Word
SW — Store Word
```

The architecture becomes:

```text
                     ┌─────────────────┐
                     │ Instruction Mem │
                     └────────┬────────┘
                              │
                              ▼
PC ───────────────────────► Decoder
                              │
                       ┌──────┴───────┐
                       ▼              ▼
                 Register File       Control
                       │
                       ▼
                      ALU
                       │
                 address calculation
                       │
                       ▼
                ┌──────────────┐
                │ Data Memory  │
                └──────┬───────┘
                       │
                       │ load data
                       ▼
                 Write Back
                       │
                       ▼
                 Register File
```

For `SW`:

```text
Register ───────────────► Data Memory
             write data

Register ──► ALU ───────► Data Memory
             address
```

For `LW`:

```text
Register ──► ALU ───────► Data Memory
             address          │
                              │
                              ▼
                           Register
```

This is the next major architectural expansion.

---

# 20. Byte Addressing and 32-bit Words

RV32I uses byte-addressed memory.

A 32-bit word contains:

```text
32 bits / 8 bits per byte = 4 bytes
```

Therefore word addresses advance by:

```text
0x00
0x04
0x08
0x0C
...
```

For a simple 32-bit word memory, the lower two address bits identify the byte offset inside a word:

```text
31                    2 1 0
┌──────────────────────┬───┐
│      word index      │off│
└──────────────────────┴───┘
                         ↑
                       2 bits
```

For aligned 32-bit word accesses:

```text
addr[1:0] = 00
```

The next memory module will therefore translate the byte address into a word index.

---

# 21. Project Architecture So Far

```text
                  ┌──────────────┐
                  │     PC       │
                  └──────┬───────┘
                         │
                         ▼
                ┌────────────────┐
                │ Instruction    │
                │ Memory         │
                └───────┬────────┘
                        │
                        ▼
                ┌────────────────┐
                │    Decoder     │
                └───────┬────────┘
                        │
             ┌──────────┼───────────┐
             │          │           │
             ▼          ▼           ▼
          rs1/rs2      rd       controls
             │
             ▼
       ┌─────────────┐
       │ Register    │
       │    File     │
       └──────┬──────┘
              │
          operands
              │
              ▼
       ┌─────────────┐
       │     ALU     │
       └──────┬──────┘
              │
              ▼
          write-back
              │
              ▼
       ┌─────────────┐
       │ Register    │
       │    File     │
       └─────────────┘
```

Next:

```text
                  ┌──────────────┐
                  │  Data Memory │
                  └──────────────┘
                         ▲
                         │
                    ALU address
                         │
                  ┌──────┴──────┐
                  │             │
                 LW             SW
                  │             │
              read data      write data
                  │             │
                  └──────┬──────┘
                         ▼
                    CPU datapath
```

---

# 22. Development Philosophy

This repository is being developed as a learning-oriented but hardware-engineering-style project.

Important principles:

### Understand the hardware, not just the syntax

For every instruction, ask:

```text
What information is encoded?
What does the decoder extract?
What datapath operation is required?
Which control signals are needed?
Where does the result go?
```

### Verify at multiple levels

```text
RTL module
   ↓
module testbench
   ↓
CPU integration
   ↓
CPU regression
```

### Keep known-good checkpoints

After completing a meaningful architectural block:

```text
git commit
    ↓
GitHub
```

This gives the project a recoverable history.

---

# 23. Roadmap

The planned architecture expansion is approximately:

```text
Current
  │
  ├── ALU operations                    ✅
  ├── Immediate operations              ✅
  ├── Comparisons                       ✅
  ├── Shifts                            ✅
  │
  ▼
Data Memory
  │
  ├── LW
  └── SW
  │
  ▼
Control Flow
  │
  ├── BEQ
  ├── BNE
  ├── BLT
  ├── BGE
  ├── BLTU
  └── BGEU
  │
  ▼
Jump Instructions
  │
  ├── JAL
  └── JALR
  │
  ▼
Upper Immediate
  │
  ├── LUI
  └── AUIPC
  │
  ▼
Complete RV32I base integer ISA
  │
  ▼
Better verification
  │
  ├── Directed tests
  ├── Randomized tests
  └── Assertions
  │
  ▼
Pipeline
  │
  └── 5-stage pipeline
       IF → ID → EX → MEM → WB
  │
  ▼
Hazards
  │
  ├── Data hazards
  ├── Forwarding
  └── Stalls
  │
  ▼
FPGA implementation
  │
  ▼
SoC integration
  │
  ▼
ASIC RTL → synthesis → physical design
```

---

# 24. Repository Structure

Current intended structure:

```text
riscv32i_cpu/
│
├── rtl/
│   ├── alu.sv
│   ├── cpu.sv
│   ├── decoder.sv
│   ├── instr_mem.sv
│   ├── pc.sv
│   └── regfile.sv
│
├── tb/
│   ├── tb_alu.sv
│   ├── tb_cpu.sv
│   ├── tb_decoder.sv
│   └── tb_instr_mem.sv
│
├── .gitignore
└── README.md
```

Generated Verilator build files should not be committed:

```text
obj_dir/
```

---

# 25. Key Mental Model

The most important mental model for this project is:

```text
Instruction
     │
     ▼
"What operation is this?"
     │
     ▼
Decoder
     │
     ▼
"What hardware operands/control do I need?"
     │
     ▼
Register File + Immediate
     │
     ▼
ALU / Memory
     │
     ▼
"Where does the result go?"
     │
     ▼
Register File / PC
```

As the ISA grows, we are not simply adding random instructions.

We are discovering the hardware structures required to support the instruction set.

For example:

```text
ADD/SUB
   ↓
ALU

ADDI
   ↓
Immediate generator + ALU input selection

SLT/SLTU
   ↓
Comparison logic

SLL/SRL/SRA
   ↓
Shift logic

LW/SW
   ↓
Data memory + memory control + write-back selection

BEQ/BNE/etc.
   ↓
Comparison + branch target generation + PC selection

JAL/JALR
   ↓
Jump target generation + PC selection + link register write-back
```

That is the core architectural way of thinking about CPU design.

---

## Current checkpoint

**The CPU currently has a verified ALU/immediate/compare/shift datapath.**

The next architectural change is:

> **Add the data-memory path and implement `LW` and `SW`.**
