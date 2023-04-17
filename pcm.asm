    .zp
zPcmDataIx: ds  1

    .code
    .bank BANK0_BANK

;
;   PCM初期化
;
pcmInit:
    stz <zPcmDataIx

    stz TimerCtrl
    rts

;
;   PCM要求
;
pcmPlay:
                    ;PSGチャネル初期化
    lda #5
    sta PsgChannel
    lda #%11011111
    sta PsgCtrl
    lda #$ff
    sta PsgChVol
                    ;タイマー割り込み設定
    cli
    stz TimerCounter    ;6.992kHz
    lda #1
    sta TimerCtrl
    lda IntCtrlMask ;タイマー割り込み有効
    and #3
    sta IntCtrlMask

    rts

;
;   タイマー割り込み
;
pcmTimerHandler:
    pha
    phx
    phy

;    sei
    stz IntCtrlState    ;acknowledge timer interrupt

    lda #5
    sta PsgChannel

    ldx <zPcmDataIx
    lda PcmData,x
    bmi .end
    sta PsgWave
    inx
    stx <zPcmDataIx

;    stz TimerCounter
;    lda #1
;    sta TimerCtrl
;    cli
.ret:
    ply
    plx
    pla
    rti

.end:
    stz <zPcmDataIx
                    ;PSGチャネル出力停止
    stz PsgCtrl
    stz PsgChVol
                    ;タイマー割り込み設定
    sei
    lda IntCtrlMask ;タイマー割り込み無効
    ora #%100
    sta IntCtrlMask
    bra .ret

PcmData:
    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1e,$1d,$1c,$1b,$1a,$19,$18
;    db  $17,$16,$15,$14,$13,$12,$11,$10
;    db  $0f,$0e,$0d,$0c,$0b,$0a,$09,$08
;    db  $07,$06,$05,$04,$03,$02,$01,$00
;    db  $00,$01,$02,$03,$04,$05,$06,$07
;    db  $08,$09,$0a,$0b,$0c,$0d,$0e,$0f
;    db  $10,$11,$12,$13,$14,$15,$16,$17
;    db  $18,$19,$1a,$1b,$1c,$1d,$1e,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $ff
