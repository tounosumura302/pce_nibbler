    .code
    .bank   MAIN_BANK

;
;   BCD数値描画
;   上位桁の0は空白で表示
;
;   @args       zarg0,1 = BAT address
;               zarg2,3 = 表示データアドレス
;               zarg4   = 数値データの長さ（バイト）
;               zarg5,6 = 数値データアドレス
;               zarg7   = カンマの間隔（なしなら 0）
;               zarg8   = パレット
;   @saveregs   なし
;   @return     なし
drawDigits:
.arg_batadr_l   equ zarg0
.arg_batadr_h   equ zarg1
.arg_bufadr_l   equ zarg2
.arg_bufadr_h   equ zarg3
.arg_len        equ zarg4
.arg_bcdadr_l   equ zarg5
.arg_bcdadr_h   equ zarg6
.arg_comma_count    equ zarg7
.arg_palette    equ zarg8


.tmp_comma_count    equ ztmp0

    stz .tmp_comma_count
    tst #$ff,<.arg_comma_count
    beq .nocomma
    lda #4
    sta <.tmp_comma_count
.nocomma:

    lda <.arg_len
    asl a
    adc <.arg_comma_count
    asl a
    tay

                        ;表示データの各桁の上位1バイト1をセットしておく
    dey
;    lda #1
    lda <.arg_palette
    ora #1              ;BGパターンは $1xx （xx はBCD）とする
.clearloop:
    sta [.arg_bufadr_l],y
    cpy #1
    beq .draw
    dey
    dey
    bra .clearloop

.draw:
                        ;BCDを1バイト1桁の文字列に変換
    cly                 ;Y = 数値データのインデックス
    lda <.arg_len
    asl a
    adc <.arg_comma_count
    asl a
    dec a
    dec a
    tax                 ;X = 描画データバッファのインデックス

                        ;数値の描画
.drawloop:
                        ;BCDの下位桁
    lda [.arg_bcdadr_l],y
    sxy
    pha

    dec <.tmp_comma_count
    bne .drawl
    pha
;    lda #36
    lda #LOW(BG_COMMA)
    sta [.arg_bufadr_l],y
    dey
    dey
    lda #3
    sta <.tmp_comma_count
    pla
    
.drawl:

    and #$0f
    sta [.arg_bufadr_l],y
    dey
    dey

    dec <.tmp_comma_count
    bne .drawh
;    pha
;    lda #36             ; TODO: カンマのコード
    lda #LOW(BG_COMMA)
    sta [.arg_bufadr_l],y
    dey
    dey
    lda #3
    sta <.tmp_comma_count
;    pla
                        ;BCDの上位桁
.drawh:
    pla
    lsr a
    lsr a
    lsr a
    lsr a
    sta [.arg_bufadr_l],y
    dey
    dey

    sxy
    iny
    cpy <.arg_len
    bne .drawloop

                        ;先頭の0を表示しない
    lda <.arg_len
    asl a
    adc <.arg_comma_count
    dec a               ;最後の桁の0は表示したい
    tax
    cly

.zeroloop:
    lda [.arg_bufadr_l],y
    beq .next
    cmp #36
    bne .push
.next:
;    lda #52             ; TOOD: スペースのコード
    lda #LOW(BG_SPACE)
    sta [.arg_bufadr_l],y
    iny
    iny
    dex
    bne .zeroloop


.push:
    lda <zarg4
    asl a
    adc <.arg_comma_count
    sta <zarg4
    jsr vqPush

    rts


;    .bss
;                        ;BCD変換バッファ
;dgBuffer    ds  64

    .code
