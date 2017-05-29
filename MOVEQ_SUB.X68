*------------------------------------------------------------------------------
* MOVEQ_SUB
*
* disassembles and prints a single MOVEQ command
*
* 68K assemblers (or at least the one we've been using in class) will
* automatically convert MOVE to MOVEQ when possible, so some MOVE's will
* look like MOVEQ's
*------------------------------------------------------------------------------

MOVEQ_SUB
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
        MOVE.W    (A1)+,D1          

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       MOVEQ_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVEQ_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVEQ_STR

MOVEQ_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       MOVEQ_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MOVEQ_COPY      ; do it again
        
MOVEQ_DONE

        MOVE.B    #'.',(A3)+    ; print the size (it's always a .L)
        MOVE.B    #'L',(A3)+
        MOVE.B    #$09,(A3)+
        MOVE.B    #2,SIZE_BUFFER  ; update the size buffer

        * print the source ( a single bit of data )
        MOVE.B    #'#',(A3)+
        MOVE.B    #'$',(A3)+
        MOVE.L    D1,D2         ; keep a copy in D2
        ANDI.L    #$FF,D1       ; isolate the data (last btye)
        MOVE.L    A3,OUT_CURR_A ; update the output address

        TST       D1            ; 0 is actually 8 here, so if it's 0, change
                                ; it to 8, otherwise skip it
        BNE       MOVEQ_ZERO_IS_EIGHT

        MOVE.B    #8,D1

MOVEQ_ZERO_IS_EIGHT

        JSR       PRINT_NUM     ; print it
        MOVE.L    D2,D1         ; move old data back

        * print destination ( always a Dn )
        MOVE.B    #',',(A3)+
        MOVE.B    #'D',(A3)+
        MOVE.W    D1,D2     ; make a copy of the opcode
        ANDI.W    #$E00,D2  ; isolate the register num
        LSR.W     #8,D2     ; move to end
        LSR.W     #1,D2
        ADDI.B    #$30,D2   ; add to make ascii char
        MOVE.B    D2,(A3)+  ; print

        MOVE.B    #$0A,(A3)+    ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

