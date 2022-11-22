
        .bss
;PL_x:   .ds     2
;PL_y:   .ds     2


;PL_chr: .ds     1       ;プレイヤーのキャラ番号

        .zp
zplx:       ds      1
zply:       ds      1

zpldir:         ds      1
zpldirr:        ds      1

zplspeed:       ds      1

        .code
        .bank   MAIN_BANK


;       ldru----
plInit:
        lda     #13*8
        sta     <zplx
        lda     #25*8
        sta     <zply

        lda     #2
        sta     <zplspeed

        lda     #%00100000
        jsr     plSetDir
        rts

;
;       移動方向をセット
;
plSetDir:
        sta     <zpldir

        bit     #%10100000
        beq     .du
        eor     #%10100000
        bra     .set
.du:    eor     #%01010000
.set:   sta     <zpldirr
        rts

;
;       移動
;
plMove:
.tmp_vadr_l     equ     ztmp0       ;仮想VRAMアドレス
.tmp_vadr_h     equ     ztmp1
.tmp_p          equ     ztmp2       ;仮想VRAM上の値
.tmp_pad        equ     ztmp3       ;コントローラーの値

        lda     <zplx
        ora     <zply
        and     #$07
        bne     .notchanged
                        ;仮想VRAMアドレス計算
        stz     <.tmp_vadr_h
        lda     <zply
        and     #$f8
        asl     a
        rol     <.tmp_vadr_h
        asl     a
        rol     <.tmp_vadr_h
        sta     <.tmp_vadr_l
        lda     <zplx
        lsr     a
        lsr     a
        lsr     a
        ora     <.tmp_vadr_l
        clc
        adc     #LOW(VMap)
        sta     <.tmp_vadr_l
        lda     <.tmp_vadr_h
        adc     #HIGH(VMap)
        sta     <.tmp_vadr_h
                        ;現在位置の仮想VRAMの値
        lda     [.tmp_vadr_l]
        sta     <.tmp_p
                        ;コントローラーが押されている場合の方向転換判定 ldru
        lda     <zpad
        and     #$f0
        beq     .notpushed
        sta     <.tmp_pad
        lda     <zpldir
        ora     <zpldirr
        trb     <.tmp_pad
        beq     .notpushed
        lda     <.tmp_pad
        bit     <.tmp_p
        bne     .changed
                        ;コントローラーが押されていない場合の方向転換判定
.notpushed:
        lda     <.tmp_p
        bit     <zpldir
        bne     .notchanged

        lsr     a
        lsr     a
        lsr     a
        lsr     a
        tax
        lda     DirCountTbl,x
        cmp     #2
        beq     .dc2
        cmp     #3
        bne     .notchanged
        bra     .notmove
.dc2:
        lda     <.tmp_p
        eor     <zpldirr
.changed:
        jsr     plSetDir
.notchanged:
                        ;ldru
        lda     <zpldir
        asl     a
        bcs     .moveleft
        asl     a
        bcs     .movedown
        asl     a
        bcs     .moveright
        bpl     .notmove
.moveup:
        lda     <zply
        sec
        sbc     <zplspeed
        sta     <zply
        bra     .moved
.moveleft:
        lda     <zplx
        sec
        sbc     <zplspeed
        sta     <zplx
        bra     .moved
.movedown:
        lda     <zply
        clc
        adc     <zplspeed
        sta     <zply
        bra     .moved
.moveright:
        lda     <zplx
        clc
        adc     <zplspeed
        sta     <zplx
.notmove:
.moved:
                        ;（実験）スプライト座標設定
        lda     <zplx
        clc
        adc     #$20-4
        sta     satb+2
        stz     satb+3

        lda     <zply
        clc
        adc     #$40-4+8
        sta     satb+0
        lda     #0
        adc     #0
        sta     satb+1

        rts

;
;       移動可能方向の数（インデックス値のセットされたビットの数）
;
DirCountTbl:
        db      0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4


