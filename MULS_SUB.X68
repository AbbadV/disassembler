MULS_SUB
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
        LEA       MULS_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVE_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVE_STR

MULS_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       MULS_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MULS_COPY      ; do it again
        
MULS_DONE
        MOVE.B  #9,(A3)+        ;add a tab
        MOVE.B  #1,SIZE_BUFFER  ;update size buffer
        JSR PRINT_SOURCE_SUB    ;get source
        MOVE.B  #',',(A3)+      ;add ,
        MOVE.B  #'D',(A3)+      ;add d
        AND.L   #$0E00,D1       ;get the data register number
        LSR.L   #8,D1           ;shift the data register value
        LSR.L   #1,D1           
        
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        JSR PRINT_NUM           ;print the data register value
        
        MOVE.B    #$0A,(A3)+    ;add cr
        MOVE.B    #$0D,(A3)+    ;add lf

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
