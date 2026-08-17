.section .text
.globl _start

_start:

    # 0x00
    addi x5,  x6,  10

    # 0x04
    addi x8,  x6,  -1

    # 0x08
    add  x9,  x6,  x7

    # 0x0C
    sub  x10, x6,  x7

    # 0x10
    and  x11, x6,  x7

    # 0x14
    or   x12, x6,  x7

    # 0x18
    xor  x13, x6,  x7

    # 0x1C
    xori x14, x6,  5

    # 0x20
    ori  x15, x6,  5

    # 0x24
    andi x16, x6,  5

    # 0x28
    slt  x17, x6,  x7

    # 0x2C
    slti x18, x6,  25

    # 0x30
    sltu x19, x6,  x7

    # 0x34
    sltu x21, x20, x7

    # 0x38
    sll  x22, x6,  x7

    # 0x3C
    srl  x23, x6,  x7

    # 0x40
    sra  x24, x6,  x7

    # 0x44
    sw   x7,  12(x6)

    # 0x48
    lw   x5,  12(x6)

    # 0x4C
    beq  x6, x7, beq_taken

    # 0x50
beq_taken:
    beq  x6, x6, bne_test

    # 0x54
    nop

    # 0x58
bne_test:
    bne  x6, x7, blt_not_taken

    # 0x5C
    nop

    # 0x60
blt_not_taken:
    blt  x6, x7, blt_taken

    # 0x64
blt_taken:
    blt  x7, x6, bge_not_taken

    # 0x68
    nop

    # 0x6C
bge_not_taken:
    bge  x7, x6, bge_taken

    # 0x70
bge_taken:
    bge  x6, x7, bltu_not_taken

    # 0x74
    nop

    # 0x78
bltu_not_taken:
    bltu x20, x7, bltu_taken

    # 0x7C
bltu_taken:
    bltu x7, x6, bgeu_taken

    # 0x80
    nop

    # 0x84
bgeu_taken:
    bgeu x20, x7, bgeu_not_taken

    # 0x88
    nop

    # 0x8C
bgeu_not_taken:
    bgeu x7, x6, end

    # 0x90
end:
    jal  x25, jal_target

    # 0x94
    addi x26, x0, 99

    # 0x98
jal_target:
    addi x27, x0, 42

    # 0x9C
    addi x28, x0, 0xA8

    # 0xA0
    jalr x30, 0(x28)

    # 0xA4
    addi x31, x0, 99

    # 0xA8
jalr_target:
    addi x27, x0, 55

    # 0xAC
    nop
