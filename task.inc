tkChangeTask_   .macro
;    .if \1=0
;    stz <ztkChgTask
;    stz <ztkChgTask+1
;    .else
    lda #LOW(\1)
    sta <ztkChgTask
    lda #HIGH(\1)
    sta <ztkChgTask+1
;    .endif
    .endm
