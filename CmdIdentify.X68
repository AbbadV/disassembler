* -----------------------------------------------------------------------------
* CMD_IDENTIFY subroutine
*
* Author  : James Winters of WeMissJava
* Version : 1 (23 Apr 2017)
*
* CSS 422
*
* this subroutine checks the current opcode (word at IN_CURR_A)
* and determines which command it corresponds to
*
* then it runs that command's subroutine, which writes prints the dissassembled
* code onto the screen increments IN_CURR_A
* -----------------------------------------------------------------------------

CMD_IDENTIFY

        MOVEM.L   D0-D7/A0-A6,-(SP) ; move the old registers onto the stack
  
        MOVEA.L   #0,A1
        MOVEA.L   IN_CURR_A,A1  ; A1 is a pointer to the current position
        MOVEA.L   OUT_CURR_A,A3 ; A3 is a pointer to the current output pos
        MOVE.L    A1,D1

        JSR       PRINT_NUM     ; print the address to the screen
        MOVE.B    #9,(A3)+      ; print tab character
        MOVE.L    A3,OUT_CURR_A
        MOVE.W    (A1),D1       ; D1 is the current opcode
        

        * check SUBI
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #SUBI_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #SUBI_S,D4  
        MOVE.W    #SUBI_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check ADDI
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #ADDI_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ADDI_S,D4  
        MOVE.W    #ADDI_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        

        * check MOVEA
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MOVEA_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MOVEA_S,D4  
        MOVE.W    #MOVEA_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check MOVE
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MOVE_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MOVE_S,D4  
        MOVE.W    #MOVE_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check NOP
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #NOP_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #NOP_S,D4  
        MOVE.W    #NOP_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check RTS
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #RTS_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #RTS_S,D4  
        MOVE.W    #RTS_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check JSR
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #JSR_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #JSR_S,D4  
        MOVE.W    #JSR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check MOVEM
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MOVEM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MOVEM_S,D4  
        MOVE.W    #MOVEM_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        
        * check ADDQ
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #ADDQ_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ADDQ_S,D4  
        MOVE.W    #ADDQ_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check BRA
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #BRA_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #BRA_S,D4  
        MOVE.W    #BRA_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check BCC
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #BCC_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #BCC_S,D4  
        MOVE.W    #BCC_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check BGE
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #BGE_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #BGE_S,D4  
        MOVE.W    #BGE_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check BLT
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #BLT_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #BLT_S,D4  
        MOVE.W    #BLT_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal 

        * check MOVEQ
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MOVEQ_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MOVEQ_S,D4  
        MOVE.W    #MOVEQ_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check DIVU
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #DIVU_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #DIVU_S,D4  
        MOVE.W    #DIVU_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal        
        
        * check OR
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #OR_P,D3     ; move values into registers for CMD_CHECK
        MOVE.W    #OR_S,D4  
        MOVE.W    #OR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal        
        
        
        * check SUB
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #SUB_P,D3     ; move values into registers for CMD_CHECK
        MOVE.W    #SUB_S,D4  
        MOVE.W    #SUB_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check MULS
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MULS_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MULS_S,D4  
        MOVE.W    #MULS_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        

        * check ADDA
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ADDA_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ADDA_S,D4  
        MOVE.W    #ADDA_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check AND
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #AND_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #AND_S,D4  
        MOVE.W    #AND_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal        

        * check ADD
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ADD_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ADD_S,D4  
        MOVE.W    #ADD_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check ASR
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ASR_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ASR_S,D4  
        MOVE.W    #ASR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check ASL
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ASL_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ASL_S,D4  
        MOVE.W    #ASL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
       
        * check LSL
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #LSL_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #LSL_S,D4  
        MOVE.W    #LSL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check LSR
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #LSR_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #LSR_S,D4  
        MOVE.W    #LSR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check ROR
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ROR_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ROR_S,D4  
        MOVE.W    #ROR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal 

        * check ROL
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ROL_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ROL_S,D4  
        MOVE.W    #ROL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal     

        * check ASRM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ASRM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ASRM_S,D4  
        MOVE.W    #ASR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal        

        * check ASLM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ASLM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ASLM_S,D4  
        MOVE.W    #ASL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal  
        
        * check LSLM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #LSLM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #LSLM_S,D4  
        MOVE.W    #LSL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check LSRM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #LSRM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #LSRM_S,D4  
        MOVE.W    #LSR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal

        * check RORM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #RORM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #RORM_S,D4  
        MOVE.W    #ROR_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal
        
        * check ROLM
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ROLM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ROLM_S,D4  
        MOVE.W    #ROL_SUB,D5
        JSR       CMD_CHECK
        CMP.B     #1,D6         ; check the answer CMD_CHECK gave us
        BEQ       END_IDENTIFY  ; skip to the end if it's equal        



        * if we hit here it's not a valid command
        JSR       BAD_COMMAND_SUB

END_IDENTIFY

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

* ------------------------------------------------------------------------------

CMD_CHECK
        MOVEM.L   A1,-(SP)   ; A1 is the only thing we need to keep from the
                             ; parent routine
        
        MOVE.B    #0,D6      ; we're storing the answer in D6

        AND.W     D3,D2      ; get rid of all the unimportant parts
        CMP.W     D4,D2      ; compare the result with the signature of the cmd
        BNE       NEGATIVE   ; if they don't match skip everything else

        MOVEA.L   D5,A1
        JSR       (A1)        ; jump to the subroutine at D5
        MOVE.B    #1,D6
 
NEGATIVE
        MOVEM.L   (SP)+,A1
        RTS

* ------------------------------------------------------------------------------

        INCLUDE 'PRINT_SIZE.X68'
        INCLUDE 'PRINT_SOURCE.X68'
        INCLUDE 'PRINT_DEST.X68'
        INCLUDE 'PRINT_NUM.X68'

        INCLUDE 'BAD_COMMAND.X68'
        INCLUDE 'SUBI_SUB.X68'
        INCLUDE 'ADDI_SUB.X68'
        INCLUDE 'MOVEA_SUB.X68'
        INCLUDE 'MOVE_SUB.X68'
        INCLUDE 'NOP_SUB.X68'
        INCLUDE 'RTS_SUB.X68'
        INCLUDE 'JSR_SUB.X68'
        INCLUDE 'MOVEM_SUB.X68'
        INCLUDE 'ADDQ_SUB.X68'
        INCLUDE 'BRA_SUB.X68'
        INCLUDE 'BCC_SUB.X68'
        INCLUDE 'BGE_SUB.X68'
        INCLUDE 'BLT_SUB.X68'
        INCLUDE 'MOVEQ_SUB.X68'
        INCLUDE 'DIVU_SUB.X68'
        INCLUDE 'OR_SUB.X68'
        INCLUDE 'SUB_SUB.X68'
        INCLUDE 'MULS_SUB.X68'
        INCLUDE 'AND_SUB.X68'
        INCLUDE 'ADD_SUB.X68'
        INCLUDE 'ADDA_SUB.X68'
        INCLUDE 'ASL_SUB.X68'
        INCLUDE 'ASR_SUB.X68'
        INCLUDE 'LSL_SUB.X68'
        INCLUDE 'LSR_SUB.X68'
        INCLUDE 'ROL_SUB.X68'
        INCLUDE 'ROR_SUB.X68'


        

* BAD_COMMAND_STR DC.B  'DATA $',0

* NOP_STR DC.B  'NOP',$0A,$0D,0
* NOP_S   EQU   $4E70
* NOP_P   EQU   $FFFF

* ------------------------------------------------------------------------------



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
