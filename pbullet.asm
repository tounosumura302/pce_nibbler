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


