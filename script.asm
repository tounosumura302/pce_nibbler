    .zp
zscrptr:    ds  2
zscrcounter:    ds  1
zscrinterval:   ds  1   

    .code
    .bank   MAIN_BANK

scrInit:
.arg_script equ zarg0
.arg_interval   equ zarg1
    lda <zarg0
    sta <zscrptr
    lda <zarg1
    sta <zscrptr+1
    lda <zarg2
    sta <zscrinterval
    sta <zscrcounter

    rts

scrExecute:
    tst #$ff,<zscrcounter
    beq .go

    dec <zscrcounter
    clc
    rts

.go:
    lda <zscrinterval
    sta <zscrcounter

    cly
scrExecute_next:
    lda [zscrptr],y
    iny
    tax
    jmp [.jmptbl,x]

.jmptbl:
    dw  scrcmd_end
    dw  scrcmd_wait
    dw  scrcmd_setinterval
    dw  scrcmd_setsprite
    dw  scrcmd_setsprite_position
    dw  scrcmd_setsprite_pattern
    dw  scrcmd_setsprite_attribute
    dw  scrcmd_setbg

scrcmd_end:
    sec
    rts

scrcmd_wait:
    tya
    clc
    adc <zscrptr
    sta <zscrptr
    lda <zscrptr+1
    adc #0
    sta <zscrptr+1

    clc
    rts

scrcmd_setinterval:
    lda [zscrptr],y
    iny
    sta <zscrinterval
    sta <zscrcounter
    jmp scrExecute_next

scrcmd_setsprite:
    stz <ztmp0
    lda #8
    sta <ztmp1

scrcmd_setsprite_loop:
    lda [zscrptr],y
    iny
    asl a
    asl a
    asl a
    adc <ztmp0
    tax
.loop:
    lda [zscrptr],y
    iny
    sta satb,x
    inx

    dec <ztmp1
    bne .loop

    bra scrExecute_next

scrcmd_setsprite_position:
    stz <ztmp0
    lda #4
    sta <ztmp1
    bra scrcmd_setsprite_loop

scrcmd_setsprite_pattern:
    lda #4
    sta <ztmp0
    lda #2
    sta <ztmp1
    bra scrcmd_setsprite_loop

scrcmd_setsprite_attribute:
    lda #6
    sta <ztmp0
    lda #2
    sta <ztmp1
    bra scrcmd_setsprite_loop

scrcmd_setbg:
    lda [zscrptr],y
    iny
    sta <zarg0
    lda [zscrptr],y
    iny
    sta <zarg1
    lda [zscrptr],y
    iny
    sta <zarg2
    lda [zscrptr],y
    iny
    sta <zarg3
    lda [zscrptr],y
    iny
    sta <zarg4
    phy
    jsr vqPush
    ply

    jmp scrExecute_next
