*-----------------------------------------------------------
* Title      : OPCODE_TEST
* Version    : 1 (23 Apr 2017)
* Written by : weMissJava
* Date       : 4/21/17
* Description: Test file containing required opcodes for 
*              disassembling. 
*-----------------------------------------------------------
    ORG    $7000

**Order according to "Required Opcodes" page

**NOP
BEGIN    NOP
    MOVE.B D0, D1
    MOVE.W #$ABCD, $1234ABCD ;doesn't increment output pointer correctly
    MOVE.L #$1234ABCD, $AAAA  ;doesn't increment output pointer correctly
    MOVE.B -(A1),(A2)
    MOVE.B (A3)+,-(A4) 
    MOVE.B (A3)+,(A4)+

    MOVE.B (A4),D0
    
    MOVEA.W D0, A1
    MOVEA.W #$ABCD, A1
    MOVEA.L #$1234ABCD, A1
    MOVEA.L -(A1),A1
    MOVEA.L (A3)+,A1 
    MOVEA.L (A4),A1
    MOVEA.L #$0067,A1
    MOVEM.W D1-D3/A1-A3/A7,-(SP)
    MOVEM.L (SP)+,D1-D3/A1-A3/A7
    MOVEQ #128,D3
    
    ASL.L   D0,D1
    ASL.B   #3,D1
    ASR.L   D0,D1
    ASR.B   #3,D1
    ASL.W   D0,D1
    ASR.W   #3,D1
    ROR.W   #3,D3
    ROL.B   #3,D5
    LSR.L   D0,D1
    LSR.B   #3,D1
    LSL.W   D0,D1
    LSL.L   D0,D1
    LSL.B   #3,D1
    LSR.W   D0,D1
    LSR (A1)
    ASR -(A3)
    ROR $4000
   
**MOVE

    Bcc begin
    BGE JUMP
    BLT JUMP
    BRA BEGIN

    JSR     JUMP
JUMP    RTS  
 
         
    
    
    






























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
