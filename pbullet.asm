; 自機弾処理　のテスト
; 弾の構造体へのアクセスを absolute,x でやれるようにするために、
; 構造体メンバーを1バイトずつに分け、それぞれを個別の配列となるよう配置。
; x は弾のインデックスとなる
;
; ４連射であることを前提としたコードになっている

    
    .code
    .bank   MAIN_BANK

        ; number of bullet per 1 shot
;PB_level_num:
;    .db 3,5,9,15
        ; direction table for each level
PB_level_table:
    .db 0,PB_level1-PB_level0,PB_level2-PB_level0,PB_level3-PB_level0
PB_level0:
    .db 0,7,14,$ff
PB_level1:
    .db 0,3,7,11,14,$ff
PB_level2:
    .db 0,1,2,6,7,8,12,13,14,$ff
PB_level3:
    .db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,$ff

        ; 方向別移動量
PB_dxl_table:
    .db $f8,$3c,$76,$a7,$cd,$e9,$fa,$00,$fa,$e9,$cd,$a7,$76,$3c,$f8
PB_dxh_table:
    .db $02,$03,$03,$03,$03,$03,$03,$04,$03,$03,$03,$03,$03,$03,$02
PB_dyl_table:
    .db $53,$a7,$01,$60,$c4,$2c,$95,$00,$6b,$d4,$3c,$a0,$ff,$59,$ad
PB_dyh_table:
    .db $fd,$fd,$fe,$fe,$fe,$ff,$ff,$00,$00,$00,$01,$01,$01,$02,$02

        ; 方向別スプライトパターン
PB_sprpatl_table:
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db LOW(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)

PB_sprpath_table:
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)
    .db HIGH(((spr_pattern_pb2-spr_pattern)/2+$4000)/32)

            ; 方向別スプライトアトリビュート（フリップ用）
PB_spratrh_table:
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$90,$90,$90,$90

PBshoot:
        phx
        ldx     #CDRV_ROLE_PBULLET_M1
.loop:
        lda     CDrv_role_class_chrnum,x
        beq     .shoot
        inx
        cpx     #CDRV_ROLE_PBULLET_M1+4
        bne     .loop
.end:
        plx
        rts

.shoot:
        stx     <z_tmp0     ; role class
        lda     #CDRV_SPR_PBULLET_M1
        sta     <z_tmp1     ; sprite class
        stz     <z_tmp2

        ldx     PL_chr
        lda     CH_xl,x
        sta     <z_tmp3
        lda     CH_xh,x
        sta     <z_tmp4
        lda     CH_yl,x
        sta     <z_tmp5
        lda     CH_yh,x
        sta     <z_tmp6

        lda     PB_level_table,y
        tay
.loop2:
        lda     PB_level0,y
        bmi     .end

        phy

        pha
        jsr     CDRVaddChr
        plx
        bcs     .end2

        lda     PB_dxl_table,x
        sta     CH_dxl,y
        lda     PB_dxh_table,x
        sta     CH_dxh,y
        lda     PB_dyl_table,x
        sta     CH_dyl,y
        lda     PB_dyh_table,x
        sta     CH_dyh,y

        lda     <z_tmp3
        sta     CH_xl,y
        lda     <z_tmp4
        sta     CH_xh,y
        lda     <z_tmp5
        sta     CH_yl,y
        lda     <z_tmp6
        sta     CH_yh,y

        lda     PB_sprpatl_table,x
;        lda     #LOW(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
        sta     CH_sprpatl,y
        lda     PB_sprpath_table,x
;        lda     #HIGH(((spr_pattern_pb-spr_pattern)/2+$4000)/32)
        sta     CH_sprpath,y

        lda     #$81
        sta     CH_spratrl,y
        lda     PB_spratrh_table,x
;        lda     #$00
        sta     CH_spratrh,y

        lda     #4/2
        sta     CH_sprdx,y
        sta     CH_sprdy,y

        lda     #LOW(PBmove)
        sta     CH_procptrl,y
        lda     #HIGH(PBmove)
        sta     CH_procptrh,y

        ply
        iny
        bra     .loop2

.end2:
        ply
        plx
        rts
;
;
;
PBmove:
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
        sec
        rts

;-----------------
; fire
        .zp
z_fire_count    .ds     1       ;ファイアーの伸び

    .code
    .bank   MAIN_BANK

PB_fire_init:
        stz     <z_fire_count
        rts

PB_fire_noshoot:
        lda     <z_fire_count
        cmp     #1
        bne     .down
        rts
.down:
        dec     a
        sta     <z_fire_count
        rts


PB_fire_shoot:
        lda     <z_fire_count
        beq     .create

        cmp     #10
        beq     .ret
        inc     a
        sta     <z_fire_count
.ret:
        rts

.create:
        ldy     #CDRV_ROLE_PBULLET_M1
        lda     CDrv_role_class_chrnum,y
        bne     .ret
        iny
        lda     CDrv_role_class_chrnum,y
        bne     .ret
        iny
        lda     CDrv_role_class_chrnum,y
        bne     .ret
        iny
        lda     CDrv_role_class_chrnum,y
        bne     .ret

                ;前
        lda     #CDRV_ROLE_PBULLET_M1
        sta     <z_tmp11
        lda     #16
        sta     <z_tmp12
        lda     #14
        sta     <z_tmp13
        lda     #LOW(PB_fire_0_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_0_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

                ;前
        lda     #CDRV_ROLE_PBULLET_M2
        sta     <z_tmp11
        lda     #16
        sta     <z_tmp12
        lda     #18
        sta     <z_tmp13
        lda     #LOW(PB_fire_0_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_0_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

                ;左
        lda     #CDRV_ROLE_PBULLET_M3
        sta     <z_tmp11
        lda     #15
        sta     <z_tmp12
        lda     #12
        sta     <z_tmp13
        lda     #LOW(PB_fire_1_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_1_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

                ;右
        lda     #CDRV_ROLE_PBULLET_M4
        sta     <z_tmp11
        lda     #17
        sta     <z_tmp12
        lda     #20
        sta     <z_tmp13
        lda     #LOW(PB_fire_0_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_0_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

        lda     #CDRV_ROLE_PBULLET_M5
        sta     <z_tmp11
        lda     #13
        sta     <z_tmp12
        lda     #12
        sta     <z_tmp13
        lda     #LOW(PB_fire_0_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_0_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

        lda     #CDRV_ROLE_PBULLET_M6
        sta     <z_tmp11
        lda     #19
        sta     <z_tmp12
        lda     #20
        sta     <z_tmp13
        lda     #LOW(PB_fire_0_move)
        sta     <z_tmp14
        lda     #HIGH(PB_fire_0_move)
        sta     <z_tmp15
        jsr     PB_fire_1_shoot

.end
        rts




PB_fire_1_shoot:
.arg_role_class .equ    z_tmp11
.arg_dir        .equ    z_tmp12
.arg_rootdir    .equ    z_tmp13
.arg_procptrl   .equ    z_tmp14
.arg_procptrh   .equ    z_tmp15

        phx

        lda     #1
        sta     <z_fire_count

        ldx     #9
.shootloop:
        lda     <.arg_role_class
        sta     <z_tmp0     ; role class
        lda     #CDRV_SPR_PBULLET_M1
        sta     <z_tmp1     ; sprite class
        stz     <z_tmp2         ; parent
        jsr     CDRVaddChr
        bcs     .end

        lda     #LOW(((spr_pattern3_fire-spr_pattern3)/2+$6000)/32)
        sta     CH_sprpatl,y
        lda     #HIGH(((spr_pattern3_fire-spr_pattern3)/2+$6000)/32)
        sta     CH_sprpath,y

        lda     #$84
        sta     CH_spratrl,y
        lda     #$11
        sta     CH_spratrh,y

        lda     #16/2
        sta     CH_sprdx,y
        sta     CH_sprdy,y

        lda     <.arg_procptrl
        sta     CH_procptrl,y
        lda     <.arg_procptrh
        sta     CH_procptrh,y

        lda     <.arg_dir
        sta     CH_dir,y        ; 関連キャラから見た方向
        sta     CH_var1,y       ; 1つ前の方向（初期値は同じ）

        cla
        sta     CH_var2,y

        txa
        sta     CH_var0,y       ; 通し番号（自機に近い方から 1,2,3..）
        dex
        bne     .shootloop

        lda     <.arg_rootdir
        sta     CH_dir,y
.end:
        plx
        rts
;
;
;
PB_fire_0_move:
        lda     CH_var0,x
        cmp     <z_fire_count
        bcs     .hide

        ldy     CH_dir,x
        lda     PB_fire_dxl_table,y
        sta     CH_xl,x
        lda     PB_fire_dxh_table,y
        sta     CH_xh,x
        lda     PB_fire_dyl_table,y
        sta     CH_yl,x
        lda     PB_fire_dyh_table,y
        sta     CH_yh,x

        lda     CH_role_prev,x
        bne     .setpos
        lda     PL_chr
.setpos:
        tay

        lda     CH_xl,y
        clc
        adc     CH_xl,x
        sta     CH_xl,x
        lda     CH_xh,y
        adc     CH_xh,x
        sta     CH_xh,x

        lda     CH_yl,y
        clc
        adc     CH_yl,x
        sta     CH_yl,x
        lda     CH_yh,y
        adc     CH_yh,x
        sta     CH_yh,x

        clc
        rts
.hide:
        cla
        sta     CH_xh,x
        sta     CH_yh,x

        clc
        rts


PB_fire_1_move:
        lda     CH_var0,x
        cmp     <z_fire_count
        bcs     .hide

        lda     CH_var2,x
        and     #$03
        bne     .next
        lda     CH_var2,x
        lsr     a
        lsr     a
        tay
        lda     CH_dir,x
        sta     CH_var1,x
        lda     .dirtbl,y
        sta     CH_dir,x
.next:
        lda     CH_var2,x
        inc     a
        cmp     #128
        bcc     .set
        cla
.set:
        sta     CH_var2,x

        ldy     CH_dir,x
        lda     PB_fire_dxl_table,y
        sta     CH_xl,x
        lda     PB_fire_dxh_table,y
        sta     CH_xh,x
        lda     PB_fire_dyl_table,y
        sta     CH_yl,x
        lda     PB_fire_dyh_table,y
        sta     CH_yh,x

        lda     CH_role_prev,x
        bne     .setpos
        lda     PL_chr
.setpos:
        tay

        lda     CH_xl,y
        clc
        adc     CH_xl,x
        sta     CH_xl,x
        lda     CH_xh,y
        adc     CH_xh,x
        sta     CH_xh,x

        lda     CH_yl,y
        clc
        adc     CH_yl,x
        sta     CH_yl,x
        lda     CH_yh,y
        adc     CH_yh,x
        sta     CH_yh,x

        clc
        rts
.hide:
        cla
        sta     CH_xh,x
        sta     CH_yh,x

        clc
        rts
.dirtbl:
        .db     15,15,14,14,13,13,12,12,11,11,10,10, 9, 9, 8, 8
        .db      8, 8, 9, 9,10,10,11,11,12,12,13,13,14,14,15,15

PB_fire_dxl_table:
    .db $00,$4f,$38,$b3,$b0,$1d,$e1,$e1,$00,$1f,$1f,$e3,$50,$4d,$c8,$b1
    .db $00,$b1,$c8,$4d,$50,$e3,$1f,$1f,$00,$e1,$e1,$1d,$b0,$b3,$38,$4f
PB_fire_dxh_table:
    .db $f0,$f0,$f1,$f2,$f4,$f7,$f9,$fc,$00,$03,$06,$08,$0b,$0d,$0e,$0f
    .db $10,$0f,$0e,$0d,$0b,$08,$06,$03,$00,$fc,$f9,$f7,$f4,$f2,$f1,$f0
PB_fire_dyl_table:
    .db $00,$e1,$e1,$1d,$b0,$b3,$38,$4f,$00,$4f,$38,$b3,$b0,$1d,$e1,$e1
    .db $00,$1f,$1f,$e3,$50,$4d,$c8,$b1,$00,$b1,$c8,$4d,$50,$e3,$1f,$1f
PB_fire_dyh_table:
    .db $00,$fc,$f9,$f7,$f4,$f2,$f1,$f0,$f0,$f0,$f1,$f2,$f4,$f7,$f9,$fc
    .db $00,$03,$06,$08,$0b,$0d,$0e,$0f,$10,$0f,$0e,$0d,$0b,$08,$06,$03
