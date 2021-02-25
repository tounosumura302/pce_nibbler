
        .zp
z_dir_targetx:  .ds     1       ;target x pos
z_dir_targety:  .ds     1       ;target y pos
z_dir_sourcex:  .ds     1       ;source x pos
z_dir_sourcey:  .ds     1       ;source y pos
z_dir_dx:       .ds     1       ;dx
z_dir_dy:       .ds     1       ;du
z_dir_flag:     .ds     1       ;flag
                                ; bit0,4-7: always 0
                                ; bit1 : 1 => dx<dy
                                ; bit2 : 1 => dx<0
                                ; bit3 : 1 => dy<0 
z_dir_quotient: .ds     1       ;quotient

z_dir_multiplicand:     .ds     2
z_dir_multiplier:       .ds     2
z_dir_result_dx:        .ds     2
z_dir_result_dy:        .ds     2

        .code
        .bank   MAIN_BANK

        ; z_dir_targetx
        ; z_dir_targety
        ; z_dir_sourcex
        ; z_dir_sourcey
        ; return  a
getDirection:
        phx

        stz     <z_dir_flag
                ; dx=(targetx-sourcex)/4
        lda     <z_dir_targetx
        sec
        sbc     <z_dir_sourcex
        bcs     .01
                ; target < source
        smb2    <z_dir_flag
        eor     #$ff
        inc     a
.01:    lsr     a
        sta     <z_dir_dx

                ; dy=(tagety-sourcey)/4
        lda     <z_dir_targety
        sec
        sbc     <z_dir_sourcey
        bcs     .02
                ; target < source
        smb3    <z_dir_flag
        eor     #$ff
        inc     a
.02:    lsr     a
        sta     <z_dir_dy

                ; dy=0?
        beq     .dy0
                ; dx=0?
        tst     #$00,<z_dir_dx
        beq     .dxdynot0
                ; dx=0
        tst     #$08,<z_dir_flag        ; dy>0 ?
        bne     .dir8
        lda     #24                     ; dy>0
        plx
        rts
.dir8:  lda     #8                      ; dy<0
        plx
        rts
                ; dy=0
.dy0:
        tst     #$04,<z_dir_flag        ; dx>=0 ?
        bne     .dir0
        lda     #16                     ; dx>=0
        plx
        rts
.dir0:  lda     #0                      ; dx<0
        plx
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
                ; z_dir_quotient=dy/dx  dx and dy are 7bit
        ldx     #8
        lda     <z_dir_dy
.divloop:
        asl     a
        cmp     <z_dir_dx
        bcc     .divskip
        sbc     <z_dir_dx
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
        plx
        rts
.f001:
        eor     #$ff
        inc     a
        clc
        adc     #24
        plx
        rts
.f010:
        eor     #$ff
        inc     a
        clc
        adc     #32
        and     #$1f    ;
        plx
        rts
.f011:
        clc
        adc     #24
        plx
        rts
.f100:
        eor     #$ff
        inc     a
        clc
        adc     #16
        plx
        rts
.f101:
        clc
        adc     #8
        plx
        rts
.f110:
        plx
        rts
.f111:
        eor     #$ff
        inc     a
        clc
        adc     #8
        plx
        rts


dirtable_x_l:
    .db $80,$83,$8a,$96,$a6,$b9,$d0,$e8,$00,$18,$30,$47,$5a,$6a,$76,$7d
    .db $80,$7d,$76,$6a,$5a,$47,$30,$18,$00,$e8,$d0,$b9,$a6,$96,$8a,$83
dirtable_x_h:
    .db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
dirtable_y_l:
    .db $00,$e8,$d0,$b9,$a6,$96,$8a,$83,$80,$83,$8a,$96,$a6,$b9,$d0,$e8
    .db $00,$18,$30,$47,$5a,$6a,$76,$7d,$80,$7d,$76,$6a,$5a,$47,$30,$18
dirtable_y_h:
    .db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

        ; y=direction
        ; a=length of vector
        ; @result
        ; z_dir_result_dx
        ; z_dir_result_dy
convDirection2DxDy:
                ; result_dx=dx*a
        sta     <z_dir_multiplier
        pha

        lda     dirtable_x_l,y
        sta     <z_dir_multiplicand
        lda     dirtable_x_h,y
        sta     <z_dir_multiplicand+1

        stz     <z_dir_result_dx
        stz     <z_dir_result_dx+1
        ldx     #8
.loopx:
        lsr     <z_dir_multiplier
        bcc     .nextx
.addx:  lda     <z_dir_result_dx
        clc
        adc     <z_dir_multiplicand
        sta     <z_dir_result_dx
        lda     <z_dir_result_dx+1
        adc     <z_dir_multiplicand+1
        sta     <z_dir_result_dx+1
.nextx:
        asl     <z_dir_multiplicand
        rol     <z_dir_multiplicand+1
        dex
        bne     .loopx
.endx:
                ; result_dy=dy*a
        pla
        sta     <z_dir_multiplier

        lda     dirtable_y_l,y
        sta     <z_dir_multiplicand
        lda     dirtable_y_h,y
        sta     <z_dir_multiplicand+1


        stz     <z_dir_result_dy
        stz     <z_dir_result_dy+1
        ldx     #8
.loopy:
        lsr     <z_dir_multiplier
        bcc     .nexty
.addy:  lda     <z_dir_result_dy
        clc
        adc     <z_dir_multiplicand
        sta     <z_dir_result_dy
        lda     <z_dir_result_dy+1
        adc     <z_dir_multiplicand+1
        sta     <z_dir_result_dy+1
.nexty:
        asl     <z_dir_multiplicand
        rol     <z_dir_multiplicand+1
        dex
        bne     .loopy
.endy:
        rts

