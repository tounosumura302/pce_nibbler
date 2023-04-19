    .zp
zPcmDataPtr:    ds  2   ;PCMデータアドレス
zPcmDataIx:     ds  1   ;PCMデータインデックス（起点はzPcmDataPtr）
zPcmDataBank:   ds  1   ;PCMデータバンク

    .code
    .bank BANK0_BANK
;
;   PCM初期化
;
pcmInit:
    stz <zPcmDataIx
    stz <zPcmDataPtr
    stz <zPcmDataPtr+1
    stz <zPcmDataBank

    stz TimerCtrl
    rts

;
;   PCM演奏開始
;
;   @args       a = PCMデータ番号
;   @saveregs   x
;   @return     なし
;   @notice     PSGチャネル番号を変更
;
pcmPlay:
                    ;PCMデータアドレス設定
    tay
    lda pcmBanks,y
    sta <zPcmDataBank
    lda pcmDataLs,y
    sta <zPcmDataPtr
    lda pcmDataHs,y
    sta <zPcmDataPtr+1
    stz <zPcmDataIx
                    ;PSGチャネル初期化
    lda #5
    sta PsgChannel
    lda #%11011111  ;DDA
    sta PsgCtrl
    lda #$ff
    sta PsgChVol
    sta PsgMainVol
                    ;タイマー割り込み設定
    cli
    stz TimerCounter    ;6.992kHz
    lda #1
    sta TimerCtrl
                    ;タイマー割り込み有効
    lda IntCtrlMask
    and #3
    sta IntCtrlMask

    rts

;
;   タイマー割り込み処理
;
pcmTimerHandler:
    pha
    phx
    phy

    stz IntCtrlState    ;acknowledge timer interrupt

                        ;バンク切り替え
    tma #PAGE(pcm_data_0)
    pha
    lda <zPcmDataBank
    tam #PAGE(pcm_data_0)
                        ;PCMデータをPSGにセット
    lda #5
    sta PsgChannel

    ldy <zPcmDataIx
    lda [zPcmDataPtr],y
    bmi .end
    sta PsgWave
                        ;PCMデータアドレスを進める
    iny
    sty <zPcmDataIx
    bne .ret
    inc <zPcmDataPtr+1

.ret:
                        ;バンクを戻す
    pla
    tam #PAGE(pcm_data_0)

    ply
    plx
    pla
    rti
                    ;PCMデータ終了
.end:
    stz <zPcmDataIx
    stz <zPcmDataPtr
    stz <zPcmDataPtr+1
    stz <zPcmDataBank
                    ;PSGチャネル出力停止
    stz PsgCtrl
    stz PsgChVol
                    ;タイマー割り込み設定
    sei
    lda IntCtrlMask ;タイマー割り込み無効
    ora #%100
    sta IntCtrlMask
    bra .ret

;
;   PCMデータテーブル
;
pcmBanks:
    db  BANK(pcm_data_0)
    db  BANK(pcm_data_1)

pcmDataLs:
    db  LOW(pcm_data_0)
    db  LOW(pcm_data_1)

pcmDataHs:
    db  HIGH(pcm_data_0)
    db  HIGH(pcm_data_1)

;PcmData:
;    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1e,$1d,$1c,$1b,$1a,$19,$18
;    db  $17,$16,$15,$14,$13,$12,$11,$10
;    db  $0f,$0e,$0d,$0c,$0b,$0a,$09,$08
;    db  $07,$06,$05,$04,$03,$02,$01,$00
;    db  $00,$01,$02,$03,$04,$05,$06,$07
;    db  $08,$09,$0a,$0b,$0c,$0d,$0e,$0f
;    db  $10,$11,$12,$13,$14,$15,$16,$17
;    db  $18,$19,$1a,$1b,$1c,$1d,$1e,$1f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $ff
