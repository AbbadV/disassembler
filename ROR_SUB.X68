ROR_SUB
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
        LEA       ROR_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

ROR_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ROR_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ROR_COPY      ; do it again
        
ROR_DONE
          MOVE.W    D1, D0
          ANDI.W    #$00C0,D0
          LSR.W     #6,D0
          
          *mem shift, get EA
          CMP.B     #3,D0
          BEQ       ROR_EA

          * we always print the period (2E in ASCII)
          MOVE.B    #$2E,(A3)+

          * switch to the correct subroutine
          CMP.B     #0,D0
          BEQ       ROR_PRINT_SIZE_BYTE
          CMP.B     #1,D0
          BEQ       ROR_PRINT_SIZE_WORD
          CMP.B     #2,D0
          BEQ       ROR_PRINT_SIZE_LONG
          
ROR_PRINT_SIZE_END
          * print a tab and return
          MOVE.B    #9,(A3)+
          MOVE.W    D1, D0
          ANDI.W    #$0020,D0
          LSR.W     #5,D0
          
          MOVE.W    D1,D7
          CMP.B #0,D0
          BEQ   ROR_IMM
          
          *DATA REGISTER
   
          MOVE.B    #'D',(A3)+
          AND.W #$0E00,D7
          LSR.W #8,D7
          LSR.W #1,D7
          ADD.B #$30,D7
          MOVE.B    D7,(A3)+
          
ROR_DEST          *GET DATA REGISTER
          MOVE.B    #',',(A3)+
          MOVE.B    #'D',(A3)+
 
          ANDI.W    #$0007,D1

          ADD.B     #$30,D1
          MOVE.B    D1,(A3)+
          
ROR_FIN          
          MOVE.B    #$0A,(A3)+
          MOVE.B    #$0D,(A3)+
 
        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
ROR_PRINT_SIZE_BYTE
          MOVE.B    #$42,(A3)+
          BRA       ROR_PRINT_SIZE_END

ROR_PRINT_SIZE_WORD
          MOVE.B    #$57,(A3)+
          BRA       ROR_PRINT_SIZE_END

ROR_PRINT_SIZE_LONG
          MOVE.B    #$4C,(A3)+
          BRA       ROR_PRINT_SIZE_END
ROR_IMM
    MOVE.B    #'#',(A3)+
    AND.W #$0E00,D7
    LSR.W #8,D7
    LSR.W #1,D7

    TST.W D7
    BEQ   ROR_EIGHT
          
    ADD.B #$30,D7
    MOVE.B D7,(A3)+

    BRA ROR_DEST

ROR_EIGHT
    MOVE.B #'8',(A3)+
    BRA    ROR_DEST

ROR_EA
    MOVE.B    #$2E,(A3)+
    MOVE.B    #$57,(A3)+
    MOVE.B #$09,(A3)+
    JSR PRINT_SOURCE_SUB
    BRA ROR_FIN





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
