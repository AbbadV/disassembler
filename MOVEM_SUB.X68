*------------------------------------------------------------------------------
* MOVEM_SUB
*
* disassembles and prints a single MOVEM command
*------------------------------------------------------------------------------

MOVEM_SUB
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
        MOVEA.L   OUT_CURR_A,A3    ; move the current output pointer to A3
        LEA       MOVEM_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVEM_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVEM_STR

MOVEM_COPY
        TST.B     (A4)        ; test the contents of A4
        BEQ       MOVEM_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MOVEM_COPY    ; do it again
        
MOVEM_DONE

        * print the size (determined by this bit 0000 0000 0100 0000)
        *                ( 0 = word, 1 = long)
        MOVE.B    #'.',(A3)+        ; print the period
        MOVE.B    D1,D2             ; make a copy of the opcode
        ANDI.B    #$40,D2
        LSR.B     #6,D2
        TST.B     D2                ; if the important bit's 0 (W)
        BEQ       MOVEM_SIZE_W      ; print a W
        MOVE.B    #'L',(A3)+        ; othereise, print a L
        MOVE.B    #2,SIZE_BUFFER    ; either way, update SIZE_BUFFER
        BRA       MOVEM_DIRECTION   ; PRINT_SOURCE needs it

MOVEM_SIZE_W
        MOVE.B    #'W',(A3)+
        MOVE.B    #1,SIZE_BUFFER

MOVEM_DIRECTION
        MOVE.B    #9,(A3)+          ; print the tab

        MOVE.W    D1,D2             ; make a copy of the opcode
        ANDI.W    #$400,D2          ; isolate the bit that tells us what
        LSR.W     #8,D2             ; direction we're goint
        LSR.W     #2,D2
        TST.B     D2
        BEQ       MOVEM_RTM         ; if it's 0, move from registers to memory
        JSR       MOVEM_MEM_TO_REG
        BRA       MOVEM_END
        
MOVEM_RTM
        JSR       MOVEM_REG_TO_MEM

MOVEM_END
        * -----------------
        * print the newline
        * -----------------
        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* MOVEM_REG_TO_MEM
*
* print the arguments if we're moving from registers to memory
*------------------------------------------------------------------------------

MOVEM_REG_TO_MEM
        MOVE.W    (A1)+,D4      ; D4 is the next word (which registers to move)
        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

        JSR   MOVEM_PRINT_REGISTER_LIST

        MOVE.B    #',',(A3)+

        JSR   PRINT_SOURCE_SUB ; it's not technically the source, but it's in
                               ; it's place, so just roll with it
        RTS

* -----------------------------------------------------------------------------

* -----------------------------------------------------------------------------
* MOVEM_MEM_TO_REG
*
* print the arguments if we're moving from memory to registers
* -----------------------------------------------------------------------------


MOVEM_MEM_TO_REG
        MOVE.W    (A1)+,D4      ; D4 is the next word (which registers to move)
        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer

        JSR   PRINT_SOURCE_SUB ; it's not technically the source, but it's in
                               ; it's place, so just roll with it

        MOVE.B    #',',(A3)+

        JSR   MOVEM_PRINT_REGISTER_LIST

        RTS

* -----------------------------------------------------------------------------

* -----------------------------------------------------------------------------
* MOVEM_PRINT_REGISTER_LIST
*
* print the registers separated by a / (so A7/A6/A5/D7/D1  etc.)
* -----------------------------------------------------------------------------

MOVEM_PRINT_REGISTER_LIST

        * -------------------------------------------------------------------
        * we need to make check if we're doing pre-decrement
        * (the mode or bits 0038 are 100), otherwise we do the other function
        * because when doing pre-decrement the list is backwards
        * -------------------------------------------------------------------

        MOVE.W    D1,D5         ; we're using D5 as a temporary buffer
        LSR.B     #3,D5         ; isolate the mode
        AND.B     #7,D5
        CMP.B     #4,D5         ; if it's 4, we're doing -(An), so run 
                                ; the other subroutine not this one
        BNE       MOVEM_PRINT_REGISTER_NOT_PRED

        JSR       MOVEM_PRINT_REGISTER_LIST_PRED 
        RTS

MOVEM_PRINT_REGISTER_NOT_PRED

        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

        * ----------------------------
        * loop through the A registers
        * ----------------------------

MOVEM_REG_LIST_A_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     #8,D6
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_LIST_A_SKIP

        MOVE.B    #'A',(A3)+    ; print a A
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_LIST_A_SKIP
        TST.B     D5
        BEQ       MOVEM_REG_LIST_A_DONE
        BRA       MOVEM_REG_LIST_A_LOOP

MOVEM_REG_LIST_A_DONE

        * ----------------------------
        * loop through the D registers
        * ----------------------------

        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

MOVEM_REG_LIST_D_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_LIST_D_SKIP

        MOVE.B    #'D',(A3)+    ; print a D
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_LIST_D_SKIP
        TST.B     D5
        BEQ       MOVEM_REG_LIST_D_DONE
        BRA       MOVEM_REG_LIST_D_LOOP

MOVEM_REG_LIST_D_DONE

        * we just printed the list of D0-D7/A0-A7, now we're done
        MOVE.B    #$FF,-(A3)    ; backspace the last /
                                ; we use FF because that's the default
                                ; for never-written-before memory

        RTS

* -----------------------------------------------------------------------------

* -----------------------------------------------------------------------------
* MOVEM_PRINT_REGISTER_LIST_PRED
*
* print the registers separated by a / (so A7/A6/A5/D7/D1  etc.)
*
* the order is reversed if the register is pre-decremented ( -(A1) )
* -----------------------------------------------------------------------------

MOVEM_PRINT_REGISTER_LIST_PRED

        MOVE.B    #0,D5         ; D5 is our counter (it starts at 0)

        * ----------------------------
        * loop through the D registers
        * ----------------------------

MOVEM_REG_LIST_PRED_D_LOOP
        MOVE.W    D4,D6         ; isolate the current bit
        ROL.W     #1,D6
        ROL.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_LIST_PRED_D_SKIP

        MOVE.B    #'D',(A3)+    ; print a D
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_LIST_PRED_D_SKIP
        ADDI.B    #1,D5         ; increment our counter

        CMP.B     #8,D5
        BEQ       MOVEM_REG_LIST_PRED_D_DONE
        BRA       MOVEM_REG_LIST_PRED_D_LOOP

MOVEM_REG_LIST_PRED_D_DONE

        * ----------------------------
        * loop through the A registers
        * ----------------------------

        MOVE.B    #0,D5         ; D5 is our counter (it starts at 0)

MOVEM_REG_LIST_PRED_A_LOOP
        MOVE.W    D4,D6         ; isolate the current bit
        ROL.W     #8,D6
        ROL.W     #1,D6
        ROL.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_LIST_PRED_A_SKIP

        MOVE.B    #'A',(A3)+    ; print a A
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_LIST_PRED_A_SKIP
        ADDI.B    #1,D5         ; increment our counter

        CMP.B     #8,D5
        BEQ       MOVEM_REG_LIST_PRED_A_DONE
        BRA       MOVEM_REG_LIST_PRED_A_LOOP

MOVEM_REG_LIST_PRED_A_DONE

        * we just printed the list of D0-D7/A0-A7, now we're done
        MOVE.B    #$FF,-(A3)    ; backspace the last /
                                ; we use FF because that's the default
                                ; for never-written-before memory


        RTS

