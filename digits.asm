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
.arg_bufadr_l   equ zarg2
.arg_bufadr_h   equ zarg3
.arg_len        equ zarg4
.arg_bcdadr_l   equ zarg5
.arg_bcdadr_h   equ zarg6
.arg_comma_count    equ zarg7

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

    dey

    lda #1
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
    lda #36
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
    lda #36
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
    lda #48
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


    .if 0
drawDigits:
.arg_batadr_l   equ zarg0
.arg_batadr_h   equ zarg1
.arg_bufadr_l   equ zarg2
.arg_bufadr_h   equ zarg3
.arg_len        equ zarg4
.arg_bcdadr_l   equ zarg5
.arg_bcdadr_h   equ zarg6
.arg_comma_count    equ zarg7

.tmp_comma_count    equ ztmp0
                        ;BCDを1バイト1桁の文字列に変換
    ldy <.arg_len
    dey                 ;Y = 数値データのインデックス
    clx                 ;X = 描画データバッファのインデックス

                        ;上位の桁が0の場合は0ではなく空白を描画
.blankloop:
                        ;BCDの上位桁
    lda [.arg_bcdadr_l],y
    sxy
    pha

    lsr a
    lsr a
    lsr a
    lsr a
    bne .drawh
    lda #48             ;TODO: 空白が48
    sta [.arg_bufadr_l],y
    iny
    lda #1
    sta [.arg_bufadr_l],y
    iny
                        ;BCDの下位桁
    pla
    and #$0f
    bne .drawl
    lda #48             ;TODO: 空白が48
    sta [.arg_bufadr_l],y
    iny
    lda #1
    sta [.arg_bufadr_l],y
    iny

    sxy
    cpy #0
    beq .push
    dey
    bra .blankloop

                        ;数値の描画
.drawloop:
                        ;BCDの上位桁
    lda [.arg_bcdadr_l],y
    sxy
    pha

    lsr a
    lsr a
    lsr a
    lsr a
.drawh:
    sta [.arg_bufadr_l],y
    iny
    lda #1
    sta [.arg_bufadr_l],y
    iny
                        ;BCDの下位桁
    pla
    and #$0f
.drawl:
    sta [.arg_bufadr_l],y
    iny
    lda #1
    sta [.arg_bufadr_l],y
    iny

    sxy
    cpy #0
    beq .push
    dey
    bra .drawloop

.push:
    asl <zarg4
    jsr vqPush

    rts

    .endif

    .if 0

drawDigits:
.arg_batadr_l   equ zarg0
.arg_batadr_h   equ zarg1
.arg_adr_l  equ zarg2
.arg_adr_h  equ zarg3
.arg_len    equ zarg4
.arg_buffer_ix  equ zarg5
.arg_comma_num  equ zarg6

.tmp_comma_count    equ ztmp0
                        ;BCDを1バイト1桁の文字列に変換
    ldy <.arg_len
    dey                 ;Y = 数値データのインデックス
;    clx                 ;X = 描画データバッファのインデックス
    ldx <.arg_buffer_ix

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
    clc
    adc <.arg_comma_num
    adc <.arg_comma_num
    tay
                        ;vqPush のパラメータ（長さ）をあらかじめセット
    txa
    clc
    adc <.arg_comma_num
    sta <zarg4
                        ;カンマのカウンタ
                        ;arg_comma_num（カンマの数）が0の場合はカンマカウンタを0にすることで事実上表示されないようになる
    lda <.arg_comma_num
    beq .set
    lda #4
.set:
    sta <.tmp_comma_count

.convloop:
    dey
    dey
    dex
                        ;カンマをセット
    dec <.tmp_comma_count
    bne .nocomma
    lda #3
    sta <.tmp_comma_count
                        ;TODO: カンマのVRAMアドレスが $1240〜 であること
    lda #36
    sta dgBuffer,y
    lda #1
    sta dgBuffer+1,y
    dey
    dey
.nocomma:
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
                        ;zarg4（長さ）は上でセット済み
    jsr vqPush

    rts

    .endif

    .bss
                        ;BCD変換バッファ
dgBuffer    ds  64

    .code
