*------------------------------------------------------------------------------
* This is a skeleton to help write all the _SUP files
*
* basically here's how they all work:
*
* IN_CURRENT_A contains the address of the current op-code we're looking at
* and re-constructing into the command
*
* right after it are any immediate values and/or addresses in the command
*
* --------------------------------------------------------------------
* YOU ARE RESPONSIBLE FOR MOVING IN_CURRENT_A OVER TO THE NEXT COMMAND
* --------------------------------------------------------------------
*
* to output the text, push the characters onto the output stack with
*
*   MOVE.B  $__,(A3)+
* 
* also, replace ADD with the name of the command, all variables and labels are
* global in assembly, so each one has to be 100% unique
*


ADDI_SUB
        MOVEM.L   D0-D7/A0-A6,-(SP) ; move the old registers onto the stack

        * sets up the data registers
        *
        * A1 - the current opcode's address
        * A3 - the current position of the output
        * A4 - the location of the text for printing
        *
        * D1 - the actual opcode
        *
        MOVEA.L   #0,A1             ; clear A1 for later use 
        MOVEA.L   IN_CURR_A,A1      ; load the current opcode into a register
        MOVE.W    (A1)+,D1          ; not necessary here, but for other cmds

        MOVEA.L   #0,A3             ; clear A3 for later use 
        MOVEA.L   OUT_CURR_A,A3     ; move the current output pointer to A3
        LEA       ADDI_STR,A4       ; move the to-be-printed string to A4

        * we need to append the string at ADDI_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDI_STR

ADDI_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADDI_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADDI_COPY      ; do it again
        
ADDI_DONE
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2         ;copy the actual op code to D2
        LSR.W     #6,D2         ; shift 6 bits right 
        ANDI.W    #7,D2         ;mask unwanted bits  

        CMP.W     #0,D2         ; check to see if D2 is 0
        BEQ       ADDI_BYTE_DN  ; its zero , data is byte of the immidiate  
        CMP.W     #1,D2         ; check if D2 is 1
        BEQ       ADDI_WORD_DN  ; its 1, data is the entire immidiate word
        CMP.W     #2,D2         ; check to see if D2 is 2
        BEQ       ADDI_LONG_DN  ; its 2,data is the next 2 immidiate words

        CMP.W     #4,D2         ; check to see if d2 is 4
        BEQ       ADDI_BYTE_EA  ; its 4, direction is ea first,size is byte 
        CMP.W     #5,D2         ; check to see if d2 is 5
        BEQ       ADDI_WORD_EA  ;  its 5, direction is ea first, size is word
        CMP.W     #6,D2         ; is d2 six?
        BEQ       ADDI_LONG_EA  ; its six, direction is EA first, size is long
        
        * if nothing is found just jump to the end
        BRA       ADDI_PARAM_DONE

ADDI_BYTE_DN
        MOVE.B    #0,D4                 ; copy byte size to d4
        MOVE.B    #0,D5                 ; copy Dn first to direction
        BRA       ADDI_PARAM_DONE       ; jump to size printing

ADDI_WORD_DN
        MOVE.B    #1,D4                 ;copy 1 for size 
        MOVE.B    #0,D5                 ;copy 0 for direction
        BRA       ADDI_PARAM_DONE       ;go to size printing

ADDI_LONG_DN
        MOVE.B    #2,D4                 ; copy 2 in to size 
        MOVE.B    #0,D5                 ; copy 0 (dn first) in to direction
        BRA       ADDI_PARAM_DONE       ; go to size printing

ADDI_BYTE_EA
        MOVE.B    #0,D4                ; copy byte size to d4
        MOVE.B    #1,D5                ; copy 1 to direction 
        BRA       ADDI_PARAM_DONE      ; go to size printing 
        
ADDI_WORD_EA
        MOVE.B    #1,D4                 ; copy 1 in to size
        MOVE.B    #1,D5                 ; copy 1 in to direction
        BRA       ADDI_PARAM_DONE       ; go to size printing

ADDI_LONG_EA
        MOVE.B    #2,D4                 ; copy 2 to size                 
        MOVE.B    #1,D5                 ; copy 1 in to direction
        BRA       ADDI_PARAM_DONE       ; go to size printing

ADDI_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        MOVE.B    #'.',(A3)+                    ; push '.' char acter to output stack,increment stack pointer 
        CMP.B     #0,D4                         ; check if size is byte
        BEQ       ADDI_PRINT_SIZE_BYTE          ; its a byte , print size as byte
        CMP.B     #1,D4                         ; check if size is word 
        BEQ       ADDI_PRINT_SIZE_WORD          ; its word ,print size as word
        CMP.B     #2,D4                         ; check to see if size is a long
        BEQ       ADDI_PRINT_SIZE_LONG          ; its a long , print size as long

        BRA       ADDI_PRINT_SIZE_DONE          ; we are done , go to printing size       

ADDI_PRINT_SIZE_BYTE
        MOVE.B    #'B',(A3)+                    ; push character 'B' to output stack
        BRA       ADDI_PRINT_SIZE_DONE          ;  we are done , go to printing size  
ADDI_PRINT_SIZE_WORD
        MOVE.B    #'W',(A3)+                    ; push character 'W' to output stack
        BRA       ADDI_PRINT_SIZE_DONE          ; go to printing size
ADDI_PRINT_SIZE_LONG
        MOVE.B    #'L',(A3)+                    ; push Character 'L' to output stack
        BRA       ADDI_PRINT_SIZE_DONE          ; go to printing size 

ADDI_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+                      ; push tab characterto output stack 
        MOVE.B    #'#',(A3)+                    ; push the immidiate character to output stack
        MOVE.B    #'$',(A3)+                    ; push "$' to output stack

        * --------------------
        * print address number
        * --------------------
        CMP.B     #2,D4                         ; if we're using long addressing, get next long
        BEQ       ADDI_PRINT_AL                 ; its long addressing,go to printing long 
        JSR       ADDI_PRINT_ADDR_WORD          ; jump to word address print 
        BRA       ADDI_PRINT_ADDR_DONE          ; go to address printing

ADDI_PRINT_AL
        JSR       ADDI_PRINT_ADDR_LONG          ; jump to long addressing printing

ADDI_PRINT_ADDR_DONE

        MOVE.B    #',',(A3)+            ; push ',' to output stack

        * JSR       ADDI_EA_TO_DN
        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here

ADDI_END

        MOVE.B    #$0A,(A3)+    ; push carriage return to output stack
        MOVE.B    #$0D,(A3)+    ; push line feed to the output stack

        MOVE.L    A1,IN_CURR_A  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6 ; move the old registers back to the stack
        RTS       ; return

*------------------------------------------------------------------------------
ADDI_EA_TO_DN

        JSR       PRINT_SOURCE_SUB    ; the "source" is actually the source here
        MOVE.B    #',',(A3)+          ; push ',' to output stack and increment pointer
        MOVE.B    #'D',(A3)+          ; push 'D' to output stack and increment pointer
        MOVE.W    D1,D2               ; copy op code to D2              
        LSR.W     #8,D2               ; shift right 8 bits
        LSR.W     #1,D2               ; shift right 1 bit 
        ANDI.W    #7,D2               ; mask unwanted bits 
        ADDI.W    #$30,D2             ; convert to hex 
        MOVE.B    D2,(A3)+            ; push D2 to output stack and increment

        RTS                            ; return

*------------------------------------------------------------------------------
ADDI_PRINT_ADDR_WORD
        MOVEM.L   D1,-(SP) ; move the old registers onto the stack

        CLR.L     D1
        MOVE.W    (A1)+,D1      ; move the next word into D1
        MOVE.L    A3,OUT_CURR_A ; update the output pos before we print
        JSR       PRINT_NUM     ; print the number in D1

        MOVEM.L   (SP)+,D1 ; move the old registers back to the stack
        RTS                     ; return
*------------------------------------------------------------------------------
ADDI_PRINT_ADDR_LONG
        MOVEM.L   D1,-(SP) ; move the old registers onto the stack

        CLR.L     D1            ; clear D1 for later 
        MOVE.L    (A1)+,D1      ; move the next word into D1
        MOVE.L    A3,OUT_CURR_A ; update the output pos before we print
        JSR       PRINT_NUM     ; print the number in D1

        MOVEM.L   (SP)+,D1 ; move the old registers back to the stack
        RTS                     ; return
