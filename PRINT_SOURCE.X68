* -----------------------------------------------------------------------------
* PRINT_SOURCE_SUB
* 
* prints the source (the last 6 bits of the command that could be a register,
* immediate value, place in memory, etc.)
* -----------------------------------------------------------------------------

PRINT_SOURCE_SUB

          * we want to modify A1 & A3 (it's like a pass-by-reference parameter)
          * so we skip A1 & A3
          MOVEM.L   D0-D7/A0/A2/A4-A6,-(SP)

          * D1 stores the opcode, so we isolate the source info and shift it
          * to the end
          MOVE.L    D1,D7       ; keep a backup
          MOVE.B    D2,D6       ; keep a backup
          ANDI.W    #$3F,D1     ; get the 6 bits that matter

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
          MOVE.L    A3,OUT_CURR_A             ; update the output address
          MOVEM.L   (SP)+,D0-D7/A0/A2/A4-A6   ; put the data back
          RTS

* -----------------------------------------------------------------------------

* -----------------------------------------------------------------------------
* PRINT_SOURCE_REGISTER
*
* print the source, when the source is either Dn, An, (An), (An)+ or -(An)
* -----------------------------------------------------------------------------

PRINT_SOURCE_REGISTER
          MOVE.B    D1,D3       ; copy Xn into D3
          ANDI.B    #7,D3       ; isolate the 3 bits that matter
          ADDI.B    #$30,D3     ; add to convert to ASCII

          CMP.B     #0,D2       ; do the subroutine based on what type of
                                ; register it is
          BEQ       PRINT_SOURCE_REGISTER_DN        ; Dn
          CMP.B     #1,D2
          BEQ       PRINT_SOURCE_REGISTER_AN        ; An
          CMP.B     #2,D2
          BEQ       PRINT_SOURCE_REGISTER_ANPAREN   ; (An)
          CMP.B     #3,D2
          BEQ       PRINT_SOURCE_REGISTER_ANPLUS    ; (An)+
          CMP.B     #4,D2
          BEQ       PRINT_SOURCE_REGISTER_ANMINUS   ; -(An)

          RTS       ; quit if nothing is found

PRINT_SOURCE_REGISTER_DN
          MOVE.B    #'D',(A3)+  ; print Dn, where n is the reg. number (in D3)
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

* -----------------------------------------------------------------------------
* PRINT_SOURCE_MEMORY
*
* prints the source, when the source is a memory location or an imm. value
* basically when we need to read the next word or byte of the input
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

PRINT_SOURCE_MEMORY_ABS_W       ; it's a word memory location, i.e., $7000
          MOVE.B    #'$',(A3)+      ; print the $

          MOVE.L    #0,D4
          MOVE.W    (A1)+,D4        ; get the next word

          MOVE.L    D1,D5           ; move it into D1 (keeping a backup)
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A   ; update the output address
          JSR       PRINT_NUM       ; print the number
          MOVE.L    D5,D1           ; put the old D1 back
          RTS

PRINT_SOURCE_MEMORY_ABS_L       ; it's a long memory location, i.e., $00009000
          MOVE.B    #'$',(A3)+      ; print the $

          MOVE.L    (A1)+,D4        ; get the next long

          MOVE.L    D1,D5           ; backup D1
          MOVE.L    D4,D1           ; move the next long into D1
          MOVE.L    A3,OUT_CURR_A   ; update the output address
          JSR       PRINT_NUM       ; print the number
          MOVE.L    D5,D1           ; put the old D1 back
          RTS

PRINT_SOURCE_MEMORY_IMM
          * check if it's long or short addressing
          * this depends on the size of the command, and commands store
          * size in different places, we need the command to tell us
          * by putting the size here (or letting PRINT_SIZE_*_SUB do it)
          CMP.B     #2,SIZE_BUFFER
          BEQ       PRINT_SOURCE_MEMORY_IMM_L
          BRA       PRINT_SOURCE_MEMORY_IMM_W

PRINT_SOURCE_MEMORY_IMM_L         ; it's a long immediate address
          MOVE.B    #'#',(A3)+    ; print the #$
          MOVE.B    #'$',(A3)+

          MOVE.L    (A1)+,D4      ; get the next long

          MOVE.L    D1,D5         
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A   ; update the output address
          JSR       PRINT_NUM       ; print the number
          MOVE.L    D5,D1
          RTS
          
PRINT_SOURCE_MEMORY_IMM_W         ; it's a word immediate address
          MOVE.B    #'#',(A3)+    ; print the #$
          MOVE.B    #'$',(A3)+

          MOVE.L    #0,D4
          MOVE.W    (A1)+,D4      ; get the next word

          MOVE.L    D1,D5
          MOVE.L    D4,D1
          MOVE.L    A3,OUT_CURR_A   ; update the output address
          JSR       PRINT_NUM       ; print the number
          MOVE.L    D5,D1
          RTS
* -----------------------------------------------------------------------------
