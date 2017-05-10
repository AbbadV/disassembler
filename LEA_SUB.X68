LEA_SUB
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
        LEA       LEA_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ###_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ###_STR

LEA_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       LEA_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       LEA_COPY      ; do it again
        
LEA_DONE 
         JSR      PRINT_SOURCE_SUB
         MOVE.B   $2C,(A3)+        ; print comma 
         CLR.L    D3                ; clear d3 for later use 
         MOVE.W   D1,D3           ;copy An to D3
         ANDI.L   #$0D00,D3        ; mask off the non address reg bits
         LSR.W    #$08,D3           ; shift 8 bits left 
         LSR.W    #$01,D3           ; shift additional 1 bit  
         ADDI.W   #30,D3             ; convert to ASCII
         MOVE.B   D3,(A3)+          ; print the n in An

         *JSR      PRINT_DEST_SUB
         

        * ----------------------------------------------------
        * ----------------------------------------------------
        *
        * At this point the name is printed and nothing else
        *
        * most if not all of your code is going to go here
        
        *
        * ----------------------------------------------------
        * ----------------------------------------------------

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------


    SIMHALT             ; halt simulator
    

* Put variables and constants here

    END    START        ; last line of source
