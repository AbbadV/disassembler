BRA_SUB
        MOVEM.L   D0-D7/A0-A6,-(SP) ; move the old registers onto the stack

        * sets up the data registers
        *
        * A1 - the current opcode's address
        * A3 - the current position of the output
        * A4 - the location of the text for printing
        *
        * D1 - the actual opcode
        *
        MOVEA.L   #0,A1             ; load the current opcode into a register
        MOVEA.L   IN_CURR_A,A1
        MOVE.L  A1,D3
        ADDQ.L  #2,D3
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       BRA_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

BRA_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       BRA_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       BRA_COPY      ; do it again
        
BRA_DONE
        MOVE.B  #$FF,D2
        AND.B   D1,D2
        CMP #0,D2
        BNE BRA_GETLONG


        MOVE.B  D1,D6
        ADD.B   D3,D6
        MOVE.B  D6,D3
        
        MOVE.W  D3,D7
        ASR.L   #8,D7
        ASR.L   #4,D7
        JSR BRA_CONVERT        
        MOVE.B  D7,(A3)+
        
        MOVE.W  D3,D7
        AND.W   #$0F00,D7
        ASR.L   #8,D7
        JSR BRA_CONVERT       
        MOVE.B  D7,(A3)+
        
        MOVE.W  D3,D7
        AND.W   #$00F0,D7
        ASR.L   #4,D7
        JSR BRA_CONVERT        
        MOVE.B  D7,(A3)+
        
        MOVE.W  D3,D7
        AND.W   #$000F,D7
        JSR BRA_CONVERT       
        MOVE.B  D7,(A3)+

BRA_GETLONG
        MOVE.L #0,D2
        

        MOVE.B  #$A,(A3)+
        MOVE.B  #$D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

BRA_CONVERT
    CMP.B   #10,D7
    BLT BRA_DIGIT
    ADD.B   #$37,D7
    RTS
BRA_DIGIT
    ADD.B #$30,D7
    RTS  



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
