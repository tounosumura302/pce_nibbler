    .bss

EB_MAXNUM   .equ    40  ; maximum number of player's bullets
                        ; x coordinate
EB_x0:  .ds EB_MAXNUM   ; fraction
EB_x1:  .ds EB_MAXNUM   ; integer(low)
EB_x2:  .ds EB_MAXNUM   ; integer(high)
                        ; y coordinate
EB_y0:  .ds EB_MAXNUM   ; fraction
EB_y1:  .ds EB_MAXNUM   ; integer(low)
EB_y2:  .ds EB_MAXNUM   ; integer(high)
                        ; direction/enable flag   $80=disabled  $00-$0e=enabled and direction
EB_dir: .ds EB_MAXNUM
                        ; character number
                        ; setSatb のコードが冗長になるのでキャラごとにキャッシュ
EB_chr0: .ds EB_MAXNUM
EB_chr1: .ds EB_MAXNUM

    .code
    .bank   MAIN_BANK

EB_init:
        ; disable all bullets
    lda #$80
    sta EB_dir
    tii EB_dir,EB_dir+1,EB_MAXNUM-1

    rts

EB_move:
        clx
.loop:
                ; enable?
        tst #$80,EB_dir,x
        bne .next

                ; copy x/y for move2Direction
        lda EB_x0,x
        sta <z_curchr_x
        lda EB_x1,x
        sta <z_curchr_x+1
        lda EB_x2,x
        sta <z_curchr_x+2

        lda EB_y0,x
        sta <z_curchr_y
        lda EB_y1,x
        sta <z_curchr_y+1
        lda EB_y2,x
        sta <z_curchr_y+2

                ; move
        ldy     EB_dir,x
        jsr     move2Direction

                ; copy back x
        lda     <z_curchr_x
        sta     EB_x0,x
        lda     <z_curchr_x+1
        sta     EB_x1,x
        tay                     ; used for clipping
        lda     <z_curchr_x+2
        sta     EB_x2,x

                ; clipping x pos
        bne     .x1
        cpy     #$20-16         ; x<$0010 ?
        bcc     .out
        bra     .sety
.x1:    cpy     #$50+$20            ; x>=$0170 ?
        bcs     .out

                ; copy back y
.sety:
        lda     <z_curchr_y
        sta     EB_y0,x
        lda     <z_curchr_y+1
        sta     EB_y1,x
        tay
        lda     <z_curchr_y+2
        sta     EB_y2,x

                ; clipping y pos
        bne     .y1
        cpy     #$40-16         ; y<$0030 ?
        bcc     .out
        bra     .next
.y1:    cpy     #$30            ; y>=$0130 ?
        bcs     .out

                ; next
.next:
        inx
        cpx     #EB_MAXNUM
        bmi     .loop
        rts

                ; out of screen
.out:
        lda #$80
        sta EB_dir,x
        bra .next


; shoot enemny bullets
;   y = direction (0x00-0x0e)
EB_shoot:
    clx
.loop:
    tst #$80,EB_dir,x
    bne .found

    inx
    cpx #EB_MAXNUM
    bmi .loop
    rts

.found:
        ; set x
    stz EB_x0,x
    lda #$40
    sta EB_x1,x
    lda #$01
    sta EB_x2,x
        ; set y
    stz EB_y0,x
    lda #$80
    sta EB_y1,x
    lda #$00
    sta EB_y2,x

    tya
    sta EB_dir,x

        ; set character
    lda #$0f
    sta EB_chr0,x
    lda #$03
    sta EB_chr1,x

    rts



; set enemy's bullets to satb
EB_setSatb:
    clx
    ldy #4*8

    ; satbの前半256バイトの範囲の書き込み
    ; y が８ビットなので、前半後半で分けている
    ; sta (),y で書き込むべきなんだろうか
.loop:
        ; enable?
    tst #$80,EB_dir,x
    bne .next
        ; set y
    lda EB_y1,x
    sta satb,y
    iny
    lda EB_y2,x
    sta satb,y
    iny
        ; set x
    lda EB_x1,x
    sta satb,y
    iny
    lda EB_x2,x
    sta satb,y
    iny
        ; set chr
    lda EB_chr0,x
    sta satb,y
    iny
    lda EB_chr1,x
    sta satb,y
    iny
        ; set attribute
    lda #$80
    sta satb,y
    iny
    cla
    sta satb,y
    iny
    beq .step2

.next:
    inx
    cpx #EB_MAXNUM
    bmi .loop
    rts

    ; satbの後半256バイトの範囲の書き込み
    ; 絶対アドレスを +256 しておくことで後半256バイトにアクセス
.step2
;    ldy #0
.loop2:
        ; enable?
    tst #$80,EB_dir,x
    bne .next2
        ; set y
    lda EB_y1,x
    sta satb+256,y
    iny
    lda EB_y2,x
    sta satb+256,y
    iny
        ; set x
    lda EB_x1,x
    sta satb+256,y
    iny
    lda EB_x2,x
    sta satb+256,y
    iny
        ; set chr
    lda EB_chr0,x
    sta satb+256,y
    iny
    lda EB_chr1,x
    sta satb+256,y
    iny
        ; set attribute
    lda #$80
    sta satb+256,y
    iny
    cla
    sta satb+256,y
    iny

.next2:
    inx
    cpx #EB_MAXNUM
    bmi .loop2
    rts
