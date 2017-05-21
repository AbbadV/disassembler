

* IN_CURRENT_A contains the address of the current op-code we're looking at
* and re-constructing into the command

* --------------------------------------------------------------------

ADDA_SUB
        MOVEM.L   D0-D7/A0-A6,-(SP)   ; move the old registers onto the stack

        * sets up the data registers
        *
        * A1 - the current opcode's address
        * A3 - the current position of the output
        * A4 - the location of the text for printing
        *
        * D1 - the actual opcode
        *
        MOVEA.L   #0,A1             ; clear A1 for later use 
        MOVEA.L   IN_CURR_A,A1      ; load the current opcode into a register 
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3             ; clear A3 for later use 
        MOVEA.L   OUT_CURR_A,A3     ; move the current output pointer to A3
        LEA       ADDA_STR,A4       ; move the to-be-printed string to A4

        * we need to append the string at ADDA_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDA_STR

ADDA_COPY
        TST.B     (A4)             ; test the contents of A4
        BEQ       ADDA_AONE        ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+      ; copy A4 into A3, then increment both
        BRA       ADDA_COPY        ; do it again
        
ADDA_AONE
  
        MOVE.B    #'.',(A3)+       ; push period character to output stack

        MOVE.W    D1,D2            ; copy the opcode to D2
        LSR.W     #8,D2            ; shift to right by 8
        ANDI.W    #1,D2            ; mask the unwanted bit 

        TST       D2               ; is opcode 0?
        BEQ       ADDA_WORD_AN     ; its zero, go to printing size as word
        BRA       ADDA_LONG_AN     ; its long, go to print size as long

ADDA_WORD_AN
        MOVE.B    #1,SIZE_BUFFER   ; copy 1 to size buffer
        MOVE.B    #'W',(A3)+       ; push 'W' to the output stack,increment stack pointer
        BRA       ADDA_PRINT_SIZE_DONE  ; we are done , go to print size

ADDA_LONG_AN
        MOVE.B    #2,SIZE_BUFFER        ; copy 2 to size buffer
        MOVE.B    #'L',(A3)+            ; push 'L' to output stack , increment pointer 
        BRA       ADDA_PRINT_SIZE_DONE  ; go to print size 

ADDA_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+         ; move 9 to the contents of A3 

        JSR       ADDA_EA_TO_AN    ; go to print 'An' subroutine

ADDA_END

        MOVE.B    #$0A,(A3)+        ; push Carriage return to output stack, increment stack
        MOVE.B    #$0D,(A3)+        ; push line feed to output stack,increment stack

        MOVE.L    A1,IN_CURR_A      ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A     ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS                         ; return

*------------------------------------------------------------------------------
ADDA_EA_TO_AN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; push , to the output stack and increment the stack
        MOVE.B    #'A',(A3)+          ; push "A" to output stack,increment the stack 
        MOVE.W    D1,D2               ; copy the opcode to D2
        LSR.W     #8,D2               ; shift 8 bits to right 
        LSR.W     #1,D2               ; shift 1 bit to the right
        ANDI.W    #7,D2               ; mask off the unwanted bits
        ADDI.W    #$30,D2             ; convert to ASCII
        MOVE.B    D2,(A3)+            ; output the ASCII, increment the stack

        RTS                           ; return 
