; 自機弾処理　のテスト
; 弾の構造体へのアクセスを absolute,x でやれるようにするために、
; 構造体メンバーを1バイトずつに分け、それぞれを個別の配列となるよう配置。
; x は弾のインデックスとなる
;
; ４連射であることを前提としたコードになっている

    .bss

PB_MAXSLOT  .equ    4
PB_MAXNUM   .equ    PB_MAXSLOT*15  ; maximum number of player's bullets

PB_slotcount:   .ds PB_MAXSLOT
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

        .if 0

;   initialize
PB_init:
        ; disable all bullets
    lda #$80
    sta PB_dir
    tii PB_dir,PB_dir+1,PB_MAXNUM-1

        ; 4連射が前提
    stz PB_slotcount
    stz PB_slotcount+1
    stz PB_slotcount+2
    stz PB_slotcount+3

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
        ; out?
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
        ; 
    txa
    sxy
    and #3
    tax
    dec PB_slotcount,x
    sxy

    bra .next

; shoot bullets
;   y = level(0-3)
PB_shoot:
    clx
.loop:
    lda PB_slotcount,x
    beq .found

    inx
    cpx #PB_MAXSLOT
    bmi .loop
.end:
    rts

.found:
    lda PB_level_num,y
    sta PB_slotcount,x

    lda PB_level_table,y
    tay

.loop2:
    lda PB_level0,y
    bmi .end
    sta PB_dir,x

        ; set x
    lda PL_x
    sta PB_x0,x
    lda PL_x+1
    sta PB_x1,x
    lda PL_y
    sta PB_y0,x
    lda PL_y+1
    sta PB_y1,x

        ; set character and enable
    lda #$20
    sta PB_chr0,x
    lda #$03
    sta PB_chr1,x

    iny
    inx
    inx
    inx
    inx
    bra .loop2


        ; number of bullet per 1 shot
PB_level_num:
    .db 3,5,9,15
        ; direction table for each level
PB_level_table:
    .db 0,PB_level1-PB_level0,PB_level2-PB_level0,PB_level3-PB_level0
PB_level0:
    .db 0,7,14,$ff
PB_level1:
    .db 0,3,7,11,14,$ff
PB_level2:
    .db 0,1,2,6,7,8,12,13,14,$ff
PB_level3:
    .db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,$ff

        ; 方向別移動量
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

    .else
        ; number of bullet per 1 shot
;PB_level_num:
;    .db 3,5,9,15
        ; direction table for each level
PB_level_table:
    .db 0,PB_level1-PB_level0,PB_level2-PB_level0,PB_level3-PB_level0
PB_level0:
    .db 0,7,14,$ff
PB_level1:
    .db 0,3,7,11,14,$ff
PB_level2:
    .db 0,1,2,6,7,8,12,13,14,$ff
PB_level3:
    .db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,$ff

        ; 方向別移動量
PB_dxl_table:
    .db $f8,$3c,$76,$a7,$cd,$e9,$fa,$00,$fa,$e9,$cd,$a7,$76,$3c,$f8
PB_dxh_table:
    .db $02,$03,$03,$03,$03,$03,$03,$04,$03,$03,$03,$03,$03,$03,$02
PB_dyl_table:
    .db $53,$a7,$01,$60,$c4,$2c,$95,$00,$6b,$d4,$3c,$a0,$ff,$59,$ad
PB_dyh_table:
    .db $fd,$fd,$fe,$fe,$fe,$ff,$ff,$00,$00,$00,$01,$01,$01,$02,$02

PBshoot:
        phx
        ldx     #3
.loop:
        lda     CDrv_role_class_chrnum,x
        beq     .shoot
        inx
        cpx     #3+4
        bne     .loop
.end:
        plx
        rts

.shoot:
        stx     <z_tmp0     ; role class
        lda     #3
        sta     <z_tmp1     ; sprite class

        ldx     PL_chr
        lda     CH_xl,x
        sta     <z_tmp2
        lda     CH_xh,x
        sta     <z_tmp3
        lda     CH_yl,x
        sta     <z_tmp4
        lda     CH_yh,x
        sta     <z_tmp5

        lda     PB_level_table,y
        tay
.loop2:
        lda     PB_level0,y
        bmi     .end

        phy

        pha
        jsr     CDRVaddChr
        plx
        bcs     .end

        lda     PB_dxl_table,x
        sta     CH_dxl,y
        lda     PB_dxh_table,x
        sta     CH_dxh,y
        lda     PB_dyl_table,x
        sta     CH_dyl,y
        lda     PB_dyh_table,x
        sta     CH_dyh,y

        lda     <z_tmp2
        sta     CH_xl,y
        lda     <z_tmp3
        sta     CH_xh,y
        lda     <z_tmp4
        sta     CH_yl,y
        lda     <z_tmp5
        sta     CH_yh,y

        lda     #$20
        sta     CH_sprpatl,y
        lda     #$03
        sta     CH_sprpath,y

        lda     #$80
        sta     CH_spratrl,y
        lda     #$11
        sta     CH_spratrh,y

        lda     #8/2
        sta     CH_sprdx,y
        sta     CH_sprdy,y

        lda     #LOW(PBmove)
        sta     CH_procptrl,y
        lda     #HIGH(PBmove)
        sta     CH_procptrh,y

        ply
        iny
        bra     .loop2

;
;
;
PBmove:
        lda     CH_xl,x
        clc
        adc     CH_dxl,x
        sta     CH_xl,x
        lda     CH_xh,x
        adc     CH_dxh,x
        sta     CH_xh,x

        cmp     #(336+32)/2
        bcs     .out
        cmp     #32/2
        bcc     .out

        lda     CH_yl,x
        clc
        adc     CH_dyl,x
        sta     CH_yl,x
        lda     CH_yh,x
        adc     CH_dyh,x
        sta     CH_yh,x

        cmp     #(240+64)/2
        bcs     .out
        cmp     #64/2
        bcc     .out

        clc
        rts
                ; out of screen
.out:
        sec
        rts


    .endif
