*------------------------------------------------------------------------------
* ADDI_SUB
* 
* this is the subroutine for processing the ADDI command
*------------------------------------------------------------------------------

ADDI_SUB
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
        LEA       ADDI_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ADDI_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDI_STR

ADDI_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADDI_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADDI_COPY      ; do it again
        
ADDI_DONE
        * isolate the size and direction we're working with here

        * I didn't notice until now that of the 3 bites, the first one is the
        * direction and the last 2 are the size, so this code is more 
        * complicated than it needs to be, the manual made it look line one
        * single 3-bit blob

        * but it works, and it's due in less than a week, so I'm not going to
        * risk fixing it and breaking the program

        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2   ; isolate the bits for direction/size
        LSR.W     #6,D2   ; they're merged into a single blob for some reason
        ANDI.W    #7,D2

        CMP.W     #0,D2         ; break to the appropriate size-direction pair
        BEQ       ADDI_BYTE_DN
        CMP.W     #1,D2
        BEQ       ADDI_WORD_DN
        CMP.W     #2,D2
        BEQ       ADDI_LONG_DN

        CMP.W     #4,D2
        BEQ       ADDI_BYTE_EA
        CMP.W     #5,D2
        BEQ       ADDI_WORD_EA
        CMP.W     #6,D2
        BEQ       ADDI_LONG_EA
        
        * if nothing is found just jump to the end
        BRA       ADDI_PARAM_DONE

ADDI_BYTE_DN              ; figure out the data in the
        MOVE.B    #0,D4
        MOVE.B    #0,D5
        BRA       ADDI_PARAM_DONE

ADDI_WORD_DN
        MOVE.B    #1,D4
        MOVE.B    #0,D5
        BRA       ADDI_PARAM_DONE

ADDI_LONG_DN
        MOVE.B    #2,D4
        MOVE.B    #0,D5
        BRA       ADDI_PARAM_DONE

ADDI_BYTE_EA
        MOVE.B    #0,D4
        MOVE.B    #1,D5
        BRA       ADDI_PARAM_DONE
        
ADDI_WORD_EA
        MOVE.B    #1,D4
        MOVE.B    #1,D5
        BRA       ADDI_PARAM_DONE

ADDI_LONG_EA
        MOVE.B    #2,D4
        MOVE.B    #1,D5
        BRA       ADDI_PARAM_DONE

ADDI_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        MOVE.B    #'.',(A3)+            ; print the period right before the size
        CMP.B     #0,D4                 ; print the correct size
        BEQ       ADDI_PRINT_SIZE_BYTE
        CMP.B     #1,D4
        BEQ       ADDI_PRINT_SIZE_WORD
        CMP.B     #2,D4
        BEQ       ADDI_PRINT_SIZE_LONG

        BRA       ADDI_PRINT_SIZE_DONE  ; if there's an invalid size just stop

ADDI_PRINT_SIZE_BYTE
        MOVE.B    #'B',(A3)+            ; print a B for byte
        BRA       ADDI_PRINT_SIZE_DONE
ADDI_PRINT_SIZE_WORD
        MOVE.B    #'W',(A3)+            ; print a W
        BRA       ADDI_PRINT_SIZE_DONE
ADDI_PRINT_SIZE_LONG
        MOVE.B    #'L',(A3)+            ; print an L (a L?, English is odd)
        BRA       ADDI_PRINT_SIZE_DONE

ADDI_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+              ; the source is an immediate value
        MOVE.B    #'#',(A3)+            ; so print a tab, than a #$
        MOVE.B    #'$',(A3)+

        * --------------------
        * print address number
        * --------------------
        CMP.B     #2,D4       ; if we're using long addressing, get next long
        BEQ       ADDI_PRINT_AL
        JSR       ADDI_PRINT_ADDR_WORD
        BRA       ADDI_PRINT_ADDR_DONE

ADDI_PRINT_AL
        JSR       ADDI_PRINT_ADDR_LONG  ; get and print the next 
                                        ; long in the data

ADDI_PRINT_ADDR_DONE

        MOVE.B    #',',(A3)+            ; print the comma between arguments

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here

ADDI_END

        MOVE.B    #$0A,(A3)+    ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* ADDI_EA_TO_DN
*
* print the arguments if we're moving data from an effective address to a
* data register
*
* this subroutine is no longer used as far as I can tell, but I'm too scared
* actually change any code this late in the project, so I'm leaving it in
*------------------------------------------------------------------------------
ADDI_EA_TO_DN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; the destination is always a D
        MOVE.B    #'D',(A3)+          ; so print the comma and
        MOVE.W    D1,D2
        LSR.W     #8,D2
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #$30,D2
        MOVE.B    D2,(A3)+

        RTS

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* ADDI_PRINT_ADDR_WORD
*
* 
*------------------------------------------------------------------------------
ADDI_PRINT_ADDR_WORD
        MOVEM.L   D1,-(SP) ; move the old D1 onto the stack

        CLR.L     D1            ; clear D1 (we'll fix it later)
        MOVE.W    (A1)+,D1      ; move the next word into D1
        MOVE.L    A3,OUT_CURR_A ; update the output pos before we print
        JSR       PRINT_NUM     ; print the number in D1

        MOVEM.L   (SP)+,D1 ; move the old D1 back to the stack
        RTS
*------------------------------------------------------------------------------
ADDI_PRINT_ADDR_LONG
        MOVEM.L   D1,-(SP) ; move the old D1 onto the stack

        CLR.L     D1            ; clear D1 (we'll fix it later)
        MOVE.W    (A1)+,D1      ; move the next word into D1
        MOVE.L    (A1)+,D1      ; move the next word into D1
        MOVE.L    A3,OUT_CURR_A ; update the output pos before we print
        JSR       PRINT_NUM     ; print the number in D1

        MOVEM.L   (SP)+,D1 ; move the old D1 back to the stack
        RTS
