* ------------------------------------------------------------------------------
* CONSTANTS
* VERSION 1 (23 APR 2017)
* Written by James Winters
* ------------------------------------------------------------------------------

PRINT_NUM_STACK DS.B  8

BAD_COMMAND_STR DC.B  'DATA',$09,'$',0

NOP_STR DC.B  'NOP',$0A,$0D,0
NOP_S   EQU   $4E71
NOP_P   EQU   $FFFF

MOVEA_STR  DC.B  'MOVEA',0
MOVEA_S    EQU   $0040
MOVEA_P    EQU   $C1C0

MOVE_STR   DC.B  'MOVE',0
MOVE_S     EQU   $0000
MOVE_P     EQU   $C000

RTS_STR    DC.B  'RTS',0
RTS_S      EQU   $4E75
RTS_P      EQU   $FFFF

JSR_STR    DC.B  'JSR',0
JSR_S      EQU   $4E80
JSR_P      EQU   $FFC0

MOVEM_STR  DC.B  'MOVEM',0
MOVEM_S    EQU   $4880
MOVEM_P    EQU   $FB80

BRA_STR    DC.B  'BRA',0
BRA_S      EQU   $6000
BRA_P      EQU   $FF00

MOVEQ_STR  DC.B  'MOVEQ',0
MOVEQ_S    EQU   $7000
MOVEQ_P    EQU   $F100

ADD_STR    DC.B  'ADD',0
ADD_S      EQU   $D000
ADD_P      EQU   $F000

ADDA_STR   DC.B  'ADDA',0
ADDA_S     EQU   $D0C0
ADDA_P     EQU   $F0C0
