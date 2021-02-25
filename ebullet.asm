    .bss

EB_MAXNUM   .equ    24  ; maximum number of player's bullets
                        ; x coordinate
EB_x0:  .ds EB_MAXNUM   ; low
EB_x1:  .ds EB_MAXNUM   ; high
                        ; y coordinate
EB_y0:  .ds EB_MAXNUM   ; low
EB_y1:  .ds EB_MAXNUM   ; high
                        ; direction/enable flag   $80=disabled  $00-$0e=enabled and direction
EB_dir: .ds EB_MAXNUM

EB_dx0: .ds EB_MAXNUM
EB_dx1: .ds EB_MAXNUM
EB_dy0: .ds EB_MAXNUM
EB_dy1: .ds EB_MAXNUM
                        ; character number
                        ; setSatb のコードが冗長になるのでキャラごとにキャッシュ
EB_chr0: .ds EB_MAXNUM
EB_chr1: .ds EB_MAXNUM

    .code
    .bank   MAIN_BANK

        .if     0

EB_init:
        ; disable all bullets
    lda #$80
    sta EB_dir
    tii EB_dir,EB_dir+1,EB_MAXNUM-1

    rts

EB_move:
        clx
.loop:
                ; enable?
        tst #$80,EB_dir,x
        bne .next

        .if     0
        ldy     EB_dir,x

        lda     EB_x0,x
        clc
        adc     dirtable_x_l,y
        sta     EB_x0,x
        lda     EB_x1,x
        adc     dirtable_x_h,y
        sta     EB_x1,x
        .else
        lda     EB_x0,x
        clc
        adc     EB_dx0,x
        sta     EB_x0,x
        lda     EB_x1,x
        adc     EB_dx1,x
        sta     EB_x1,x
        .endif

        cmp     #(336+32)/2
        bcs     .out
        cmp     #32/2
        bcc     .out

        .if     0
        lda     EB_y0,x
        clc
        adc     dirtable_y_l,y
        sta     EB_y0,x
        lda     EB_y1,x
        adc     dirtable_y_h,y
        sta     EB_y1,x
        .else
        lda     EB_y0,x
        clc
        adc     EB_dy0,x
        sta     EB_y0,x
        lda     EB_y1,x
        adc     EB_dy1,x
        sta     EB_y1,x
        .endif

        cmp     #(240+64)/2
        bcs     .out
        cmp     #64/2
        bcc     .out

                ; next
.next:
        inx
        cpx     #EB_MAXNUM
        bmi     .loop
        rts

                ; out of screen
.out:
        lda #$80
        sta EB_dir,x
        bra .next


; shoot enemny bullets
;   y = direction (0x00-0x0e)
EB_shoot:
    clx
.loop:
    tst #$80,EB_dir,x
    bne .found

    inx
    cpx #EB_MAXNUM
    bmi .loop
    rts

.found:
        ; set x
    stz EB_x0,x
    lda #300/2
    sta EB_x1,x
        ; set y
    stz EB_y0,x
    lda #140/2
    sta EB_y1,x

        .if     0
    tya
    sta EB_dir,x
        .endif

        ; set character
    lda #$20
    sta EB_chr0,x
    lda #$03
    sta EB_chr1,x

        .if     1
        phx
        lda     #4
        jsr     convDirection2DxDy
        plx

        lda     <z_dir_result_dx
        sta     EB_dx0,x
        lda     <z_dir_result_dx+1
        sta     EB_dx1,x
        lda     <z_dir_result_dy
        sta     EB_dy0,x
        lda     <z_dir_result_dy+1
        sta     EB_dy1,x

        stz     EB_dir,x
        .endif

    rts



; set enemy's bullets to satb
EB_setSatb:
    clx
    ldy #4*8

    ; satbの前半256バイトの範囲の書き込み
    ; y が８ビットなので、前半後半で分けている
    ; sta (),y で書き込むべきなんだろうか
.loop:
        ; enable?
    tst #$80,EB_dir,x
    bne .next

    lda EB_y0,x
    asl a
    php
    lda EB_y1,x          ;5
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

    lda EB_x0,x
    asl a
    php
    lda EB_x1,x          ;5
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
    lda EB_chr0,x
    sta satb,y
    iny
    lda EB_chr1,x
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
    cpx #EB_MAXNUM
    bmi .loop
    rts

    ; satbの後半256バイトの範囲の書き込み
    ; 絶対アドレスを +256 しておくことで後半256バイトにアクセス
.step2
;    ldy #0
.loop2:
        ; enable?
    tst #$80,EB_dir,x
    bne .next2

    lda EB_y0,x
    asl a
    php
    lda EB_y1,x          ;5
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

    lda EB_x0,x
    asl a
    php
    lda EB_x1,x          ;5
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
    lda EB_chr0,x
    sta satb+256,y
    iny
    lda EB_chr1,x
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
    cpx #EB_MAXNUM
    bmi .loop2
    rts


        .else

EB_shoot:
        phx

        phy

        lda     #2
        sta     <z_tmp0
        sta     <z_tmp1
        jsr     CDRVaddChr
        bcs     .ret

        sxy
                    ;y = source chr  x = new chr
        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sta     CH_yh,x

        lda     #$20
        sta     CH_sprpatl,x
        lda     #$03
        sta     CH_sprpath,x

        lda     #$80
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #8/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #LOW(EB_move)
        sta     CH_procptrl,x
        lda     #HIGH(EB_move)
        sta     CH_procptrh,x

        ply             ; y = direction

        phx
        lda     #4
        jsr     convDirection2DxDy
        plx

        lda     <z_dir_result_dx
        sta     CH_dxl,x
        lda     <z_dir_result_dx+1
        sta     CH_dxh,x
        lda     <z_dir_result_dy
        sta     CH_dyl,x
        lda     <z_dir_result_dy+1
        sta     CH_dyh,x

        plx
        rts

.ret:
        ply
        plx
        rts


EB_move:
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
;        jsr     CDRVremoveChr
        sec
        rts

        .endif