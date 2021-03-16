        .zp
z_last_new_chr  .ds     1       ;直前に生成されたキャラクタ番号（複数キャラが連携している場合に使う）


        .code
        .bank   MAIN_BANK

;------------------------------
; @experimental
;  複数キャラの組み合わせ

ENcreate_Tank:
        ldy     #1
        jsr     ENcreate

        bcs     .ret
        phy

        ldy     #2
        jsr     ENcreate
        bcs     .ret2

        pla             ;tank
        sta     CH_var0,y       ;戦車のキャラクタ番号を砲塔にセット
        tax
        tya
        sta     CH_var0,x       ;砲塔のキャラクタ番号を戦車にセット
.ret:
        rts
.ret2:
        plx
        stz     CH_var0,x       ;砲塔のキャラクタ番号を戦車にセット
        rts




ENcreate_Big:
        stz     <z_tmp11
        stz     <z_tmp12
        stz     <z_tmp13
        stz     <z_tmp14
        stz     <z_tmp15

        ldy     #3
        jsr     ENcreate

        bcs     .ret
        sty     <z_tmp11

        ldy     #4
        jsr     ENcreate
        bcs     .ret2
        sty     <z_tmp12

        ldy     #5
        jsr     ENcreate
        bcs     .ret2
        sty     <z_tmp13

        ldy     #6
        jsr     ENcreate
        bcs     .ret2
        sty     <z_tmp14

        ldy     #7
        jsr     ENcreate
        bcs     .ret2
        sty     <z_tmp15


.ret2:
                ;本体にパーツをセット
        ldx     <z_tmp11
        lda     <z_tmp12
        sta     CH_var0,x
        lda     <z_tmp13
        sta     CH_var1,x
        lda     <z_tmp14
        sta     CH_var2,x
        lda     <z_tmp15
        sta     CH_var3,x

                ;パーツに本体をセット
        lda     <z_tmp11
        ldx     <z_tmp12
        sta     CH_var0,x
        ldx     <z_tmp13
        sta     CH_var0,x
        ldx     <z_tmp14
        sta     CH_var0,x
        ldx     <z_tmp15
        sta     CH_var0,x
.ret:
        rts


;------------------------------

; @return       y       キャラ番号
;               c flag  1ならキャラ割り当て失敗
; @savereg      x
ENcreate:
        phy
        lda     ENRoleClassTable,y
        sta     <z_tmp0
        lda     ENSpriteClassTable,y
        sta     <z_tmp1
        jsr     CDRVaddChr
        bcc     .init

        stz     <z_last_new_chr
        ply
        cly
        rts
.init:
        pla             ;a=enemy type
        phx             ;save current chrno
        sxy             ;x=new chrno
        tay             ;y=enemy type

        ;stz     CH_flag,x
;####        stz     CH_damaged_class,x

        lda     #HIGH(.end-1)       ;要注意 pushするのは 戻りアドレス-1
        pha
        lda     #LOW(.end-1)
        pha

        lda     ENInitProcTableLow,y
        sta     <z_tmp0
        lda     ENInitProcTableHigh,y
        sta     <z_tmp1

        jmp     [z_tmp0]
.end:
        stx     <z_last_new_chr
        sxy
        plx             ;restore chrno
        clc
        rts

ENRoleClassTable:
        .db     0
                ;戦車
        .db     CDRV_ROLE_ENEMY_G1
        .db     CDRV_ROLE_ENEMY_G2
                ;大型機
        .db     CDRV_ROLE_ENEMY_S1
        .db     CDRV_ROLE_ENEMY_S2
        .db     CDRV_ROLE_ENEMY_S2
        .db     CDRV_ROLE_ENEMY_S2
        .db     CDRV_ROLE_ENEMY_S2

ENSpriteClassTable:
        .db     0
                ;戦車
        .db     CDRV_SPR_ENEMY_G1
        .db     CDRV_SPR_ENEMY_G2
                ;大型機
        .db     CDRV_SPR_ENEMY_S1
        .db     CDRV_SPR_ENEMY_S2
        .db     CDRV_SPR_ENEMY_S2
        .db     CDRV_SPR_ENEMY_S2
        .db     CDRV_SPR_ENEMY_S2




ENInitProcTableLow:
        .db     LOW(ENDummy_init)

        .db     LOW(ENTank_init)
        .db     LOW(ENTankTurret_init)

        .db     LOW(ENBig_main_init)
        .db     LOW(ENBig_sub0_init)
        .db     LOW(ENBig_sub1_init)
        .db     LOW(ENBig_sub2_init)
        .db     LOW(ENBig_sub3_init)

ENInitProcTableHigh:
        .db     HIGH(ENDummy_init)

        .db     HIGH(ENTank_init)
        .db     HIGH(ENTankTurret_init)

        .db     HIGH(ENBig_main_init)
        .db     HIGH(ENBig_sub0_init)
        .db     HIGH(ENBig_sub1_init)
        .db     HIGH(ENBig_sub2_init)
        .db     HIGH(ENBig_sub3_init)

;------------------------------------------------

ENDummy_init:
        rts

ENTank_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #LOW(((spr_pattern_en-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern_en-spr_pattern)/2+$4000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #8
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #4
        sta     CH_regist,x

        lda     #1
        sta     CH_damaged_class,x

        lda     #LOW(ENTank_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENTank_move)
        sta     CH_procptrh,x


        phx
        lda     #2
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

        rts


ENTankTurret_init:
        ldy     <z_last_new_chr

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sta     CH_yh,x

        lda     #LOW(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #0
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #LOW(ENTankTurret_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENTankTurret_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        tya
        sta     CH_var0,x               ;戦車本体のキャラクタ番号

        rts



ENBig_main_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
;        lda     <z_frame
;        asl     a
        lda     #(64+128)/2
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_big_02-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_big_02-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #16/2
        sta     CH_coldx,x
        lda     #40/2
        sta     CH_coldy,x

        lda     #16
        sta     CH_regist,x

        lda     #2
        sta     CH_damaged_class,x

        lda     #LOW(ENBig_main_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_main_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        lda     #0
        sta     CH_dxl,x
        lda     #$ff
        sta     CH_dxh,x
        lda     #0
        sta     CH_dyl,x
        sta     CH_dyh,x

        rts

ENBig_sub0_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_big_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_big_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #0
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #LOW(ENBig_sub0_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_sub0_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        rts

ENBig_sub1_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_big_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_big_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$91
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #0
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #LOW(ENBig_sub1_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_sub1_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        rts

ENBig_sub2_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_big_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_big_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #0
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #LOW(ENBig_sub2_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_sub2_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        rts

ENBig_sub3_init:
        stz     CH_xl,x
        lda     #(336+$20)/2
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_frame
        asl     a
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_big_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_big_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$83
        sta     CH_spratrl,x
        lda     #$91
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #0
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #LOW(ENBig_sub3_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_sub3_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        rts

;----------------------------------------------------------------

;
; @experimental
;  ダメージを受けた時の処理
;
ENTank_damaged:
        lda     CH_regist,x
        cmp     #2+1
        bcs     .ret
                ; 砲塔を消す
        lda     CH_var0,x
        beq     .ret
        phx
        tax
        jsr     CDRVremoveChr
        plx
        stz     CH_var0,x
.ret:
        rts

EN_damaged_dummy:
ENBig_damaged:
        rts

EN_dead_dummy:
ENTank_dead:
        jsr     EFcreateExplosion
        jsr     CDRVremoveChr
        rts

ENBig_dead:
        phx

        lda     CH_var0,x
        sta     <z_tmp12
        lda     CH_var1,x
        sta     <z_tmp13
        lda     CH_var2,x
        sta     <z_tmp14
        lda     CH_var3,x
        sta     <z_tmp15

        ldx     <z_tmp12
        beq     .01
        jsr     CDRVremoveChr
.01:
        ldx     <z_tmp13
        beq     .02
        jsr     CDRVremoveChr
.02:
        ldx     <z_tmp14
        beq     .03
        jsr     CDRVremoveChr
.03:
        ldx     <z_tmp15
        beq     .04
        jsr     CDRVremoveChr
.04:
        plx
        jsr     CDRVremoveChr

        rts



EN_damaged_procl:
        .db     LOW(EN_damaged_dummy)
;        .db     LOW(EN_damaged_dummy)
        .db     LOW(ENTank_damaged)
        .db     LOW(ENBig_damaged)
EN_damaged_proch:
        .db     HIGH(EN_damaged_dummy)
;        .db     HIGH(EN_damaged_dummy)
        .db     HIGH(ENTank_damaged)
        .db     HIGH(ENBig_damaged)

EN_dead_procl:
        .db     LOW(EN_dead_dummy)
        .db     LOW(ENTank_dead)
        .db     LOW(ENBig_dead)
EN_dead_proch:
        .db     HIGH(EN_dead_dummy)
        .db     HIGH(ENTank_dead)
        .db     HIGH(ENBig_dead)




ENTank_move:
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
        jsr     .destroy
        sec
        rts

.destroy:
                ; 砲塔を消す
        lda     CH_var0,x
        beq     .00
        phx
        tax
        jsr     CDRVremoveChr
        plx
.00:
        rts


ENdead:
        sec
        rts


ENTankTurret_move:
        lda     CH_var0,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sta     CH_yh,x

                        ; rotate
       	tst	#$07,<z_frame
	bne	.skip

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

        sec
        sbc     CH_dir,x
        beq     .skip
        and     #$1f
        cmp     #$10
        bcc     .inc
        lda     CH_dir,x
        dec     a
        bra     .00
.inc:   lda     CH_dir,x
        inc     a
.00:
        and     #$1f
        sta     CH_dir,x

        lsr     a
        tay

        lda     ENTankTurretPatternLow,y
        sta     CH_sprpatl,x
        lda     ENTankTurretPatternHigh,y
        sta     CH_sprpath,x

        lda     ENTankTurretAttributeLow,y
        sta     CH_spratrl,x
        lda     ENTankTurretAttributeHigh,y
        sta     CH_spratrh,x

.skip:

                        ; shoot
       	tst	#$0f,<z_frame
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

        sec
        sbc     CH_dir,x
        inc     a
        cmp     #3
        bcs     .skipeb
        ldy     CH_dir,x
	jsr	EB_shoot
.skipeb:

        clc
        rts



; 戦車の砲塔のスプライトテーブル
ENTankTurretPatternLow:
        .db     LOW(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret04-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret04-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     LOW(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
ENTankTurretPatternHigh:
        .db     HIGH(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret04-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret00-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret04-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret03-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret02-spr_pattern)/2+$4000)/32)
        .db     HIGH(((spr_pattern_turret01-spr_pattern)/2+$4000)/32)
ENTankTurretAttributeLow:
        .db     $83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83,$83
ENTankTurretAttributeHigh:
        .db     $11,$11,$11,$11,$11,$19,$19,$19,$19,$99,$99,$99,$91,$91,$91,$91




ENBig_main_move:
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
        phx

        lda     CH_var0,x
        sta     <z_tmp12
        lda     CH_var1,x
        sta     <z_tmp13
        lda     CH_var2,x
        sta     <z_tmp14
        lda     CH_var3,x
        sta     <z_tmp15

        ldx     <z_tmp12
        beq     .01
        jsr     CDRVremoveChr
.01:
        ldx     <z_tmp13
        beq     .02
        jsr     CDRVremoveChr
.02:
        ldx     <z_tmp14
        beq     .03
        jsr     CDRVremoveChr
.03:
        ldx     <z_tmp15
        beq     .04
        jsr     CDRVremoveChr
.04:
        plx


        sec
        rts


ENBig_sub0_move:
        lda     CH_var0,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sec
        sbc     #32/2
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sec
        sbc     #24/2
        sta     CH_yh,x

        clc
        rts

ENBig_sub1_move:
        lda     CH_var0,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sec
        sbc     #32/2
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        clc
        adc     #8/2
        sta     CH_yh,x

        clc
        rts

ENBig_sub2_move:
        lda     CH_var0,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sec
        sbc     #8/2
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sec
        sbc     #32/2
        sta     CH_yh,x

        clc
        rts

ENBig_sub3_move:
        lda     CH_var0,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sec
        sbc     #8/2
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        clc
        adc     #16/2
        sta     CH_yh,x

        clc
        rts
