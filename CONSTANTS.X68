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

MOVEM_STR  DC.B  'MOVEM',0
MOVEM_S    EQU   $4880
MOVEM_P    EQU   $FB80

MOVEQ_STR  DC.B  'MOVEQ',0
MOVEQ_S    EQU   $7000
MOVEQ_P    EQU   $F100
