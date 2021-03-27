        .code
        .bank   MAIN_BANK


EFcreateExplosion:
        lda     #CDRV_ROLE_EFFECT
        sta     <z_tmp0
        lda     #CDRV_SPR_EFFECT_G
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

EFcreateDamagedFire:
.arg_dy .equ    z_tmp3
        lda     #CDRV_ROLE_EFFECT
        sta     <z_tmp0
        lda     #CDRV_SPR_EFFECT_DAMAGE
        sta     <z_tmp1
        stx     <z_tmp2
        jsr     CDRVaddChr
        bcc     .init
        rts
.init:
        phx
                        ;y=new chr
        lda     <.arg_dy
        sta     CH_var0,y
;        lda     CH_xl,x
;        sta     CH_xl,y
;        lda     CH_xh,x
;        sec
;        sbc     #8/2
;        sta     CH_xh,y
;        lda     CH_yl,x
;        sta     CH_yl,y
;        lda     CH_yh,x
;        clc
;        adc     <.arg_dy
;        sta     CH_yh,y

        lda     #LOW(((spr_pattern2_damaged_fire-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,y
        lda     #HIGH(((spr_pattern2_damaged_fire-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,y

        lda     #$84
        sta     CH_spratrl,y
        lda     #$01
        sta     CH_spratrh,y

        lda     #32/2
        sta     CH_sprdx,y
        lda     #16/2
        sta     CH_sprdy,y

;        lda     #8
;        sta     CH_coldx,y
;        sta     CH_coldy,y

;        lda     #4
;        sta     CH_regist,x

;        lda     #1
;        sta     CH_damaged_class,x

        lda     #LOW(EFDamagedFire_move)
        sta     CH_procptrl,y
        lda     #HIGH(EFDamagedFire_move)
        sta     CH_procptrh,y

;        cla
;        sta     CH_var0,y

        plx
        clc
        rts

EFDamagedFire_move:
        lda     CH_grp_parent,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        clc
        adc     #4
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        clc
        adc     CH_var0,x
        sta     CH_yh,x

        tst	#$03,<z_frame
	bne	.end

;        lda     CH_var0,x
;        inc     a
;        cmp     #5
;        bcs     .end
;        sta     CH_var0,x

        lda     CH_spratrh,x
        eor     #$80
        sta     CH_spratrh,x

.end:
        clc
        rts
