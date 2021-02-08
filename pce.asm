;       鮫！鮫！鮫！(Fire Shark) 勝手移植版 for PCEngine
;       2020/12/09
;
;       common definitions
;
;       VDC
;
VdcPort         .equ    $0000
VdcReg          .equ    VdcPort
VdcStatus       .equ    VdcPort
VdcData         .equ    VdcPort+2
VdcDataL        .equ    VdcData
VdcDataH        .equ    VdcData+1
;
;       VCE
;
VcePort         .equ    $0400
VceCtrl         .equ    VcePort
VceIndex        .equ    VcePort+2
VceIndexL       .equ    VceIndex
VceIndexH       .equ    VceIndex+1
VceData         .equ    VcePort+4
VceDataL        .equ    VceData
VceDataH        .equ    VceData+1
;
;       PSG
;
PsgPort         .equ    $0800
PsgChannel      .equ    PsgPort
PsgMainVol      .equ    PsgPort+1
PsgFreqL        .equ    PsgPort+2
PsgFreqH        .equ    PsgPort+3
PsgCtrl         .equ    PsgPort+4
PsgChVol        .equ    PsgPort+5
PsgWave         .equ    PsgPort+6
PsgNoise        .equ    PsgPort+7
PsgLfoFreq      .equ    PsgPort+8
PsgLfoCtrl      .equ    PsgPort+9
;
;       timer
;
TimerPort       .equ    $0c00
TimerCounter    .equ    TimerPort
TimerCtrl       .equ    TimerPort+1
;
;       interrupt
;
IntCtrlPort     .equ    $1402
IntCtrlMask     .equ    IntCtrlPort
IntCtrlState    .equ    IntCtrlPort+1
;
;       control pad
;
PadPort         .equ    $1000

