; 自機弾処理　のテスト
; 弾の構造体へのアクセスを absolute,x でやれるようにするために、
; 構造体メンバーを1バイトずつに分け、それぞれを個別の配列となるよう配置。
; x は弾のインデックスとなる

    .bss

PB_MAXNUM   .equ    60  ; maximum number of player's bullets
                        ; x coordinate
PB_x0:  .ds PB_MAXNUM   ; fraction
PB_x1:  .ds PB_MAXNUM   ; integer(low)
PB_x2:  .ds PB_MAXNUM   ; integer(high)
                        ; y coordinate
PB_y0:  .ds PB_MAXNUM   ; fraction
PB_y1:  .ds PB_MAXNUM   ; integer(low)
PB_y2:  .ds PB_MAXNUM   ; integer(high)
                        ; direction/enable flag   $80=disabled  $00-$0e=enabled and direction
PB_dir: .ds PB_MAXNUM
                        ; character number
                        ; setSatb のコードが冗長になるのでキャラごとにキャッシュ
PB_chr0: .ds PB_MAXNUM
PB_chr1: .ds PB_MAXNUM

    .code
    .bank   MAIN_BANK

;   initialize
PB_init:
        ; disable all bullets
;    stz PB_enable
;    tii PB_enable,PB_enable+1,PB_MAXNUM-1
    lda #$80
    sta PB_dir
    tii PB_dir,PB_dir+1,PB_MAXNUM-1

    rts

; move player's bullets
PB_move:
    clx
.loop:
        ; enable?
;    tst #$ff,PB_enable,x
;    beq .next
    tst #$80,PB_dir,x
    bne .next

    ldy PB_dir,x

        ; add x
    lda PB_x0,x
    clc
;    adc PB_dx0,x
    adc PB_dx0_table,y
    sta PB_x0,x
    lda PB_x1,x
;    adc PB_dx1,x
    adc PB_dx1_table,y
    sta PB_x1,x
    lda PB_x2,x
;    adc PB_dx2,x
    adc PB_dx2_table,y
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
;    adc PB_dy0,x
    adc PB_dy0_table,y
    sta PB_y0,x
    lda PB_y1,x
;    adc PB_dy1,x
    adc PB_dy1_table,y
    sta PB_y1,x
    lda PB_y2,x
;    adc PB_dy2,x
    adc PB_dy2_table,y
    sta PB_y2,x
        ; next
.next:
    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts
        ; out of screen
.out:
;    stz PB_enable,x
    lda #$80
    sta PB_dir,x
    bra .next

; shoot bullets
;   y = direction (0x00-0x0e)
PB_shoot:
    clx
.loop:
;    tst #$ff,PB_enable,x
;    beq .found
    tst #$80,PB_dir,x
    bne .found

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
;    lda PB_dx0_table,y
;    sta PB_dx0,x
;    lda PB_dx1_table,y
;    sta PB_dx1,x
;    lda PB_dx2_table,y
;    sta PB_dx2,x

;    lda PB_dy0_table,y
;    sta PB_dy0,x
;    lda PB_dy1_table,y
;    sta PB_dy1,x
;    lda PB_dy2_table,y
;    sta PB_dy2,x

    tya
    sta PB_dir,x

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

    ; satbの前半256バイトの範囲の書き込み
    ; y が８ビットなので、前半後半で分けている
    ; sta (),y で書き込むべきなんだろうか
.loop:
        ; enable?
;    tst #$ff,PB_enable,x
;    beq .next
    tst #$80,PB_dir,x
    bne .next
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
    beq .step2

.next:
    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts

    ; satbの後半256バイトの範囲の書き込み
    ; 絶対アドレスを +256 しておくことで後半256バイトにアクセス
.step2
;    ldy #0
.loop2:
        ; enable?
;    tst #$ff,PB_enable,x
;    beq .next2
    tst #$80,PB_dir,x
    bne .next2
        ; set y
    lda PB_y1,x
    sta satb+256,y
    iny
    lda PB_y2,x
    sta satb+256,y
    iny
        ; set x
    lda PB_x1,x
    sta satb+256,y
    iny
    lda PB_x2,x
    sta satb+256,y
    iny
        ; set chr
    lda PB_chr0,x
    sta satb+256,y
    iny
    lda PB_chr1,x
    sta satb+256,y
    iny
        ; set attribute
    lda #$80
    sta satb+256,y
    iny
    cla
    sta satb+256,y
    iny

.next2:
    inx
    cpx #PB_MAXNUM
    bmi .loop2
    rts
