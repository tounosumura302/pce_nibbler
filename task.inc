tkChangeTask_   .macro
    lda #LOW(\1)
    sta <ztkChgTask
    lda #HIGH(\1)
    sta <ztkChgTask+1
    .endm

tkYield_    .macro
    jsr tkYield
    .endm
