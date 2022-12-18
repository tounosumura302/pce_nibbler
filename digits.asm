    .code
    .bank   MAIN_BANK

;
;   BCD数値描画
;   上位桁の0は空白で表示
;
;   @args       zarg0,1 = BAT address
;               zarg2,3 = 数値データアドレス
;               zarg4   = 数値データの長さ（バイト）
;   @saveregs   なし
;   @return     なし
drawDigits:
.arg_batadr_l   equ zarg0
.arg_batadr_h   equ zarg1
.arg_adr_l  equ zarg2
.arg_adr_h  equ zarg3
.arg_len    equ zarg4
                        ;BCDを1バイト1桁の文字列に変換
    ldy <.arg_len
    dey                 ;Y = 数値データのインデックス
    clx                 ;X = 描画データバッファのインデックス

                        ;上位の桁が0の場合は0ではなく空白を描画
.blankloop:
                        ;BCDの上位桁
    lda [.arg_adr_l],y
    lsr a
    lsr a
    lsr a
    lsr a
    bne .drawh
    lda #48             ;TODO: 空白が48
    sta dgBuffer,x
    inx
                        ;BCDの下位桁
    lda [.arg_adr_l],y
    and #$0f
    bne .drawl
    lda #48             ;TODO: 空白が48
    sta dgBuffer,x
    inx

    cpy #0
    beq .convert
    dey
    bra .blankloop

                        ;数値の描画
.drawloop:
                        ;BCDの上位桁
    lda [.arg_adr_l],y
    lsr a
    lsr a
    lsr a
    lsr a
.drawh:
    sta dgBuffer,x
    inx
                        ;BCDの下位桁
    lda [.arg_adr_l],y
    and #$0f
.drawl:
    sta dgBuffer,x
    inx
    cpy #0
    beq .convert
    dey
    bra .drawloop

                        ;文字列をBATデータに変換
.convert:
    lda <.arg_len
    asl a
    tax
    asl a
    tay
.convloop:
    dey
    dey
    dex
                        ;TODO: 数字のVRAMアドレスが $1000〜 であること
    lda dgBuffer,x
    sta dgBuffer,y
    lda #1
    sta dgBuffer+1,y

    cpx #0
    bne .convloop

    lda #LOW(dgBuffer)
    sta <zarg2
    lda #HIGH(dgBuffer)
    sta <zarg3
    asl <.arg_len
    jsr vqPush

    rts

    .bss
                        ;BCD変換バッファ
dgBuffer    ds  32

    .code
