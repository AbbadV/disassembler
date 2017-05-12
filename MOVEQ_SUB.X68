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

MOVEQ_SUB
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
        LEA       MOVEQ_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at MOVEQ_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in MOVEQ_STR

MOVEQ_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       MOVEQ_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       MOVEQ_COPY      ; do it again
        
MOVEQ_DONE

        MOVE.B    #'.',(A3)+    ; print the size (it's always a .L)
        MOVE.B    #'L',(A3)+
        MOVE.B    #$09,(A3)+

        * print the source ( a single bit of data )
        MOVE.B    #'#',(A3)+
        MOVE.B    #'$',(A3)+
        MOVE.L    D1,D2       ; keep a copy in D2
        ANDI.L    #$FF,D1     ; isolate the data (last btye)
        MOVE.L    A3,OUT_CURR_A
        JSR       PRINT_NUM   ; print it
        MOVE.L    D2,D1       ; move old data back

        * print destination ( always a Dn )
        MOVE.B    #',',(A3)+
        MOVE.B    #'D',(A3)+
        MOVE.W    D1,D2     ; make a copy of the opcode
        ANDI.W    #$E00,D2  ; isolate the register num
        LSR.W     #8,D2     ; move to end
        LSR.W     #1,D2
        ADDI.B    #$30,D2   ; add to make ascii char
        MOVE.B    D2,(A3)+  ; print

        MOVE.B    #$0A,(A3)+
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------

