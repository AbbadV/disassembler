*-----------------------------------------------------------
* Title      : OPCODE_TEST
* Version    : 1 (23 Apr 2017)
* Written by : weMissJava
* Date       : 4/21/17
* Description: Test file containing required opcodes for 
*              disassembling. 
*-----------------------------------------------------------
    ORG    $3000

**Order according to "Required Opcodes" page


    MOVE.L  #$00001234,$4000

    MOVE.L D1,D2

    MOVE.L A2,D5

    MOVE.L (A3)+,D6
    
    MOVE.W  -(A3),(A4)+
    
    MOVE.L  (A2),$0012
    
    MOVE.L  #$00001234,$F234

    NOP

    MOVE.W #$1234,D7

    MOVE.W #$00CD,$12345678

    NOP
    
    NOP










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
