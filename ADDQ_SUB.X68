*------------------------------------------------------------------------------
* ADDQ_SUB
*
* this is responsible for disassembling and printing a single ADDQ command
*
* the 68K assembler (or at least the one we've been using in class) will
* automatically convert ADD commands to ADDQ if it can, so sometimes ADD
* commands will turn into ADDQ.
*
*------------------------------------------------------------------------------

ADDQ_SUB
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
        LEA       ADDQ_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ADDQ_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDQ_STR

ADDQ_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADDQ_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADDQ_COPY      ; do it again
        
ADDQ_DONE
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2
        LSR.W     #6,D2
        ANDI.W    #7,D2

        CMP.W     #0,D2
        BEQ       ADDQ_BYTE_DN
        CMP.W     #1,D2
        BEQ       ADDQ_WORD_DN
        CMP.W     #2,D2
        BEQ       ADDQ_LONG_DN

        CMP.W     #4,D2
        BEQ       ADDQ_BYTE_EA
        CMP.W     #5,D2
        BEQ       ADDQ_WORD_EA
        CMP.W     #6,D2
        BEQ       ADDQ_LONG_EA
        
        * if nothing is found just jump to the end
        BRA       ADDQ_PARAM_DONE

ADDQ_BYTE_DN
        MOVE.B    #0,D4
        MOVE.B    #0,D5
        BRA       ADDQ_PARAM_DONE

ADDQ_WORD_DN
        MOVE.B    #1,D4
        MOVE.B    #0,D5
        BRA       ADDQ_PARAM_DONE

ADDQ_LONG_DN
        MOVE.B    #2,D4
        MOVE.B    #0,D5
        BRA       ADDQ_PARAM_DONE

ADDQ_BYTE_EA
        MOVE.B    #0,D4
        MOVE.B    #1,D5
        BRA       ADDQ_PARAM_DONE
        
ADDQ_WORD_EA
        MOVE.B    #1,D4
        MOVE.B    #1,D5
        BRA       ADDQ_PARAM_DONE

ADDQ_LONG_EA
        MOVE.B    #2,D4
        MOVE.B    #1,D5
        BRA       ADDQ_PARAM_DONE

ADDQ_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        MOVE.B    #'.',(A3)+
        CMP.B     #0,D4
        BEQ       ADDQ_PRINT_SIZE_BYTE
        CMP.B     #1,D4
        BEQ       ADDQ_PRINT_SIZE_WORD
        CMP.B     #2,D4
        BEQ       ADDQ_PRINT_SIZE_LONG

        BRA       ADDQ_PRINT_SIZE_DONE

ADDQ_PRINT_SIZE_BYTE
        MOVE.B    #'B',(A3)+
        BRA       ADDQ_PRINT_SIZE_DONE
ADDQ_PRINT_SIZE_WORD
        MOVE.B    #'W',(A3)+
        BRA       ADDQ_PRINT_SIZE_DONE
ADDQ_PRINT_SIZE_LONG
        MOVE.B    #'L',(A3)+
        BRA       ADDQ_PRINT_SIZE_DONE

ADDQ_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+            ; the source is always an immediate value
        MOVE.B    #'#',(A3)+          ; so print a tab, than a #$
        MOVE.B    #'$',(A3)+

        JSR       ADDQ_PRINT_NUM      ; print the number
        MOVE.B    #',',(A3)+          ; print the comma
        JSR       PRINT_SOURCE_SUB    ; the "source" is the destination here

ADDQ_END

        MOVE.B    #$0A,(A3)+    ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* ADDQ_PRINT_NUM
*
* isolate and print the number we're adding somewhere
*------------------------------------------------------------------------------
ADDQ_PRINT_NUM
        MOVEM.L   D1,-(SP) ; move the old registers onto the stack

        LSR.W     #8,D1
        LSR.W     #1,D1
        AND.L     #7,D1   ; isolate the number part of the opcode

        TST.W     D1      ; if the number is 0, print an 8 and not a 0
        BNE       ADDQ_ZERO_IS_EIGHT  ; otherwise we skip the next line

        * probably skip this line
        MOVE.B    #8,D1
        * it's usually not 8 (87.5% of the time)

ADDQ_ZERO_IS_EIGHT

        MOVE.L    A3,OUT_CURR_A ; update the output pos before we print
        JSR       PRINT_NUM     ; print the number in D1 (the number)

        MOVEM.L   (SP)+,D1 ; move the old registers back to the stack
        RTS
