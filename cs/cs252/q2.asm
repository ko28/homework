.ORIG x3000   ; begin program at x3000   

AND R1, R1, #0 ; R0 <- 0 
STI R1, INDEX ; MEM[INDEX] = MEM[9000] <-  0

LOOP_START
LD R0, STRING ; R0 <- mem address of STRING
LDI R1, INDEX ; R1 <- offset index
ADD R2, R0, R1; R2 <- correct mem address
LDR R3, R2, #0 ; R3 <- value of current character/string[INDEX]
BRz END

; INDEX++   -----------------
ADD R1, R1, #1
STI R1, INDEX
;---------------------------


ADD R4, R3, #-16
ADD R4, R4, #-16 ; check if char is a space
BRz LOOP_START; go to loop start if space

STI R3, NEW_STRING
; NEW_STRING++   -----------
LD  R5, NEW_STRING ; R5 <- mem address of NEW_STRING
ADD R5, R5, #1
ST  R5, NEW_STRING 
;---------------------------
BR LOOP_START;
END
;add end of string char '\0' = x0000
AND R7, R7, #0 ; R0 <- x0000
STI R7, NEW_STRING


HALT
INDEX: .FILL x9000
STRING: .FILL x5000
NEW_STRING: .FILL x5100 
