
        .zp
z_dir_targetx:  .ds     2       ;target x pos
z_dir_targety:  .ds     2       ;target y pos
z_dir_sourcex:  .ds     2       ;source x pos
z_dir_sourcey:  .ds     2       ;source y pos
z_dir_dx:       .ds     1       ;dx
z_dir_dy:       .ds     1       ;du
z_dir_flag:     .ds     1       ;flag
                                ; bit0,4-7: always 0
                                ; bit1 : 1 => dx<dy
                                ; bit2 : 1 => dx<0
                                ; bit3 : 1 => dy<0 
z_dir_quotient: .ds     1       ;quotient


        .code
        .bank   MAIN_BANK

        ; z_dir_targetx
        ; z_dir_targety
        ; z_dir_sourcex
        ; z_dir_sourcey
        ; return  a
getDirection:
        stz     <z_dir_flag

                ; dx=(targetx/2)-(sourcex/2)
        lsr     <z_dir_targetx+1
        ror     <z_dir_targetx
        lsr     <z_dir_sourcex+1
        ror     <z_dir_sourcex
        lda     <z_dir_targetx
        sec
        sbc     <z_dir_sourcex
        bcs     .01
                ; target < source
        smb2    <z_dir_flag
        eor     #$ff
        inc     a
.01:    sta     <z_dir_dx

                ; dy=(targety/2)-(sourcey/2)
        lsr     <z_dir_targety+1
        ror     <z_dir_targety
        lsr     <z_dir_sourcey+1
        ror     <z_dir_sourcey
        lda     <z_dir_targety
        sec
        sbc     <z_dir_sourcey
        bcs     .02
                ; target < source
        smb3    <z_dir_flag
        eor     #$ff
        inc     a
.02:    sta     <z_dir_dy

                ; dy=0?
        beq     .dy0
                ; dx=0?
        tst     #$00,<z_dir_dx
        beq     .dxdynot0
                ; dx=0
        tst     #$08,<z_dir_flag        ; dy>0 ?
        bne     .dir8
        lda     #24                     ; dy>0
        rts
.dir8:  lda     #8                      ; dy<0
        rts
                ; dy=0
.dy0:
        tst     #$04,<z_dir_flag        ; dx>=0 ?
        bne     .dir0
        lda     #16                     ; dx>=0
        rts
.dir0:  lda     #0                      ; dx<0
        rts

.dxdynot0:
                ; dy>dx ?
        cmp     <z_dir_dx
        bcc     .03
                ; dy>dx
        smb1    <z_dir_flag
                ; swap dx/dy
        ldx     <z_dir_dx
        sta     <z_dir_dx
        stx     <z_dir_dy
.03:
                ; z_dir_quotient=dy/dx
        ldx     #8
        lda     <z_dir_dy       ; a       = lower byte of divident
        stz     <z_dir_dy       ; z_dir_y = higher byte of divident
.divloop:
        asl     a
        rol     <z_dir_dy
        bne     .gt             ; divident is always greater than divisor if higher byte of divident > 0
        cmp     <z_dir_dx
        bcc     .divskip
                ; 9bit（被除数）-8bit（除数）だが、被除数の9ビット目は減算で必ず0になるので、減算はせずに強制的に0にしている。
                ; ただし、9ビット目が１だった場合、下位8ビットの減算でCフラグが0になってしまうので、強制的にC=1にする必要がある。
.gt:
        sec
        sbc     <z_dir_dx
        stz     <z_dir_dy
        sec
.divskip:
        rol     <z_dir_quotient
        dex
        bne     .divloop
                ; quotient -> direction index
        lda     <z_dir_quotient
        cmp     #$4d
        bcs     .d020304
        cmp     #$19
        bcs     .d01
        lda     #0
        bra     .d
.d01:   lda     #1
        bra     .d
.d020304:
        cmp     #$88
        bcc     .d02
        cmp     #$d2
        bcc     .d03
        lda     #4
        bra     .d
.d02:   lda     #2
        bra     .d
.d03:   lda     #3
.d:     
                ; adjust direction index
        ldx     <z_dir_flag
        jmp     [.jmptbl,x]
.jmptbl .dw     .f000,.f001,.f010,.f011,.f100,.f101,.f110,.f111
.f000:
        clc
        adc     #16
        rts
.f001:
        eor     #$ff
        inc     a
        clc
        adc     #24
        rts
.f010:
        eor     #$ff
        inc     a
        clc
        adc     #32
        and     #$1f    ;
        rts
.f011:
        clc
        adc     #24
        rts
.f100:
        eor     #$ff
        inc     a
        clc
        adc     #16
        rts
.f101:
        clc
        adc     #8
        rts
.f110:
        rts
.f111:
        eor     #$ff
        inc     a
        clc
        adc     #8
        rts


        ; move
        ; y = direction
move2Direction:
        lda     <z_curchr_x
        clc
        adc     dirtable_x_l,y
        sta     <z_curchr_x
        lda     <z_curchr_x+1
        adc     dirtable_x_m,y
        sta     <z_curchr_x+1
        lda     <z_curchr_x+2
        adc     dirtable_x_h,y
        sta     <z_curchr_x+2

        lda     <z_curchr_y
        clc
        adc     dirtable_y_l,y
        sta     <z_curchr_y
        lda     <z_curchr_y+1
        adc     dirtable_y_m,y
        sta     <z_curchr_y+1
        lda     <z_curchr_y+2
        adc     dirtable_y_h,y
        sta     <z_curchr_y+2

        rts

dirtable_x_l:
    .db $00,$05,$14,$2c,$4b,$72,$9f,$cf,$00,$31,$61,$8e,$b5,$d4,$ec,$fb,$00,$fb,$ec,$d4,$b5,$8e,$61,$31,$00,$cf,$9f,$72,$4b,$2c
    .db $14,$05
dirtable_x_m:
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00
    .db $01,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
dirtable_x_h:
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
dirtable_y_l:
    .db $00,$cf,$9f,$72,$4b,$2c,$14,$05,$00,$05,$14,$2c,$4b,$72,$9f,$cf
    .db $00,$31,$61,$8e,$b5,$d4,$ec,$fb,$00,$fb,$ec,$d4,$b5,$8e,$61,$31
dirtable_y_m:
    .db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .db $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00
dirtable_y_h:
    .db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
