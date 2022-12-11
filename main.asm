; Zero-page variables

	.zp

ztmp0:	ds	1
ztmp1:	ds	1
ztmp2:	ds	1
ztmp3:	ds	1
ztmp4:	ds	1
ztmp5:	ds	1
ztmp6:	ds	1

zarg0:	ds	1
zarg1:	ds	1
zarg2:	ds	1
zarg3:	ds	1
zarg4:	ds	1
zarg5:	ds	1

;ptr:	.ds   2 	; pointer to buffer address
;a_cnt:	.ds   1
;x_cnt:	.ds   1


	;; scroll counter
scrx:	.ds	2
scry:	.ds	2

z_frame:	.ds	1

;--- CODE area ----------

	.code
	.bank MAIN_BANK
	.org  $C000

;       wait VSync (polling)
waitVsync:
.wait:
	tst     #$20,VdcStatus
    beq     .wait
    rts



;
;       main
;
main:	
        lda     #BANK(BgPattern)
        tam     #PAGE(BgPattern)

	; set bg pattern
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$10
        sta     VdcDataH
	st0	#2
	tia	BgPattern,VdcData,BgPattern_size

	; set bg palette
        lda     #LOW(0*16)
        sta     VceIndexL
        lda     #HIGH(0*16)
        sta     VceIndexH
        tia     BgPalette,VceData,16*16*2

	
	; set sprite pattern
	st0	#0
        lda     #$00
        sta     VdcDataL
        lda     #$40
        sta     VdcDataH
	st0	#2
	tia	SpPattern,VdcData,SpPattern_size

	; set sprite palette
        lda     #LOW(16*16)
        sta     VceIndexL
        lda     #HIGH(16*16)
        sta     VceIndexH
        tia     SpPalette,VceData,16*16*2

	;vsync			; vsync to avoid snow
        jsr     waitVsync

	; draw background (test)

	lda	#LOW(WaveMap_01)
	sta	<zarg0
	lda	#HIGH(WaveMap_01)
	sta	<zarg1
	jsr	DrawWave


	st0	#0
	lda #LOW(0+30*32)
    sta VdcDataL
    lda #HIGH(0+30*32)
    sta VdcDataH
	st0	#2
	lda	#LOW(($1000+52*16)/16)
	sta	VdcDataL
	lda	#HIGH(($1000+52*16)/16)
	sta	VdcDataH
	lda	#LOW(($1000+53*16)/16)
	sta	VdcDataL
	lda	#HIGH(($1000+53*16)/16)
	sta	VdcDataH
	lda	#LOW(($1000+54*16)/16)
	sta	VdcDataL
	lda	#HIGH(($1000+54*16)/16)
	sta	VdcDataH
	lda	#LOW(($1000+55*16)/16)
	sta	VdcDataL
	lda	#HIGH(($1000+55*16)/16)
	sta	VdcDataH

	;; initialize sprite

	jsr	spr_init
	jsr	spr_update



	jsr	initPsgTest

	jsr	tkInit

	jsr	plInit

	jsr	vqInit

mainloop:
	jsr	tkDispatch
	jmp	mainloop




;
;       vsync
;
VSyncTask:
    jsr	spr_update
    jsr	waitVsync

	jsr	vqDraw

;       scroll
	st0	#7
	stz	VdcDataL
	stz	VdcDataH

	st0	#8
	lda	#$ef
	sta	VdcDataL
	lda	#$ff
	sta	VdcDataH

    jsr	readPad

	inc	<z_frame
	
	jsr	tkYield
	bra	VSyncTask




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
	;lda	#$ff
	cla
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


spr_init:

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

	lda	#$80		;priority  & color=0
	sta	satb+6
	stz	satb+7


	;; set satb 1
	lda	#$40
	sta	satb+8
	stz	satb+9

	lda	#$20
	sta	satb+10
	stz	satb+11

	stz	satb+12
	lda	#$2		;vram address = $4000 -> $200
	sta	satb+13

	lda	#$80		;priority  & color=0
	sta	satb+14
	stz	satb+15

	rts


spr_update:
	st0	#0
	st1	#$00
	st2	#$7f
	st0	#2
	tia	satb,VdcDataL,512
	rts



	;...
	;; satb
	.bss
satb	.ds 512	; the local SATB
