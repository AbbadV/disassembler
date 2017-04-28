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

        * check MOVEM
        MOVE.W    D1,D2         ; move the value into D2 for temp storage
        MOVE.W    #MOVEM_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #MOVEM_S,D4  
        MOVE.W    #MOVEM_SUB,D5
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

        * check ADDA
        MOVE.W    D1,D2        ; move the value into D2 for temp storage
        MOVE.W    #ADDA_P,D3    ; move values into registers for CMD_CHECK
        MOVE.W    #ADDA_S,D4  
        MOVE.W    #ADDA_SUB,D5
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
        INCLUDE 'MOVEA_SUB.X68'
        INCLUDE 'MOVE_SUB.X68'
        INCLUDE 'NOP_SUB.X68'
        INCLUDE 'MOVEM_SUB.X68'
        INCLUDE 'MOVEQ_SUB.X68'
        INCLUDE 'ADD_SUB.X68'
        INCLUDE 'ADDA_SUB.X68'

* BAD_COMMAND_STR DC.B  'DATA $',0

* NOP_STR DC.B  'NOP',$0A,$0D,0
* NOP_S   EQU   $4E70
* NOP_P   EQU   $FFFF

* ------------------------------------------------------------------------------
