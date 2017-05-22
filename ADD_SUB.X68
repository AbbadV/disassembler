

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
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3             ; clear A3 for later use 
        MOVEA.L   OUT_CURR_A,A3     ; move the current output pointer to A3
        LEA       ADD_STR,A4        ; move the to-be-printed string to A4

        * we need to append the string at ADD_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADD_STR

ADD_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADD_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADD_COPY      ; do it again
        
ADD_DONE
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)

        MOVE.W    D1,D2         ; copy the actual op code to D2
        LSR.W     #6,D2         ; shift right 6 bits 
        ANDI.W    #7,D2         ; mask off unwanted bits to get opmode bits 

        CMP.W     #0,D2         ; is opmode 0?
        BEQ       ADD_DN        ; its 0, we are adding Dn 
        CMP.W     #1,D2         ; is opmode 1
        BEQ       ADD_DN        ; its 1, we are adding Dn
        CMP.W     #2,D2         ; is opmode 2
        BEQ       ADD_DN        ; its 2 , we are adding Dn

        CMP.W     #4,D2         ;is opmode ?
        BEQ       ADD_EA        ; we are adding <ea>
        CMP.W     #5,D2         ; is opmode 0?
        BEQ       ADD_EA        ; we are adding <ea>
        CMP.W     #6,D2         ; is opmode 0?
        BEQ       ADD_EA        ; we are adding <ea>
        
        * if nothing is found just jump to the end
        BRA       ADD_PARAM_DONE

ADD_DN
        MOVE.B    #0,D5         ; copy 0 to direction , dn first
        BRA       ADD_PARAM_DONE ; we are done , go to print 

ADD_EA
        MOVE.B    #1,D5         ;copy 1 to direction, <ea> first
        BRA       ADD_PARAM_DONE ; we are done , go to print 


ADD_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        JSR       PRINT_SIZE_LATE_SUB    ; jump to printing size 

        MOVE.B    #9,(A3)+              ; push tab to output stack

        * -------------------
        * check the direction
        * -------------------

        TST.B     D5                    ; is direction 0?
        BEQ       ADD_EA_DN             ; its zero, its ea first
        JSR       ADD_DN_TO_EA          ; its not zero, its Dn first
        BRA       ADD_END               ; go to print CR,LF

ADD_EA_DN
        JSR       ADD_EA_TO_DN          ; jump to adding ea to dn

ADD_END

        MOVE.B    #$0A,(A3)+            ; push carriage return to output stack
        MOVE.B    #$0D,(A3)+            ; push line feed to output stack

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
ADD_EA_TO_DN

        JSR       PRINT_SOURCE_SUB      ; the "source" is actually the source here
        MOVE.B    #',',(A3)+            ; push comma to output stack           
        MOVE.B    #'D',(A3)+            ; push'D' to output stack
        MOVE.W    D1,D2                 ; copy op code to D2
        LSR.W     #8,D2                 ;shift right 8 bits
        LSR.W     #1,D2                 ;shift right 1 bit
        ANDI.W    #7,D2                 ; mask off thunwanted bits 
        ADDI.W    #$30,D2               ; convert to hex
        MOVE.B    D2,(A3)+              ; push to output stack

        RTS
*------------------------------------------------------------------------------
ADD_DN_TO_EA

        MOVE.B    #'D',(A3)+            ; push 'D' to output stack
        MOVE.W    D1,D2                 ; copy op code to D2
        LSR.W     #8,D2                 ; shift 8 bits right
        LSR.W     #1,D2                 ; shift 1 bit right
        ANDI.W    #7,D2                 ;mask off unwanted bits
        ADDI.W    #$30,D2               ;convert to hex
        MOVE.B    D2,(A3)+              ; push to output stack
        MOVE.B    #',',(A3)+            ; push comma to output stack
        JSR       PRINT_SOURCE_SUB      ; the "source" is actually the source here

        RTS                             return


