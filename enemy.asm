        
        .code
        .bank   MAIN_BANK


ENcreate:
        lda     #7
        sta     <z_tmp0
        sta     <z_tmp1
        jsr     CDRVaddChr
        bcs     .ret

        sxy

        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
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

        lda     #8
        sta     CH_coldx,x
        sta     CH_coldy,x

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

                        ; shoot
       	tst	#$07,<z_frame
	bne	.skipeb

	ldy	PL_chr
	lda	CH_xh,y
	sta	<z_dir_targetx
	lda	CH_yh,y
	sta	<z_dir_targety
	lda	CH_xh,x
	sta	<z_dir_sourcex
	lda	CH_yh,x
	sta	<z_dir_sourcey

	jsr	getDirection
	tay
	jsr	EB_shoot
.skipeb:

        clc
        rts
                ; out of screen
.out:
;        jsr     CDRVremoveChr
        sec
        rts


ENdead:
        sec
        rts

