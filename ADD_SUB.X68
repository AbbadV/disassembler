*------------------------------------------------------------------------------
* ADD_SUB
*
* this handles disassembling and printing a single ADD_SUB opcode
*
*------------------------------------------------------------------------------

ADD_SUB
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
        MOVEA.L   OUT_CURR_A,A3  ; move the current output pointer to A3
        LEA       ADD_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ADD_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADD_STR

ADD_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADD_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADD_COPY      ; do it again
        
ADD_DONE

        * I never noticed that the direction is a single bit, the opcode
        * chart and the manual make it look like the direction and size are
        * combined into a single 3-bit section.
        
        * It's pretty late in the project and I'm scared to change anything
        * so I'm keeping it
  
        * D5 = direction ( 0 = <ea> to Dn, 1 = Dn to <ea> )

        MOVE.W    D1,D2   ; isolate the important bits
        LSR.W     #6,D2
        ANDI.W    #7,D2

        CMP.W     #0,D2   ; if it's 0-2, it's <ea> to Dn
        BEQ       ADD_DN
        CMP.W     #1,D2
        BEQ       ADD_DN
        CMP.W     #2,D2
        BEQ       ADD_DN

        CMP.W     #4,D2   ; if it's 4-6, it's Dn to <ea>
        BEQ       ADD_EA
        CMP.W     #5,D2
        BEQ       ADD_EA
        CMP.W     #6,D2
        BEQ       ADD_EA
        
        * if nothing is found just jump to the end
        BRA       ADD_PARAM_DONE

ADD_DN
        MOVE.B    #0,D5   ; store the direction in D5
        BRA       ADD_PARAM_DONE

ADD_EA
        MOVE.B    #1,D5
        BRA       ADD_PARAM_DONE

ADD_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        JSR       PRINT_SIZE_LATE_SUB   ; different commands store the size
                                        ; in different places, this command
                                        ; uses the "late" position
                                        ; i.e., towards the end of the command

        MOVE.B    #9,(A3)+              ; print a tab after the size

        * -------------------
        * check the direction
        * -------------------

        TST.B     D5                    ; check which direction we're going
        BEQ       ADD_EA_DN
        JSR       ADD_DN_TO_EA          ; if D5 == 1, use dn->ea
        BRA       ADD_END

ADD_EA_DN
        JSR       ADD_EA_TO_DN          ; if D5 == 0, use ea->dn

ADD_END

        MOVE.B    #$0A,(A3)+            ; print a newline
        MOVE.B    #$0D,(A3)+

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
ADD_EA_TO_DN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; the destination is a data-register
        MOVE.B    #'D',(A3)+          ; so print a D after the comma
        MOVE.W    D1,D2               ; make a copy of the opcode
        LSR.W     #8,D2               ; isolate the register number
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #'0',D2             ; add '0' to make it an ascii digit
        MOVE.B    D2,(A3)+            ; print the digit

        RTS
*------------------------------------------------------------------------------
ADD_DN_TO_EA

        MOVE.B    #'D',(A3)+          ; the source is data-register, so print D
        MOVE.W    D1,D2               ; make a copy of the opcode
        LSR.W     #8,D2               ; isolate the register number
        LSR.W     #1,D2
        ANDI.W    #7,D2
        ADDI.W    #'0',D2             ; add '0' to get the ascii digit
        MOVE.B    D2,(A3)+            ; print it with the comma
        MOVE.B    #',',(A3)+
        JSR       PRINT_SOURCE_SUB    ; the "source" is the destination here

        RTS


