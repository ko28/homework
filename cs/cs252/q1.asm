.ORIG x3000   ; begin program at x3000   
LDI R0, NUM ; load value that needs to be abs
BRn ELSE       ;
STI R0, RESULT  ;            
BR   END_ELSE   ; don't execute else code
ELSE                 ; code for else clause here
NOT R0, R0  ;twos compliment
ADD R0, R0, #1 ;twos compliment
STI R0, RESULT 
END_ELSE             ; remainder of code after else
HALT
NUM:     .FILL x4000
RESULT:   .FILL x4001