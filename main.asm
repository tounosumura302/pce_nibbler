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
zarg6:	ds	1
zarg7:	ds	1
zarg8:	ds	1


	;; scroll counter
scrx:	.ds	2
scry:	.ds	2

zframe:	.ds	1


zdotnum:	ds	1
zwave:	ds	1
ztime:	ds	2

zscore:	ds	5
zhiscore:	ds	5

zleft:	ds	1

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

	lda	#BANK(SpPattern)
	tam	#PAGE(SpPattern)

	lda	#BANK(WaveMap)
	tam	#PAGE(WaveMap)

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


	jsr	spr_init
	jsr	spr_update

	jsr	vqInit

	jsr	initPsgTest

	jsr	tkInit

	stz	<zwave

;	lda	#$99
;	sta	<ztime
;	lda	#$9
;	sta	<ztime+1

	lda	#$0
	sta	<zscore
	stz	<zscore+1
	stz	<zscore+2
	stz	<zscore+3
	stz	<zscore+4

	lda	#$0
	sta	<zhiscore
	stz	<zhiscore+1
	stz	<zhiscore+2
	stz	<zhiscore+3
	lda	#$90
	sta	<zhiscore+4

	lda	#2
	sta	<zleft

	tkChangeTask_	tklInitWave


	;; initialize sprite
;	jsr	plInit

mainloop:
	jsr	tkDispatch
	jsr	tkChangeTasks
	jmp	mainloop


DrawWaveTask:
	jsr	DrawWave
	jsr	plInit

	lda	#$99
	sta	<ztime
	lda	#$9
	sta	<ztime+1
	jsr	DrawStatusString

	tkYield_

;	tkChangeTask_	tklGameMain
	tkChangeTask_	tklAppear
	tkYield_
;	bra	DrawWaveTask

DrawStatusString:
						;PLAYER1
	lda #LOW(0+30*32)
    sta <zarg0
    lda #HIGH(0+30*32)
    sta <zarg1
	lda	#LOW(.player1)
	sta	<zarg2
	lda	#HIGH(.player1)
	sta	<zarg3
	lda	#4
	sta	<zarg4
	jsr	vqPush
						;HISCORE
	lda #LOW(0+31*32)
    sta <zarg0
    lda #HIGH(0+31*32)
    sta <zarg1
	lda	#LOW(.hiscore)
	sta	<zarg2
	lda	#HIGH(.hiscore)
	sta	<zarg3
	lda	#4
	sta	<zarg4
	jsr	vqPush
						;LEFT
	lda #LOW(22+30*32)
    sta <zarg0
    lda #HIGH(22+30*32)
    sta <zarg1
	lda	#LOW(.left)
	sta	<zarg2
	lda	#HIGH(.left)
	sta	<zarg3
	lda	#2
	sta	<zarg4
	jsr	vqPush
						;TIME
	lda #LOW(19+31*32)
    sta <zarg0
    lda #HIGH(19+31*32)
    sta <zarg1
	lda	#LOW(.time)
	sta	<zarg2
	lda	#HIGH(.time)
	sta	<zarg3
	lda	#4
	sta	<zarg4
	jsr	vqPush
						;WAVE
	lda #LOW(10+27*32)
    sta <zarg0
    lda #HIGH(10+27*32)
    sta <zarg1
	lda	#LOW(.wave)
	sta	<zarg2
	lda	#HIGH(.wave)
	sta	<zarg3
	lda	#4
	sta	<zarg4
	jsr	vqPush


	lda #LOW(25+30*32)
    sta <zarg0
    lda #HIGH(25+30*32)
    sta <zarg1
	lda	#LOW(leftBuffer)
	sta	<zarg2
	lda	#HIGH(leftBuffer)
	sta	<zarg3
	lda	#1
	sta	<zarg4
	lda	#LOW(zleft)
	sta	<zarg5
	lda	#HIGH(zleft)
	sta	<zarg6
	stz	<zarg7
	lda	#HIGH(BGPAL_WHITE)
	sta	<zarg8
	jsr	drawDigits

	lda #LOW(5+31*32)
    sta <zarg0
    lda #HIGH(5+31*32)
    sta <zarg1
	lda	#LOW(hiscoreBuffer)
	sta	<zarg2
	lda	#HIGH(hiscoreBuffer)
	sta	<zarg3
	lda	#5
	sta	<zarg4
	lda	#LOW(zhiscore)
	sta	<zarg5
	lda	#HIGH(zhiscore)
	sta	<zarg6
	lda	#3
	sta	<zarg7
	lda	#HIGH(BGPAL_CYAN)
	sta	<zarg8
	jsr	drawDigits

	rts
.player1:	dw	($100+38)|BGPAL_YELLOW,($100+39)|BGPAL_YELLOW,($100+40)|BGPAL_YELLOW,($100+41)|BGPAL_YELLOW
.hiscore:	dw	($100+42)|BGPAL_RED   ,($100+43)|BGPAL_RED   ,($100+44)|BGPAL_RED   ,($100+45)|BGPAL_RED
.left:		dw	($100+46)|BGPAL_YELLOW,($100+47)|BGPAL_YELLOW
.time:		dw	($100+29)|BGPAL_YELLOW,($100+18)|BGPAL_YELLOW,($100+22)|BGPAL_YELLOW,($100+14)|BGPAL_YELLOW
.wave:		dw	($100+32)|BGPAL_WHITE ,($100+10)|BGPAL_WHITE ,($100+31)|BGPAL_WHITE ,($100+14)|BGPAL_WHITE 

WaveClearTask:
						;TIME->BONUS 書き換え
	lda #LOW(19+31*32)
    sta <zarg0
    lda #HIGH(19+31*32)
    sta <zarg1
	lda	#LOW(.bonus)
	sta	<zarg2
	lda	#HIGH(.bonus)
	sta	<zarg3
	lda	#4
	sta	<zarg4
	jsr	vqPush

						;点数
	lda	#$10
	sta	<zpoint
	stz	<zpoint+1
						;残りタイムをスコアに加算する
.bonusloop:
	sed

	lda	<ztime
	bne	.count
	lda	<ztime+1
	beq	.endtime
	
	sec
	sbc	#1
	sta	<ztime+1
	cla
.count:
	sec
	sbc	#1
	sta	<ztime

	cld

	jsr	addScore

	jsr	drawTime
	jsr	drawScore

	tkYield_
	bra	.bonusloop

						;終了
.endtime:
	cld

	lda	<zwave
	inc	a
	cmp	#100
	bmi	.set
	cla
.set:
	sta	<zwave

	tkChangeTask_	tklInitWave
	tkYield_

.bonus:		dw	BG_SPACE|BGPAL_YELLOW,BG_BONUS|BGPAL_YELLOW,(BG_BONUS+1)|BGPAL_YELLOW,(BG_BONUS+2)|BGPAL_YELLOW


drawTime:
	lda #LOW(23+31*32)
    sta <zarg0
    lda #HIGH(23+31*32)
    sta <zarg1
	lda	#LOW(timerBuffer)
	sta	<zarg2
	lda	#HIGH(timerBuffer)
	sta	<zarg3
	lda	#2
	sta	<zarg4
	lda	#LOW(ztime)
	sta	<zarg5
	lda	#HIGH(ztime)
	sta	<zarg6
	stz	<zarg7
	lda	#HIGH(BGPAL_WHITE)
	sta	<zarg8
	jsr	drawDigits

	rts

drawScore:
	lda #LOW(5+30*32)
    sta <zarg0
    lda #HIGH(5+30*32)
    sta <zarg1
	lda	#LOW(scoreBuffer)
	sta	<zarg2
	lda	#HIGH(scoreBuffer)
	sta	<zarg3
	lda	#5
	sta	<zarg4
	lda	#LOW(zscore)
	sta	<zarg5
	lda	#HIGH(zscore)
	sta	<zarg6
	lda	#3
	sta	<zarg7
	lda	#HIGH(BGPAL_WHITE)
	sta	<zarg8
	jsr	drawDigits

	rts

StatusTask:
					;TODO: タイマーの減少間隔調整
	lda	<zframe
	and	#32-1
	bne	.score

	sed
	lda	<ztime
	sec
	sbc	#1
	sta	<ztime
	lda	<ztime+1
	sbc	#0
	sta	<ztime+1
	cld

	jsr	drawTime
;	lda #LOW(23+31*32)
;    sta <zarg0
;    lda #HIGH(23+31*32)
;    sta <zarg1
;	lda	#LOW(timerBuffer)
;	sta	<zarg2
;	lda	#HIGH(timerBuffer)
;	sta	<zarg3
;	lda	#2
;	sta	<zarg4
;	lda	#LOW(ztime)
;	sta	<zarg5
;	lda	#HIGH(ztime)
;	sta	<zarg6
;	stz	<zarg7
;	lda	#HIGH(BGPAL_WHITE)
;	sta	<zarg8
;	jsr	drawDigits

;.yield:
;	jsr	tkYield
;	bra	TimerTask
;
;ScoreTask:
.score:
	tst	#$0f,<zframe
	bne	.yield

	jsr	drawScore
;	lda #LOW(5+30*32)
;    sta <zarg0
;    lda #HIGH(5+30*32)
;    sta <zarg1
;	lda	#LOW(scoreBuffer)
;	sta	<zarg2
;	lda	#HIGH(scoreBuffer)
;	sta	<zarg3
;	lda	#5
;	sta	<zarg4
;	lda	#LOW(zscore)
;	sta	<zarg5
;	lda	#HIGH(zscore)
;	sta	<zarg6
;	lda	#3
;	sta	<zarg7
;	lda	#HIGH(BGPAL_WHITE)
;	sta	<zarg8
;	jsr	drawDigits
.yield:
	jsr	tkYield
	bra	StatusTask


;
;	スコア加算
;
;       @args           zpoint = 加算する点数（2バイト、1000点の桁まで）
;       @saveregs       x,y
;       @return         なし

addScore:
.arg_scoreptr	equ	zarg0

	sed

	lda	<zscore
	clc
	adc	<zpoint
	sta	<zscore
	lda	<zscore+1
	adc	<zpoint+1
	sta	<zscore+1
	lda	<zscore+2
	adc	#0
	sta	<zscore+2
	lda	<zscore+3
	adc	#0
	sta	<zscore+3
	lda	<zscore+4
	adc	#0
	sta	<zscore+4

	cld
	rts

	.zp
zpoint	ds	5

	.bss
timerBuffer	ds	2*2*2
leftBuffer	ds	1*2*2
scoreBuffer	ds	(10+3)*2*2
hiscoreBuffer	ds	(10+3)*2*2

	.code

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

	inc	<zframe
	
	jsr	tkYield
	bra	VSyncTask

;
;	nibbler出現時のアニメーション
;
NibblerAppearTask:
	lda	#LOW(.script)
	sta	<zarg0
	lda	#HIGH(.script)
	sta	<zarg1
	lda	#2
	sta	<zarg2
	jsr	scrInit
.loop:
	jsr	scrExecute
	bcs	.end
	tkYield_
	bra	.loop

.end:
	tkChangeTask_	tklGameMain
	tkYield_

	; nibbler出現時のアニメーションスクリプト
.script:
	scrSetInterval_	2
	; クロスハッチ用スプライト配置
	scrSetSprite_	0,(11*3+1)*8+4,(4*3+1)*8+16*0,(SpritePatternAddress+08*64)/32,$82
	scrSetSprite_	1,(11*3+1)*8+4,(4*3+1)*8+16*1,(SpritePatternAddress+08*64)/32,$82
	scrSetSprite_	2,(11*3+1)*8+4,(4*3+1)*8+16*2,(SpritePatternAddress+08*64)/32,$82
	scrSetSprite_	3,(11*3+1)*8+4,(4*3+1)*8+16*3,(SpritePatternAddress+08*64)/32,$82
	scrSetSprite_	4,(11*3+1)*8+4,(4*3+1)*8+16*4,(SpritePatternAddress+08*64)/32,$82
	scrWait_
	; クロスハッチを左から右に表示
	scrSetSpritePattern_	0,(SpritePatternAddress+09*64)/32
	scrWait_
	scrSetSpritePattern_	0,(SpritePatternAddress+10*64)/32
	scrWait_

	scrSetSpritePattern_	1,(SpritePatternAddress+09*64)/32
	scrWait_
	scrSetSpritePattern_	1,(SpritePatternAddress+10*64)/32
	scrWait_

	scrSetSpritePattern_	2,(SpritePatternAddress+09*64)/32
	scrWait_
	scrSetSpritePattern_	2,(SpritePatternAddress+10*64)/32
	scrWait_

	scrSetSpritePattern_	3,(SpritePatternAddress+09*64)/32
	scrWait_
	scrSetSpritePattern_	3,(SpritePatternAddress+10*64)/32
	scrWait_

	scrSetSpritePattern_	4,(SpritePatternAddress+09*64)/32
	scrWait_
	scrSetSpritePattern_	4,(SpritePatternAddress+10*64)/32
	scrWait_
	; ヘビの体を表示
	scrSetBG_	11+25*32,.BodyParts_blue,6
	scrSetSprite_	5,(11*3+1)*8+4,(4*3+1)*8,(SpritePatternAddress+06*64)/32,$01
	scrSetSprite_	6,(11*3+1)*8+4,(4*3+1)*8+16+16+16+8,(SpritePatternAddress+01*64)/32,$81
	scrWait_
	; クロスハッチを左から右に消去
	scrSetSpritePattern_	0,(SpritePatternAddress+11*64)/32
	scrWait_
	scrSetSpritePattern_	0,(SpritePatternAddress+08*64)/32
	scrWait_

	scrSetSpritePattern_	1,(SpritePatternAddress+11*64)/32
	scrWait_
	scrSetSpritePattern_	1,(SpritePatternAddress+08*64)/32
	scrWait_

	scrSetSpritePattern_	2,(SpritePatternAddress+11*64)/32
	scrWait_
	scrSetSpritePattern_	2,(SpritePatternAddress+08*64)/32
	scrWait_

	scrSetSpritePattern_	3,(SpritePatternAddress+11*64)/32
	scrWait_
	scrSetSpritePattern_	3,(SpritePatternAddress+08*64)/32
	scrWait_

	scrSetSpritePattern_	4,(SpritePatternAddress+11*64)/32
	scrWait_
	scrSetSpritePattern_	4,(SpritePatternAddress+08*64)/32
	scrWait_
	; ヘビの体の色を左から右に変化
	scrSetSpriteAttribute_	5,$00
	scrWait_
	scrSetBG_	11+25*32,.BodyParts_red,1
	scrWait_
	scrSetBG_	12+25*32,.BodyParts_red,1
	scrWait_
	scrSetBG_	13+25*32,.BodyParts_red,1
	scrWait_
	scrSetBG_	14+25*32,.BodyParts_red,1
	scrWait_
	scrSetBG_	15+25*32,.BodyParts_red,1
	scrWait_
	scrSetBG_	16+25*32,.BodyParts_red,1
	scrWait_
	scrSetSpriteAttribute_	6,$00
	scrWait_
	scrWait_
	; スプライトの後始末
	scrSetSpriteAttribute_	0,$80	;頭　スプライト優先
	scrSetSpriteAttribute_	1,$00	;尻尾
	scrSetSpritePosition_	2,0,0
	scrSetSpritePosition_	3,0,0
	scrSetSpritePosition_	4,0,0
	scrSetSpritePosition_	5,0,0
	scrSetSpritePosition_	6,0,0

	scrEnd_

	; 胴体表示データ（青）
.BodyParts_blue:
	dw	BG_BODY_R | $3000
	dw	BG_BODY_R | $3000
	dw	BG_BODY_R | $3000
	dw	BG_BODY_R | $3000
	dw	BG_BODY_R | $3000
	dw	BG_BODY_R | $3000

	; 胴体表示データ（赤）
.BodyParts_red:
	dw	BG_BODY_R | $2000


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

	lda	#4
	sta	satb+12
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
