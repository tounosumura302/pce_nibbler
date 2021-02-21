
        .bss
PL_x:   .ds     2
PL_y:   .ds     2


PL_chr: .ds     1       ;プレイヤーのキャラ番号

        .code
        .bank   MAIN_BANK
PL_init:
        lda     #1
        sta     <z_tmp0
        sta     <z_tmp1
        jsr     CDRVaddChr
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
                ; shoot
	bbr0	<z_paddelta,.notshoot

	ldy	#3
	jsr	PBshoot
.notshoot:

        clc
        rts

