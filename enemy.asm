        .bss

EN_MAXNUM   .equ    24  ; maximum number of enemies

EN_type .ds     EN_MAXNUM
EN_procptr_l    .ds EN_MAXNUM
EN_procptr_h    .ds EN_MAXNUM
EN_procptr_tmp  .ds     2       ; jmp address(temporarily used)

                        ; x coordinate
EN_x0:  .ds EN_MAXNUM   ; low
EN_x1:  .ds EN_MAXNUM   ; high
                        ; y coordinate
EN_y0:  .ds EN_MAXNUM   ; low
EN_y1:  .ds EN_MAXNUM   ; high
                        ; direction/enable flag   $80=disabled  $00-$0e=enabled and direction
EN_dir: .ds EN_MAXNUM

EN_dx0: .ds EN_MAXNUM
EN_dx1: .ds EN_MAXNUM
EN_dy0: .ds EN_MAXNUM
EN_dy1: .ds EN_MAXNUM
                        ; character number
                        ; setSatb のコードが冗長になるのでキャラごとにキャッシュ
EN_chr0: .ds EN_MAXNUM
EN_chr1: .ds EN_MAXNUM

        .code
        .bank   MAIN_BANK

        .if 0
                

        
EN_init:
        ; disable all enemies
        stz EN_type
        tii EN_type,EN_type+1,EN_MAXNUM-1

        rts

EN_move:
        clx
.loop:
                ; enable?
        tst #$ff,EN_type,x
        beq .next

        lda     #HIGH(.ret)
        pha
        lda     #LOW(.ret)
        pha
        lda     EN_procptr_l,x
        sta     EN_procptr_tmp        
        lda     EN_procptr_h,x
        sta     EN_procptr_tmp+1        
        jmp     [EN_procptr_tmp]

.ret:
        lda     EN_x0,x
        clc
        adc     EN_dx0,x
        sta     EN_x0,x
        lda     EN_x1,x
        adc     EN_dx1,x
        sta     EN_x1,x

        cmp     #(336+32)/2
        bcs     .out
        cmp     #32/2
        bcc     .out

        lda     EN_y0,x
        clc
        adc     EN_dy0,x
        sta     EN_y0,x
        lda     EN_y1,x
        adc     EN_dy1,x
        sta     EN_y1,x

        cmp     #(240+64)/2
        bcs     .out
        cmp     #64/2
        bcc     .out

                ; next
.next:
        inx
        cpx     #EN_MAXNUM
        bmi     .loop
        rts

                ; out of screen
.out:
        stz EN_type,x
        bra .next





; create enemy
;   y = direction (0x00-0x0e)
EN_create:
        clx
.loop:
        tst #$ff,EN_type,x
        beq .found

        inx
        cpx #EN_MAXNUM
        bmi .loop
        rts

.found:
        ; set x
        lda     <z_tmp0
        sta     EN_x0,x
        lda     <z_tmp1
        sta     EN_x1,x
        ; set y
        lda     <z_tmp2
        sta     EN_y0,x
        lda     <z_tmp3
        sta     EN_y1,x

        lda     <z_tmp4
        sta     EN_type,x

        asl     a
        tay
        lda     EN_proctbl,y
        sta     EN_procptr_l,x
        lda     EN_proctbl+1,y
        sta     EN_procptr_h,x

        lda     #HIGH(.ret)
        pha
        lda     #LOW(.ret)
        pha
        lda     EN_initproctbl,y
        sta     EN_procptr_tmp
        lda     EN_initproctbl+1,y
        sta     EN_procptr_tmp+1
        jmp     [EN_procptr_tmp]

.ret:
        rts

EN_setDirection:
        ; y=direction
        tya
        sta     EN_dir,x

        phx
        lda     #4
        jsr     convDirection2DxDy
        plx

        lda     <z_dir_result_dx
        sta     EN_dx0,x
        lda     <z_dir_result_dx+1
        sta     EN_dx1,x
        lda     <z_dir_result_dy
        sta     EN_dy0,x
        lda     <z_dir_result_dy+1
        sta     EN_dy1,x
        rts


; set enemy's bullets to satb
EN_setSatb:
    clx
    ldy #4*8

    ; satbの前半256バイトの範囲の書き込み
    ; y が８ビットなので、前半後半で分けている
    ; sta (),y で書き込むべきなんだろうか
.loop:
        ; enable?
    tst #$ff,EN_type,x
    beq .next

    lda EN_y0,x
    asl a
    php
    lda EN_y1,x          ;5
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

    lda EN_x0,x
    asl a
    php
    lda EN_x1,x          ;5
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
    lda EN_chr0,x
    sta satb,y
    iny
    lda EN_chr1,x
    sta satb,y
    iny
        ; set attribute
    lda #$80
    sta satb,y
    iny
    lda         #$03
    sta satb,y
    iny
    beq .step2

.next:
    inx
    cpx #EN_MAXNUM
    bmi .loop
    rts

    ; satbの後半256バイトの範囲の書き込み
    ; 絶対アドレスを +256 しておくことで後半256バイトにアクセス
.step2
;    ldy #0
.loop2:
        ; enable?
    tst #$ff,EN_type,x
    beq .next2

    lda EN_y0,x
    asl a
    php
    lda EN_y1,x          ;5
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

    lda EN_x0,x
    asl a
    php
    lda EN_x1,x          ;5
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
    lda EN_chr0,x
    sta satb+256,y
    iny
    lda EN_chr1,x
    sta satb+256,y
    iny
        ; set attribute
    lda #$80
    sta satb+256,y
    iny
    lda         #$03
    sta satb+256,y
    iny

.next2:
    inx
    cpx #EN_MAXNUM
    bmi .loop2
    rts



;------------------------------------------------
;
;
;------------------------------------------------
EN_initproc_dummy:
EN_initproc_test:
        stz     EN_dir,x
        cly
        jsr     EN_setDirection
                ; set character
        lda #$00
        sta EN_chr0,x
        lda #$03
        sta EN_chr1,x

        rts

EN_proc_dummy:
EN_proc_test:
        rts


;------------------------------------------------
;
;
;------------------------------------------------
EN_proctbl:
        .dw     EN_proc_dummy
        .dw     EN_proc_test

EN_initproctbl:
        .dw     EN_initproc_dummy
        .dw     EN_initproc_test


        .else

ENcreate:
        lda     #7
        sta     <z_tmp0
        sta     <z_tmp1
        jsr     CDRVaddChr
        bcs     .ret

        sxy

        stz     CH_xl,x
        lda     #320/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #$00
        sta     CH_sprpatl,x
        lda     #$03
        sta     CH_sprpath,x

        lda     #$80
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #LOW(ENmove)
        sta     CH_procptrl,x
        lda     #HIGH(ENmove)
        sta     CH_procptrh,x


        phx
        lda     #4
        ldy     #0
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
.ret:
        rts


ENmove:
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
