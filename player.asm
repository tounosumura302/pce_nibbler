
        .bss

        .zp
                    ;キャラクタ配列
zplx:   ds  2       ;x座標
zply:   ds  2       ;y座標
zpldir: ds  2       ;移動方向(LDRU----)
zpldirr:    ds  2   ;移動方向の逆方向(LDRU----)
zplspeed:   ds  2   ;移動速度

zpldirnum:  ds  2   ;移動方向(0=U 1=R 2=D 3=L)

zplbodytilel:   ds  2   ;胴体のキャラクタ番号を保存したアドレス（下位8ビット）
zplbodytileh:   ds  2   ;胴体のキャラクタ番号を保存したアドレス（上位8ビット）

zplprevdir: ds  2       ;過去の移動方向(----LDRU)
zplbodycornertilel: ds  2   ;胴体の曲がった箇所のキャラクタ番号を保存したアドレス（下位8ビット）
zplbodycornertileh: ds  2   ;胴体の曲がった箇所のキャラクタ番号を保存したアドレス（上位8ビット）

zplheadtilel: ds  2   ;頭のキャラクタ番号を保存したアドレス（下位8ビット）
zplheadtileh: ds  2   ;頭のキャラクタ番号を保存したアドレス（上位8ビット）

zplTailStop:    ds  1   ;尻尾を停止させる
zplTailPriority:    ds  1   ;尻尾の表示プライオリティ

zplcount:       ds  2

    .code
    .bank   MAIN_BANK

;
;   初期化
;
;   @args       なし
;   @saveregs   なし
;   @return     なし
plInit:
.tmp_fldadr_l   equ     zarg2       ;フィールドアドレス
.tmp_fldadr_h   equ     zarg3

    stz <zplTailStop
    stz <zplcount
    stz <zplcount+1

    lda #%10000000
    sta <zplTailPriority

                        ;頭の座標
    clx
    lda     #(5*3+1)*8
    sta     <zplx
    lda     #(8*3+1)*8
    sta     <zply
;    lda     #4
;    sta     <zplspeed
    lda     #%00100000
    jsr     plSetDir
                        ;尻尾の座標
    ldx #1
    lda     #(3*3+1)*8
    sta     <zplx,x
    lda     #(8*3+1)*8
    sta     <zply,x
;    lda     #4
;    sta     <zplspeed,x
    lda     #%00100000
    jsr     plSetDir
                        ;胴体
                        ;TODO: 胴体の絵を描いてない
    jsr plGetBatFldAdr
    cly
.loop:
    lda [.tmp_fldadr_l],y
    ora #%00000010
    sta [.tmp_fldadr_l],y
    iny
    cpy #6
    bne .loop
                        ;尻尾の速度を頭に合わせる
    lda <zplspeed
    sta <zplspeed+1

    rts

;
;   移動方向（とその逆方向）をセット
;
;   @args       a = 移動方向(LDRU----)
;               x = キャラクタインデックス
;   @saveregs   x
;   @return     なし
plSetDir:

    and     #$f0        ;下位4ビットは必ずクリアしておく（方向転換判定で誤判定の元となる）
    sta     <zpldir,x

    pha

    bit     #%10100000
    beq     .du
    eor     #%10100000
    bra     .set
.du:
    eor     #%01010000
.set:
    sta     <zpldirr,x

    pla

    lsr a
    lsr a
    lsr a
    lsr a
    pha
    tay
    lda .dir2num,y
    sta <zpldirnum,x
                        ;胴体のキャラクタを求めておく
;    lsr a
;    lsr a
;    lsr a
;    lsr a
;    tay
;    lda .dir2index,y

    asl a
    pha

    adc #LOW(.BodyPartsTiles)
    sta <zplbodytilel,x
    lda #HIGH(.BodyPartsTiles)
    adc #0
    sta <zplbodytileh,x

;    phy
;    lda .dir2index,y
;    tay
    ply
    lda .HeadPartsTiles,y
    sta <zplheadtilel,x
    lda .HeadPartsTiles+1,y
    sta <zplheadtileh,x
;    ply

;
;   胴体の曲がった箇所のキャラクタ番号
;   オリジナルは胴体幅が7ドットなので、曲がる向きに応じてキャラクタを使い分けないと綺麗につながらない
;
; 0123
; ┌┐└┘
;
; 3210
; LDRU
;
; L8 -> D 12 0  U 9 2
; D4 -> L 12 3  R 6 2
; R2 -> D  6 1  U 3 3
; U1 -> L  9 1  R 3 0
;
; x=pd|nd を求める
; xをyに変換
;   x 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
;   y  -  -  -  3  -  -  1  -  -  2  -  -  0  -  -  -
; pdがUかDなら、yをビット反転
;   y = 0123
;       ┌┐└┘
; y*2をtilesのアドレスに加算 -> 表示するタイルのアドレス
;

;    tya
    pla
    pha

    ora <zplprevdir,x
    tay
    lda .dir2corner,y
    tst #%0101,<zplprevdir,x
    beq .LR
    eor #%11
.LR:
    asl a
    adc #LOW(.BodyCornerPartsTiles)
    sta <zplbodycornertilel,x
    lda #HIGH(.BodyCornerPartsTiles)
    adc #0
    sta <zplbodycornertileh,x

    pla
    sta <zplprevdir,x

    rts

.dir2num:
    db  0
    db  0   ;U
    db  1   ;R
    db  0
    db  2   ;D
    db  0
    db  0
    db  0
    db  3   ;L

                                ;方向のビット(LDRU)を .BodyPartsTiles のインデックスに変換
                                ;ビットは1つしかセットされてないことが前提
;.dir2index:
;    db  0
;    db  0   ;U
;    db  2   ;R
;    db  0
;    db  4   ;D
;    db  0
;    db  0
;    db  0
;    db  6   ;L

;   x 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
;   y  -  -  -  3  -  -  1  -  -  2  -  -  0  -  -  -
.dir2corner:
    db  0,0,0,3
    db  0,0,1,0
    db  0,2,0,0
    db  0,0,0,0

                                ;胴体のキャラクタ番号
PatternAddress  equ $1000
;BodyPartsL  equ (PatternAddress+66*16)/16
;BodyPartsL  equ BG_BODY_L
;BodyPartsD  equ (PatternAddress+67*16)/16
;BodyPartsR  equ (PatternAddress+68*16)/16
;BodyPartsU  equ (PatternAddress+69*16)/16

;BodyPartsLU equ (PatternAddress+70*16)/16
;BodyPartsRU equ (PatternAddress+71*16)/16
;BodyPartsLD equ (PatternAddress+72*16)/16
;BodyPartsRD equ (PatternAddress+73*16)/16

.BodyPartsTiles:
    dw  BG_BODY_U | $2000
    dw  BG_BODY_R | $2000
    dw  BG_BODY_D | $2000
    dw  BG_BODY_L | $2000
;    dw  BodyPartsU | $2000
;    dw  BodyPartsR | $2000
;    dw  BodyPartsD | $2000
;    dw  BodyPartsL | $2000

.BodyCornerPartsTiles:
    dw  BG_BODY_CORNER_UL | $2000
    dw  BG_BODY_CORNER_UR | $2000
    dw  BG_BODY_CORNER_DL | $2000
    dw  BG_BODY_CORNER_DR | $2000
;    dw  (PatternAddress+70*16)/16 | $2000
;    dw  (PatternAddress+71*16)/16 | $2000
;    dw  (PatternAddress+72*16)/16 | $2000
;    dw  (PatternAddress+73*16)/16 | $2000

SpritePatternAddress  equ $4000
.HeadPartsTiles:
    dw  (SpritePatternAddress+00*64)/32
    dw  (SpritePatternAddress+01*64)/32
    dw  (SpritePatternAddress+02*64)/32
    dw  (SpritePatternAddress+03*64)/32
;
;   BATアドレス&フィールドアドレス
;
;   @args       x = キャラクタインデックス
;   @saveregs   x
;   @return     zarg0,1 = BATアドレス
;               zarg2,3 = フィールドアドレス
plGetBatFldAdr:
.arg_batadr_l     equ     zarg0
.arg_batadr_h     equ     zarg1
.arg_fldadr_l     equ     zarg2
.arg_fldadr_h     equ     zarg3

    lda     <zplx,x
    lsr     a
    lsr     a
    lsr     a
    sta     <.arg_batadr_l
    stz     <.arg_batadr_h
    lda     <zply,x
    and     #$f8
    asl     a
    rol     <.arg_batadr_h
    asl     a
    rol     <.arg_batadr_h
    tsb     <.arg_batadr_l

    lda <.arg_batadr_l
    clc
    adc #LOW(VMap)
    sta <.arg_fldadr_l
    lda <.arg_batadr_h
    adc #HIGH(VMap)
    sta <.arg_fldadr_h

    rts

;
;       ヘビの頭の動き
;
;       @args           x = キャラクタインデックス
;       @saveregs       x
;       @return         その場で停止すべき時は cf=1
plHeadAction:
.tmp_fldadr_l   equ     ztmp0       ;フィールドアドレス
.tmp_fldadr_h   equ     ztmp1
.tmp_fldv       equ     ztmp2       ;フィールド上の値
.tmp_pad        equ     ztmp3       ;コントローラーの値

.tmp_dead_flg   equ ztmp0

                        ;グリッドの中間にいる場合は何もしない
    tst #$7,<zplcount,x
    beq .act
    jmp .move           ;branchだと届かない
                        ;尻尾を停止しているなら解除
.act:
    lda <zplTailStop
    beq .act2
    dec a
    sta <zplTailStop
.act2:
    jsr plGetBatFldAdr
                        ;zarg2,3 の値をコピーしておく（他のサブルーチン呼び出しで競合することがあるため）
    lda <zarg2
    sta <.tmp_fldadr_l
    lda <zarg3
    sta <.tmp_fldadr_h
                        ;フィールド上の現在位置の値
    lda     [.tmp_fldadr_l]
    sta     <.tmp_fldv

    and #$0f
    beq .controller
                        ;現在位置に尻尾があったら死亡
    cmp #9
;    bmi .dead
    bpl .notdead        ;bmi だと届かない
    jmp .dead
.notdead:
    cmp #$0f
    bne .controller
                        ;現在位置にドットがあるなら尻尾を停止させる（胴体を伸ばす）
    inc <zplTailStop

    dec <zdotnum        ;ドット数減少
                        ;点数
    lda <zdotpoint
    sta <zpoint
    lda <zdotpoint+1
    sta <zpoint+1
    jsr addScore

    lda #1
    jsr pcmPlay

.controller:
                        ;
                        ;コントローラーが押されている場合の方向転換判定 ldru
    lda     <zpad
    and     #$f0
                        ;押されていない
    beq     .notpushed
                        ;移動方向および逆方向が押されていても押されていないとみなす
    sta     <.tmp_pad
    lda     <zpldir,x
    ora     <zpldirr,x
    trb     <.tmp_pad
    beq     .notpushed
                        ;移動方向以外かつ逆方向以外が押されていて、そっちに移動可能なら変更
    lda     <.tmp_pad
    bit     <.tmp_fldv
    bne     .changed
                        ;コントローラーが押されていない場合の方向転換判定
.notpushed:
                        ;直進可能ならそのまま進む
    lda     <.tmp_fldv
    bit     <zpldir,x
    bne     .notchanged
                        ;直進と後退以外の移動可能方向？
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    tay
    lda     .DirCountTbl,y
                        ;直角
    cmp     #2
    beq     .dc2
                        ;この時点で移動可能方向は3以外はありえない
                        ;直進できないので移動可能方向は1,2,3のいずれか
                        ;2の場合は分岐しており、1（つまり行き止まり）は存在しない
                        ;よって3のみ（つまり丁字路で直進方向が塞がっている状態）
;    cmp     #3
;    bne     .notchanged

    sec                 ;丁字路の場合は一時停止
    stz <.tmp_dead_flg  ;死んでいない
    rts
                        ;直角に曲がる
.dc2:
    lda     <.tmp_fldv
    eor     <zpldirr,x  ;2方向のうち進行方向の逆を打ち消して残った方向が進むべき方向

                        ;進行方向を変更
.changed:
    jsr     plSetDir
                        ;胴体のキャラクタ
    lda <zplbodycornertilel,x
    sta <zarg2
    lda <zplbodycornertileh,x
    sta <zarg3
    bra .draw
                        ;進行方向はそのまま
.notchanged:
                        ;胴体のキャラクタ
    lda <zplbodytilel,x
    sta <zarg2
    lda <zplbodytileh,x
    sta <zarg3
                        ;胴体の描画
.draw:
    lda #1
    sta <zarg4
    jsr vqPush
                        ;フィールドに胴体フラグをセット
    lda #$0f
    trb <.tmp_fldv
    lda <zpldir,x
    lsr a
    lsr a
    lsr a
    lsr a
    ora <.tmp_fldv
    sta [.tmp_fldadr_l]

;.move:
                            ;移動先に尻尾があったら死亡
                            ;nibblerの動画を見ると完全に重なった時でなく口先が触れただけで死んでいるため
                            ;移動先のvmapアドレスを求める
    lda <zpldirnum,x
    asl a
    tay
    lda <.tmp_fldadr_l
    clc
    adc .dirnum2vmapdiff,y
    sta <.tmp_fldadr_l
    lda <.tmp_fldadr_h
    adc .dirnum2vmapdiff+1,y
    sta <.tmp_fldadr_h
                            ;胴体有無判定
    lda [.tmp_fldadr_l]
    and #$0f
    beq .move
    cmp #9
    bmi .dead

.move:
;    clc                 ;指定方向に進行
    jsr plMove

    lda <zplheadtilel,x
    sta satb+4,y
    lda <zplheadtileh,x
    sta satb+5,y

    clc
    rts

                        ;移動先のvmapアドレス差分
.dirnum2vmapdiff:
;         U   R   D   L
    dw  -32,  1, 32, -1

                        ;死亡
.dead:
    lda #1
    sta <.tmp_dead_flg  ;死んだ

    sec
    rts
;
;       移動可能方向の数（インデックス値のセットされたビットの数）
;
.DirCountTbl:
    db      0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4

;BodyCornerPartsTiles:
;    dw  (PatternAddress+66*16)/16

BlankPartsTiles:
    dw  (PatternAddress+52*16)/16



;
;       ヘビの尻尾の動き
;
;       @args           x = キャラクタインデックス
;       @saveregs       x
;       @return         その場で停止すべき時は cf=1
;
plTailAction:
.tmp_fldadr_l   equ     zarg2       ;フィールドアドレス
.tmp_fldadr_h   equ     zarg3

.tmp_frame  equ ztmp0

                        ;尻尾を停止させる指示が出ている場合は何もしない
    lda <zplTailStop
;    bne .notmove
    beq .go
    rts
.go:
                        ;グリッド同士の間にいる場合
    tst #$7,<zplcount,x
;    lda <zplx,x
;    ora <zply,x
;    and #$07
    bne .move2
;    beq .move
;    clc
;    rts

                        ;グリッドに収まった場合は方向転換
.move:
    jsr plGetBatFldAdr
                        ;フィールド上の現在位置の値
                        ;頭が移動した方向を尻尾の移動方向とする
    lda [.tmp_fldadr_l]
    pha
;    pha
    asl a
    asl a
    asl a
    asl a
    jsr plSetDir

                        ;方向転換をしたら
    lda #%10000000
    sta <zplTailPriority
;    sta <zpldir,x
                        ;頭が移動した方向をクリア
    pla
    and #$f0
    sta [.tmp_fldadr_l]

                        ;描画
    lda #LOW(BlankPartsTiles)
    sta <zarg2
    lda #HIGH(BlankPartsTiles)
    sta <zarg3
    lda #1
    sta <zarg4
    jsr vqPush

    bra .move3

                        ;グリッド同士の間にいる場合
                        ;次の移動方向が変わる予定なら、尻尾の表示プライオリティを変えて、胴体に隠れるようにする
.move2:
    lda <zplTailPriority
    beq .move3

    jsr plGetBatFldAdr
    lda [.tmp_fldadr_l]
    asl a
    asl a
    asl a
    asl a
    beq .move3          ;今の場所の胴体がすでに消えているなら何もしない
    cmp <zpldir,x
    beq .move3
                        ;表示プライオリティをBGより下にして、胴体に隠れるようにする
    stz <zplTailPriority

.move3:
    jsr plMove

    ldy <zpldirnum,x
    lda <zplx,x
    clc
    adc .sprdx,y
    sta satb+8+2
    stz satb+8+2+1

    lda <zply,x
    clc
    adc .sprdy,y
    sta satb+8+0
    cla
    adc #0
    sta satb+8+1


                            ;尻尾のアニメーション用フレームカウンタ
    lda <zframe
    and #$03
    asl a
    asl a
    sta <.tmp_frame

                            ;TODO: 前にaslした後でまたlsrしてるのが無駄だなあ
    lda <zpldir,x
    lsr a
    lsr a
    lsr a
    lsr a
    tay
    lda .dir2index,y
    ora <.tmp_frame
    tay
    lda .TailPartsTiles,y
    sta satb+8+4
    lda .TailPartsTiles+1,y
    sta satb+8+5
    lda .TailPartsTiles+2,y
    ora <zplTailPriority        ;プライオリティ
    sta satb+8+6
    lda .TailPartsTiles+3,y
    sta satb+8+7


;    clc
    rts

;.notmove:
;    sec
;    rts

.sprdx:
    db  $20-4       ;U
    db  $20-8       ;R
    db  $20-4       ;D
    db  $20-0       ;L

;   +16 はスクロールカウンタの差分
.sprdy:
    db  $40+16+1    ;U
    db  $40+16+1-4  ;R
    db  $40+16+1-8  ;D
    db  $40+16+1-4  ;L

                                ;方向のビット(LDRU)を .BodyPartsTiles のインデックスに変換
                                ;ビットは1つしかセットされてないことが前提
.dir2index:
    db  0
    db  0   ;U
    db  1*16   ;R
    db  0
    db  2*16   ;D
    db  0
    db  0
    db  0
    db  3*16   ;L

SpritePatternAddress  equ $4000
.TailPartsTiles:
    dw  (SpritePatternAddress+04*64)/32,%0000000000000000
    dw  (SpritePatternAddress+05*64)/32,%0000000000000000
    dw  (SpritePatternAddress+04*64)/32,%0000000000000000
    dw  (SpritePatternAddress+05*64)/32,%0000100000000000

    dw  (SpritePatternAddress+06*64)/32,%0000000000000000
    dw  (SpritePatternAddress+07*64)/32,%0000000000000000
    dw  (SpritePatternAddress+06*64)/32,%0000000000000000
    dw  (SpritePatternAddress+07*64)/32,%1000000000000000

    dw  (SpritePatternAddress+04*64)/32,%1000000000000000
    dw  (SpritePatternAddress+05*64)/32,%1000000000000000
    dw  (SpritePatternAddress+04*64)/32,%1000000000000000
    dw  (SpritePatternAddress+05*64)/32,%1000100000000000

    dw  (SpritePatternAddress+06*64)/32,%0000100000000000
    dw  (SpritePatternAddress+07*64)/32,%0000100000000000
    dw  (SpritePatternAddress+06*64)/32,%0000100000000000
    dw  (SpritePatternAddress+07*64)/32,%1000100000000000


;    dw  (SpritePatternAddress+04*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+05*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+04*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+05*64)/32,%0000100010000000

;    dw  (SpritePatternAddress+06*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+07*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+06*64)/32,%0000000010000000
;    dw  (SpritePatternAddress+07*64)/32,%1000000010000000

;    dw  (SpritePatternAddress+04*64)/32,%1000000010000000
;    dw  (SpritePatternAddress+05*64)/32,%1000000010000000
;    dw  (SpritePatternAddress+04*64)/32,%1000000010000000
;    dw  (SpritePatternAddress+05*64)/32,%1000100010000000

;    dw  (SpritePatternAddress+06*64)/32,%0000100010000000
;    dw  (SpritePatternAddress+07*64)/32,%0000100010000000
;    dw  (SpritePatternAddress+06*64)/32,%0000100010000000
;    dw  (SpritePatternAddress+07*64)/32,%1000100010000000


;       移動
;       @args           x = キャラクタインデックス
;       @saveregs       x,y
;       @return         なし
plMove:
.tmp_x  equ ztmp0
.tmp_y  equ ztmp1

    lda <zplx,x
    sta <.tmp_x
    lda <zply,x
    sta <.tmp_y

    lda <zplcount,x
    clc
    adc <zplspeed
    cmp #8
    bcc .under8
    lda #8
.under8:
    sta <zplcount,x

    lda     <zpldir,x         ;bits of zpldir = LDRU----
    asl     a
    bcs     .moveleft
    asl     a
    bcs     .movedown
    asl     a
    bcs     .moveright
    bpl     .notmove
.moveup:
    lda <.tmp_y
    sec
    sbc <zplcount,x
    sta <.tmp_y
;    lda     <zply,x
;    sec
;    sbc     <zplspeed,x
;    sta     <zply,x
    bra     .moved
.moveleft:
    lda <.tmp_x
    sec
    sbc <zplcount,x
    sta <.tmp_x
;    lda     <zplx,x
;    sec
;    sbc     <zplspeed,x
;    sta     <zplx,x
    bra     .moved
.movedown:
    lda <.tmp_y
    clc
    adc <zplcount,x
    sta <.tmp_y
;    lda     <zply,x
;    clc
;    adc     <zplspeed,x
;    sta     <zply,x
    bra     .moved
.moveright:
    lda <.tmp_x
    clc
    adc <zplcount,x
    sta <.tmp_x
;    lda     <zplx,x
;    clc
;    adc     <zplspeed,x
;    sta     <zplx,x
.notmove:
.moved:
                        ;スプライト座標設定
    txa
    asl a
    asl a
    asl a
    tay

;    lda     <zplx,x
    lda <.tmp_x
    clc
    adc     #$20-4
    sta     satb+2,y
    cla
    sta     satb+3,y

;    lda     <zply,x
    lda <.tmp_y
    clc
    adc     #$40-4+16+1   ;+16 はスクロールカウンタの差分
    sta     satb+0,y
    lda     #0
    adc     #0
    sta     satb+1,y


    lda <zplcount,x
    cmp #8
    beq .movetonextgrid
    rts

.movetonextgrid:
    lda <.tmp_x
    sta <zplx,x
    lda <.tmp_y
    sta <zply,x
    stz <zplcount,x
    rts


;
;
;
;       胴体のパターン書き換え
;       @args           なし
;       @saveregs       なし
;       @return         なし
plWriteBodyPattern:
                            ;パターンデータの書き換えサイズ（ワード）
                            ;書き換えるのは２プレーン分のみなので8ワード
    lda #8
    sta <zarg4
                            ;パターンデータ（４種類）の選択
                            ;パターンデータは1セット16バイトで、上下左右各方向4セット
                            ;並び順は LLLLDDDDRRRRUUUU 
    lda <zplcount
    and #%0110
    asl a
    asl a
    asl a
                            ;Lのパターンアドレス
    adc #LOW(BodyPatterns)
    sta <zarg2
    lda #HIGH(BodyPatterns)
    adc #0
    sta <zarg3
                            ;LのVRAMアドレス
    lda #LOW(PatternAddress+66*16)
    sta <zarg0
    lda #HIGH(PatternAddress+66*16)
    sta <zarg1
    jsr vqPush
                            ;Dのパターンアドレス
    lda <zarg2
    clc
    adc #64
    sta <zarg2
    lda <zarg3
    adc #0
    sta <zarg3
                            ;DのVRAMアドレス
    lda #LOW(PatternAddress+67*16)
    sta <zarg0
    lda #HIGH(PatternAddress+67*16)
    sta <zarg1
    jsr vqPush
                            ;Rのパターンアドレス
    lda <zarg2
    clc
    adc #64
    sta <zarg2
    lda <zarg3
    adc #0
    sta <zarg3
                            ;RのVRAMアドレス
    lda #LOW(PatternAddress+68*16)
    sta <zarg0
    lda #HIGH(PatternAddress+68*16)
    sta <zarg1
    jsr vqPush
                            ;Uのパターンアドレス
    lda <zarg2
    clc
    adc #64
    sta <zarg2
    lda <zarg3
    adc #0
    sta <zarg3
                            ;UのVRAMアドレス
    lda #LOW(PatternAddress+69*16)
    sta <zarg0
    lda #HIGH(PatternAddress+69*16)
    sta <zarg1
    jsr vqPush

    rts



;
;   task test
;
plTask:
.tmp_dead_flg   equ ztmp0

                    ;頭
	clx
	jsr	plHeadAction
	bcs	.skipmove
;	jsr	plMove

                    ;胴体のパターン書き換え
;    lda <zplcount
;    clc
;    adc <zplspeed
;    sta <zplcount
    jsr plWriteBodyPattern

                    ;尻尾
    ldx #1
    jsr plTailAction
;    bcs .yield
;    jsr plMove
    bra .yield

.skipmove:
    tst #$ff,<.tmp_dead_flg
    bne .dead

.yield:
    lda <zdotnum
    beq .clear

    jsr tkYield
    bra plTask

.dead:
    stz <zplTailStop

 	tkChangeTask_	tklDead
    tkYield_

.clear:
 	tkChangeTask_	tklClearWave
    tkYield_


;
;   自分の胴体を噛んだ時の処理
;
plDeadTask:
    ldx #1
    jsr plTailAction
    lda <zpldir,x
    beq .over
    tkYield_
    bra plDeadTask

.over:
; 	tkChangeTask_	tklInitWave
 	tkChangeTask_	tklAppear
    tkYield_
