PRINT_SOURCE_SUB

          * we want to modify A1 & A3 (it's like a pass-by-reference parameter)
          * so we skip A1 & A3
          MOVEM.L   D0-D1/A0/A2/A4-A6,-(SP)

          * D1 stores the opcode, so we isolate the source info and shift it
          * to the end
          MOVE.L    D1,D7 ; keep a backup
          MOVE.B    D2,D6 ; keep a backup
          ANDI.W    #$3F,D1

          * D2 is the mode, so isolate and shift
          MOVE.B    D1,D2
          ANDI.B    #$38,D2
          LSR.B     #$3,D2

          * if it's not 7, it's Dn, An, (An), (An)+, etc
          CMP.B     #7,D2
          BEQ       PRINT_SOURCE_MEM
          JSR       PRINT_SOURCE_REGISTER
          BRA       PRINT_SOURCE_END

PRINT_SOURCE_MEM
          JSR       PRINT_SOURCE_MEMORY
          BRA       PRINT_SOURCE_END

PRINT_SOURCE_END
          MOVE.L    A3,OUT_CURR_A
          MOVEM.L   (SP)+,D0-D1/A0/A2/A4-A6
          RTS

* -----------------------------------------------------------------------------

PRINT_SOURCE_REGISTER
          MOVE.B    D1,D3       ; copy Xn into D3
          ANDI.B    #7,D3       ; isolate the 3 bits that matter
          ADDI.B    #$30,D3     ; add to convert to ASCII

          CMP.B     #0,D2
          BEQ       PRINT_SOURCE_REGISTER_DN
          CMP.B     #1,D2
          BEQ       PRINT_SOURCE_REGISTER_AN
          CMP.B     #2,D2
          BEQ       PRINT_SOURCE_REGISTER_ANPAREN
          CMP.B     #3,D2
          BEQ       PRINT_SOURCE_REGISTER_ANPLUS
          CMP.B     #4,D2
          BEQ       PRINT_SOURCE_REGISTER_ANMINUS

          RTS       ; quit if nothing is found

PRINT_SOURCE_REGISTER_DN
          MOVE.B    #'D',(A3)+
          MOVE.B    D3,(A3)+
          RTS

PRINT_SOURCE_REGISTER_AN
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          RTS

PRINT_SOURCE_REGISTER_ANPAREN
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          RTS

PRINT_SOURCE_REGISTER_ANPLUS
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          MOVE.B    #'+',(A3)+
          RTS

PRINT_SOURCE_REGISTER_ANMINUS
          MOVE.B    #'-',(A3)+
          MOVE.B    #'(',(A3)+
          MOVE.B    #'A',(A3)+
          MOVE.B    D3,(A3)+
          MOVE.B    #')',(A3)+
          RTS

* -----------------------------------------------------------------------------

PRINT_SOURCE_MEMORY

          MOVE.B    D1,D3       ; copy type into D3
          ANDI.B    #7,D3       ; isolate the 3 bits that matter
          
          CMP.B     #0,D3
          BEQ       PRINT_SOURCE_MEMORY_ABS_W
          CMP.B     #1,D3
          BEQ       PRINT_SOURCE_MEMORY_ABS_L
          CMP.B     #4,D3
          BEQ       PRINT_SOURCE_MEMORY_IMM

PRINT_SOURCE_MEMORY_ABS_W
          MOVE.B    #'$',(A3)+

          MOVE.L    #0,D4
          MOVE.W    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS

PRINT_SOURCE_MEMORY_ABS_L
          MOVE.B    #'$',(A3)+

          MOVE.L    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS

PRINT_SOURCE_MEMORY_IMM
          * check if it's long or short addressing
          CMP.B     #2,SIZE_BUFFER
          BEQ       PRINT_SOURCE_MEMORY_IMM_L
          BRA       PRINT_SOURCE_MEMORY_IMM_W

PRINT_SOURCE_MEMORY_IMM_L
          MOVE.B    #'#',(A3)+
          MOVE.B    #'$',(A3)+

          MOVE.L    (A1)+,D4

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A
          JSR       PRINT_NUM
          MOVE.L    D5,D1
          RTS
          
PRINT_SOURCE_MEMORY_IMM_W
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
