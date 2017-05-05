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
* also, replace ADD with the name of the command, all variables and labels are
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
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADDA_AONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADDA_COPY      ; do it again
        
ADDA_AONE
  
        MOVE.B    #'.',(A3)+

        MOVE.W    D1,D2
        LSR.W     #8,D2
        ANDI.W    #1,D2

        TST       D2
        BEQ       ADDA_WORD_AN
        BRA       ADDA_LONG_AN

ADDA_WORD_AN
        MOVE.B    #'W',(A3)+
        BRA       ADDA_PRINT_SIZE_DONE

ADDA_LONG_AN
        MOVE.B    #'L',(A3)+
        BRA       ADDA_PRINT_SIZE_DONE

ADDA_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+

        JSR       ADDA_EA_TO_AN

ADDA_END

        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
ADDA_EA_TO_AN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+
        MOVE.B    #'A',(A3)+
        MOVE.W    D1,D2
        LSR.W     #8,D2
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #$30,D2
        MOVE.B    D2,(A3)+

        RTS
