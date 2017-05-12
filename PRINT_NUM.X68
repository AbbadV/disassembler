* -----------------------------------------------------------------------------
* this converts the number in D1, converts it to ASCII, and prints it to the
* output
*
* note: you MUST run 
*     MOVE.L   A3,OUT_CURR_A
* before running this command
* -----------------------------------------------------------------------------
PRINT_NUM
        MOVEM.L     D0-D7/A1-A2/A4-A6,-(SP)
        MOVEA.L     OUT_CURR_A,A3
        LEA         PRINT_NUM_STACK,A5
        MOVE.W      #0,D3  ; D3 is our counter
                        ; like the i in "for(int i=0;i<9;i++)"

        * get the last digit into D2
PRINT_NUM_LOOP1
        MOVE.L      D1,D2
        LSR.L       #4,D1
        ANDI.L      #$F,D2
        JSR         PRINT_NUM_CONV
        MOVE.B      D2,(A5)+ ; push onto temporary stack
        ADDI.W      #1,D3
        TST.L       D1      ; if the next digit is a 0, stop
        BEQ         PRINT_NUM_LOOP1_END
        BRA         PRINT_NUM_LOOP1

PRINT_NUM_LOOP1_END

PRINT_NUM_LOOP2
        TST.W       D3
        BEQ         PRINT_NUM_LOOP2_END ; stop once we print all out numbers
        MOVE.B      -(A5),(A3)+         ; add our number to our output
        SUBI.W      #1,D3
        BRA         PRINT_NUM_LOOP2
      
PRINT_NUM_LOOP2_END

        MOVE.L      A3,OUT_CURR_A
        MOVEM.L     (SP)+,D0-D7/A1-A2/A4-A6
        RTS

* -----------------------------------------------------------------------------
PRINT_NUM_CONV
        CMP.B       #9,D2
        BLS         PRINT_NUM_CONV_DIG    ; BLS because we want to ignore +/-
        ADDI.B      #$37,D2   ; it's a digit A-F, add the right number and RTS
        RTS

PRINT_NUM_CONV_DIG
        ADDI.B      #$30,D2   ; it's a digit 0-9, add the right number and RTS
        RTS
* -----------------------------------------------------------------------------

* PRINT_NUM_STACK DS.B  8
