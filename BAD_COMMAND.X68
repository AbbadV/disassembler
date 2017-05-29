* ------------------------------------------------------------------------------
* BAD_COMMAND_SUB
* VERSION 1 (23 APR 2017)
* Written by James Winters
*
* This is the subroutine responsible for printing   DATA $0123
* if the opcode is not recognized as a valid command
* ------------------------------------------------------------------------------

BAD_COMMAND_SUB
        MOVEM.L   D0-D7/A0-A6,-(SP) ; move the old registers onto the stack

        MOVEA.L   #0,A1             ; load the current opcode into a register
        MOVEA.L   IN_CURR_A,A1
        MOVE.W    (A1)+,D1

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       BAD_COMMAND_STR,A4 ; move the to-be-printed string to A4

        * we need to append the string at NOP_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in NOP_STR

        * the code is invalid of we find a bad command
        MOVE.B    #0,IS_VALID

BCMD_COPY
        TST.B     (A4)  ; test the contents of A4
        BEQ       BCMD_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       BCMD_COPY     ; do it again

BCMD_DONE

        * convert the opcode into ASCII
        * digit 1
        MOVE.W    D1,D2
        LSR.W     #8,D2           ; get the first digit all on it's own
        LSR.W     #4,D2
        ANDI.W    #$F,D2
        JSR       DIGIT_TO_ASCII  ; convert it to ASCII
        MOVE.B    D2,(A3)+        ; print it

        * digit 2
        MOVE.W    D1,D2
        LSR.W     #8,D2           ; get the second digit all on it's own
        ANDI.W    #$F,D2
        JSR       DIGIT_TO_ASCII  ; convert it to ASCII
        MOVE.B    D2,(A3)+        ; print it

        * digit 3
        MOVE.W    D1,D2
        LSR.W     #4,D2   ; get the third digit all on it's own
        ANDI.W    #$F,D2
        JSR       DIGIT_TO_ASCII  ; convert it to ASCII
        MOVE.B    D2,(A3)+        ; print it

        * digit 4
        MOVE.W    D1,D2
        ANDI.W    #$F,D2  ; get the last digit all on it's own
        JSR       DIGIT_TO_ASCII  ; convert it to ASCII
        MOVE.B    D2,(A3)+        ; print it

        * print a newline
        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* DIGIT_TO_ASCII
*
* converts the number in D2 into a single ASCII digit in hex
* the result is kept in D2
*------------------------------------------------------------------------------

DIGIT_TO_ASCII

        CMP.B   #0,D2       ; if it's less than 0 or greater than 9
        BLT     BCMD_NAN    ; it's a not a number
        CMP.B   #9,D2
        BGT     BCMD_NAN

        ADDI.B  #'0',D2     ; it's 0-9, so add '0' to it to get the ascii 
        RTS

BCMD_NAN 
        ADDI.B  #$37,D2     ; it's A-F, so add 'A'-10 to get the ascii

        RTS

*------------------------------------------------------------------------------
