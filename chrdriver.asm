        .bss

CH_MAX_CHR      .equ    60

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

CH_role_class:  .ds     CH_MAX_CHR
CH_role_next:   .ds     CH_MAX_CHR
CH_role_prev:   .ds     CH_MAX_CHR

CH_spr_class:   .ds     CH_MAX_CHR
CH_spr_next:   .ds     CH_MAX_CHR
CH_spr_prev:   .ds     CH_MAX_CHR

;

CDRV_MAX_ROLE_CLASS       .equ    10
CDrv_role_class_table:  .ds     CDRV_MAX_ROLE_CLASS
CDrv_role_class_chrnum: .ds     CDRV_MAX_ROLE_CLASS

CDRV_MAX_SPR_CLASS:   .equ    10
CDrv_spr_class_table: .ds     CDRV_MAX_SPR_CLASS
CDrv_spr_class_chrnum:    .ds     CDRV_MAX_SPR_CLASS


;

CH_procptr_tmp: .ds     2

        .code
        .bank   MAIN_BANK
;
; initialize chr driver
;
CDRVinit:
                ; clear role table
        ldx     #CDRV_MAX_ROLE_CLASS-1
.loop1:
        stz     CDrv_role_class_table,x
        stz     CDrv_role_class_chrnum,x
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
        stz     CDrv_spr_class_chrnum,x
        dex
        bpl     .loop3

        rts
;
; @param        z_tmp0  role class
; @param        z_tmp1  spr class
; @return       y       キャラ番号
;               c flag  1ならキャラ割り当て失敗
CDRVaddChr:
.arg_role_class     .equ    z_tmp0
.arg_spr_class  .equ    z_tmp1

        lda     CDrv_role_class_table
        beq     .nochr

        phx

        tay     ; y = 新しいキャラ
                ; 未使用キャラの次のキャラを未使用リストの先頭に移動
        ldx     CH_role_next,y
        stz     CH_role_prev,x
        stx     CDrv_role_class_table
        dec     CDrv_role_class_chrnum
                ; 新しいキャラをrole classリストの先頭に挿入
        ldx     <.arg_role_class
        inc     CDrv_role_class_chrnum,x
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
        tya
        sta     CDrv_spr_class_table,x

        plx
        sta     CH_spr_prev,x

        cla
        sta     CH_spr_prev,y

        plx
        clc
        rts

.nochr:
        cly
        sec
        rts
;
; @param        x       キャラ番号
;
CDRVremoveChr:
                ; キャラをrole classリストから除去
        ldy     CH_role_class,x
        sxy
        dec     CDrv_role_class_chrnum,x
        sxy

        lda     CH_role_next,x
        ldy     CH_role_prev,x
        beq     .root
        sta     CH_role_next,y
        say
        sta     CH_role_prev,y
        bra     .j1
.root:  ldy     CH_role_class,x
        sta     CDrv_role_class_table,y
        cla
        sta     CH_role_prev,y
.j1:
                ; キャラをspr classリストから除去
        ldy     CH_spr_class,x
        sxy
        dec     CDrv_spr_class_chrnum,x
        sxy

        lda     CH_spr_next,x
        ldy     CH_spr_prev,x
        beq     .root2
        sta     CH_spr_next,y
        say
        sta     CH_spr_prev,y
        bra     .j2
.root2: ldy     CH_spr_class,x
        sta     CDrv_spr_class_table,y
        cla
        sta     CH_spr_prev,y
.j2:
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

        lda     #LOW(satb)
        sta     <.satbptr
        lda     #HIGH(satb)
        sta     <.satbptr+1

        lda     #64
        sta     <.sprnum

        cly
        ldx     #1
.loop:
        lda     CDrv_spr_class_table,x
        beq     .next

        phx
.chrloop:
        tax
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
        beq     .addptr

.nextchr:
        dec     <.sprnum
        beq     .ret

        lda     CH_spr_next,x
        bne     .chrloop
        plx

.next:
        inx
        cpx     #CDRV_MAX_SPR_CLASS
        bne     .loop

                ; clear rest of satb
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
.ret:
        rts

.addptr:
        inc     <.satbptr+1
        bra     .nextchr
.addptr2:
        inc     <.satbptr+1
        bra     .next2


