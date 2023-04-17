;       鮫！鮫！鮫！(Fire Shark) 勝手移植版 for PCEngine
;       2020/12/09
;
;       バンク０に配置すべきコード
;       割り込みベクタ・割り込みハンドラ（RESET）
;       アドレスは $e000-$ffff

BANK0_BANK .equ 0

        .code
        .bank BANK0_BANK
;
;       interrupt vectors
;
        .org $fff6
        .dw     interrupt_dummy         ;$fff6 IRQ2/BRK
        .dw     interrupt_dummy2         ;$fff8 IRQ1
;        .dw     interrupt_dummy3         ;$fffa timer
        .dw     pcmTimerHandler         ;$fffa timer
        .dw     interrupt_dummy4         ;$fffc NMI
        .dw     interrupt_reset         ;$fffe RESET
;
;       interrupt handlers
;
        .org $e000
;
;       dummy handler
;
interrupt_dummy:
        rti

interrupt_dummy2:
        rti

interrupt_dummy3:
        rti

interrupt_dummy4:
        rti
;
;       RESET interrupt handler
;
interrupt_reset:
        sei                             ; disable interrupt
        csh                             ; high speed mode
        cld                             ; 

        ldx     #$ff                    ; initialize stack pointer
        txs

        lda     #$ff                    ; map i/o bank
        tam0
        lda     #$f8                    ; map ram bank
        tam1

        stz     $2000                   ; clear ram
        tii     $2000,$2001,$1fff
        
        stz     TimerCtrl               ; stop timer

        jsr     initPsg
        jsr     initVdc
        jsr     initPad

        lda     #7
        sta     IntCtrlMask             ; disable interrupt

        lda     #5
        sta     VdcReg
        lda     #$c8                    ; enable sprite & bg / disable interrupt
        sta     VdcDataL
        st2     #0                      ; auto increment +1

;       jump to main
        lda     #BANK(main)
        tam     #PAGE(main)
        jmp     main
;
;       initialize psg
;
initPsg:
        stz     PsgMainVol
        stz     PsgLfoCtrl

;       disable all channels
        lda     #5
.loop:  sta     PsgChannel
        stz     PsgMainVol
        stz     PsgCtrl
        dec     a
        bpl     .loop

;       disable noise(channel 4/5)
        lda     #4
        sta     PsgChannel
        stz     PsgNoise
        inc     a
        sta     PsgChannel
        stz     PsgNoise

        rts
;
;       initialize VDC,VCE
;       TODO: 解像度が横336ドット限定の設定になっている

; ----
; HSR(xres)
; ----
; macros to calculate the value of the HSR VDC register
; ----
; IN :  xres, horizontal screen resolution
; ----

HSR	.macro
	 .if (\1 <= 272)
	  ; low res
	  .db $02
	  .db (18 - (((\1 / 8) - 1) / 2))
	 .else
	  ; high res
	  .db $03
	  .db (24 - (((\1 / 8) - 1) / 2))
	 .endif
	.endm


; ----
; HDR(xres)
; ----
; macros to calculate the value of the HDR VDC register
; ----
; IN :  xres, horizontal screen resolution
; ----

HDR	.macro
	 .db ((\1 / 8) - 1)
	 .if (\1 <= 272)
	  ; low res
	  .db (38 - ((18 - (((\1 / 8) - 1) / 2)) + (\1 / 8)))
	 .else
	  ; high res
	  .db (54 - ((24 - (((\1 / 8) - 1) / 2)) + (\1 / 8)))
	 .endif
	.endm


initVdc:
;       set VDC registers from .table
        clx
.loop:
        lda     .table,x
        beq     .endloop
        sta     VdcReg
        inx
        lda     .table,x
        sta     VdcDataL
        inx
        lda     .table,x
        sta     VdcDataH
        inx
        bra     .loop
.endloop:

;       init vce
;        lda     #1              ;horizontal resolution >272!!!!!!
;        sta     VceCtrl
        stz     VceCtrl

;       clear vram
        st0     #0
        st1     #0
        st2     #0
        st0     #2

        ldx     #128
.cl2:   cly
.cl1:   st1     #0
        st2     #0
        dey
        bne     .cl1
        dex
        bne     .cl2

        rts

;       resolution      256x240
;       bat size        32x32
;       satb copy       $7f00
.table:
        .db     $05,$00,$00     ;control register
        .db     $06,$00,$00     ;raster counter register
        .db     $07,$00,$00     ;x scroll register
        .db     $08,$00,$00     ;y scroll register
        .db     $09,$00,$00     ;memory access width register
        .db     $0a             ;horizontal synchro register
        HSR     256
        .db     $0b             ;horizontal display register
        HDR     256
        .db     $0c,$02,$0f     ;vertical synchro register
        .db     $0d,$ef,$00     ;vertical display register
        .db     $0e,$03,$00     ;vertical display end position register
        .db     $0f,$10,$00     ;dma control register
        .db     $13,$00,$7f     ;vram-satb source address register
        .db     $00             ;end of table
;
;       initialize pad
;
initPad:
        stz     <zpad
        stz     <zpadold
        stz     <zpaddelta
        rts
;
;       read pad
;       TODO: support multi tap
readPad:
        lda     #1
        sta     PadPort
        lda     #3
        sta     PadPort

        lda     <zpad
        eor     #$ff
        sta     <zpadold

        lda     #1
        sta     PadPort
        sax                     ;wait 10 cycles
        sax
        nop
        nop
        lda     PadPort
        asl     a
        asl     a
        asl     a
        asl     a
        sta     <zpad

        stz     PadPort
        sax                     ;wait 10 cycles
        sax
        nop
        nop
        lda     PadPort
        and     #$0f
        ora     <zpad
        eor     #$ff
        sta     <zpad

        and     <zpadold
        sta     <zpaddelta

        rts
;
        .zp
zpad:          .ds 1   ;pad status
zpaddelta      .ds 1   ;pad status(delta)
zpadold        .ds 1   ;pad status(previous)

