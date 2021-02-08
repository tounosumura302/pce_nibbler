; Zero-page variables

	.zp

ptr:	.ds   2 	; pointer to buffer address
a_cnt:	.ds   1
x_cnt:	.ds   1


	;; scroll counter
scrx:	.ds	2
scry:	.ds	2
	;...

z_sprx: .ds     2
z_spry: .ds     2



;--- CODE area ----------

	.code
	.bank MAIN_BANK
	.org  $C000

;       wait VSync (polling)
waitVsync:
.wait:  tst     #$20,VdcStatus
        beq     .wait
        rts



;
;       main
;
main:	
        lda     #BANK(offchar)
        tam     #PAGE(offchar)
        ;map    offchar		; map in the memory bank

	; load blank character into VRAM:

        ;	vload  offchar,#16
	st0	#0
        lda     #$f0
        sta     VdcDataL
        lda     #$0f
        sta     VdcDataH
	st0	#2
	tia	offchar,VdcData,8*2



	;vsync			; vsync to avoid snow
        jsr     waitVsync

;	set_bgpal #0,cgpal,#1	; fill palette #0
        lda     #LOW(0*16)
        sta     VceIndexL
        lda     #HIGH(0*16)
        sta     VceIndexH
        tia     cgpal,VceData,16*2

;	set_bgpal #1,cgpal2,#1	; fill palette #0
        lda     #LOW(1*16)
        sta     VceIndexL
        lda     #HIGH(1*16)
        sta     VceIndexH
        tia     cgpal2,VceData,16*2

	;; 	vload  $3000,zero,#16*16
	;vload  $1000,zero,#16*17
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$10
        sta     VdcDataH
	st0	#2
	tia	zero,VdcData,16*17*2

; blank the background

	;; 	setvwaddr  $0		; set the VRAM address to $0000

	;; set VRAM address to $0000
	st0	#0
	st1	#0
	st2	#0

	;; fill digit on screen
	st0	#2

	cla
	ldy	#64
.loop1:	phy

	say
	and	#1
	rol	a
	rol	a
	rol	a
	rol	a
	ora	#1
	say
	
	ldx	#64
.loop2:	sta	VdcDataL
	sty	VdcDataH
	;; 	st2	#$11
	inc	a
	and	#$0f
.next:	dex
	bne	.loop2
	ply
	dey
	bne	.loop1

	;;
	st0	#0
	st1	#0
	st2	#0
	st0	#2
	lda	#$10
	sta	VdcDataL
	lda	#$11
	sta	VdcDataH

	;; initialize sprite

	jsr	spr_init
	jsr	spr_update

        lda     #$40
        sta     z_sprx
        stz     z_sprx+1
        lda     #$60
        sta     z_spry
        stz     z_spry+1
	;;
	;; .loop:	bra	.loop
				;
	stz	<scrx
	stz	<scry

	jsr	initPsgTest

	jsr PB_init		; player's bullet

mainloop:
;       scroll
	ldx	#scry&$ff
	clc
	set
	adc	#1
	inx
	set
	adc	#0
 	
;       move sprite
        bbr7    <z_pad,.notleft
.left:
        lda     <z_sprx
        sec
        sbc     #1
        sta     <z_sprx
        lda     <z_sprx+1
        sbc     #0
        sta     <z_sprx+1
.notleft:
        bbr5    <z_pad,.notright
.right:
        lda     <z_sprx
        clc
        adc     #1
        sta     <z_sprx
        lda     <z_sprx+1
        adc     #0
        sta     <z_sprx+1
.notright:
        bbr4    <z_pad,.notup
.up:
        lda     <z_spry
        sec
        sbc     #1
        sta     <z_spry
        lda     <z_spry+1
        sbc     #0
        sta     <z_spry+1
.notup:
        bbr6    <z_pad,.notdown
.down:
        lda     <z_spry
        clc
        adc     #1
        sta     <z_spry
        lda     <z_spry+1
        adc     #0
        sta     <z_spry+1
.notdown:
        lda     <z_spry
        sta     satb+8
        lda     <z_spry+1
        sta     satb+9
        lda     <z_sprx
        sta     satb+10
        lda     <z_sprx+1
        sta     satb+11

        jsr     spr_update

			; shoot
		bbr0	<z_paddelta,.pbmove
		ldy		#0
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
		iny
		jsr		PB_shoot
.pbmove:
		jsr		PB_move
		jsr		PB_setSatb

;
;       vsync
;
        jsr     waitVsync

;       scroll
	st0	#8
	lda	<scry
	sta	VdcDataL
	lda	<scry+1
	sta	VdcDataH

;       pad
        jsr     readPad
	jmp	mainloop

	

;.loop:	bra	.loop

;	psg test	
initPsgTest:
	lda	#0
	sta	PsgChannel

;	write wave data
	lda	#$40
	sta	PsgCtrl
	stz	PsgCtrl

	clx
.loop:	lda	.wave,x
	cmp	#$ff
	beq	.loopend
	sta	PsgWave
	inx
	bra	.loop

.loopend:
;	set frequency
	lda	#$fe
	sta	PsgFreqL
	stz	PsgFreqH

;	set volume
	lda	#$ff
	sta	PsgChVol
	sta	PsgMainVol

	lda	#$8f
	sta	PsgCtrl

	rts

.wave:
	.db	$1f,$1d,$1b,$19,$17,$15,$13,$11
	.db	$0f,$0d,$0b,$09,$07,$05,$03,$01
	.db	$1f,$1d,$1b,$19,$17,$15,$13,$11
	.db	$0f,$0d,$0b,$09,$07,$05,$03,$01
	.db	$ff	

	.db	$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
	.db	$00,$00,$00,$00,$00,$00,$00,$00
	.db	$00,$00,$00,$00,$00,$00,$00,$00
	.db	$00,$00,$00,$00,$00,$00,$00,$00
	.db	$ff

	.db	$0f,$12,$15,$17,$19,$1b,$1d,$1E
	.db	$1e,$1e,$1d,$1b,$19,$17,$15,$12
	.db	$0f,$0c,$09,$07,$05,$03,$01,$00
	.db	$00,$00,$01,$03,$05,$07,$09,$0c
	.db	$ff	

	;; test sprite
spr_init:
;	vsync
        jsr     waitVsync
	;; set palette
	;; 	map   spr_palette
;	set_sprpal #0,spr_palette
        lda     #LOW(0*16+16*16)
        sta     VceIndexL
        lda     #HIGH(0*16+16*16)
        sta     VceIndexH
        tia     spr_palette,VceData,16*2

;	set_sprpal #1,cgpal2
        lda     #LOW(1*16+16*16)
        sta     VceIndexL
        lda     #HIGH(1*16+16*16)
        sta     VceIndexH
        tia     cgpal2,VceData,16*2

	;; set sprite pattern
;	vload	$4000,spr_pattern_0,#16*4
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$40
        sta     VdcDataH
	st0	#2
	tia	spr_pattern_0,VdcData,16*4*2

;	vload	$4080,spr_pattern_1,#16*4
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$50
        sta     VdcDataH
	st0	#2
	tia	spr_pattern_1,VdcData,16*4*2*4

;
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$60
        sta     VdcDataH
	st0	#2
	tia	spr_pat_0,VdcData,16*4*2*8

	;; clear satb
	stz	satb
	tii	satb,satb+1,512-1

	;; set satb 0
	lda	#$40
	sta	satb+0
	stz	satb+1

	lda	#$20
	sta	satb+2
	stz	satb+3

	stz	satb+4
	lda	#$2		;vram address = $4000 -> $200
	sta	satb+5

	lda	#$02		;priority = bg & color=0
	sta	satb+6
	stz	satb+7

	;; set satb 1
	lda	#$80
	sta	satb+8
	stz	satb+9

	lda	#$60
	sta	satb+10
	stz	satb+11

	lda	#$0f
	sta	satb+12
	lda	#$03		;vram address = $4040 -> $202
	sta	satb+13

	lda	#$80		;priority = sprite & color=1
	sta	satb+14
        lda     #$30
	sta	satb+15

	rts

spr_update:
	st0	#0
	st1	#$00
	st2	#$7f
	st0	#2
	tia	satb,VdcDataL,512
	rts
	;...

;ｱｱｱ[ USER DATA ]ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ


	.bank  MAIN_BANK+1
	.org   $6000

;
; Blank char
;
offchar:  .defchr $0FF0,0,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000,\
	  $00000000

;
; numbers from 0-9,A-F:
;
zero:
        dw $003c,$307e,$60ff,$40ff,$02fd,$06f9,$0c72,$003c
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

;zero:	  .defchr $1000,0,\
;	  $00111110,\
;	  $01000011,\
;	  $01000101,\
;	  $01001001,\
;	  $01010001,\
;	  $01100001,\
;	  $00111110,\
;	  $11111111

one:	  .defchr $1010,0,\
	  $00001000,\
	  $00011000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00001000,\
	  $00011100,\
	  $00000000

two:	  .defchr $1020,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111111,\
	  $00000000

three:	  .defchr $1030,0,\
	  $00111110,\
	  $01000001,\
	  $00000001,\
	  $00011110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

four:	  .defchr $1040,0,\
	  $00000010,\
	  $00100010,\
	  $00100010,\
	  $00111111,\
	  $00000010,\
	  $00000010,\
	  $00000010,\
	  $00000000

five:	  .defchr $1050,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $00111110,\
	  $00000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

six:	  .defchr $1060,0,\
	  $00111110,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

seven:	  .defchr $1070,0,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00000010,\
	  $00000100,\
	  $00001000,\
	  $00001000,\
	  $00000000

eight:	  .defchr $1080,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111110,\
	  $00000000

nine:	  .defchr $1090,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $00111111,\
	  $00000001,\
	  $00000001,\
	  $00111110,\
	  $00000000

ten:	  .defchr $10A0,0,\
	  $00111110,\
	  $01000001,\
	  $01000001,\
	  $01111111,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $00000000

eleven:   .defchr $10B0,0,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $00000000

twelve:   .defchr $10C0,0,\
	  $00111110,\
	  $01000001,\
	  $01000000,\
	  $01000000,\
	  $01000000,\
	  $01000001,\
	  $00111110,\
	  $00000000

thirteen: .defchr $10D0,0,\
	  $01111110,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01000001,\
	  $01111110,\
	  $00000000

fourteen: .defchr $10E0,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000000,\
	  $01000000,\
	  $01111111,\
	  $00000000

fifteen:  .defchr $10F0,0,\
	  $01111111,\
	  $01000000,\
	  $01000000,\
	  $01111110,\
	  $01000000,\
	  $01000000,\
	  $01000000,\
	  $00000000

	;; cg character pattern definition 
testchr:
	;;      b0  b1
	db	$0f,$00		;line0
	db	$0f,$ff		;line1
	db	$0f,$00		;line2
	db	$0f,$ff		;line3
	db	$0f,$00		;line4
	db	$0f,$ff		;line5
	db	$0f,$00		;line6
	db	$0f,$ff		;line7
	;;      b2  b3
	db	$00,$00		;line0
	db	$00,$00		;line1
	db	$ff,$00		;line2
	db	$ff,$00		;line3
	db	$00,$ff		;line4
	db	$00,$ff		;line5
	db	$ff,$ff		;line6
	db	$ff,$ff		;line7
;
; Simple palette entry
;
; entry #0 = black, #1-#15 are all white
;
cgpal:
        dw $0000,$0007,$01c7,$01ff,$0000,$0000,$0000,$0020,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$01c0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

;cgpal:	.defpal $000,$777,$777,$777,\
;		$777,$777,$777,$777,\
;		$777,$777,$777,$777,\
;		$777,$777,$777,$777

cgpal2:	.defpal $000,$700,$200,$300,\
		$400,$500,$600,$700,\
		$010,$020,$030,$040,\
		$050,$060,$070,$777

;
; Just a bunch of hex digits to print out
;
buffer:
	db   $00,$01,$02,$03,$04,$05,$06,$07
	db   $08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	db   $10,$11,$12,$13,$14,$15,$16,$17
	db   $18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	db   $20,$21,$22,$23,$24,$25,$26,$27
	db   $28,$29,$2A,$2B,$2C,$2D,$2E,$2F
	db   $30,$31,$32,$33,$34,$35,$36,$37
	db   $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
	db   $40,$41,$42,$43,$44,$45,$46,$47
	db   $48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	db   $50,$51,$52,$53,$54,$55,$56,$57
	db   $58,$59,$5A,$5B,$5C,$5D,$5E,$5F
	db   $60,$61,$62,$63,$64,$65,$66,$67
	db   $68,$69,$6A,$6B,$6C,$6D,$6E,$6F
	db   $70,$71,$72,$73,$74,$75,$76,$77
	db   $78,$79,$7A,$7B,$7C,$7D,$7E,$7F
	db   $80,$81,$82,$83,$84,$85,$86,$87
	db   $88,$89,$8A,$8B,$8C,$8D,$8E,$8F
	db   $90,$91,$92,$93,$94,$95,$96,$97
	db   $98,$99,$9A,$9B,$9C,$9D,$9E,$9F
	db   $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
	db   $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
	db   $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7
	db   $B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
	db   $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
	db   $C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
	db   $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
	db   $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
	db   $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
	db   $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
	db   $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
	db   $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF



	;; test sprite
spr_palette:
	.defpal $000,$777,$777,$777,$777,$777,$777,$777,\
		$777,$221,$332,$443,$554,$665,$776,$777


spr_pat_0:
	db	%00111110,%00111110
	db	%01000011,%01000011
	db	%01000101,%01000101
	db	%01001001,%01001001
	db	%01010001,%01010001
	db	%01100001,%01100001
	db	%00111110,%00111110
	db	%00000000,%00000000
	db	%00111110,%00111110
	db	%01000011,%01000011
	db	%01000101,%01000101
	db	%01001001,%01001001
	db	%01010001,%01010001
	db	%01100001,%01100001
	db	%00111110,%00111110
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_1:
	db	%00001000,%00001000
	db	%00011000,%00011000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00011100,%00011100
	db	%00000000,%00000000
	db	%00001000,%00001000
	db	%00011000,%00011000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00011100,%00011100
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_2:
	db	%00111110,%00111110
	db	%01000001,%01000001
	db	%00000001,%00000001
	db	%00111110,%00111110
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%01111111,%01111111
	db	%00000000,%00000000
	db	%00111110,%00111110
	db	%01000001,%01000001
	db	%00000001,%00000001
	db	%00111110,%00111110
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%01111111,%01111111
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_3:
	db	%00111110,%00111110
	db	%01000001,%01000001
	db	%00000001,%00000001
	db	%00011110,%00011110
	db	%00000001,%00000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	db	%00111110,%00111110
	db	%01000001,%01000001
	db	%00000001,%00000001
	db	%00011110,%00011110
	db	%00000001,%00000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_4:
	db	%00000010,%00000010
	db	%00100010,%00100010
	db	%00100010,%00100010
	db	%00111111,%00111111
	db	%00000010,%00000010
	db	%00000010,%00000010
	db	%00000010,%00000010
	db	%00000000,%00000000
	db	%00000010,%00000010
	db	%00100010,%00100010
	db	%00100010,%00100010
	db	%00111111,%00111111
	db	%00000010,%00000010
	db	%00000010,%00000010
	db	%00000010,%00000010
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_5:
	db	%01111111,%01111111
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%00111110,%00111110
	db	%00000001,%00000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	db	%01111111,%01111111
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%00111110,%00111110
	db	%00000001,%00000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_6:
	db	%00111110,%00111110
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%01111110,%01111110
	db	%01000001,%01000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	db	%00111110,%00111110
	db	%01000000,%01000000
	db	%01000000,%01000000
	db	%01111110,%01111110
	db	%01000001,%01000001
	db	%01000001,%01000001
	db	%00111110,%00111110
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pat_7:
	db	%00111111,%00111111
	db	%00000001,%00000001
	db	%00000001,%00000001
	db	%00000010,%00000010
	db	%00000100,%00000100
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00000000,%00000000
	db	%00111111,%00111111
	db	%00000001,%00000001
	db	%00000001,%00000001
	db	%00000010,%00000010
	db	%00000100,%00000100
	db	%00001000,%00001000
	db	%00001000,%00001000
	db	%00000000,%00000000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


spr_pattern_0:
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

spr_pattern_1:
	dw	$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
	dw	$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff

	dw	$0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
	dw	$0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff

	dw	$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff
	dw	$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff

	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff


	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff


	dw	$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff
	dw	$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff

	dw	$0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff
	dw	$0000,$0000,$ffff,$ffff,$0000,$0000,$ffff,$ffff

	dw	$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff
	dw	$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff

	dw	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dw	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff


	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

	;; satb
	.bss
satb	.ds 512	; the local SATB
