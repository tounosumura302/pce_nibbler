;       Nibbler 勝手移植版 for PCEngine
;       2022/11/16
;
        list
MAIN_BANK       equ 1
BGPATTERN_BANK  equ 4
SPRPATTERN_BANK equ 5
WAVEMAP_BANK    equ 6

        .include "pce.asm"        
        .include "task.inc"
        .include "script.inc"
        
        
        .include "bank0.asm"
        .include "main.asm"
        .include "task.asm"
    .include "script.asm"
;        .include "chrdriver.asm"
;        .include "pbullet.asm"
;        .include "direction.asm"
;        .include "enemy.asm"
;        .include "ebullet.asm"
;        .include "collision.asm"
;        .include "effect.asm"
 ;       .include        "sprpattern.asm"

        .include "bgpattern.asm"
        .include "sprpattern.asm"
        .include "map.asm"
        .include "mapdata.asm"
        .include "vqueue.asm"
    .include "digits.asm"
    
        .include "player.asm"
        
        
        
        
