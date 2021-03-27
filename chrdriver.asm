        .bss

CH_MAX_CHR      .equ    128

CH_xl:  .ds     CH_MAX_CHR
CH_xh:  .ds     CH_MAX_CHR
CH_yl:  .ds     CH_MAX_CHR
CH_yh:  .ds     CH_MAX_CHR

CH_dxl:  .ds     CH_MAX_CHR
CH_dxh:  .ds     CH_MAX_CHR
CH_dyl:  .ds     CH_MAX_CHR
CH_dyh:  .ds     CH_MAX_CHR

CH_dir: .ds     CH_MAX_CHR
CH_vel: .ds     CH_MAX_CHR

CH_procptrl:    .ds     CH_MAX_CHR
CH_procptrh:    .ds     CH_MAX_CHR

CH_sprpatl:      .ds     CH_MAX_CHR
CH_sprpath:      .ds     CH_MAX_CHR
CH_spratrl:      .ds     CH_MAX_CHR
CH_spratrh:      .ds     CH_MAX_CHR

CH_sprdx:       .ds     CH_MAX_CHR
CH_sprdy:       .ds     CH_MAX_CHR

CH_coldx:       .ds     CH_MAX_CHR      ;collision
CH_coldy:       .ds     CH_MAX_CHR

CH_regist:       .ds     CH_MAX_CHR     ;抵抗力

;CH_flag:        .ds     CH_MAX_CHR      ;フラグ
;CH_flag_damaged:        .equ    1       ;ダメージ受けたフラグ

CH_damaged_class:       .ds    CH_MAX_CHR      ;ダメージを受けた時の処理

CH_var0:        .ds     CH_MAX_CHR      ;汎用（用途はキャラクタによって異なる）
CH_var1:        .ds     CH_MAX_CHR      ;汎用（用途はキャラクタによって異なる）
;CH_var2:        .ds     CH_MAX_CHR      ;汎用（用途はキャラクタによって異なる）
;CH_var3:        .ds     CH_MAX_CHR      ;汎用（用途はキャラクタによって異なる）

CH_grp_child:   .ds     CH_MAX_CHR      ; 子供
CH_grp_parent:  .ds     CH_MAX_CHR      ; 親

CH_role_class:  .ds     CH_MAX_CHR
CH_role_next:   .ds     CH_MAX_CHR
CH_role_prev:   .ds     CH_MAX_CHR

CH_spr_class:   .ds     CH_MAX_CHR
CH_spr_next:   .ds     CH_MAX_CHR
CH_spr_prev:   .ds     CH_MAX_CHR

;

;
; role class
;
CDRV_MAX_ROLE_CLASS     .equ    17

CDRV_ROLE_PLAYER        .equ    1
CDRV_ROLE_PBULLET_M1    .equ    2
CDRV_ROLE_PBULLET_M2    .equ    3
CDRV_ROLE_PBULLET_M3    .equ    4
CDRV_ROLE_PBULLET_M4    .equ    5
CDRV_ROLE_EBULLET       .equ    6
CDRV_ROLE_ENEMY_S1      .equ    7
CDRV_ROLE_ENEMY_S2      .equ    8
CDRV_ROLE_ENEMY_G1      .equ    9
CDRV_ROLE_ENEMY_G2      .equ    10
CDRV_ROLE_ENEMY_G3      .equ    11
CDRV_ROLE_ENEMY_G4      .equ    12
CDRV_ROLE_ITEM_S        .equ    13
CDRV_ROLE_ITEM_G        .equ    14
CDRV_ROLE_EFFECT        .equ    15
CDRV_ROLE_BONUS         .equ    16

;
; sprite class
;
CDRV_MAX_SPR_CLASS:     .equ    13

CDRV_SPR_PLAYER         .equ    2
CDRV_SPR_PBULLET_M1     .equ    7
CDRV_SPR_PBULLET_M2     .equ    7
CDRV_SPR_PBULLET_M3     .equ    7
CDRV_SPR_PBULLET_M4     .equ    7
CDRV_SPR_EBULLET        .equ    3
CDRV_SPR_ENEMY_S1       .equ    4
CDRV_SPR_ENEMY_S2       .equ    5
CDRV_SPR_ENEMY_G1       .equ    9
CDRV_SPR_ENEMY_G2       .equ    8
CDRV_SPR_ENEMY_G3       .equ    8
CDRV_SPR_ENEMY_G4       .equ    10
CDRV_SPR_ITEM_S         .equ    6
CDRV_SPR_ITEM_G         .equ    11
CDRV_SPR_EFFECT         .equ    12
CDRV_SPR_EFFECT_G       .equ    8
CDRV_SPR_EFFECT_S       .equ    5
CDRV_SPR_EFFECT_DAMAGE  .equ    4
CDRV_SPR_BONUS          .equ    1

CDRV_MAX_SPRITE         .equ    60      ; キャラクタドライバで割り当てる最大スプライト数

CDrv_role_class_table:  .ds     CDRV_MAX_ROLE_CLASS     ; クラスごとの先頭キャラ
CDrv_role_class_chrnum: .ds     CDRV_MAX_ROLE_CLASS     ; クラスごとのキャラ数
CDrv_role_class_unusedchrnum: .ds     CDRV_MAX_ROLE_CLASS     ; クラスごとの未使用キャラ数

CDrv_spr_class_table:           .ds     CDRV_MAX_SPR_CLASS      ; スプライトクラスの先頭キャラ
CDrv_spr_class_last_table:      .ds     CDRV_MAX_SPR_CLASS      ; スプライトクラスの最後キャラ
CDrv_spr_class_chrnum:          .ds     CDRV_MAX_SPR_CLASS      ; スプライトクラスごとのキャラ数
CDrv_spr_class_allocnum:        .ds     CDRV_MAX_SPR_CLASS      ; スプライトクラスごとのスプライト割り当て数

CDrv_chrnum:    .ds     1       ; 全キャラ数

CH_procptr_tmp: .ds     2



        .code
        .bank   MAIN_BANK

                ; role class ごとの最大キャラクタ数
CDrv_role_class_maxchr:
        .db     0
        .db     1               ; player
        .db     15,15,15,15     ; player bullet
        .db     24              ; enemy bullet
        .db     16,16           ; enemy (sky)
        .db     16,16,8,8       ; enemy (ground)
        .db     4,8             ; item
        .db     16              ; effect
        .db     8               ; bonus display

                ; sprite classをスプライト割り当て優先順位の低い順に並べたリスト（最後は 0 ）
CDrv_spr_class_alloc_prty:
        .db     12, 7,11, 6,10, 8, 9, 5, 4, 3, 2, 1, 0

                ; sprite classごとの最小スプライト割り当て数
CDrv_alloc_min:
        .db     0
        .db     0               ; bonus
        .db     1               ; player
        .db     24              ; enemy bullet
        .db     8,4             ; enemy (sky)
        .db     2               ; item (sky)
        .db     7               ; player bullet
        .db     4,8,2           ; enemy (ground)
        .db     0               ; item (ground)
        .db     0               ; effect

                ; sprite classごとの最大スプライト割り当て数
CDrv_alloc_max:
        .db     0
        .db     60              ; bonus
        .db     60              ; player
        .db     60              ; enemy bullet
        .db     60,60           ; enemy (sky)
        .db     60              ; item (sky)
        .db     7               ; player bullet
        .db     60,60,60        ; enemy (ground)
        .db     60              ; item (ground)
        .db     60              ; effect



;
; initialize chr driver
;
CDRVinit:
        stz     CDrv_chrnum
                ; clear role table
        ldx     #CDRV_MAX_ROLE_CLASS-1
.loop1:
        stz     CDrv_role_class_table,x
        stz     CDrv_role_class_chrnum,x
        lda     CDrv_role_class_maxchr,x
        sta     CDrv_role_class_unusedchrnum,x
        dex
        bne     .loop1
                ; set chrs to unused role link
        lda     #1
        sta     CDrv_role_class_table
        tax
.loop2:
        dec     a
        sta     CH_role_prev,x
        inc     a
        inc     a
        sta     CH_role_next,x
        stz     CH_role_class,x
        stz     CH_spr_class,x
        stz     CH_damaged_class,x
        stz     CH_grp_parent,x
        stz     CH_grp_child,x
        inx
        cpx     #CH_MAX_CHR
        bne     .loop2
        dex
        stx     CDrv_role_class_chrnum
        stz     CH_role_next,x  ; 最後のキャラの次はないので 0 にする

                ; clear spr class
        ldx     #CDRV_MAX_SPR_CLASS-1
.loop3:
        stz     CDrv_spr_class_table,x
        stz     CDrv_spr_class_last_table,x
        stz     CDrv_spr_class_chrnum,x
        dex
        bpl     .loop3

        rts
;
; @param        z_tmp0  role class
; @param        z_tmp1  spr class
; @param        z_tmp2  親キャラ
; @return       y       キャラ番号
;               c flag  1ならキャラ割り当て失敗
; @savereg      x
CDRVaddChr:
.arg_role_class .equ    z_tmp0
.arg_spr_class  .equ    z_tmp1
.arg_grp_parent .equ    z_tmp2

        ldy     <.arg_role_class
        .if     1
        lda     CDrv_role_class_unusedchrnum,y
        .else
        lda     CDrv_role_class_chrnum,y
        cmp     CDrv_role_class_maxchr,y
        .endif
        beq     .nochr

        lda     CDrv_role_class_table
        beq     .nochr

        phx

        tay     ; y = 新しいキャラ
        cla
        sta     CH_damaged_class,y
                ; 未使用キャラの次のキャラを未使用リストの先頭に移動
        ldx     CH_role_next,y
        stz     CH_role_prev,x
        stx     CDrv_role_class_table
        dec     CDrv_role_class_chrnum
                ; 新しいキャラをrole classリストの先頭に挿入
        ldx     <.arg_role_class
        inc     CDrv_role_class_chrnum,x
        dec     CDrv_role_class_unusedchrnum,x
        txa
        sta     CH_role_class,y

        lda     CDrv_role_class_table,x
        sta     CH_role_next,y
        pha
        tya
        sta     CDrv_role_class_table,x

        plx
        sta     CH_role_prev,x

        cla
        sta     CH_role_prev,y

                ; 新しいキャラをspr classリストの先頭に挿入
        ldx     <.arg_spr_class
        inc     CDrv_spr_class_chrnum,x
        txa
        sta     CH_spr_class,y

        lda     CDrv_spr_class_table,x
        sta     CH_spr_next,y
        pha
                ; 初めてのキャラの場合は、最後のキャラでもある
        bne     .00
        tya
        sta     CDrv_spr_class_last_table,x
.00:

        tya
        sta     CDrv_spr_class_table,x

        plx                     ; x= 追加したキャラの次のキャラ
        sta     CH_spr_prev,x

        cla
        sta     CH_spr_prev,y


                ; グループのリンクの末尾に新しいキャラを連結する
        lda     .arg_grp_parent
        sta     CH_grp_parent,y
        beq     .endgrp

.findchild:
        tax
        lda     CH_grp_child,x  ;グループの最後を探す
        bne     .findchild

        tya
        sta     CH_grp_child,x  ;最後のキャラの子供に新しいキャラをセット
        cla
.endgrp:
        sta     CH_grp_child,y  ;a=0 新しいキャラの子供は 0



        inc     CDrv_chrnum

        plx
        clc
        rts

.nochr:
        cly
        sec
        rts
;
; @param        x       キャラ番号
; @save         x
;
; ※注意
;  キャラクタをトラバースしている最中に実行すると、次のキャラクタが未使用のものになってしまい、無限ループなど誤動作が起きる。
;  あらかじめ次のキャラクタを保管しておいてからこれを実行すること。
CDRVremoveChr:
        lda     CH_grp_parent,x
        bne     .child
        lda     CH_grp_child,x
        bne     .all
                ;自分がグループに属してないか、子供の場合は、自分だけ消す
.child:
        clc
        jmp     CDRVremove1Chr

                ;自分が親の場合は、子供もまとめて消す
.all:
        phx
.allloop:
        pha                             ;a=child
        sec
        jsr     CDRVremove1Chr
        plx                             ;x=child
        beq     .allend
        lda     CH_grp_child,x
        bra     .allloop
.allend:
        plx
        rts


; @param        c=1     グループのリンク付け替えをしない（グループのキャラをまとめて削除する場合）

CDRVremove1Chr:
        php
                ; キャラをrole classリストから除去
                ; role class のキャラ数を減らす
        ldy     CH_role_class,x
        sxy
        dec     CDrv_role_class_chrnum,x
        inc     CDrv_role_class_unusedchrnum,x
        sxy

        lda     CH_role_next,x
        ldy     CH_role_prev,x
        beq     .root
        sta     CH_role_next,y
        say
        sta     CH_role_prev,y
        bra     .j1
                ; role class のリストの先頭だった場合は CDrv_role_class_table を変更
.root:  ldy     CH_role_class,x
        sta     CDrv_role_class_table,y
        tay
        cla
        sta     CH_role_prev,y
.j1:
                ; キャラをspr classリストから除去
        ldy     CH_spr_class,x
        sxy
        dec     CDrv_spr_class_chrnum,x         ; dec nnnn,y がないので一時的にx/yを入れ替えて対処
        sxy

        lda     CH_spr_next,x
                        ; 最後のキャラなら、最後のキャラを更新
        bne     .00
        pha
        lda     CH_spr_prev,x
        ldy     CH_spr_class,x
        sta     CDrv_spr_class_last_table,y
        pla
.00
        ldy     CH_spr_prev,x
        beq     .root2
        sta     CH_spr_next,y
        say
        sta     CH_spr_prev,y
        bra     .j2
.root2: ldy     CH_spr_class,x
        sta     CDrv_spr_class_table,y
        tay
        cla
        sta     CH_spr_prev,y
.j2:

                ;グループに属している場合、グループリンクから自分を外す
                ;グループのリンクリストは一方向なので、先頭から順に探す必要がある
.tmp_chrno      .equ    z_tmp15
        plp
        bcs     .addunusedlist          ;c=1 （グループを全部削除）の場合はスキップ

        lda     CH_grp_parent,x
        beq     .addunusedlist

        stx     <.tmp_chrno
.find:
        tay
        lda     CH_grp_child,y
        cmp     <.tmp_chrno
        bne     .find

        lda     CH_grp_child,x
        sta     CH_grp_child,y



.addunusedlist:
                ; キャラを未使用リストに挿入
        ldy     CDrv_role_class_table
        stx     CDrv_role_class_table
        tya
        sta     CH_role_next,x
        stz     CH_role_prev,x
        txa
        sta     CH_role_prev,y
        inc     CDrv_role_class_chrnum
        stz     CH_role_class,x
        stz     CH_spr_class,x

        dec     CDrv_chrnum

        rts
;
; move chrs
;
CDRVmove:
        ldy     #1
.loop:
        lda     CDrv_role_class_table,y
        beq     .next
                ; move chrs in one role class
        phy
.chrloop:
        tax
        lda     #HIGH(.endmove-1)       ;要注意 pushするのは 戻りアドレス-1
        pha
        lda     #LOW(.endmove-1)
        pha

        lda     CH_procptrl,x
        sta     CH_procptr_tmp
        lda     CH_procptrh,x
        sta     CH_procptr_tmp+1
        jmp     [CH_procptr_tmp]
.endmove:
        bcs     .remove

        lda     CH_role_next,x
.nextchr:
        bne     .chrloop
        ply
                ; next role class
.next:
        iny
        cpy     #CDRV_MAX_ROLE_CLASS
        bne     .loop
        rts

                ; remove current chr
.remove:
        lda     CH_role_next,x
        pha
        jsr     CDRVremoveChr
        pla
        bra     .nextchr
;
;
;


CDRVsetSprite:
.satbptr        .equ    z_tmp0
.sprnum         .equ    z_tmp2
.allocnum       .equ    z_tmp3
.chrnum         .equ    z_tmp4

.firstchr       .equ    z_tmp9
.chrnumsave     .equ    z_tmp10

.chr1           .equ    z_tmp5
.chr2           .equ    z_tmp6
.chr3           .equ    z_tmp7
.chr4           .equ    z_tmp8

        lda     #LOW(satb)
        sta     <.satbptr
        lda     #HIGH(satb)
        sta     <.satbptr+1

        lda     #CDRV_MAX_SPRITE
        sta     <.sprnum

        cly
        ldx     #1
.loop:
        lda     CDrv_spr_class_allocnum,x
        beq     .next
        sta     <.allocnum

        lda     CDrv_spr_class_chrnum,x
        beq     .next
        sta     <.chrnum
        sta     <.chrnumsave

        lda     CDrv_spr_class_table,x
        sta     <.firstchr
        phx
.chrloop:
                ; set sprite to satb
        tax     ; x = キャラ番号
                ; set y
        lda     CH_yl,x
        asl     a
        php
        lda     CH_yh,x
        sec
        sbc     CH_sprdy,x
        plp
        rol     a
        sta     [.satbptr],y
        iny
        rol     a
        and     #1
        sta     [.satbptr],y
        iny
                ; set x
        lda     CH_xl,x
        asl     a
        php
        lda     CH_xh,x
        sec
        sbc     CH_sprdx,x
        plp
        rol     a
        sta     [.satbptr],y
        iny
        rol     a
        and     #1
        sta     [.satbptr],y
        iny
                ; set pattern
        lda     CH_sprpatl,x
        sta     [.satbptr],y
        iny
        lda     CH_sprpath,x
        sta     [.satbptr],y
        iny
                ; set attribute
        lda     CH_spratrl,x
        sta     [.satbptr],y
        iny
        lda     CH_spratrh,x
        sta     [.satbptr],y
        iny
                ; y>=256 になったら .satbptr を+256
        beq     .addptr

.nextchr:
        lda     CH_spr_next,x

        dec     <.sprnum
        dec     <.chrnum
        dec     <.allocnum
        bne     .chrloop

        lda     <.chrnum   ; .chrnum == 0 ?
        bne     .swap
        lda     <.chrnumsave
        cmp     #1
        beq     .endswap
        ldx     <.firstchr
        bra     .swap
.endswap:
        plx                     ; x = sprite class

.next:
        inx
        cpx     #CDRV_MAX_SPR_CLASS
        bne     .loop

                ; clear rest of satb
        lda     <.sprnum
        beq     .end
        cla
.clearloop:
        sta     [.satbptr],y
        iny
        sta     [.satbptr],y
        say
        clc
        adc     #7
        say
        beq     .addptr2
.next2
        dec     <.sprnum
        bne     .clearloop
.end:
        rts
.ret:
        plx
        rts
.addptr:
        inc     <.satbptr+1
        bra     .nextchr
.addptr2:
        inc     <.satbptr+1
        bra     .next2

                ; スプライトが割り当てられたキャラと、そうでないキャラを入れ替える
.swap:
        phy
                ; x=chr2
        lda     CH_spr_prev,x
        beq     .swap2
        lda     CH_spr_next,x
        beq     .swap3
                        ; 入れ替えキャラが途中の場合
        sta     <.chr3
        lda     CH_spr_class,x
        tay
        lda     CDrv_spr_class_table,y
        sta     <.chr1
        lda     CDrv_spr_class_last_table,y
        sta     <.chr4

        stz     CH_spr_next,x

        txa
        sta     CDrv_spr_class_last_table,y

        ldx     <.chr1
        lda     <.chr4
        sta     CH_spr_prev,x

        sax
        sta     CH_spr_next,x

        lda     <.chr3
        sta     CDrv_spr_class_table,y

        tax
        stz     CH_spr_prev,x

        ply
        bra     .endswap

                        ; 入れ替えキャラが先頭の場合
.swap2:
        lda     CH_spr_next,x
        sta     <.chr3
        lda     CH_spr_class,x
        tay
        lda     CDrv_spr_class_last_table,y
        sta     <.chr4

        stz     CH_spr_next,x

        txa
        sta     CDrv_spr_class_last_table,y

        lda     <.chr4
        sta     CH_spr_prev,x

        sax
        sta     CH_spr_next,x

        lda     <.chr3
        sta     CDrv_spr_class_table,y

        tax
        stz     CH_spr_prev,x

        ply
        jmp     .endswap

                        ; 入れ替えキャラが最後の場合
.swap3:
        lda     CH_spr_prev,x
        sta     <.chr2
        lda     CH_spr_class,x
        tay
        lda     CDrv_spr_class_table,y
        sta     <.chr1

        sta     CH_spr_next,x
        stz     CH_spr_prev,x

        txa
        sta     CDrv_spr_class_table,y

        ldx     <.chr1
        sta     CH_spr_prev,x

        sax
        sta     CH_spr_next,x

        lda     <.chr2
        sta     CDrv_spr_class_last_table,y

        tax
        stz     CH_spr_next,x

        ply
        jmp     .endswap


;
;
;


CDRVallocSprite:
.totalreduce         .equ    z_tmp0
.classreduce    .equ    z_tmp1
        lda     CDrv_chrnum
        sec
        sbc     #CDRV_MAX_SPRITE             ;@todo 残りスプライト数
        bcc     .allok          ;全キャラ割り当て可能
        sta     <.totalreduce

        cly                     ; y = alloc class table index
.loop1:
        ldx     CDrv_spr_class_alloc_prty,y     ;x=spr class
        beq     .end

        lda     CDrv_spr_class_chrnum,x
        sec
        sbc     CDrv_alloc_min,x
        bcc     .02

        cmp     <.totalreduce
        bcc     .00
        beq     .00
                ;削減可能数>削減数
        lda     CDrv_spr_class_chrnum,x
        sec
        sbc     <.totalreduce
        sta     CDrv_spr_class_allocnum,x
        stz     <.totalreduce
        bra     .next
                ;削減可能数=<削減数
.00:
                                ; a=削減可能数
        eor     #$ff
        inc     a
        pha
        clc
        adc     CDrv_spr_class_chrnum,x
        sta     CDrv_spr_class_allocnum,x

        pla                     ; a=-削減可能数
        clc
        adc     <.totalreduce
        sta     <.totalreduce
        bra     .next

                ;削減可能数<0
.02:
        lda     CDrv_spr_class_chrnum,x
        sta     CDrv_spr_class_allocnum,x

.next:
        iny
        bra     .loop1

                ;全キャラ割り当て可能
.allok:
        cly
.loop2:
        lda     CDrv_spr_class_chrnum,y
        sta     CDrv_spr_class_allocnum,y
        iny
        cpy     #CDRV_MAX_SPR_CLASS
        bne     .loop2
.end:
        rts
