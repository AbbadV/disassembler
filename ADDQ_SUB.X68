

* IN_CURRENT_A contains the address of the current op-code we're looking at
* and re-constructing into the command



ADDQ_SUB
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
        MOVEA.L   OUT_CURR_A,A3 ; move the current output pointer to A3
        LEA       ADDQ_STR,A4     ; move the to-be-printed string to A4

        * we need to append the string at ADDQ_STR to the output string
        * we do this char by char (byte by byte) until we see a NULL (0)
        * in ADDQ_STR

ADDQ_COPY
        TST.B     (A4)      ; test the contents of A4
        BEQ       ADDQ_DONE  ; if we hit a 00, we're done copying

        MOVE.B    (A4)+,(A3)+   ; copy A4 into A3, then increment both
        BRA       ADDQ_COPY      ; do it again
        
ADDQ_DONE
  
        * D4 = size       ( 0 = B, 1 = W, 2 = L)
        * D5 = direction  ( 0 = Dn first, 1 = <ea> first)

        MOVE.W    D1,D2                 ;copy actual op code to D2
        LSR.W     #6,D2                 ;shift 6 bits to the right 
        ANDI.W    #7,D2                 ;mask of unwnted bits to isolate size 

        CMP.W     #0,D2                 ; check if size is byte
        BEQ       ADDQ_BYTE_DN          ; size is byte , go to ADDQ_BYTE_DN
        CMP.W     #1,D2                 ; check if size is word  
        BEQ       ADDQ_WORD_DN          ; size is word , go to ADDQ_WORD_DN
        CMP.W     #2,D2                 ; check if size is long 
        BEQ       ADDQ_LONG_DN          ; its long go to ADDQ_LONG_DN 

        CMP.W     #4,D2                 ; check if D2 is 4             
        BEQ       ADDQ_BYTE_EA          ; its 4 go to ADDQ_BYTE_EA
        CMP.W     #5,D2                 ; check if D2 is 5
        BEQ       ADDQ_WORD_EA          ; its 5 go to ADDQ_BYTE_EA
        CMP.W     #6,D2                 ; check if D2 is 6
        BEQ       ADDQ_LONG_EA          ; its 6 , go to ADDQ_LONG_EA
        
        * if nothing is found just jump to the end
        BRA       ADDQ_PARAM_DONE

ADDQ_BYTE_DN
        MOVE.B    #0,D4                 ; copy 0 to size
        MOVE.B    #0,D5                 ; copy 0 to direction Dn first
        BRA       ADDQ_PARAM_DONE       ; go to pritning output

ADDQ_WORD_DN
        MOVE.B    #1,D4                 ; copy 1 to size 
        MOVE.B    #0,D5                 ; copy 0 in to direction , Dn first
        BRA       ADDQ_PARAM_DONE       ; go to printing output 

ADDQ_LONG_DN
        MOVE.B    #2,D4                 ; copy 2 to size
        MOVE.B    #0,D5                 ; copy 0 to direction , Dn first
        BRA       ADDQ_PARAM_DONE       ; go to printing output

ADDQ_BYTE_EA
        MOVE.B    #0,D4                 ; copy 0 in to size 
        MOVE.B    #1,D5                 ; copy 1 to direction, <ea> first
        BRA       ADDQ_PARAM_DONE       ;go  to printing output 
        
ADDQ_WORD_EA
        MOVE.B    #1,D4                 ; copy 1 to size
        MOVE.B    #1,D5                 ; copy 1 to direction , <ea> first
        BRA       ADDQ_PARAM_DONE       ; go to printing output 

ADDQ_LONG_EA
        MOVE.B    #2,D4                 ; copy 2 to D4
        MOVE.B    #1,D5                 ; copy 1 to direction , <ea> first
        BRA       ADDQ_PARAM_DONE       ; go to printing output

ADDQ_PARAM_DONE
        
        * -------------------
        * print the size
        * -------------------

        MOVE.B    #'.',(A3)+                    ; push '.' character to output stack
        CMP.B     #0,D4                         ; check if size is byte 
        BEQ       ADDQ_PRINT_SIZE_BYTE          ; its byte go to byte printing
        CMP.B     #1,D4                         ; check if size is word
        BEQ       ADDQ_PRINT_SIZE_WORD          ; its word , go to word printing
        CMP.B     #2,D4                         ; check if size is Long
        BEQ       ADDQ_PRINT_SIZE_LONG          ; its a long , go to long printing

        BRA       ADDQ_PRINT_SIZE_DONE          ; go to print Ascii characters and numbers

ADDQ_PRINT_SIZE_BYTE
        MOVE.B    #'B',(A3)+                    ; push 'B' to output stack
        BRA       ADDQ_PRINT_SIZE_DONE           ; go to print Ascii characters and numbers
ADDQ_PRINT_SIZE_WORD
        MOVE.B    #'W',(A3)+                    ; push 'w' to output stack 
        BRA       ADDQ_PRINT_SIZE_DONE          ; go to print Ascii characters and numbers
ADDQ_PRINT_SIZE_LONG
        MOVE.B    #'L',(A3)+                    ; push 'L' to output stack
        BRA       ADDQ_PRINT_SIZE_DONE          ; go to print Ascii characters and numbers

ADDQ_PRINT_SIZE_DONE
        MOVE.B    #9,(A3)+                      ; push tab caracter to output stack
        MOVE.B    #'#',(A3)+                    ; push "#" to output stack 
        MOVE.B    #'$',(A3)+                    ; push "$" to putput stack

        JSR       ADDQ_PRINT_NUM                ; jump to priting the number part of opcode
        MOVE.B    #',',(A3)+                    ; push ',' to the output stack
        JSR       PRINT_SOURCE_SUB              ; the "source" is actually the source here

ADDQ_END

        MOVE.B    #$0A,(A3)+                    ; push carriage return to output stack
        MOVE.B    #$0D,(A3)+                    ; push line feed to output stack

        MOVE.L    A1,IN_CURR_A                  ; move the current A1 back to the input pointer
        MOVE.L    A3,OUT_CURR_A                 ; move the current A3 back to the output pointer

        MOVEM.L   (SP)+,D0-D7/A0-A6             ; move the old registers back to the stack
        RTS                                     ; return

*------------------------------------------------------------------------------
ADDQ_PRINT_NUM
        MOVEM.L   D1,-(SP)                      ; move the old registers onto the stack

        LSR.W     #8,D1                         ; shift right 8 bits
        LSR.W     #1,D1                         ; shift right 1 bit
        AND.L     #7,D1                         ; isolate the number part of the opcode

        TST.W     D1                             ; is d1 0 ? 
        BNE       ADDQ_ZERO_IS_EIGHT            ; not 0 , go to printing number

        MOVE.B    #8,D1                         ; its zero which means its 8 , copy 8 to D1

ADDQ_ZERO_IS_EIGHT

        MOVE.L    A3,OUT_CURR_A                 ; update the output pos before we print
        JSR       PRINT_NUM                      ; print the number in D1

        MOVEM.L   (SP)+,D1                       ; move the old registers back to the stack
        RTS                                     ; return                    
