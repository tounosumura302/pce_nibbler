
        .bss
;PL_x:   .ds     2
;PL_y:   .ds     2


PL_chr: .ds     1       ;プレイヤーのキャラ番号

        .zp
PL_speed:       .ds     2       ; speed

z_pl_arm:       .ds     1       ; 武器

        .code
        .bank   MAIN_BANK
PL_init:
        lda     #CDRV_ROLE_PLAYER
        sta     <z_tmp0
        lda     #CDRV_SPR_PLAYER
        sta     <z_tmp1
        stz     <z_tmp2
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

        lda     #1
        sta     <z_pl_arm

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

        lda     <z_pl_arm
        beq     .arm_wide
        dec     a
        beq     .arm_fire
.arm_beam:
        bra     .notshoot

.arm_wide:
                ; shoot
	bbr0	<z_paddelta,.notshoot

	ldy	#3
	jsr	PBshoot
        bra     .notshoot

.arm_fire:
	bbr0	<z_pad,.arm_fire_notshoot
        jsr     PB_fire_shoot
        bra     .notshoot
.arm_fire_notshoot:
        jsr     PB_fire_noshoot

.notshoot:

                ; 左右スクロール
	lda	CH_yh,x
	sec
	sbc	#(64+16)/2
	tay
	lda	PLScrollY,y
	sta	scry
	stz	scry+1

                ; スクロールの差分から地上敵の座標補正値を求める
                ; 差分を1/2してゲーム座標に変換する
        lda     prevscry
        sec
        sbc     scry
        bcc     .scrminus
        clc
        bra     .scradd
.scrminus:
        sec
.scradd:
        ror     a
        sta     <z_d_scryh
        cla
        ror     a
        sta     <z_d_scryl



        clc
        rts

PLdead:
        clc
        rts

                ;自機の左右の動きに合わせたスクロール位置
PLScrollY:
        .db 0
        .db 0
        .db 1
        .db 2
        .db 3
        .db 3
        .db 4
        .db 5
        .db 6
        .db 6
        .db 7
        .db 8
        .db 9
        .db 10
        .db 10
        .db 11
        .db 12
        .db 13
        .db 13
        .db 14
        .db 15
        .db 16
        .db 16
        .db 17
        .db 18
        .db 19
        .db 20
        .db 20
        .db 21
        .db 22
        .db 23
        .db 23
        .db 24
        .db 25
        .db 26
        .db 26
        .db 27
        .db 28
        .db 29
        .db 30
        .db 30
        .db 31
        .db 32
        .db 33
        .db 33
        .db 34
        .db 35
        .db 36
        .db 36
        .db 37
        .db 38
        .db 39
        .db 40
        .db 40
        .db 41
        .db 42
        .db 43
        .db 43
        .db 44
        .db 45
        .db 46
        .db 46
        .db 47
        .db 48
        .db 49
        .db 50
        .db 50
        .db 51
        .db 52
        .db 53
        .db 53
        .db 54
        .db 55
        .db 56
        .db 56
        .db 57
        .db 58
        .db 59
        .db 60
        .db 60
        .db 61
        .db 62
        .db 63
        .db 63
        .db 64
        .db 65
        .db 66
        .db 66
        .db 67
        .db 68
        .db 69
        .db 70
        .db 70
        .db 71
        .db 72
        .db 73
        .db 73
        .db 74
        .db 75
        .db 76
        .db 76
        .db 77
        .db 78
        .db 79
        .db 80
