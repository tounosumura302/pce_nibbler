
        .bss
PL_x:   .ds     2
PL_y:   .ds     2


        .code
        .bank   MAIN_BANK

PL_init:
        stz     PL_x
        lda     #$40
        sta     PL_x+1
        stz     PL_y
        lda     #$60
        sta     PL_y+1
        rts

PL_move:
        bbr7    <z_pad,.notleft
.left:
        lda     PL_x
        sec
        sbc     #$80
        sta     PL_x
        lda     PL_x+1
        sbc     #0
        sta     PL_x+1
.notleft:
        bbr5    <z_pad,.notright
.right:
        lda     PL_x
        clc
        adc     #$80
        sta     PL_x
        lda     PL_x+1
        adc     #0
        sta     PL_x+1
.notright:
        bbr4    <z_pad,.notup
.up:
        lda     PL_y
        sec
        sbc     #$80
        sta     PL_y
        lda     PL_y+1
        sbc     #0
        sta     PL_y+1
.notup:
        bbr6    <z_pad,.notdown
.down:
        lda     PL_y
        clc
        adc     #$80
        sta     PL_y
        lda     PL_y+1
        adc     #0
        sta     PL_y+1
.notdown:
        rts

PL_setSatb:
        lda     PL_y            ;5
        asl     a               ;2
        php                     ;3
        lda     PL_y+1          ;5
        sec                     ;2
        sbc     #16/2            ;2
        plp                     ;3
        rol     a               ;2
        sta     satb+8          ;5
        rol     a               ;2
        and     #1              ;2
        sta     satb+9          ;5   38

        lda     PL_x
        asl     a
        php
        lda     PL_x+1
        sec
        sbc     #16/2
        plp
        rol     a
        sta     satb+10
        rol     a
        and     #1
        sta     satb+11

     	lda	#$0f
	sta	satb+12
	lda	#$03		;vram address = $4040 -> $202
	sta	satb+13

	lda	#$80		;priority = sprite & color=1
	sta	satb+14
        lda     #$11
	sta	satb+15

        rts
