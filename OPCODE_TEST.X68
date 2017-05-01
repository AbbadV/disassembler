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

**NOP
BEGIN    NOP
   
**MOVE
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
    Bcc begin
    BGE JUMP
    BLT BEGIN
    JSR     JUMP
JUMP    RTS  
 
         
    
    
    



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
