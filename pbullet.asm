    .bss

PB_MAXNUM   .equ    60  ; maximum number of player's bullets
                        ; x coordinate
PB_x0:  .ds PB_MAXNUM
PB_x1:  .ds PB_MAXNUM
PB_x2:  .ds PB_MAXNUM
                        ; y coordinate
PB_y0:  .ds PB_MAXNUM
PB_y1:  .ds PB_MAXNUM
PB_y2:  .ds PB_MAXNUM
                        ; difference
PB_dx0: .ds PB_MAXNUM
PB_dx1: .ds PB_MAXNUM
PB_dx2: .ds PB_MAXNUM

PB_dy0: .ds PB_MAXNUM
PB_dy1: .ds PB_MAXNUM
PB_dy2: .ds PB_MAXNUM
                        ; character number / enable flag
PB_chr0: .ds PB_MAXNUM
PB_chr1: .ds PB_MAXNUM
PB_enable   .equ    PB_chr1

    .code
    .bank   MAIN_BANK

;   initialize
PB_init:
        ; disable all bullets
    stz PB_enable
    tii PB_enable,PB_enable+1,PB_MAXNUM-1

    rts

; move player's bullets
PB_move:
    clx
.loop:
        ; enable?
    tst #$ff,PB_enable,x
    beq .next
        ; add x
    lda PB_x0,x
    clc
    adc PB_dx0,x
    sta PB_x0,x
    lda PB_x1,x
    adc PB_dx1,x
    sta PB_x1,x
    lda PB_x2,x
    adc PB_dx2,x
    sta PB_x2,x
        ; out?
    cmp #$01
    bmi .addy
    lda PB_x1,x
    cmp #$70
    bpl .out
        ; add y
.addy:
    lda PB_y0,x
    clc
    adc PB_dy0,x
    sta PB_y0,x
    lda PB_y1,x
    adc PB_dy1,x
    sta PB_y1,x
    lda PB_y2,x
    adc PB_dy2,x
    sta PB_y2,x
        ; next
.next:
    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts
        ; out of screen
.out:
    stz PB_enable,x
    bra .next

; shoot bullets
;   y = direction (0x00-0x0e)
PB_shoot:
    clx
.loop:
    tst #$ff,PB_enable,x
    beq .found

    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts

.found:
        ; set x
    stz PB_x0,x
    lda <z_sprx
    sta PB_x1,x
    lda <z_sprx+1
    sta PB_x2,x
        ; set y
    stz PB_y0,x
    lda <z_spry
    sta PB_y1,x
    lda <z_spry+1
    sta PB_y2,x
        ; set difference
    lda PB_dx0_table,y
    sta PB_dx0,x
    lda PB_dx1_table,y
    sta PB_dx1,x
    lda PB_dx2_table,y
    sta PB_dx2,x

    lda PB_dy0_table,y
    sta PB_dy0,x
    lda PB_dy1_table,y
    sta PB_dy1,x
    lda PB_dy2_table,y
    sta PB_dy2,x

        ; set character and enable
    lda #$0f
    sta PB_chr0,x
    lda #$03
    sta PB_chr1,x

    rts

;PB_dx0_table:
;    .db $be,$cf,$dd,$e9,$f3,$fa,$fe,$00,$fe,$fa,$f3,$e9,$dd,$cf,$be
;PB_dx1_table:
;    .db $00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00
;PB_dx2_table:
;    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;PB_dy0_table:
;    .db $55,$6a,$81,$98,$b1,$cb,$e6,$00,$1a,$35,$4f,$68,$7f,$96,$ab
;PB_dy1_table:
;    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00
;PB_dy2_table:
;    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00

PB_dx0_table:
    .db $f1,$78,$ed,$4e,$9b,$d3,$f4,$00,$f4,$d3,$9b,$4e,$ed,$78,$f1
PB_dx1_table:
    .db $05,$06,$06,$07,$07,$07,$07,$08,$07,$07,$07,$07,$06,$06,$05
PB_dx2_table:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
PB_dy0_table:
    .db $a6,$4d,$01,$c0,$88,$57,$2a,$00,$d6,$a9,$78,$40,$ff,$b3,$5a
PB_dy1_table:
    .db $fa,$fb,$fc,$fc,$fd,$fe,$ff,$00,$00,$01,$02,$03,$03,$04,$05
PB_dy2_table:
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00

; set player's bullets to satb
PB_setSatb:
    clx
    ldy #4*8
.loop:
        ; enable?
    tst #$ff,PB_enable,x
    beq .next
        ; set y
    lda PB_y1,x
    sta satb,y
    iny
    lda PB_y2,x
    sta satb,y
    iny
        ; set x
    lda PB_x1,x
    sta satb,y
    iny
    lda PB_x2,x
    sta satb,y
    iny
        ; set chr
    lda PB_chr0,x
    sta satb,y
    iny
    lda PB_chr1,x
    sta satb,y
    iny
        ; set attribute
    lda #$80
    sta satb,y
    iny
    cla
    sta satb,y
    iny

.next:
    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts
