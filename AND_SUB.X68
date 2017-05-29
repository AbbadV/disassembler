*------------------------------------------------------------------------------
* AND_SUB
*
* this file is responsible for disassembling and printing a single AND command
*------------------------------------------------------------------------------

AND_SUB
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
        LEA       AND_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at AND_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in AND_STR

AND_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       AND_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       AND_COPY      ; do it again
        
AND_DONE

        * the opcode table and the manual both made this look line a single
        * 3-bit blob, I never noticed that the direction is the 1st bit,
        * and the size is the other 2 bits.

        * also, the size is found later, not here

        * this code is horrible, I know, but it works and it's late in the
        * project so I don't want to change anything.

        * please forgive me
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2   ; get the right bits
        LSR.W     #6,D2
        ANDI.W    #7,D2

        CMP.W     #0,D2   ; if it's 0-2, it's Dn first
        BEQ       AND_DN
        CMP.W     #1,D2
        BEQ       AND_DN
        CMP.W     #2,D2
        BEQ       AND_DN

        CMP.W     #4,D2   ; if it's 4-6, it's <ea> first
        BEQ       AND_EA
        CMP.W     #5,D2
        BEQ       AND_EA
        CMP.W     #6,D2
        BEQ       AND_EA
        
        * if nothing is found just jump to the end
        BRA       AND_PARAM_DONE

AND_DN
        MOVE.B    #0,D5  ; move the right value into D5
        BRA       AND_PARAM_DONE

AND_EA
        MOVE.B    #1,D5
        BRA       AND_PARAM_DONE

AND_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        JSR       PRINT_SIZE_LATE_SUB   ; print the size
        MOVE.B    #9,(A3)+              ; and a tab

        * -------------------
        * check the direction
        * -------------------

        TST.B     D5                    ; check if we're doing Dn -> <ea>
        BEQ       AND_EA_DN             ; or vice versa
        JSR       AND_DN_TO_EA
        BRA       AND_END

AND_EA_DN
        JSR       AND_EA_TO_DN

AND_END

        MOVE.B    #$0A,(A3)+    ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
AND_EA_TO_DN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; the destination is a D-register
        MOVE.B    #'D',(A3)+          ; so print the comma and a D
        MOVE.W    D1,D2               ; make a copy of the opcode
        LSR.W     #8,D2               ; isolate the D-register number
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #'0',D2             ; add '0' to get the ascii digit
        MOVE.B    D2,(A3)+            ; print it

        RTS
*------------------------------------------------------------------------------
AND_DN_TO_EA

        MOVE.B    #'D',(A3)+          ; the source is a D-register, so print a D
        MOVE.W    D1,D2               ; make a copy of the opcode
        LSR.W     #8,D2               ; isolate the D-register number
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #'0',D2             ; add '0' to get the ascii digit
        MOVE.B    D2,(A3)+            ; print the number, then a comma
        MOVE.B    #',',(A3)+
        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here

        RTS


