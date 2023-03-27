    .code
    .bank   MAIN_BANK

;
;   BATクリア
;
;   @args       なし
;   @saveregs   なし
;   @return     なし

clearBAT:
    st0     #0
    st1     #0
    st2     #0
    st0     #2

    ldx     #16
.cl2:
    cly
.cl1:
    st1     #LOW(BG_SPACE)
    st2     #HIGH(BG_SPACE)
    dey
    bne     .cl1
    dex
    bne     .cl2

    rts

;
;   Wave描画
;
;   @args       zwave = wave番号
;   @saveregs   なし
;   @return     なし
DrawWaveMap:
.arg_wavemap_l  equ zarg0   ;waveマップデータアドレス
.arg_wavemap_h  equ zarg1
.tmp_mul_h  equ ztmp0

    jsr clearBAT
                            ;zwave*81 の計算
    stz <.tmp_mul_h
    lda <zwave
    asl a
    rol <.tmp_mul_h
    asl a
    rol <.tmp_mul_h
    asl a
    rol <.tmp_mul_h
    asl a
    rol <.tmp_mul_h
                            ;zwave*16 を一旦保存
    sta <.arg_wavemap_l
    ldx <.tmp_mul_h
    stx <.arg_wavemap_h

    asl a
    rol <.tmp_mul_h
    asl a
    rol <.tmp_mul_h
                            ;arg = zwave*16+zwave*64 = zwave*80
    clc
    adc <.arg_wavemap_l
    sta <.arg_wavemap_l
    lda <.arg_wavemap_h
    adc <.tmp_mul_h
    sta <.arg_wavemap_h
                            ;arg = zwave*80 + zwave = zwave*81
    lda <.arg_wavemap_l
    clc
    adc <zwave
    sta <.arg_wavemap_l
    lda <.arg_wavemap_h
    adc #0
    sta <.arg_wavemap_h
                            ;arg = zwave*81 + WaveMap
    lda <.arg_wavemap_l
    clc
    adc #LOW(WaveMap)
    sta <.arg_wavemap_l
    lda <.arg_wavemap_h
    adc #HIGH(WaveMap)
    sta <.arg_wavemap_h

    jsr DrawWaveByWaveMapAdr
    rts

;
;   Wave描画
;
;   @args       zarg0,1 = Waveマップアドレス
;   @saveregs   なし
;   @return     なし
DrawWaveByWaveMapAdr:
.arg_wavemap_l  equ zarg0   ;マップデータアドレス
.arg_wavemap_h  equ zarg1

.tmp_vram_l     equ zarg2   ;vram(BAT)アドレス
.tmp_vram_h     equ zarg3
.tmp_vmap_ptr_l equ zarg4   ;仮想vramアドレス
.tmp_vmap_ptr_h equ zarg5

    stz <zdotnum

    stz <.tmp_vram_l
    stz <.tmp_vram_h

    lda #LOW(VMap)
    sta <.tmp_vmap_ptr_l
    lda #HIGH(VMap)
    sta <.tmp_vmap_ptr_h

    cly                 ;y=マップデータのインデックス
.loop_nextrow:
    ldx #9              ;x=行カウンタ
.loop_nextgrid:
                        ;grid描画
    phx
    phy
    lda [.arg_wavemap_l],y
    jsr DrawMapGrid
    ply
    plx
                        ;全grid済なら終了
    iny
    cpy #9*9
    beq .loop_end
                        ;1行終了？
    dex
    beq .nextrow
                        ;同一行の右隣に移動
    lda <.tmp_vram_l
    clc
    adc #3
    sta <.tmp_vram_l
    lda <.tmp_vram_h
    adc #0
    sta <.tmp_vram_h

    lda <.tmp_vmap_ptr_l
    clc
    adc #3
    sta <.tmp_vmap_ptr_l
    lda <.tmp_vmap_ptr_h
    adc #0
    sta <.tmp_vmap_ptr_h

    bra .loop_nextgrid

                        ;次の行の左端に移動
.nextrow:
    lda <.tmp_vram_l
    clc
    adc #3*32-3*8
    sta <.tmp_vram_l
    lda <.tmp_vram_h
    adc #0
    sta <.tmp_vram_h

    lda <.tmp_vmap_ptr_l
    clc
    adc #3*32-3*8
    sta <.tmp_vmap_ptr_l
    lda <.tmp_vmap_ptr_h
    adc #0
    sta <.tmp_vmap_ptr_h

    bra .loop_nextrow

.loop_end:
    rts



;
;   Waveマップの１グリッド分（3*3キャラクタ）の描画
;
;   @args       A = グリッド番号
;               zarg2,3 = BAT address
;               zarg4,5 = Virtual Map address
;   @saveregs   なし
;   @return     なし
DrawMapGrid:
.arg_vram_l     equ zarg2   ;vram(BAT)アドレス
.arg_vram_h     equ zarg3
.arg_vmap_ptr_l equ zarg4   ;仮想vramアドレス
.arg_vmap_ptr_h equ zarg5

.tmp_x9         equ ztmp0   ;9倍計算用ワーク
.tmp_vram_l     equ ztmp0   ;vram(BAT)アドレス
.tmp_vram_h     equ ztmp1
.tmp_looprow    equ ztmp2   ;行カウンタ
.tmp_loopchar   equ ztmp3   ;
.tmp_dotcombi   equ ztmp4
.tmp_vmap_value equ ztmp5

    tay
                        ;x=gridデータのインデックス
                        ;grid番号x9
    and #$0f
    sta <.tmp_x9
    asl a
    asl a
    asl a
    adc <.tmp_x9
    tax
                        ;ドット配置
    tya
    lsr a
    lsr a
    lsr a
    lsr a
    tay
    lda DotCombination,y
    sta <.tmp_dotcombi

                        ;vram(BAT)アドレス初期値
    lda <.arg_vram_l
    sta <.tmp_vram_l
    lda <.arg_vram_h
    sta <.tmp_vram_h

    cly                 ;y=仮想vramのインデックス
                        ;gridの行数
    lda #3
    sta <.tmp_looprow

.loop_row:
                        ;vram(BAT)アドレスセット
    st0 #0
    lda <.tmp_vram_l
    sta VdcDataL
    lda <.tmp_vram_h
    sta VdcDataH
    st0 #2
                        ;gridの水平方向のキャラ数
    lda #3
    sta <.tmp_loopchar
.loop_char:
    lda VMapGrids,x
    sta <.tmp_vmap_value

    lda MapGrids,x
    bne .setchar
                            ;空白かつドットが配置されているならドットのタイルをセット
    bbr7    <.tmp_dotcombi,.setchar

    inc <zdotnum            ;ドット数を増加
;    lda #1
;    sta <zdotnum

    lda #$0f
    tsb <.tmp_vmap_value
    lda #$0d*2                  ;TODO: ドットのタイル番号

.setchar
                        ;タイルをvram(BAT)に書き込み
    phy
    tay
    lda MapPartsTiles,y
    sta VdcDataL
    lda MapPartsTiles+1,y
    sta VdcDataH
    ply
                        ;仮想vramに書き込み
    lda <.tmp_vmap_value
    sta [.arg_vmap_ptr_l],y

    asl <.tmp_dotcombi
    inx
    iny

    dec <.tmp_loopchar
    bne .loop_char

    dec <.tmp_looprow
    beq .end_loop
                        ;次の行にvramアドレスを移動
    lda <.tmp_vram_l
    clc
    adc #32
    sta <.tmp_vram_l
    lda <.tmp_vram_h
    adc #0
    sta <.tmp_vram_h
                        ;次の行に仮想vramインデックスを移動
    tya
    clc
    adc #32-3
    tay

    bra .loop_row

.end_loop:
    rts


;
;

    .bss
    
;   フィールドマップ
;   必要なのは 27*27 だが、アドレス計算が面倒なので 32*27 とする
VMap:   ds  32*27
