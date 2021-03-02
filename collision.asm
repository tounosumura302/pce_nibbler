        .code


; 衝突判定
; @param        x       character
; @param        z_tmp0  x of collision partner
; @param        z_tmp1  y of collision partner
; @return       cc      collided
CLtest:
.targetx        .equ    z_tmp0
.targety        .equ    z_tmp1

                                ;24-28
        lda     CH_xh,x         ;5
        sec                     ;2
        sbc     <.targetx       ;4
        bpl     .plusx          ;2 / 4

        eor     #$ff            ;2
        inc     a               ;2
.plusx:
        cmp     CH_coldx,x      ;5
        bcs     .ret            ;2 / 4

        lda     CH_yh,x         ;5
        sec                     ;2
        sbc     <.targety       ;4
        bpl     .plusy          ;2 / 4

        eor     #$ff            ;2
        inc     a               ;2
.plusy:
        cmp     CH_coldy,x      ;5
.ret:   rts                     ;cs = collision


;
; 自機と敵弾
;
CLtestPlayer2EBullet:
                ; set player's position
        ldx     PL_chr
        lda     CH_xh,x
        sta     <z_tmp0
        lda     CH_yh,x
        sta     <z_tmp1

        lda     CDrv_role_class_table+CDRV_ROLE_EBULLET
.loop:
        beq     .end
        tax
        
        jsr     CLtest

        bcs     .next

                ; collided
        ldy     PL_chr
        lda     #LOW(PLdead)
        sta     CH_procptrl,y
        lda     #HIGH(PLdead)
        sta     CH_procptrh,y

        lda     CH_role_next,x
        pha
        jsr     CDRVremoveChr
        pla
        bra     .loop

.next:
        lda     CH_role_next,x
        bra     .loop
.end:
        rts


;
;
;
CLtestPBullet2Enemy:
                ;自機弾でループ
        ldy     #CDRV_ROLE_PBULLET_M1
.loop:
        lda     CDrv_role_class_table,y
        beq     .next

        phy
.loop2:
        tax
        lda     CH_xh,x
        sta     <z_tmp0
        lda     CH_yh,x
        sta     <z_tmp1

        jsr     CLtest1PBullet2Enemy
        bcs     .next2

        lda     CH_role_next,x
        pha
        jsr     CDRVremoveChr
        pla
        bra     .next3

.next2:
        lda     CH_role_next,x
.next3:
        bne     .loop2

        ply
.next:
        iny
        cpy     #CDRV_ROLE_PBULLET_M1+4
        bne     .loop
        rts



CLtest1PBullet2Enemy:
                ;敵でループ
        phx

        lda     CDrv_role_class_table+CDRV_ROLE_ENEMY_S1
.loop:
        beq     .end
        tax
        
        jsr     CLtest

        bcs     .next

                ; collided
        lda     #LOW(ENdead)
        sta     CH_procptrl,x
        lda     #HIGH(ENdead)
        sta     CH_procptrh,x

        plx
        clc
        rts

.next:
        lda     CH_role_next,x
        bra     .loop
.end:
        plx
        sec
        rts

