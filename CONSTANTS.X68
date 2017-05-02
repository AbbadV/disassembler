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

BCC_STR DC.B    'BCC',$09,'$',0
BCC_S   EQU     $6400
BCC_P   EQU     $FF00

BGE_STR DC.B    'BGE',$09,'$',0
BGE_S   EQU     $6C00
BGE_P   EQU     $FF00

BLT_STR DC.B    'BLT',$09,'$',0
BLT_S   EQU     $6D00
BLT_P   EQU     $FF00

*BIT OPERATOR CONSTANTS

ROL_STR DC.B    'ROL',0
ROL_S   EQU     $E118
ROL_P   EQU     $F118
ROLM_S   EQU     $E7C0
ROLM_P   EQU     $FFC0

ROR_STR DC.B    'ROR',0
ROR_S   EQU     $E018
ROR_P   EQU     $F118
RORM_S   EQU     $E6C0
RORM_P   EQU     $FFC0

ASL_STR DC.B    'ASL',0
ASL_S   EQU     $E100
ASL_P   EQU     $E118
ASLM_S   EQU     $E1C0
ASLM_P   EQU     $FFC0

ASR_STR DC.B    'ASR',0
ASR_S   EQU     $E000
ASR_P   EQU     $E118
ASRM_S   EQU     $E0C0
ASRM_P   EQU     $FFC0

LSL_STR DC.B    'LSL',0
LSL_S   EQU     $E108
LSL_P   EQU     $E118
LSLM_S   EQU     $E3C0
LSLM_P   EQU     $FFC0

LSR_STR DC.B    'LSR',0
LSR_S   EQU     $E008
LSR_P   EQU     $E118
LSRM_S   EQU     $E2C0
LSRM_P   EQU     $FFC0
