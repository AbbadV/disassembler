* ------------------------------------------------------------------------------
* PRINT_SIZE_EARLY_SUB
*
* prints the size of the command, for commands that store the size here:
*
*           0 1 0 1   0 1 0 1   0 1 0 1   0 1 0 1
*               --- 
*
* also updates the SIZE_BUFFER, because PRINT_SOURCE and PRINT_DEST need that
* ------------------------------------------------------------------------------

* ------------------------------------------
* THIS CHANGES SIZE_BUFFER TO STORE THE SIZE
* 0 = Byte
* 1 = Word
* 2 = Long
* ------------------------------------------

PRINT_SIZE_EARLY_SUB

          * we want to modify A3 (it's like a pass-by-reference parameter)
          * so we skip A3
          MOVEM.L   D0-D1/D3-D7/A0-A2/A4-A6,-(SP)

          * D1 stores the opcode, so we isolate the size info and shift it
          * to the end
          ANDI.W    #$3000,D1
          LSR.W     #8,D1
          LSR.W     #4,D1

          * we always print the period
          MOVE.B    #'.',(A3)+

          * switch to the correct subroutine
          CMP.B     #1,D1
          BEQ       PRINT_SIZE_EARLY_BYTE
          CMP.B     #3,D1
          BEQ       PRINT_SIZE_EARLY_WORD
          CMP.B     #2,D1
          BEQ       PRINT_SIZE_EARLY_LONG

PRINT_SIZE_EARLY_BYTE
          MOVE.B    #0,SIZE_BUFFER
          MOVE.B    #'B',(A3)+
          BRA       PRINT_SIZE_EARLY_END

PRINT_SIZE_EARLY_WORD
          MOVE.B    #1,SIZE_BUFFER
          MOVE.B    #'W',(A3)+
          BRA       PRINT_SIZE_EARLY_END

PRINT_SIZE_EARLY_LONG
          MOVE.B    #2,SIZE_BUFFER
          MOVE.B    #'L',(A3)+
          BRA       PRINT_SIZE_EARLY_END

PRINT_SIZE_EARLY_END
          * print a tab and return
          MOVE.B    #9,(A3)+

          MOVEM.L   (SP)+,D0-D1/D3-D7/A0-A2/A4-A6
          RTS
