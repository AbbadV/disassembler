*------------------------------------------------------------------------------
* This is a skeleton to help write all the _SUP files
*
* basically here's how they all work:
*
* IN_CURRENT_A contains the address of the current op-code we're looking at
* and re-constructing into the command
*
* right after it are any immediate values and/or addresses in the command
*
* --------------------------------------------------------------------
* YOU ARE RESPONSIBLE FOR MOVING IN_CURRENT_A OVER TO THE NEXT COMMAND
* --------------------------------------------------------------------
*
* to output the text, push the characters onto the output stack with
*
*   MOVE.B  $__,(A3)+
* 
* also, replace MOVE with the name of the command, all variables and labels are
* global in assembly, so each one has to be 100% unique
*
* things like
*
*     void func()
*     {
*       int NAME = 5;
*     }
*
*     int NAME = 2;
*     func();
*
* don't work here
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
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       MOVEM_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVEM_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVEM_STR

MOVEM_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       MOVEM_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MOVEM_COPY      ; do it again
        
MOVEM_DONE

        * print the size (determined by this bit 0000 0000 0100 0000)
        *                ( 0 = word, 1 = long)
        MOVE.B    #'.',(A3)+
        MOVE.B    D1,D2
        ANDI.B    #$40,D2
        LSR.B     #6,D2
        TST.B     D2
        BEQ       MOVEM_SIZE_W
        MOVE.B    #'L',(A3)+
        BRA       MOVEM_DIRECTION

MOVEM_SIZE_W
        MOVE.B    #'W',(A3)+

MOVEM_DIRECTION
        MOVE.B    #9,(A3)+

        MOVE.W    D1,D2
        ANDI.W    #$400,D2
        LSR.W     #8,D2
        LSR.W     #2,D2
        TST.B     D2
        BEQ       MOVEM_RTM
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

MOVEM_REG_TO_MEM
        MOVE.W    (A1)+,D4      ; D4 is the next word (which registers to move)
        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

MOVEM_REG_TO_MEM_D_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     #8,D6
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_TO_MEM_D_SKIP

        MOVE.B    #'D',(A3)+    ; print a D
        MOVE.B    #'7',D7       ; start with ASCII 7
        SUB.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_TO_MEM_D_SKIP
        TST.B     D5
        BEQ       MOVEM_REG_TO_MEM_D_DONE
        BRA       MOVEM_REG_TO_MEM_D_LOOP

MOVEM_REG_TO_MEM_D_DONE

        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

MOVEM_REG_TO_MEM_A_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_REG_TO_MEM_A_SKIP

        MOVE.B    #'A',(A3)+    ; print a A
        MOVE.B    #'7',D7       ; start with ASCII 7
        SUB.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_REG_TO_MEM_A_SKIP
        TST.B     D5
        BEQ       MOVEM_REG_TO_MEM_A_DONE
        BRA       MOVEM_REG_TO_MEM_A_LOOP

MOVEM_REG_TO_MEM_A_DONE

        * we just printed the list of D0-D7/A0-A7, now we print the register
        MOVE.B    #',',-(A3)    ; overwrite the last /
        MOVE.B    #',',(A3)+

        JSR   PRINT_SOURCE_SUB ; it's not technically the source, but it's in
                               ; it's place, so just roll with it
        RTS

* -----------------------------------------------------------------------------


MOVEM_MEM_TO_REG
        JSR   PRINT_SOURCE_SUB ; it's not technically the source, but it's in
                               ; it's place, so just roll with it
        MOVE.B    #',',(A3)+

        MOVE.W    (A1)+,D4      ; D4 is the next word (which registers to move)
        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

MOVEM_MEM_TO_REG_A_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     #8,D6
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_MEM_TO_REG_A_SKIP

        MOVE.B    #'A',(A3)+    ; print a A
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_MEM_TO_REG_A_SKIP
        TST.B     D5
        BEQ       MOVEM_MEM_TO_REG_A_DONE
        BRA       MOVEM_MEM_TO_REG_A_LOOP

MOVEM_MEM_TO_REG_A_DONE

        MOVE.B    #8,D5         ; D5 is our counter (it starts at 8)

MOVEM_MEM_TO_REG_D_LOOP
        SUBI.B    #1,D5         ; pre-decrement our counter

        MOVE.W    D4,D6         ; isolate the current bit
        LSR.W     D5,D6
        ANDI.B    #1,D6
        TST.B     D6            ; if it's 0, that register's not present
                                ; so skip
        BEQ       MOVEM_MEM_TO_REG_D_SKIP

        MOVE.B    #'D',(A3)+    ; print a D
        MOVE.B    #'0',D7       ; start with ASCII 7
        ADD.B     D5,D7         ; subtract to get the real ASCII char
        MOVE.B    D7,(A3)+      ; print it
        MOVE.B    #'/',(A3)+

MOVEM_MEM_TO_REG_D_SKIP
        TST.B     D5
        BEQ       MOVEM_MEM_TO_REG_D_DONE
        BRA       MOVEM_MEM_TO_REG_D_LOOP

MOVEM_MEM_TO_REG_D_DONE


        * we just printed the list of D0-D7/A0-A7, now we print the register
        MOVE.B    #$FF,-(A3)    ; backspace the last /

        RTS

