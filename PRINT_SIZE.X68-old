* ----------------------------------
* THIS CHANGES D2 TO STORE THE SIZE
* 0 = Byte
* 1 = Word
* 2 = Long
* ----------------------------------

PRINT_SIZE_SUB

          * we want to modify A3 (it's like a pass-by-reference parameter)
          * so we skip A3
          MOVEM.L   D0-D1/D3-D7/A0-A2/A4-A6,-(SP)

          * D1 stores the opcode, so we isolate the size info and shift it
          * to the end
          ANDI.W    #$3000,D1
          LSR.W     #8,D1
          LSR.W     #4,D1

          * we always print the period (2E in ASCII)
          MOVE.B    #$2E,(A3)+

          * switch to the correct subroutine
          CMP.B     #1,D1
          BEQ       PRINT_SIZE_BYTE
          CMP.B     #3,D1
          BEQ       PRINT_SIZE_WORD
          CMP.B     #2,D1
          BEQ       PRINT_SIZE_LONG

PRINT_SIZE_BYTE
          MOVE.B    #0,D2
          MOVE.B    #$42,(A3)+
          BRA       PRINT_SIZE_END

PRINT_SIZE_WORD
          MOVE.B    #1,D2
          MOVE.B    #$57,(A3)+
          BRA       PRINT_SIZE_END

PRINT_SIZE_LONG
          MOVE.B    #2,D2
          MOVE.B    #$4C,(A3)+
          BRA       PRINT_SIZE_END

PRINT_SIZE_END
          * print a tab and return
          MOVE.B    #9,(A3)+

          MOVEM.L   (SP)+,D0-D1/D3-D7/A0-A2/A4-A6
          RTS
