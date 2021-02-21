
        .bss
PL_x:   .ds     2
PL_y:   .ds     2


PL_chr: .ds     1

        .code
        .bank   MAIN_BANK

        .if     0

PL_init:
        stz     PL_x
        lda     #$40
        sta     PL_x+1
        stz     PL_y
        lda     #$60
        sta     PL_y+1
        rts

PL_move:
        bbr7    <z_pad,.notleft
.left:
        lda     PL_x
        sec
        sbc     #$80
        sta     PL_x
        lda     PL_x+1
        sbc     #0
        sta     PL_x+1
.notleft:
        bbr5    <z_pad,.notright
.right:
        lda     PL_x
        clc
        adc     #$80
        sta     PL_x
        lda     PL_x+1
        adc     #0
        sta     PL_x+1
.notright:
        bbr4    <z_pad,.notup
.up:
        lda     PL_y
        sec
        sbc     #$80
        sta     PL_y
        lda     PL_y+1
        sbc     #0
        sta     PL_y+1
.notup:
        bbr6    <z_pad,.notdown
.down:
        lda     PL_y
        clc
        adc     #$80
        sta     PL_y
        lda     PL_y+1
        adc     #0
        sta     PL_y+1
.notdown:
        rts

PL_setSatb:
        lda     PL_y            ;5
        asl     a               ;2
        php                     ;3
        lda     PL_y+1          ;5
        sec                     ;2
        sbc     #16/2            ;2
        plp                     ;3
        rol     a               ;2
        sta     satb+8          ;5
        rol     a               ;2
        and     #1              ;2
        sta     satb+9          ;5   38

        lda     PL_x
        asl     a
        php
        lda     PL_x+1
        sec
        sbc     #16/2
        plp
        rol     a
        sta     satb+10
        rol     a
        and     #1
        sta     satb+11

     	lda	#$0f
	sta	satb+12
	lda	#$03		;vram address = $4040 -> $202
	sta	satb+13

	lda	#$80		;priority = sprite & color=1
	sta	satb+14
        lda     #$11
	sta	satb+15

        rts

        .else

PL_init:
        lda     #1
        sta     <z_tmp0
        sta     <z_tmp1
        jsr     CDRVaddChr
        bcs     .ret

        sty     PL_chr

        sxy
        stz     CH_xl,x
        lda     #$40
        sta     CH_xh,x
        stz     CH_yl,x
        lda     #$60
        sta     CH_yh,x

        lda     #$0f
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

        lda     #LOW(PL_move)
        sta     CH_procptrl,x
        lda     #HIGH(PL_move)
        sta     CH_procptrh,x


.ret
        rts


PL_move:
        bbr7    <z_pad,.notleft
.left:
        lda     CH_xl,x
        sec
        sbc     #$80
        sta     CH_xl,x
        lda     CH_xh,x
        sbc     #0
        sta     CH_xh,x
.notleft:
        bbr5    <z_pad,.notright
.right:
        lda     CH_xl,x
        clc
        adc     #$80
        sta     CH_xl,x
        lda     CH_xh,x
        adc     #0
        sta     CH_xh,x
.notright:
        bbr4    <z_pad,.notup
.up:
        lda     CH_yl,x
        sec
        sbc     #$80
        sta     CH_yl,x
        lda     CH_yh,x
        sbc     #0
        sta     CH_yh,x
.notup:
        bbr6    <z_pad,.notdown
.down:
        lda     CH_yl,x
        clc
        adc     #$80
        sta     CH_yl,x
        lda     CH_yh,x
        adc     #0
        sta     CH_yh,x
.notdown:
        clc
        rts

        .endif
