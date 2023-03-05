scrEnd_   .macro
    db  0
    .endm

scrWait_    .macro
    db  2
    .endm

scrSetInterval_ .macro
    db  4
    db  \1
    .endm

scrSetSprite_    .macro
    db  6
    db  \1
    dw  \2,\3,\4,\5
    .endm

scrSetSpritePosition_    .macro
    db  8
    db  \1
    dw  \2,\3
    .endm

scrSetSpritePattern_    .macro
    db  10
    db  \1
    dw  \2
    .endm

scrSetSpriteAttribute_    .macro
    db  12
    db  \1
    dw  \2
    .endm

scrSetBG_   .macro
    db  14
    dw  \1,\2
    db  \3
    .endm
