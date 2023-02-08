        .code
;        .bank   MAIN_BANK+3
    .bank   BGPATTERN_BANK
        .org    $4000

BgPattern:

;
;   フォント 0-9,A-Z ,
;
bp_font_0:
    db  %00111000,0
    db  %01001100,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %01100100,0
    db  %00111000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_1:
    db  %00110000,0
    db  %01110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %11111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_2:
    db  %01111100,0
    db  %11000110,0
    db  %00001110,0
    db  %00111100,0
    db  %01111000,0
    db  %11100000,0
    db  %11111110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_3:
    db  %11111110,0
    db  %00001100,0
    db  %00011000,0
    db  %00111100,0
    db  %00000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_4:
    db  %00011100,0
    db  %00111100,0
    db  %01101100,0
    db  %11001100,0
    db  %11111110,0
    db  %00001100,0
    db  %00001100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_5:
    db  %11111100,0
    db  %11000000,0
    db  %11111100,0
    db  %00000110,0
    db  %00000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_6:
    db  %00111100,0
    db  %01100000,0
    db  %11000000,0
    db  %11111100,0
    db  %11000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_7:
    db  %11111110,0
    db  %11000110,0
    db  %00001100,0
    db  %00011000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_8:
    db  %01111000,0
    db  %11000100,0
    db  %11100100,0
    db  %01111000,0
    db  %10011110,0
    db  %10000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_9:
    db  %01111100,0
    db  %11000110,0
    db  %11000110,0
    db  %01111110,0
    db  %00000110,0
    db  %00001100,0
    db  %01111000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_A:
    db  %00111000,0
    db  %01101100,0
    db  %11000110,0
    db  %11000110,0
    db  %11111110,0
    db  %11000110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_B:
    db  %11111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_C:
    db  %00111100,0
    db  %01100110,0
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %01100110,0
    db  %00111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_D:
    db  %11111000,0
    db  %11001100,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11001100,0
    db  %11111000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_E:
    db  %11111100,0
    db  %11000000,0
    db  %11000000,0
    db  %11111000,0
    db  %11000000,0
    db  %11000000,0
    db  %11111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_F:
    db  %11111100,0
    db  %11000000,0
    db  %11000000,0
    db  %11111000,0
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_G:
    db  %00111110,0
    db  %01100000,0
    db  %11000000,0
    db  %11001110,0
    db  %11000110,0
    db  %01100110,0
    db  %00111110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_H:
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11111110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_I:
    db  %11111100,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %11111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_J:
    db  %00000110,0
    db  %00000110,0
    db  %00000110,0
    db  %00000110,0
    db  %00000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_K:
    db  %11000110,0
    db  %11001100,0
    db  %11011000,0
    db  %11110000,0
    db  %11111000,0
    db  %11011100,0
    db  %11001110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_L:
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %11000000,0
    db  %11111110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_M:
    db  %11000110,0
    db  %11101110,0
    db  %11111110,0
    db  %11111110,0
    db  %11010110,0
    db  %11000110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_N:
    db  %11000110,0
    db  %11100110,0
    db  %11110110,0
    db  %11111110,0
    db  %11011110,0
    db  %11001110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_O:
    db  %01111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_P:
    db  %11111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11111100,0
    db  %11000000,0
    db  %11000000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_Q:
    db  %01111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11011110,0
    db  %11001100,0
    db  %01111010,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_R:
    db  %11111100,0
    db  %11000110,0
    db  %11000110,0
    db  %11001110,0
    db  %11111000,0
    db  %11011100,0
    db  %11001110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_S:
    db  %01111100,0
    db  %11000110,0
    db  %11000000,0
    db  %01111100,0
    db  %00000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_T:
    db  %11111100,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_U:
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %01111100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_V:
    db  %11000110,0
    db  %11000110,0
    db  %11000110,0
    db  %11101110,0
    db  %01111100,0
    db  %00111000,0
    db  %00010000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_W:
    db  %11000110,0
    db  %11000110,0
    db  %11010110,0
    db  %11111110,0
    db  %11111110,0
    db  %11101110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_X:
    db  %11000110,0
    db  %11101110,0
    db  %01111100,0
    db  %00111000,0
    db  %01111100,0
    db  %11101110,0
    db  %11000110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_Y:
    db  %11001100,0
    db  %11001100,0
    db  %11001100,0
    db  %01111000,0
    db  %00110000,0
    db  %00110000,0
    db  %00110000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_Z:
    db  %11111110,0
    db  %00001110,0
    db  %00011100,0
    db  %00111000,0
    db  %01110000,0
    db  %11100000,0
    db  %11111110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_comma:
    db  %00000000,0
    db  %00000000,0
    db  %00000000,0
    db  %00000000,0
    db  %00000000,0
    db  %00110000,0
    db  %00110000,0
    db  %00010000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_player1_0:
    db  %11110100,0
    db  %10010100,0
    db  %11110100,0
    db  %10000100,0
    db  %10000100,0
    db  %10000100,0
    db  %10000111,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_player1_1:
    db  %00100101,0
    db  %01010101,0
    db  %01010101,0
    db  %01110010,0
    db  %01010010,0
    db  %01010010,0
    db  %01010010,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_player1_2:
    db  %01110111,0
    db  %01000101,0
    db  %01000111,0
    db  %01100110,0
    db  %01000101,0
    db  %01000101,0
    db  %01110101,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_player1_3:
    db  %00010000,0
    db  %00110000,0
    db  %00010000,0
    db  %00010000,0
    db  %00010000,0
    db  %00010000,0
    db  %00111000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_hiscore_0:
    db  %10101110,0
    db  %10100100,0
    db  %10100100,0
    db  %11100100,0
    db  %10100100,0
    db  %10100100,0
    db  %10101110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_hiscore_1:
    db  %00100010,0
    db  %01010101,0
    db  %01000100,0
    db  %00100100,0
    db  %00010100,0
    db  %01010101,0
    db  %00100010,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_hiscore_2:
    db  %00100111,0
    db  %01010101,0
    db  %01010111,0
    db  %01010110,0
    db  %01010101,0
    db  %01010101,0
    db  %00100101,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_hiscore_3:
    db  %01110000,0
    db  %01000000,0
    db  %01000000,0
    db  %01100000,0
    db  %01000000,0
    db  %01000000,0
    db  %01110000,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_left_0:
    db  %10001110,0
    db  %10001000,0
    db  %10001000,0
    db  %10001100,0
    db  %10001000,0
    db  %10001000,0
    db  %11101110,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_left_1:
    db  %11101110,0
    db  %10000100,0
    db  %10000100,0
    db  %11000100,0
    db  %10000100,0
    db  %10000100,0
    db  %10000100,0
    db  %00000000,0
    dw  $00,$00,$00,$00,$00,$00,$00,$00

bp_font_space:
    dw $00,$00,$00,$00,$00,$00,$00,$00
    dw $00,$00,$00,$00,$00,$00,$00,$00


;
;
;

bp_blank:
        dw $00,$00,$00,$00,$00,$00,$00,$00
        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_ul:
    dw $e619,$807f,$8040,$00c0,$00c0,$8040,$8040,$00c0
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $ff,$ff,$c0,$c0,$c0,$c0,$c0,$c0
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_ur:
    dw $6798,$01fe,$0102,$0003,$0003,$0102,$0102,$0003
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $ff,$ff,$03,$03,$03,$03,$03,$03
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_dl:
    dw $00c0,$8040,$8040,$00c0,$00c0,$8040,$807f,$e619
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $c0,$c0,$c0,$c0,$c0,$c0,$ff,$ff
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_dr:
    dw $0003,$0102,$0102,$0003,$0003,$0102,$01fe,$6798
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $03,$03,$03,$03,$03,$03,$ff,$ff
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_l:
    dw $00c0,$8040,$8040,$00c0,$00c0,$8040,$8040,$00c0
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_r:
    dw $0003,$0102,$0102,$0003,$0003,$0102,$0102,$0003
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $03,$03,$03,$03,$03,$03,$03,$03
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_u:
    dw $6699,$00ff,$0000,$0000,$0000,$0000,$0000,$0000
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $ff,$ff,$00,$00,$00,$00,$00,$00
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_d:
    dw $0000,$0000,$0000,$0000,$0000,$0000,$00ff,$6699
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $00,$00,$00,$00,$00,$00,$ff,$ff
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_blank_ul:
    dw $00c0,$0080,$0000,$0000,$0000,$0000,$0000,$0000
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $c0,$80,$00,$00,$00,$00,$00,$00
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_blank_ur:
    dw $0003,$0001,$0000,$0000,$0000,$0000,$0000,$0000
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $03,$01,$00,$00,$00,$00,$00,$00
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_blank_dl:
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0080,$00c0
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $00,$00,$00,$00,$00,$00,$80,$c0
;        dw $00,$00,$00,$00,$00,$00,$00,$00
bp_wall_blank_dr:
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0001,$0003
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $00,$00,$00,$00,$00,$00,$01,$03
;        dw $00,$00,$00,$00,$00,$00,$00,$00

bp_dot:
    dw $0018,$0034,$006e,$df00,$bb00,$7676,$2c2c,$1818
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $00,$7e,$7e,$7e,$7e,$7e,$7e,$00
;        dw $00,$00,$00,$00,$00,$00,$00,$00

bp_body_l:
    dw $0000,$00ff,$00ff,$10ef,$38c7,$10ef,$00ff,$00ff
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

bp_body_d:
    dw $00fe,$00fe,$00fe,$10ee,$38c6,$10ee,$00fe,$00fe
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

bp_body_r:
    dw $0000,$00ff,$00ff,$10ef,$38c7,$10ef,$00ff,$00ff
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

bp_body_u:
    dw $00fe,$00fe,$00fe,$10ee,$38c6,$10ee,$00fe,$00fe
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
;        dw $00,$00,$00,$00,$00,$00,$00,$00

BgPattern_end:
BgPattern_size  equ BgPattern_end-BgPattern

; ┌─┐
; │ │
; └─┘

BgPalette:
    dw $000,$028,$03f,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
    dw $000,$03f,$1ff,$1f8,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
    dw $000,$038,$1ff,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
;        dw $0000,$ffff,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
;        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$01b6,$0120,$0000,$0000,$0000,$0000,$0000,$0107,$01c7,$0000,$0000,$0000,$0000,$0000,$0000
