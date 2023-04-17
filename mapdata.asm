    .code
    .bank   MAIN_BANK



;
;   gridを構成するタイルのキャラクター番号（BATの下12ビットの値）
;
MapPartsPatternAddress  equ $1000+52*16
MapPartsTiles:
    dw  (MapPartsPatternAddress+$00*16)/16  ;空白
    dw  (MapPartsPatternAddress+$01*16)/16  ;左上┌
    dw  (MapPartsPatternAddress+$02*16)/16  ;右上┐
    dw  (MapPartsPatternAddress+$03*16)/16  ;左下└
    dw  (MapPartsPatternAddress+$04*16)/16  ;右下┐
    dw  (MapPartsPatternAddress+$05*16)/16  ;左│
    dw  (MapPartsPatternAddress+$06*16)/16  ;右│
    dw  (MapPartsPatternAddress+$07*16)/16  ;上─
    dw  (MapPartsPatternAddress+$08*16)/16  ;下─
    dw  (MapPartsPatternAddress+$09*16)/16  ;左上・
    dw  (MapPartsPatternAddress+$0a*16)/16  ;右上・
    dw  (MapPartsPatternAddress+$0b*16)/16  ;左下・
    dw  (MapPartsPatternAddress+$0c*16)/16  ;右下・
    dw  (MapPartsPatternAddress+$0d*16)/16 + $1000  ;ドット

;
;   マップのgridの中身
;   gridは3x3のタイルで構成され、各タイルを1バイトで表現
;   タイルの値は MapPartsTiles のインデックス
;
MapGridData .macro
    db  \1*2,\2*2,\3*2
    .endm

MapGrids:
MapGrid_00:
    MapGridData  $01,$07,$02
    MapGridData  $05,$00,$06
    MapGridData  $03,$08,$04
MapGrid_01:
    MapGridData  $05,$00,$06
    MapGridData  $05,$00,$06
    MapGridData  $03,$08,$04
MapGrid_02:
    MapGridData  $01,$07,$07
    MapGridData  $05,$00,$00
    MapGridData  $03,$08,$08
MapGrid_03:
    MapGridData  $05,$00,$0a
    MapGridData  $05,$00,$00
    MapGridData  $03,$08,$08
MapGrid_04:
    MapGridData  $01,$07,$02
    MapGridData  $05,$00,$06
    MapGridData  $05,$00,$06
MapGrid_05:
    MapGridData  $05,$00,$06
    MapGridData  $05,$00,$06
    MapGridData  $05,$00,$06
MapGrid_06:
    MapGridData  $01,$07,$07
    MapGridData  $05,$00,$00
    MapGridData  $05,$00,$0c
MapGrid_07:
    MapGridData  $05,$00,$0a
    MapGridData  $05,$00,$00
    MapGridData  $05,$00,$0c
MapGrid_08:
    MapGridData  $07,$07,$02
    MapGridData  $00,$00,$06
    MapGridData  $08,$08,$04
MapGrid_09:
    MapGridData  $09,$00,$06
    MapGridData  $00,$00,$06
    MapGridData  $08,$08,$04
MapGrid_0a:
    MapGridData  $07,$07,$07
    MapGridData  $00,$00,$00
    MapGridData  $08,$08,$08
MapGrid_0b:
    MapGridData  $09,$00,$0a
    MapGridData  $00,$00,$00
    MapGridData  $08,$08,$08
MapGrid_0c:
    MapGridData  $07,$07,$02
    MapGridData  $00,$00,$06
    MapGridData  $0b,$00,$06
MapGrid_0d:
    MapGridData  $09,$00,$06
    MapGridData  $00,$00,$06
    MapGridData  $0b,$00,$06
MapGrid_0e:
    MapGridData  $07,$07,$07
    MapGridData  $00,$00,$00
    MapGridData  $0b,$00,$0c
MapGrid_0f:
    MapGridData  $09,$00,$0a
    MapGridData  $00,$00,$00
    MapGridData  $0b,$00,$0c

;
;   マップのgridの中身（仮想vram用）
;   gridは3x3のタイルで構成され、各タイルを1バイトで表現
;   タイルの値は、下位4ビットが移動可能方向、上位4ビットはフラグ
;

VMapGridData .macro
    db  \1*16,\2*16,\3*16
    .endm

VMapGrids:
VMapGrid_00:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %0000,%0000,%0000
VMapGrid_01:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %0000,%0001,%0000
    VMapGridData  %0000,%0000,%0000
VMapGrid_02:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %0000,%0010,%1010
    VMapGridData  %0000,%0000,%0000
VMapGrid_03:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %0000,%0011,%1010
    VMapGridData  %0000,%0000,%0000
VMapGrid_04:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %0000,%0100,%0000
    VMapGridData  %0000,%0101,%0000
VMapGrid_05:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %0000,%0101,%0000
VMapGrid_06:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %0000,%0110,%1010
    VMapGridData  %0000,%0101,%0000
VMapGrid_07:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %0000,%0111,%1010
    VMapGridData  %0000,%0101,%0000
VMapGrid_08:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %1010,%1000,%0000
    VMapGridData  %0000,%0000,%0000
VMapGrid_09:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %1010,%1001,%0000
    VMapGridData  %0000,%0000,%0000
VMapGrid_0a:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %1010,%1010,%1010
    VMapGridData  %0000,%0000,%0000
VMapGrid_0b:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %1010,%1011,%1010
    VMapGridData  %0000,%0000,%0000
VMapGrid_0c:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %1010,%1100,%0000
    VMapGridData  %0000,%0101,%0000
VMapGrid_0d:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %1010,%1101,%0000
    VMapGridData  %0000,%0101,%0000
VMapGrid_0e:
    VMapGridData  %0000,%0000,%0000
    VMapGridData  %1010,%1110,%1010
    VMapGridData  %0000,%0101,%0000
VMapGrid_0f:
    VMapGridData  %0000,%0101,%0000
    VMapGridData  %1010,%1111,%1010
    VMapGridData  %0000,%0101,%0000


;
;   grid中のドットの有無の組み合わせ
;   左のビットから順に　左上、上、右上、左、中央、右、左下、下　の位置に対応
;   右下に対応するビットがないが、右下にドットが置かれることはないので有無を表すビットを用意する必要がない。
;   左上、右上、左下もドットが置かれることはないが、マップ描画処理の都合上、対応するビットは用意（ただし常に0）
;
DotCombination:
    db  %00000000   ;0
    db  %00001000   ;1　中央
    db  %01000000   ;2　上
    db  %00000001   ;3　下
    db  %00010000   ;4　左
    db  %00000100   ;5　右
    db  %01000001   ;6　上下
    db  %00010100   ;7　左右


;
;   wave（ステージ）のマップ
;   1waveで81バイト
;   マップは9x9の格子でできており、各格子は1バイトで表現
;   格子バイトの上4ビットはドット配置、下4ビットは壁の配置
;   ドット配置は DotCombination のインデックス
;   壁配置は MapGrids のインデックス
;
    .code
    .bank   WAVEMAP_BANK
    org $8000   

WaveMap:
WaveMap_01:
  db $06,$1a,$0e,$1e,$0a,$1e,$0e,$1a,$0c
  db $15,$00,$15,$07,$0e,$0d,$15,$00,$15
  db $07,$0a,$09,$15,$05,$15,$03,$0a,$0d
  db $15,$06,$5a,$0b,$0f,$0b,$5a,$0c,$15
  db $07,$0b,$5a,$0e,$0b,$0e,$5a,$0b,$0d
  db $07,$1a,$0e,$0d,$00,$07,$0e,$1a,$0d
  db $05,$00,$05,$07,$1a,$0d,$05,$00,$05
  db $67,$0a,$09,$25,$00,$25,$03,$0a,$6d
  db $03,$0a,$0a,$0b,$0a,$0b,$0a,$0a,$09

WaveMap_02:
  db $06,$1a,$0a,$1e,$0e,$1e,$0a,$1a,$0c
  db $17,$0a,$1e,$09,$05,$03,$1e,$0a,$1d
  db $05,$00,$07,$1a,$0b,$1a,$0d,$00,$05
  db $13,$0e,$4b,$0a,$0e,$0a,$5b,$0e,$19
  db $06,$0b,$4a,$0a,$3f,$0a,$5a,$0b,$0c
  db $07,$1a,$0a,$0e,$0f,$0e,$0a,$1a,$0d
  db $07,$0e,$0c,$07,$1f,$0d,$06,$0e,$0d
  db $65,$05,$03,$09,$05,$03,$09,$05,$65
  db $03,$0b,$0a,$0a,$0b,$0a,$0a,$0b,$09

WaveMap_03:
  db $06,$1e,$0e,$1e,$0e,$1e,$0e,$1e,$0c
  db $17,$0f,$1f,$0f,$0f,$0f,$1f,$0f,$1d
  db $07,$0f,$0f,$1f,$0f,$1f,$0f,$0f,$0d
  db $17,$0f,$4f,$0f,$0f,$0f,$5f,$0f,$1d
  db $07,$0f,$4f,$0f,$2f,$0f,$5f,$0f,$0d
  db $07,$1f,$0f,$0f,$0f,$0f,$0f,$1f,$0d
  db $07,$0f,$0f,$0f,$1f,$0f,$0f,$0f,$0d
  db $67,$0f,$2f,$2f,$0f,$2f,$2f,$0f,$6d
  db $03,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$09

WaveMap_04:
  db $06,$1a,$0e,$0e,$1a,$0e,$0e,$1a,$0c
  db $07,$1a,$0d,$27,$1a,$2d,$07,$1a,$0d
  db $15,$16,$0b,$0f,$1a,$0f,$0b,$1c,$15
  db $07,$0d,$06,$2d,$00,$27,$0c,$07,$0d
  db $07,$0f,$1d,$07,$1a,$0d,$17,$0f,$0d
  db $07,$0d,$03,$3d,$00,$37,$09,$07,$0d
  db $15,$03,$0e,$0f,$1a,$0f,$0e,$09,$15
  db $07,$1a,$0d,$07,$1a,$0d,$07,$1a,$0d
  db $03,$0a,$0b,$0b,$0a,$0b,$0b,$0a,$09

WaveMap_05:
  db $06,$1a,$0a,$1e,$0e,$1e,$0a,$1a,$0c
  db $17,$0a,$1e,$09,$05,$03,$1e,$0a,$1d
  db $05,$00,$07,$1a,$0b,$1a,$0d,$00,$05
  db $13,$0e,$4b,$0a,$0e,$0a,$5b,$0e,$19
  db $06,$0b,$4a,$0a,$2f,$0a,$5a,$0b,$0c
  db $07,$1a,$0a,$0c,$05,$06,$0a,$1a,$0d
  db $07,$0e,$0c,$07,$1f,$0d,$06,$0e,$0d
  db $65,$05,$03,$09,$05,$03,$09,$25,$65
  db $03,$0b,$0a,$0a,$0b,$0a,$0a,$0b,$09

WaveMap_06:
  db $06,$1e,$0e,$1e,$0e,$1e,$0e,$1e,$0c
  db $17,$0f,$1f,$0f,$0f,$0f,$1f,$0f,$1d
  db $07,$0f,$0f,$1f,$0f,$1f,$0f,$0f,$0d
  db $17,$0f,$4f,$0f,$0f,$0f,$5f,$0f,$1d
  db $07,$0f,$4f,$0f,$2f,$0f,$5f,$0f,$0d
  db $07,$1f,$0f,$0f,$0f,$0f,$0f,$1f,$0d
  db $07,$0f,$0f,$0f,$1f,$0f,$0f,$0f,$0d
  db $67,$0f,$2f,$2f,$0f,$2f,$2f,$0f,$6d
  db $03,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$09

WaveMap_07:
  db $06,$1a,$0e,$1e,$0a,$1e,$0e,$1a,$0c
  db $05,$00,$15,$07,$0e,$0d,$15,$00,$05
  db $07,$0a,$09,$15,$05,$15,$03,$0a,$0d
  db $15,$06,$4a,$0b,$0f,$0b,$5a,$0c,$15
  db $07,$0b,$4a,$0e,$0b,$0e,$5a,$0b,$0d
  db $07,$1a,$0e,$2d,$00,$27,$0e,$1a,$0d
  db $05,$00,$05,$07,$1a,$0d,$05,$00,$05
  db $67,$0a,$09,$25,$00,$25,$03,$0a,$6d
  db $03,$0a,$0a,$0b,$0a,$0b,$0a,$0a,$09

WaveMap_08:
  db $06,$1a,$0a,$1e,$0e,$1e,$0a,$1a,$0c
  db $17,$0a,$1e,$09,$25,$03,$1e,$0a,$1d
  db $05,$00,$07,$1a,$0b,$1a,$0d,$00,$05
  db $13,$0e,$4b,$0a,$0e,$0a,$5b,$0e,$19
  db $06,$0b,$4a,$0a,$2f,$0a,$5a,$0b,$0c
  db $07,$1a,$0a,$0c,$05,$06,$0a,$1a,$0d
  db $07,$0e,$0c,$07,$1f,$0d,$06,$0e,$0d
  db $65,$05,$03,$09,$05,$03,$09,$05,$65
  db $03,$0b,$0a,$0a,$0b,$0a,$0a,$0b,$09

WaveMap_09:
  db $06,$1e,$0e,$1e,$0e,$1e,$0e,$1e,$0c
  db $17,$0f,$1f,$0f,$0f,$0f,$1f,$0f,$1d
  db $07,$0f,$0f,$1f,$0f,$1f,$0f,$0f,$0d
  db $17,$0f,$4f,$0f,$0f,$0f,$5f,$0f,$1d
  db $07,$0f,$4f,$0f,$2f,$0f,$5f,$0f,$0d
  db $07,$1f,$0f,$0f,$0f,$0f,$0f,$1f,$0d
  db $07,$0f,$0f,$0f,$1f,$0f,$0f,$0f,$0d
  db $67,$0f,$2f,$2f,$0f,$2f,$2f,$0f,$6d
  db $03,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$09

WaveMap_10:
  db $06,$1a,$0e,$0e,$1a,$0e,$0e,$1a,$0c
  db $07,$1a,$0d,$27,$1a,$2d,$07,$1a,$0d
  db $15,$16,$0b,$0f,$1a,$0f,$0b,$1c,$15
  db $07,$0d,$06,$2d,$00,$27,$0c,$07,$0d
  db $07,$0f,$1d,$07,$1a,$0d,$17,$0f,$0d
  db $07,$0d,$03,$3d,$00,$37,$09,$07,$0d
  db $15,$03,$0e,$0f,$1a,$0f,$0e,$09,$15
  db $07,$1a,$0d,$07,$1a,$0d,$07,$1a,$0d
  db $03,$0a,$0b,$0b,$0a,$0b,$0b,$0a,$09

    db  $06,$1a,$0e,$0e,$1a,$0e,$0e,$1a,$0c
    db  $07,$1a,$0d,$27,$1a,$2d,$07,$1a,$0d
    db  $15,$16,$0b,$0f,$1a,$0f,$0b,$1c,$15
    db  $07,$0d,$06,$2d,$00,$27,$0c,$07,$0d
    db  $07,$0f,$1d,$07,$1a,$0d,$17,$0f,$0d
    db  $07,$0d,$03,$3d,$00,$37,$09,$07,$0d
    db  $15,$03,$3e,$0f,$1a,$0f,$3e,$09,$15
    db  $07,$1a,$0d,$07,$1a,$0d,$07,$1a,$0d
    db  $03,$0a,$0b,$0b,$0a,$0b,$0b,$0a,$09
