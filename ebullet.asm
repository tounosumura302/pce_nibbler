
    .code
    .bank   MAIN_BANK


EB_shoot:
        phx

        phy

        lda     #CDRV_ROLE_EBULLET
        sta     <z_tmp0
        lda     #CDRV_SPR_EBULLET
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

        lda     #LOW(((spr_pattern_eb-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern_eb-spr_pattern)/2+$4000)/32)
        sta     CH_sprpath,x

        lda     #$80
        sta     CH_spratrl,x
        lda     #$00
        sta     CH_spratrh,x

        lda     #4/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #2
        sta     CH_coldx,x
        sta     CH_coldy,x

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

