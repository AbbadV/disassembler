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

MOVE_STR  DC.B  'MOVE',0
MOVE_S    EQU   $0000
MOVE_P    EQU   $C000

RTS_STR DC.B    'RTS',$0A,$0D,0
RTS_S   EQU     $4E75
RTS_P   EQU     $4E75

BRA_STR DC.B    'BRA',0
BRA_S   EQU     $6000
BRA_P   EQU     $6000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
