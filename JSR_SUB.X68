JSR_SUB
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
        LEA       JSR_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

JSR_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       JSR_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       JSR_COPY      ; do it again
        
JSR_DONE

        MOVE.B    #9,(A3)+      ;print tab character 
        MOVE.B    #'$',(A3)+    ;print '$' character

        MOVE.L D1,D4            ;copy actual op code to D4
        MOVE.L  #0,D3           ;clear D3 for later use
        
        AND #1,D4               ;mask off unwanted bits
        CMP #0,D4               ; check if D4 is zero
        BEQ JSR_ABSW            ; go to JSR_ABSW if it is 0
        
JSR_ABSL        JSR JSR_GETBYTE   ; go to JSR_GETBYTE
                  ADDQ.B    #1,D3   ;increment D3
                  CMP.B     #4,D3    ; check if D3 is 4
                  BNE   JSR_ABSL     ; do the loop again if d3 is not 4
                  BRA JSR_FINISH     ; jump to printing output

JSR_ABSW    JSR JSR_GETBYTE
                  ADDQ.B    #1,D3       ; increment D3 by 1
                  CMP.B     #2,D3       ; is d3 2?
                  BNE   JSR_ABSW        ; not 3 , loop again
                  BRA JSR_FINISH        ; jump to printing output
                                
JSR_GETBYTE
    MOVE.B  (A1)+,D5            ; copy A1 to D5 and increment A1
    MOVE.B  D5,D6               ; copy D5 to D6
    AND.B   #$F0,D6             ; mask off unwanted bits
    LSR.B   #4,D6               ; shift right by 4
    JSR JSR_CONVERT             ; jump to convert ASCII to hex
    MOVE.B  D6,(A3)+            ; print d6 and increment output pointer
    MOVE.B  D5,D6               ; copy d5 to d6 
    AND.B   #$F,D6              ; mask off unwanted bits
    JSR JSR_CONVERT             ; convert to hex 
    MOVE.B  D6,(A3)+            ;print D6 and increment output pointer
    RTS
JSR_CONVERT
    CMP.B   #10,D6              ; check if D6 is a digit 
    BLT JSR_DIGIT               ; d6 is a digit , jump to digit converter 
    ADD.B   #$37,D6             ; convert letter to hex 
    RTS                         ; return
JSR_DIGIT                        
    ADD.B #$30,D6               ; convert number to hex
    RTS                         ; return

JSR_FINISH
        MOVE.B  #$A,(A3)+       ; print line feed
        MOVE.B  #$D,(A3)+       ; print carriage return
        
        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
