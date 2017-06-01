BRA_SUB
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
        MOVEA.L   IN_CURR_A,A1      ; move the current input pointer to A1
        MOVEQ.L  #$0,D3
        MOVE.W  A1,D3               ; move the current op code address to D3
        ADDQ.W  #2,D3               ; increment D3 by 2
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3             ; clear A3 for later use
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       BRA_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

BRA_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       BRA_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       BRA_COPY      ; do it again
        
BRA_DONE
        *MOVE.B  D1,D2           ; copy actual op code to D2
        
        MOVE.B  D1,D2           ; copy actual op code to D2
        AND.W   #$FF,D2         ; mask off unwanted bits         
        CMP #0,D2               ; check to see if D2 is 0
        BEQ BRA_GETWORD         ; its 0 , go to BRA_GETWORD

        MOVE.B  #'.',(A3)+
        MOVE.B  #'B',(A3)+
        MOVE.B  #$09,(A3)+
        MOVE.B  #'$',(A3)+
        MOVE.B  D1,D6           ;copy the op code to D6
        ADD.B   D3,D6           ; add d3 to d6 and store it in D6
        MOVE.B D6,D3            ;copy d6 to d3
        MOVE.L D3,D1            ;copy d3 to d1

BRA_FINISH
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        JSR PRINT_NUM
        


        
        MOVE.B  #$A,(A3)+       ; print line feed
        MOVE.B  #$D,(A3)+       ; print carriage return

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
BRA_GETWORD
        MOVE.B  #'.',(A3)+
        MOVE.B  #'W',(A3)+ 
        MOVE.B  #$09,(A3)+
        MOVE.B  #'$',(A3)+
        MOVE.L #0,D2            ; clear d2 for later use 
        MOVE.W  (A1)+,D2        ; move current op code address to D2 and increment address
        ADD.W   D3,D2           ; add d3 to d2
        MOVE.W  D2,D1           ; copy d2 to d1
        BRA BRA_FINISH          ; done here , go to printing output










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
