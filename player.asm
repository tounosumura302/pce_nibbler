
        .bss
;PL_x:   .ds     2
;PL_y:   .ds     2


PL_chr: .ds     1       ;プレイヤーのキャラ番号

        .zp
PL_speed:       .ds     2       ; speed

        .code
        .bank   MAIN_BANK
PL_init:
        lda     #CDRV_ROLE_PLAYER
        sta     <z_tmp0
        lda     #CDRV_SPR_PLAYER
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

        lda     #LOW(((spr_pattern_pl-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern_pl-spr_pattern)/2+$4000)/32)
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

        lda     #$00
        sta     PL_speed
        lda     #$01
        sta     PL_speed+1

        rts


PL_move:
        bbr7    <z_pad,.notleft
.left:
        lda     CH_xl,x
        sec
;        sbc     #$80
        sbc     <PL_speed
        sta     CH_xl,x
        lda     CH_xh,x
;        sbc     #0
        sbc     <PL_speed+1
        cmp     #(32+16)/2
        bcs     .leftok
        stz     CH_xl,x
        lda     #(32+16)/2
.leftok:
        sta     CH_xh,x

.notleft:
        bbr5    <z_pad,.notright
.right:
        lda     CH_xl,x
        clc
;        adc     #$80
        adc     <PL_speed
        sta     CH_xl,x
        lda     CH_xh,x
;        adc     #0
        adc     <PL_speed+1
        cmp     #(320+32-16)/2
        bcc     .rightok
        stz     CH_xl,x
        lda     #(320+32-16)/2
.rightok:
        sta     CH_xh,x

.notright:
        bbr4    <z_pad,.notup
.up:
        lda     CH_yl,x
        sec
;        sbc     #$80
        sbc     <PL_speed
        sta     CH_yl,x
        lda     CH_yh,x
;        sbc     #0
        sbc     <PL_speed+1
        cmp     #(64+16)/2
        bcs     .upok
        stz     CH_yl,x
        lda     #(64+16)/2
.upok:
        sta     CH_yh,x

.notup:
        bbr6    <z_pad,.notdown
.down:
        lda     CH_yl,x
        clc
;        adc     #$80
        adc     <PL_speed
        sta     CH_yl,x
        lda     CH_yh,x
;        adc     #0
        adc     <PL_speed+1
        cmp     #(240+64-16)/2
        bcc     .downok
        stz     CH_yl,x
        lda     #(240+64-16)/2
.downok:
        sta     CH_yh,x
.notdown:

                ; scroll
	lda	CH_yh,x
	sec
	sbc	#(64+16)/2
	tay
	lda	ScrollX,y
	sta	scry
	stz	scry+1

                ; shoot
	bbr0	<z_paddelta,.notshoot

	ldy	#3
	jsr	PBshoot
.notshoot:

        clc
        rts

PLdead:
        clc
        rts
