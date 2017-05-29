*------------------------------------------------------------------------------
* MOVE_SUB
*
* disassembles and prints a single MOVE command
*------------------------------------------------------------------------------

MOVE_SUB
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
        LEA       MOVE_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVE_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVE_STR

MOVE_COPY
        TST.B     (A4)       ; test the contents of A4
        BEQ       MOVE_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MOVE_COPY     ; do it again
        
MOVE_DONE
        JSR       PRINT_SIZE_EARLY_SUB  ; the size is early in this command
                                        ; so call this one (this includes
                                        ; the tab after it)
        JSR       PRINT_SOURCE_SUB      ; print the source
        MOVE.B    #',',(A3)+            ; print the comma between them
        JSR       PRINT_DEST_SUB        ; print the destination
        MOVE.B    #$0A,(A3)+            ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

