;   VRAM部分書き換え
;
;   書き換え内容をキューに保管し、vblank中に書き換える。

VQ_MAX_QUQUE_SIZE   equ 16  ;キューのサイズ

    .zp
zvqIndex:   ds  1

    .bss
vqArea:
vqDstL: ds  VQ_MAX_QUQUE_SIZE   ;VRAMアドレス
vqDstH: ds  VQ_MAX_QUQUE_SIZE
vqSrcL: ds  VQ_MAX_QUQUE_SIZE   ;ソースデータアドレス
vqSrcH: ds  VQ_MAX_QUQUE_SIZE
vqWLen: ds  VQ_MAX_QUQUE_SIZE   ;データ長（ワード単位）

vqArea_end:
vqArea_size equ vqArea_end-vqArea

    .code
    .bank   MAIN_BANK

;   キューを初期化
;   @args       なし
;   @saveregs   なし
;   @return     なし
vqInit:
                        ;キューをクリア
    stz vqArea
    tii vqArea,vqArea+1,vqArea_size-1
    stz <zvqIndex
    rts

;   キューにデータを追加
;   @args       zarg0,1 = vramアドレス
;               zarg2,3 = データ
;               zarg4   = 長さ
;   @saveregs   x
;   @return     なし
vqPush:
.tmp_vramadr_l  equ zarg0
.tmp_vramadr_h  equ zarg1
.tmp_src_l      equ zarg2
.tmp_src_h      equ zarg3
.tmp_len        equ zarg4
    ldy <zvqIndex

    lda .tmp_vramadr_l
    sta vqDstL,y
    lda .tmp_vramadr_h
    sta vqDstH,y

    lda .tmp_src_l
    sta vqSrcL,y
    lda .tmp_src_h
    sta vqSrcH,y

    lda .tmp_len
    sta vqWLen,y

    iny
    sty <zvqIndex

    rts

;   キューの内容を描画
;   VRAMを更新するのでvblank中に呼び出すこと
;   @args       なし
;   @saveregs   なし
;   @return     なし
vqDraw:
.tmp_src_l  equ ztmp0
.tmp_src_h  equ ztmp1

    ldx <zvqIndex
    bne .loop_queue
    rts

.loop_queue:
    dex

    st0 #0
    lda vqDstL,x
    sta VdcDataL
    lda vqDstH,x
    sta VdcDataH

    lda vqSrcL,x
    sta <.tmp_src_l
    lda vqSrcH,x
    sta <.tmp_src_h

    st0 #2
    cly

.loop_copy:
    lda [.tmp_src_l],y
    sta VdcDataL
    iny
    lda [.tmp_src_l],y
    sta VdcDataH
    iny

    dec vqWLen,x
    bne .loop_copy

    cpx #0
    bne .loop_queue

    stz <zvqIndex
    rts
