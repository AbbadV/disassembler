*------------------------------------------------------------------------------
* ADDA_SUB
* 
* this is the subroutine for processing the ADDA command
*------------------------------------------------------------------------------

ADDA_SUB
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
        LEA       ADDA_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ADDA_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDA_STR

ADDA_COPY
        TST.B     (A4)            ; test the contents of A4
        BEQ       ADDA_DONE       ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+     ; copy A4 into A3, then increment both
        BRA       ADDA_COPY       ; do it again
        
ADDA_DONE
    
        * print the size
  
        MOVE.B    #'.',(A3)+      ; print the period between the command
                                  ; and the size

        MOVE.W    D1,D2           ; isolate the bit that has the size
        LSR.W     #8,D2
        ANDI.W    #1,D2

        TST       D2              ; if that bit's 0, it's a word, otherwise
        BEQ       ADDA_WORD_AN
        BRA       ADDA_LONG_AN    ; it's a long

ADDA_WORD_AN
        MOVE.B    #1,SIZE_BUFFER  ; PRINT_SOURCE_SUB needs to know the size
        MOVE.B    #'W',(A3)+      ; print the W
        BRA       ADDA_PRINT_SIZE_DONE

ADDA_LONG_AN
        MOVE.B    #2,SIZE_BUFFER  ; PRINT_SOURCE_SUB needs to know the size
        MOVE.B    #'L',(A3)+      ; print the L
        BRA       ADDA_PRINT_SIZE_DONE

ADDA_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+        ; print a tab between the command and its
                                  ; arguments

        JSR       ADDA_EA_TO_AN   ; print the arguments

ADDA_END

        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* ADDA_EA_TO_AN
*
* we're moving something else to an an address register, so print that
*
* This subroutine exists because we wrote ADD_SUB first, which can do either
* effective address to data register (EA_TO_DN) or vice versa (DN_TO_EA)
*
* once that worked, we just modified it to make ADDA_SUB, so there's still a
* subroutine even though there's not really a decision to make
* 
*------------------------------------------------------------------------------

ADDA_EA_TO_AN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; ptint the comma and the A
        MOVE.B    #'A',(A3)+          ; since the destination is always an An
        MOVE.W    D1,D2               ; copy the opcode
        LSR.W     #8,D2               
        LSR.W     #1,D2
        ANDI.W    #7,D2               ; isolate the bits for the dest number
        ADDI.W    #'0',D2             ; add '0' to get the ascii for the number
        MOVE.B    D2,(A3)+            ; print it

        RTS
