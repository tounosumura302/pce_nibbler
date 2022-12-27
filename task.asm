

TK_MAX_TASK equ 4               ;タスク数
TK_TASK_STACK_SIZE  equ 16      ;タスクあたりのスタックサイズ
TK_STACK_AREA   equ $2100       ;スタック開始アドレス

    .zp
ztkTaskNum: ds  1
ztkSaveSp:  ds  1               ;tkDispatch 実行時のsp保存
ztkCurTask: ds  1               ;tkDispatch 実行中のタスク番号
ztkChgTask: ds  2

    .bss

tkSp:   ds  TK_MAX_TASK         ;タスクのsp

    .code
    .bank   MAIN_BANK


;
;   タスク初期化
;   @args           なし
;   @saveregs       なし
;   @return         なし
;
                ;pレジスタも保管すると、割り込み状態も変わってしまって予期せぬ動きに繋がりかねないので保管しない。
                ;実際、禁止していた割り込みが勝手にかかってしまい、おかしな動きになってしまった。
tkInit:
    stz ztkTaskNum

    lda #LOW(tklNone)
    sta <zarg2
    lda #HIGH(tklNone)
    sta <zarg3
    jsr tkSetAllTasks

    tkChangeTask_   0
    rts

;
;   タスク変更
;   @args           zarg0,1 = タスク開始アドレス
;                   x = タスク番号
;   @saveregs       x
;   @return         なし
;
tkSetTask:
    phx

    txa
    inc a
    .if TK_TASK_STACK_SIZE=16
    asl a
    asl a
    asl a
    asl a
    .else
    .fail   "ST_TASK_STACK_SIZE!=16"
    .endif
    sta tkSp,x

    tax
    stz TK_STACK_AREA+1,x
    stz TK_STACK_AREA+2,x
    stz TK_STACK_AREA+3,x
    lda <zarg0
    sta TK_STACK_AREA+4,x
    lda <zarg1
    sta TK_STACK_AREA+5,x

    plx
    rts

;
;   全てのタスク変更
;   @args           zarg2,3 = タスクリストアドレス
;   @saveregs       なし
;   @return         なし
;
tkSetAllTasks:
    clx
    cly

.loop:
    lda [zarg2],y
    sta <zarg0
    iny
    ora [zarg2],y
    beq .taskend

    lda [zarg2],y
    sta <zarg1
    jsr tkSetTask

    iny
    inx
    cpx #TK_MAX_TASK
    bne .loop
.taskend:
    stx <ztkTaskNum

    rts



;
;   タスクの実行
;   @args           なし
;   @saveregs       なし
;   @return         なし
;
tkDispatch:
                    ;タスクがない場合
    lda <ztkTaskNum
    beq tkDispatch_end

                    ;このルーチン開始時のspを保管
    tsx
    stx <ztkSaveSp

    cly             ;y=タスク番号

tkDispatch_loop:
                    ;タスクを実行
                    ;タスクのspを復元
    ldx tkSp,y
    txs
    sty <ztkCurTask ;現在のタスク番号を保管
                    ;タスクのレジスタを復元
    ply
    plx
    pla
    rts             ;タスクの実行アドレスにジャンプ

                    ;タスク切り替え
tkYield:
                    ;タスクのレジスタを保管
    pha
    phx
    phy
                    ;タスクのspを保管
    ldy <ztkCurTask ;y=現在のタスク番号
    tsx
    txa
    sta tkSp,y      
                    ;次のタスク
tkNextTask:
    iny
;    cpy #TK_MAX_TASK
    cpy <ztkTaskNum
    bne tkDispatch_loop
                    ;tkDispatch開始時のspを復元
    ldx <ztkSaveSp
    txs

tkDispatch_end:
    rts

;
;
;
tkChangeTasks:
    lda <ztkChgTask
;    bit <ztkChgTask+1
    ora <ztkChgTask+1
    bne .chg
    rts
.chg:
    lda <ztkChgTask
    sta <zarg2
    lda <ztkChgTask+1
    sta <zarg3
    jsr tkSetAllTasks

    tkChangeTask_   0
    rts
;
;   実行中のタスクの変更
;   ※タスク内からの呼び出し専用
;   @args           zarg0,1 = タスク開始アドレス
;   @saveregs       なし
;   @return         なし
;
tkLink:
                    ;タスクのレジスタを保管
    pha
    phx
    phy
                    ;タスクのspを保管
    ldy <ztkCurTask ;y=現在のタスク番号
    tsx
    txa
    sta tkSp,y      
                    ;タスクの開始アドレスを変更
    lda <zarg0
    sta TK_STACK_AREA+4,x
    lda <zarg1
    sta TK_STACK_AREA+5,x

    bra tkNextTask




;
;   何もしないタスク
;
tkDummyTask:
    jsr tkYield
    bra tkDummyTask



;
;   タスクリスト
;
;
tkTaskAddress_  .macro
;    .if \1!=0
    dw  \1-1
;    .else
;    dw  0
;    .endif
    .endm

tkEndTaskList_  .macro
    dw  0
    .endm


tklNone:
    tkEndTaskList_

tklInitWave:
    tkTaskAddress_  DrawWaveTask
    tkTaskAddress_  VSyncTask
    tkEndTaskList_

tklGameMain:
    tkTaskAddress_  plTask
    tkTaskAddress_  StatusTask
    tkTaskAddress_  VSyncTask
    tkEndTaskList_

tklClearWave:
    tkTaskAddress_  WaveClearTask
    tkTaskAddress_  VSyncTask
    tkEndTaskList_
