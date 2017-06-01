*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

* Put program code here

            movem.L      d0-d2/a7,(a1)
            movem.l      d0-d2/a7,-(a1)
            movem.l (a1),d0-d2/a7
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
