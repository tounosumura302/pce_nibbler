        .bank   MAIN_BANK+2
        .org    $8000

spr_pattern2:

spr_pattern2_big_00:
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$7c00,$7a00,$7d00,$7e80,$7ec0
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$3c00,$7e00,$7f00,$7f80,$3f40
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$4000,$7e00,$7f00,$7f80,$4000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$7e00,$7f00,$7f80,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $3cc0,$4960,$7560,$49b0,$75b0,$49b0,$75d8,$49d8
        dw $75d8,$49ec,$3dec,$7fec,$7fec,$7fef,$306f,$007e
        dw $4140,$0da0,$39a0,$0dd0,$39d0,$0dd0,$39e8,$0de8
        dw $39e8,$0df4,$41f4,$3ff4,$3ff7,$3ff4,$3ff7,$ff80
        dw $7e00,$7200,$4200,$7200,$4200,$7200,$4200,$7200
        dw $4200,$7200,$7e00,$4000,$4003,$4003,$4f80,$0001
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0f80,$fffe
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0002,$0001,$0002,$0002,$07f9,$dc42,$d87a,$2541
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0003,$0002,$0003,$07c3,$d83a,$247b,$dd43,$057a
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0003,$0003,$0003,$07c3,$dffb,$fbbb,$22bb,$fabb
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$003c,$003c,$2004,$0004,$0004,$0004

spr_pattern2_big_01:
        dw $0040,$0027,$0058,$0127,$01d8,$0058,$0027,$001c
        dw $002c,$0063,$006c,$002c,$0023,$00ac,$012c,$01a3
        dw $0040,$004f,$0068,$02cf,$0068,$0068,$004f,$0064
        dw $0034,$0077,$0074,$0034,$0037,$0034,$0034,$0037
        dw $007f,$0070,$01f7,$0270,$01f7,$0077,$0070,$007b
        dw $004b,$0078,$007b,$004b,$0048,$01cb,$014b,$01c8
        dw $0000,$0000,$0180,$0380,$0180,$0000,$0000,$0000
        dw $0000,$0070,$0070,$0000,$0000,$0180,$0100,$0180
        dw $2000,$b800,$2c00,$dc00,$1600,$1600,$ce00,$1600
        dw $1600,$ce00,$1600,$1700,$ce00,$17c0,$0a40,$d7d0
        dw $2000,$d800,$3400,$e400,$1a00,$1a00,$f200,$1a00
        dw $1a00,$f200,$1a00,$1b00,$f300,$1a40,$0c00,$f900
        dw $c000,$0000,$c000,$0000,$e000,$e000,$0000,$e000
        dw $e000,$0000,$e000,$e100,$0100,$e180,$f140,$00d0
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$00c0,$0040,$00d0
        dw $07dc,$08ac,$07a3,$14ac,$09dc,$0ca3,$07ad,$01ad
        dw $0022,$006d,$006d,$0022,$0f9d,$0055,$002a,$0199
        dw $0264,$0334,$0437,$1734,$0364,$0237,$0234,$0034
        dw $0036,$0074,$0074,$0036,$1c64,$0064,$004e,$01e8
        dw $078b,$0ecb,$0ac8,$1acb,$0e8b,$0fc8,$07cb,$01cb
        dw $0049,$007b,$007b,$0049,$0bfb,$007b,$0071,$01f7
        dw $0580,$0d80,$0d80,$1d80,$0d80,$0d80,$0580,$0180
        dw $0000,$0070,$0070,$0000,$1f80,$0000,$0000,$0000
        dw $0af0,$0bd0,$d6d0,$0bf8,$0a00,$d7f0,$ca00,$4bd0
        dw $9600,$4b00,$4a00,$9700,$4ac0,$4b00,$9600,$4b00
        dw $0cf0,$0d20,$f800,$0d08,$0cf0,$f9f0,$0c00,$8d00
        dw $3800,$8d00,$8c00,$3900,$8c60,$8d00,$3800,$8d00
        dw $f120,$f020,$0120,$f028,$f120,$0020,$f1d0,$f0d0
        dw $c100,$f000,$f100,$c000,$f180,$f000,$c100,$f000
        dw $00d0,$00d0,$00d0,$00d8,$00d0,$00d0,$00f0,$00d0
        dw $0000,$0000,$0000,$0000,$00e0,$0000,$0000,$0000

spr_pattern2_big_02:
        dw $314a,$9fd7,$640a,$680b,$9ff6,$624b,$61ca,$9f7b
        dw $61ca,$624b,$9ff6,$680b,$640a,$9fd7,$314a,$994b
        dw $d08c,$3ff9,$a40c,$a80d,$3fb8,$a00d,$a00c,$3e8d
        dw $a00c,$a00d,$3fb8,$a80d,$a40c,$3ff9,$d08c,$e88d
        dw $eff1,$c000,$dbf1,$d7f0,$c041,$dff0,$dff1,$c1f0
        dw $dff1,$dff0,$c041,$d7f0,$dbf1,$c000,$eff1,$f7f0
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $fc00,$1e00,$0180,$2060,$4a70,$b5b8,$9db8,$c9a8
        dw $8448,$93b8,$1c00,$1fa0,$fe00,$0000,$fc00,$0000
        dw $fc00,$0000,$e000,$1e00,$0de0,$4a50,$6250,$3640
        dw $7de0,$61a0,$0010,$0040,$0180,$fe00,$fc00,$0000
        dw $0800,$fe00,$1f80,$21e0,$7010,$8008,$8008,$8018
        dw $8218,$8e58,$1ff0,$1fe0,$ff80,$fe00,$0800,$0000
        dw $0800,$0000,$0000,$e020,$fc20,$0e20,$0620,$0620
        dw $0620,$0e20,$fc20,$e020,$0000,$0000,$0800,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

spr_pattern2_end:

spr_pattern2_size	.equ	spr_pattern2_end-spr_pattern2
