* -----------------------------------------------------------------------------
* PRINT_DEST_SUB
*
* prints the dest (the register, immediate value or memory location)
* which is stored here
*
*               0 1 0 1   0 1 0 1   0 1 0 1   0 1 0 1
*                         [   dest    ]
*
* this is very similar to PRINT_SOURCE_SUB, the only difference is where
* the memory bits come from
*
* so look there for more detailed comments
* -----------------------------------------------------------------------------

PRINT_DEST_SUB

          * we want to modify A3 (it's like a pass-by-reference parameter)
          * so we skip A3
          MOVEM.L   D0-D1/A0/A2/A4-A6,-(SP)

          * D1 stores the opcode, so we isolate the source info and shift it
          * to the end
          ANDI.W    #$FC0,D1

          * D2 is the mode, so isolate and shift
          MOVE.W    D1,D2
          ANDI.W    #$1C0,D2
          LSR.W     #6,D2

          * if it's not 7, it's Dn, An, (An), (An)+, etc
          CMP.B     #7,D2
          BEQ       PRINT_DEST_MEM
          JSR       PRINT_DEST_REGISTER
          BRA       PRINT_DEST_END

PRINT_DEST_MEM
          JSR       PRINT_DEST_MEMORY
          BRA       PRINT_DEST_END

PRINT_DEST_END
          MOVEM.L   (SP)+,D0-D1/A0/A2/A4-A6
          RTS

* -----------------------------------------------------------------------------

PRINT_DEST_REGISTER
          MOVE.W    D1,D3       ; copy Xn into D3
          ANDI.W    #$E00,D3    ; isolate the 3 bits that matter
          LSR.W     #8,D3
          LSR.W     #1,D3
          ADDI.W    #$30,D3     ; add to convert to ASCII

          CMP.B     #0,D2
          BEQ       PRINT_DEST_REGISTER_DN
          CMP.B     #1,D2
          BEQ       PRINT_DEST_REGISTER_AN
          CMP.B     #2,D2
          BEQ       PRINT_DEST_REGISTER_ANPAREN
          CMP.B     #3,D2
          BEQ       PRINT_DEST_REGISTER_ANPLUS
          CMP.B     #4,D2
          BEQ       PRINT_DEST_REGISTER_ANMINUS

          RTS       ; quit if nothing is found

PRINT_DEST_REGISTER_DN
          MOVE.B    #'D',(A3)+
          MOVE.B    D3,(A3)+
          RTS

PRINT_DEST_REGISTER_AN
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          RTS

PRINT_DEST_REGISTER_ANPAREN
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          RTS

PRINT_DEST_REGISTER_ANPLUS
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          MOVE.B    #'+',(A3)+
          RTS

PRINT_DEST_REGISTER_ANMINUS
          MOVE.B    #'-',(A3)+
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          RTS

* -----------------------------------------------------------------------------

PRINT_DEST_MEMORY

          MOVE.W    D1,D3       ; copy type into D3
          ANDI.W    #$E00,D3    ; isolate the 3 bits that matter
          LSR.W     #8,D3
          LSR.W     #1,D3
          
          CMP.B     #0,D3
          BEQ       PRINT_DEST_MEMORY_ABS_W
          CMP.B     #1,D3
          BEQ       PRINT_DEST_MEMORY_ABS_L
          CMP.B     #4,D3
          BEQ       PRINT_DEST_MEMORY_IMM

PRINT_DEST_MEMORY_ABS_W
          MOVE.B    #'$',(A3)+

          MOVE.L    #0,D4
          MOVE.W    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS

PRINT_DEST_MEMORY_ABS_L
          MOVE.B    #'$',(A3)+

          MOVE.L    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS

PRINT_DEST_MEMORY_IMM
          * check if it's long or short addressing
          MOVE.L    D1,D4
          LSR.L     #8,D4
          LSR.L     #4,D4
          ANDI.L    #3,D4

          CMP.B     #2,D0
          BEQ       PRINT_DEST_MEMORY_IMM_L
          BRA       PRINT_DEST_MEMORY_IMM_W

PRINT_DEST_MEMORY_IMM_L
          MOVE.B    #'#',(A3)+
          MOVE.B    #'$',(A3)+

          MOVE.L    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS
          
PRINT_DEST_MEMORY_IMM_W
          MOVE.B    #'#',(A3)+
          MOVE.B    #'$',(A3)+

          MOVE.L    #0,D4
          MOVE.W    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS
* -----------------------------------------------------------------------------
