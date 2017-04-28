JSR_SUB
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
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       JSR_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

JSR_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       JSR_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       JSR_COPY      ; do it again
        
JSR_DONE

        MOVE.L D1,D4
        MOVE.L  #0,D3
        
        AND #1,D4
        CMP #0,D4
        BEQ JSR_ABSW
        
JSR_ABSL        JSR JSR_GETBYTE
                  ADDQ.B    #1,D3
                  CMP.B     #4,D3
                  BNE   JSR_ABSL
                  BRA JSR_FINISH

JSR_ABSW    JSR JSR_GETBYTE
                  ADDQ.B    #1,D3
                  CMP.B     #2,D3
                  BNE   JSR_ABSW
                  BRA JSR_FINISH  
                                
JSR_GETBYTE
    MOVE.B  (A1)+,D5
    MOVE.B  D5,D6
    AND.B   #$F0,D6
    LSR.B   #4,D6
    JSR JSR_CONVERT
    MOVE.B  D6,(A3)+
    MOVE.B  D5,D6
    AND.B   #$F,D6
    JSR JSR_CONVERT
    MOVE.B  D6,(A3)+
    RTS
JSR_CONVERT
    CMP.B   #10,D6
    BLT JSR_DIGIT
    ADD.B   #$37,D6
    RTS
JSR_DIGIT
    ADD.B #$30,D6
    RTS         

JSR_FINISH
        MOVE.B  #$A,(A3)+
        MOVE.B  #$D,(A3)+
        
        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
