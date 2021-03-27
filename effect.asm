        .code
        .bank   MAIN_BANK


EFcreateExplosion:
        lda     #CDRV_ROLE_EFFECT
        sta     <z_tmp0
        lda     #CDRV_SPR_EFFECT
        sta     <z_tmp1
        stz     <z_tmp2
        jsr     CDRVaddChr
        bcc     .init
        rts
.init:
        phx
                        ;y=new chr
        lda     CH_xl,x
        sta     CH_xl,y
        lda     CH_xh,x
        sta     CH_xh,y
        lda     CH_yl,x
        sta     CH_yl,y
        lda     CH_yh,x
        sta     CH_yh,y

        lda     #LOW(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,y
        lda     #HIGH(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)
        sta     CH_sprpath,y

        lda     #$84
        sta     CH_spratrl,y
        lda     #$11
        sta     CH_spratrh,y

;        lda     #16/2
;        sta     CH_sprdx,x
;        sta     CH_sprdy,x

        lda     #8
        sta     CH_coldx,y
        sta     CH_coldy,y

;        lda     #4
;        sta     CH_regist,x

;        lda     #1
;        sta     CH_damaged_class,x

        lda     #LOW(EFExplosion_move)
        sta     CH_procptrl,y
        lda     #HIGH(EFExplosion_move)
        sta     CH_procptrh,y

        cla
        sta     CH_var0,y

        plx
        clc
        rts

EFExplosion_move:
        tst	#$03,<z_frame
	bne	.skip

        lda     CH_var0,x
        inc     a
        cmp     #5
        bcs     .end
        sta     CH_var0,x

        tay
        lda     .pattern_l,y
        sta     CH_sprpatl,x
        lda     .pattern_h,y
        sta     CH_sprpath,x

.skip:
        clc
.end:
        rts
.pattern_l:
        .db     LOW(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_exp01-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_exp02-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_exp01-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)
.pattern_h:
        .db     HIGH(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_exp01-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_exp02-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_exp01-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_exp00-spr_pattern)/2+$4000)/32)

;-----------------------------

