        .zp
;z_last_new_chr  .ds     1       ;直前に生成されたキャラクタ番号（複数キャラが連携している場合に使う）
z_eni_ptr       .ds     2       ;生成時の初期化スクリプトのポインタ

z_en_init_xl:   .ds     1
z_en_init_xh:   .ds     1
z_en_init_yl:   .ds     1
z_en_init_yh:   .ds     1


        .code
        .bank   MAIN_BANK

;------------------------------
; @experimental
;  複数キャラの組み合わせ

ENcreate_Tank:
        stz     <z_en_init_xl
        lda     #(336+$20)/2
        sta     <z_en_init_xh
        stz     <z_en_init_yl
        lda     scry
        lsr     a
        sta     <z_tmp15
        lda     <z_frame
        asl     a
        and     #$3c
        adc     #30*8/2
        sbc     <z_tmp15
        sta     <z_en_init_yh
        

        ldy     #0
        jsr     ENcreate_Ex
        rts

ENcreate_Boat_v:
        stz     <z_en_init_xl
        lda     #(336+$20)/2
        sta     <z_en_init_xh
        stz     <z_en_init_yl
        lda     scry
        lsr     a
        sta     <z_tmp15
        lda     <z_frame
        asl     a
        and     #$3c
        adc     #12*8/2
        sbc     <z_tmp15
        sta     <z_en_init_yh


        ldy     #3
        jsr     ENcreate_Ex
        rts



ENcreate_Big:
        ldy     #1
        jsr     ENcreate_Ex
        rts


;------------------------------
; 敵キャラクターを生成
;
; @param        y       敵タイプ番号
; @return       c=0     成功
; @save         -

ENcreate_Ex:
                ;敵タイプに対応する初期化スクリプトのポインタ
.tmp_eni_ptr    .equ    z_eni_ptr
        lda     ENinitPtrTable_l,y
        sta     <.tmp_eni_ptr
        lda     ENinitPtrTable_h,y
        sta     <.tmp_eni_ptr+1

                ;初期化スクリプト処理
                ;ロールクラスごとにキャラの空きがあるか調べる
                ;必要なロールクラスに1つでも空きがなければキャラを生成しない
        cly
.chkloop:
        lda     [.tmp_eni_ptr],y                ;ロールクラス
        beq     .chkok                          ;ロールクラスが0なら次へ
        tax
        iny
        lda     [.tmp_eni_ptr],y                ;生成予定のキャラ数
        iny
        cmp     CDrv_role_class_unusedchrnum,x
        bcc     .chkloop
        beq     .chkloop
                ;空きがなかったので、生成せずに終了
        sec
        rts
.chkok:

                ;キャラクターを1つずつ生成
        iny
        stz     <z_tmp2                         ;最初は親キャラなので0
.addloop:
        lda     [.tmp_eni_ptr],y                ;ロールクラス
        beq     .addend                         ;ロールクラスが0なら終わり
        sta     <z_tmp0
        iny
        lda     [.tmp_eni_ptr],y                ;スプライトクラス
        sta     <z_tmp1
        iny
        phy
        jsr     CDRVaddChr
        sxy                                     ;x=生成したキャラ
        ply
                ;キャラ初期化
        lda     [.tmp_eni_ptr],y                ;初期化ルーチンアドレス
        sta     <z_tmp0
        iny
        lda     [.tmp_eni_ptr],y                ;初期化ルーチンアドレス
        sta     <z_tmp1
        iny
        phy

        lda     #HIGH(.end-1)                   ;要注意 pushするのは 戻りアドレス-1
        pha
        lda     #LOW(.end-1)
        pha

        jmp     [z_tmp0]                        ;初期化ルーチン
.end:
        ply
                ;生成するキャラが2つ以上ある場合、最初は親、2つ目以降は子供として扱う
        tst     #$ff,<z_tmp2                    ;親キャラ=0 の時だけ、親キャラ番号を保存
        bne     .addloop
        stx     <z_tmp2
        bra     .addloop

.addend:
        clc
        rts
        

;敵キャラの初期化スクリプトのポインタテーブル

ENinitPtrTable_l:
        .db  LOW(ENI_tank)
        .db  LOW(ENI_big)
        .db  LOW(ENI_bigexp)
        .db     LOW(ENI_boat_v)

ENinitPtrTable_h:
        .db  HIGH(ENI_tank)
        .db  HIGH(ENI_big)
        .db  HIGH(ENI_bigexp)
        .db     HIGH(ENI_boat_v)


;初期化スクリプト


ENI_tank:
        .db     CDRV_ROLE_ENEMY_G1,1
        .db     CDRV_ROLE_ENEMY_G2,1
        .db     0
        .db     CDRV_ROLE_ENEMY_G1,CDRV_SPR_ENEMY_G1
        .dw     ENTank_init
        .db     CDRV_ROLE_ENEMY_G2,CDRV_SPR_ENEMY_G2
        .dw     ENTankTurret_init
        .db     0

ENI_boat_v:
        .db     CDRV_ROLE_ENEMY_G1,1
        .db     CDRV_ROLE_ENEMY_G2,2
        .db     0
        .db     CDRV_ROLE_ENEMY_G1,CDRV_SPR_ENEMY_G1
        .dw     ENBoat_v_init
        .db     CDRV_ROLE_ENEMY_G2,CDRV_SPR_ENEMY_G2    ;砲塔は本体の次！
        .dw     ENBoat_v_Turret_init
        .db     CDRV_ROLE_ENEMY_G2,CDRV_SPR_ENEMY_G3
        .dw     ENBoat_v_sub_init
        .db     0

ENI_big:
        .db     CDRV_ROLE_ENEMY_S1,1
        .db     CDRV_ROLE_ENEMY_S2,4
        .db     0
        .db     CDRV_ROLE_ENEMY_S1,CDRV_SPR_ENEMY_S1
        .dw     ENBig_main_init
        .db     CDRV_ROLE_ENEMY_S2,CDRV_SPR_ENEMY_S2
        .dw     ENBig_sub0_init
        .db     CDRV_ROLE_ENEMY_S2,CDRV_SPR_ENEMY_S2
        .dw     ENBig_sub1_init
        .db     CDRV_ROLE_ENEMY_S2,CDRV_SPR_ENEMY_S2
        .dw     ENBig_sub2_init
        .db     CDRV_ROLE_ENEMY_S2,CDRV_SPR_ENEMY_S2
        .dw     ENBig_sub3_init
        .db     0

ENI_bigexp:
        .db     CDRV_ROLE_EFFECT,4
        .db     0
        .db     CDRV_ROLE_EFFECT,CDRV_SPR_EFFECT_S
        .dw     ENBigExp_0_init
        .db     CDRV_ROLE_EFFECT,CDRV_SPR_EFFECT_S
        .dw     ENBigExp_1_init
        .db     CDRV_ROLE_EFFECT,CDRV_SPR_EFFECT_S
        .dw     ENBigExp_2_init
        .db     CDRV_ROLE_EFFECT,CDRV_SPR_EFFECT_S
        .dw     ENBigExp_3_init
        .db     0





;------------------------------------------------

ENDummy_init:
        rts

ENTank_init:
;        stz     CH_xl,x
;        lda     #(336+$20)/2
;        sta     CH_xh,x
;        stz     CH_yl,x
;        lda     <z_frame
;        asl     a
;        sta     CH_yh,x
        lda     <z_en_init_xl
        sta     CH_xl,x
        lda     <z_en_init_xh
        sta     CH_xh,x
        lda     <z_en_init_yl
        sta     CH_yl,x
        lda     <z_en_init_yh
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

        lda     #3
        sta     CH_regist,x

        lda     #1
        sta     CH_damaged_class,x

        lda     #LOW(ENTank_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENTank_move)
        sta     CH_procptrh,x


        phx
        lda     #1
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
;        ldy     <z_last_new_chr
        ldy     CH_grp_parent,x

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

;-----
ENBoat_v_init:
;        stz     CH_xl,x
;        lda     #(336+$20)/2
;        sta     CH_xh,x
;        stz     CH_yl,x
;        lda     <z_frame
;        asl     a
;        sta     CH_yh,x
        lda     <z_en_init_xl
        sta     CH_xl,x
        lda     <z_en_init_xh
        sta     CH_xh,x
        lda     <z_en_init_yl
        sta     CH_yl,x
        lda     <z_en_init_yh
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_boatv_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_boatv_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$85
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        lda     #8
        sta     CH_coldx,x
        sta     CH_coldy,x

        lda     #3
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

ENBoat_v_sub_init:
;        stz     CH_xl,x
;        lda     #(336+$20)/2
;        sta     CH_xh,x
;        stz     CH_yl,x
;        lda     <z_frame
;        asl     a
;        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_boatv_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_boatv_01-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$85
        sta     CH_spratrl,x
        lda     #$10
        sta     CH_spratrh,x

        lda     #8/2
        sta     CH_sprdx,x
        lda     #16/2
        sta     CH_sprdy,x

;        lda     #8
;        sta     CH_coldx,x
;        sta     CH_coldy,x

 ;       lda     #4
 ;       sta     CH_regist,x

 ;       lda     #1
 ;       sta     CH_damaged_class,x

        lda     #LOW(ENBoat_v_sub_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBoat_v_sub_move)
        sta     CH_procptrh,x

        rts


ENBoat_v_Turret_init:
        ldy     CH_grp_parent,x

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$85
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #16/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

;        lda     #0
;        sta     CH_coldx,x
;        sta     CH_coldy,x

        lda     #LOW(ENBoatTurret_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBoatTurret_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        tya
        sta     CH_var0,x               ;戦車本体のキャラクタ番号

        rts

;-----

ENBig_main_init:
        stz     CH_xl,x
        lda     #(336+$48)/2
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

        lda     #80
        sta     CH_regist,x

        lda     #2
        sta     CH_damaged_class,x

        lda     #LOW(ENBig_main_move)
        sta     CH_procptrl,x
        lda     #HIGH(ENBig_main_move)
        sta     CH_procptrh,x

        lda     #0
        sta     CH_dir,x

        lda     #$80
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
        bne     .ret
                ; 砲塔を消す
        lda     CH_grp_child,x
;        lda     CH_var0,x
        beq     .ret

        pha
        phx
        tax
        jsr     EFcreateExplosion
        plx
        pla

        phx
        tax
        jsr     CDRVremoveChr
        plx
;        stz     CH_var0,x
.ret:
        rts



ENBig_damaged:
        lda     CH_regist,x
        cmp     #64
        beq     .fire1
        cmp     #32
        beq     .fire2
        rts
.fire1:
        lda     #-8
        bra     .fire
.fire2:
        lda     #8
.fire:
        sta     <z_tmp3
        jsr     EFcreateDamagedFire
        rts

EN_damaged_dummy:
        rts

EN_dead_dummy:
ENTank_dead:
        jsr     EFcreateExplosion
        jsr     CDRVremoveChr
        rts

ENBig_dead:

        phx
        lda     CH_xh,x
        sta     <z_en_init_xh
        lda     CH_yh,x
        sta     <z_en_init_yh
        ldy     #2
        jsr     ENcreate_Ex
        plx
;        jsr     EFcreateExplosion
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
        cmp     #16/2
        bcc     .out

        lda     CH_yl,x
        clc
        adc     CH_dyl,x
        sta     CH_yl,x
        lda     CH_yh,x
        adc     CH_dyh,x
        sta     CH_yh,x

        lda     CH_yl,x
        clc
        adc     <z_d_scryl
        sta     CH_yl,x
        lda     CH_yh,x
        adc     <z_d_scryh
        sta     CH_yh,x

;        cmp     #(240+64)/2
;        bcs     .out
;        cmp     #64/2
;        bcc     .out

        clc
        rts
                ; out of screen
.out:
        ;jsr     .destroy
        sec
        rts

        .if     0
.destroy:
                ; 砲塔を消す
        lda     CH_grp_child,x
;        lda     CH_var0,x
        beq     .00
        phx
        tax
        jsr     CDRVremoveChr
        plx
.00:
        rts
        .endif

ENdead:
        sec
        rts


ENTankTurret_move:
        lda     CH_grp_parent,x

;        lda     CH_var0,x
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
        stz     <z_tmp3
        stz     <z_tmp4
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

;----

ENBoatTurret_move:
        lda     CH_grp_parent,x
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
       	tst	#$0f,<z_frame
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

        lda     ENBoatTurretPatternLow,y
        sta     CH_sprpatl,x
        lda     ENBoatTurretPatternHigh,y
        sta     CH_sprpath,x

        lda     ENBoatTurretAttributeLow,y
        sta     CH_spratrl,x
        lda     ENBoatTurretAttributeHigh,y
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
        stz     <z_tmp3
        stz     <z_tmp4
        ldy     CH_dir,x
	jsr	EB_shoot
.skipeb:

        clc
        rts



; 戦車の砲塔のスプライトテーブル
ENBoatTurretPatternLow:
        .db     LOW(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_04-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_04-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
ENBoatTurretPatternHigh:
        .db     HIGH(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_04-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_00-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_04-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_03-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_02-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_boatturret_01-spr_pattern2)/2+$5000)/32)
ENBoatTurretAttributeLow:
        .db     $85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85,$85
ENBoatTurretAttributeHigh:
        .db     $11,$11,$11,$11,$11,$19,$19,$19,$19,$99,$99,$99,$91,$91,$91,$91


ENBoat_v_sub_move:
        lda     CH_grp_parent,x
        tay

        lda     CH_xl,y
        sta     CH_xl,x
        lda     CH_xh,y
        clc
        adc     #10
        sta     CH_xh,x
        lda     CH_yl,y
        sta     CH_yl,x
        lda     CH_yh,y
        sta     CH_yh,x

        clc
        rts

;-----------------------------

ENBig_main_move:
        lda     CH_xl,x
        clc
        adc     CH_dxl,x
        sta     CH_xl,x
        lda     CH_xh,x
        adc     CH_dxh,x
        sta     CH_xh,x

;        cmp     #(336+32)/2
;        bcs     .out
        cmp     #4/2
        bcc     .out

        bbr6    <z_frame,.right
        lda     CH_yl,x
        sec
        sbc     #$40
        sta     CH_yl,x
        lda     CH_yh,x
        sbc     #0
        sta     CH_yh,x
        bra     .end
.right:
        lda     CH_yl,x
        clc
        adc     #$40
        sta     CH_yl,x
        lda     CH_yh,x
        adc     #0
        sta     CH_yh,x

;        cmp     #(240+64)/2
;        bcs     .out
;        cmp     #64/2
;        bcc     .out
.end
                        ; shoot
       	tst	#$1f,<z_frame
	bne	.skipeb

        lda     #-8
        sta     <z_tmp3
        lda     #-20
        sta     <z_tmp4
        cly
	jsr	EB_shoot

        lda     #-8
        sta     <z_tmp3
        lda     #8
        sta     <z_tmp4
        cly
	jsr	EB_shoot
.skipeb:
        clc
        rts
                ; out of screen
.out:
        sec
        rts


ENBig_sub0_move:
;        lda     CH_var0,x
        lda     CH_grp_parent,x
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
;        lda     CH_var0,x
        lda     CH_grp_parent,x
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
 ;       lda     CH_var0,x
        lda     CH_grp_parent,x
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
;        lda     CH_var0,x
        lda     CH_grp_parent,x
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


;-----------------------------


ENBigExp_0_init:
        stz     CH_xl,x
        lda     <z_en_init_xh
        sec
        sbc     #8
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_en_init_yh
        sec
        sbc     #8
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$84
        sta     CH_spratrl,x
        lda     #$11
        sta     CH_spratrh,x

        lda     #LOW(EFBigExp_0_move)
        sta     CH_procptrl,x
        lda     #HIGH(EFBigExp_0_move)
        sta     CH_procptrh,x

        lda     #32/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        cla
        sta     CH_var0,x

        rts

ENBigExp_1_init:
        stz     CH_xl,x
        lda     <z_en_init_xh
        clc
        adc     #8
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_en_init_yh
        sec
        sbc     #8
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$84
        sta     CH_spratrl,x
        lda     #$19
        sta     CH_spratrh,x

        lda     #LOW(EFBigExp_0_move)
        sta     CH_procptrl,x
        lda     #HIGH(EFBigExp_0_move)
        sta     CH_procptrh,x

        lda     #32/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        cla
        sta     CH_var0,x

        rts

ENBigExp_2_init:
        stz     CH_xl,x
        lda     <z_en_init_xh
        sec
        sbc     #8
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_en_init_yh
        clc
        adc     #8
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$84
        sta     CH_spratrl,x
        lda     #$91
        sta     CH_spratrh,x

        lda     #LOW(EFBigExp_0_move)
        sta     CH_procptrl,x
        lda     #HIGH(EFBigExp_0_move)
        sta     CH_procptrh,x

        lda     #32/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        cla
        sta     CH_var0,x

        rts

ENBigExp_3_init:
        stz     CH_xl,x
        lda     <z_en_init_xh
        clc
        adc     #8
        sta     CH_xh,x
        stz     CH_yl,x
        lda     <z_en_init_yh
        clc
        adc     #8
        sta     CH_yh,x

        lda     #LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpatl,x
        lda     #HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        sta     CH_sprpath,x

        lda     #$84
        sta     CH_spratrl,x
        lda     #$99
        sta     CH_spratrh,x

        lda     #LOW(EFBigExp_0_move)
        sta     CH_procptrl,x
        lda     #HIGH(EFBigExp_0_move)
        sta     CH_procptrh,x

        lda     #32/2
        sta     CH_sprdx,x
        sta     CH_sprdy,x

        cla
        sta     CH_var0,x

        rts

EFBigExp_0_move:
        tst	#$07,<z_frame
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
        .db     LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_bigexp_01-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_bigexp_02-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_bigexp_01-spr_pattern2)/2+$5000)/32)
        .db     LOW(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
.pattern_h:
        .db     HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_bigexp_01-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_bigexp_02-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_bigexp_01-spr_pattern2)/2+$5000)/32)
        .db     HIGH(((spr_pattern2_bigexp_00-spr_pattern2)/2+$5000)/32)


