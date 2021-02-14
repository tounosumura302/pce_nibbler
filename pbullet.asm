; 自機弾処理　のテスト
; 弾の構造体へのアクセスを absolute,x でやれるようにするために、
; 構造体メンバーを1バイトずつに分け、それぞれを個別の配列となるよう配置。
; x は弾のインデックスとなる

    .bss

PB_MAXNUM   .equ    60  ; maximum number of player's bullets
                        ; x coordinate
PB_x0:  .ds PB_MAXNUM   ; low
PB_x1:  .ds PB_MAXNUM   ; high
                        ; y coordinate
PB_y0:  .ds PB_MAXNUM   ; low
PB_y1:  .ds PB_MAXNUM   ; high
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
    lda #$80
    sta PB_dir
    tii PB_dir,PB_dir+1,PB_MAXNUM-1

    rts

; move player's bullets
PB_move:
    clx
.loop:
        ; enable?
    tst #$80,PB_dir,x
    bne .next

    ldy PB_dir,x

        ; add x
    lda PB_x0,x
    clc
    adc PB_dx0_table,y
    sta PB_x0,x
    lda PB_x1,x
    adc PB_dx1_table,y
    sta PB_x1,x
        ; out?
    cmp #184
    bcs .out
    cmp #16
    bcc .out

        ; add y
.addy:
    lda PB_y0,x
    clc
    adc PB_dy0_table,y
    sta PB_y0,x
    lda PB_y1,x
    adc PB_dy1_table,y
    sta PB_y1,x

    cmp #152
    bcs .out
    cmp #32
    bcc .out

        ; next
.next:
    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts
        ; out of screen
.out:
    lda #$80
    sta PB_dir,x
    bra .next

; shoot bullets
;   y = direction (0x00-0x0e)
PB_shoot:
    clx
.loop:
    tst #$80,PB_dir,x
    bne .found

    inx
    cpx #PB_MAXNUM
    bmi .loop
    rts

.found:
        ; set x
    lda PL_x
    sta PB_x0,x
    lda PL_x+1
    sta PB_x1,x
    lda PL_y
    sta PB_y0,x
    lda PL_y+1
    sta PB_y1,x

    tya
    sta PB_dir,x

        ; set character and enable
    lda #$0f
    sta PB_chr0,x
    lda #$03
    sta PB_chr1,x

    rts

PB_dx0_table:
    .db $f8,$3c,$76,$a7,$cd,$e9,$fa,$00,$fa,$e9,$cd,$a7,$76,$3c,$f8
PB_dx1_table:
    .db $02,$03,$03,$03,$03,$03,$03,$04,$03,$03,$03,$03,$03,$03,$02
PB_dy0_table:
    .db $53,$a7,$01,$60,$c4,$2c,$95,$00,$6b,$d4,$3c,$a0,$ff,$59,$ad
PB_dy1_table:
    .db $fd,$fd,$fe,$fe,$fe,$ff,$ff,$00,$00,$00,$01,$01,$01,$02,$02

; set player's bullets to satb
PB_setSatb:
    clx
    ldy #4*8

    ; satbの前半256バイトの範囲の書き込み
    ; y が８ビットなので、前半後半で分けている
    ; sta (),y で書き込むべきなんだろうか
.loop:
        ; enable?
    tst #$80,PB_dir,x
    bne .next
    lda PB_y0,x
    asl a
    php
    lda PB_y1,x          ;5
    sec                     ;2
    sbc     #8/2            ;2
    plp                     ;3
    rol     a               ;2
    sta     satb,y          ;5
    iny
    rol     a               ;2
    and     #1              ;2
    sta     satb,y          ;5   38
    iny

    lda PB_x0,x
    asl a
    php
    lda PB_x1,x          ;5
    sec                     ;2
    sbc     #8/2            ;2
    plp                     ;3
    rol     a               ;2
    sta     satb,y          ;5
    iny
    rol     a               ;2
    and     #1              ;2
    sta     satb,y          ;5   38
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
    tst #$80,PB_dir,x
    bne .next2

    lda PB_y0,x
    asl a
    php
    lda PB_y1,x          ;5
        sec                     ;2
        sbc     #8/2            ;2
        plp                     ;3
        rol     a               ;2
        sta     satb+256,y          ;5
        iny
        rol     a               ;2
        and     #1              ;2
        sta     satb+256,y          ;5   38
        iny

    lda PB_x0,x
    asl a
    php
    lda PB_x1,x          ;5
        sec                     ;2
        sbc     #8/2            ;2
        plp                     ;3
        rol     a               ;2
        sta     satb+256,y          ;5
        iny
        rol     a               ;2
        and     #1              ;2
        sta     satb+256,y          ;5   38
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
