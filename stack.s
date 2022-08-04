*=$c000
begin:

; Init 6502
LDX #$FF  ; Initialize stack pointer to $01FF
TXS
CLD       ; Clear decimal mode
SEI       ; Disable interrupts

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3c
STA $df80

; Print stack
LDA #$fe
STA $df94
STX $df93


; Add items to stack
LDA #$11
PHA
LDA #$22
PHA
LDA #$33
PHA
LDA #$44
PHA
LDA #$55
PHA

; Print stack
LDA #$fe
STA $df94
STX $df93

; Remove items from stack
PLA
PLA
PLA

; Print stack
LDA #$fe
STA $df94
STX $df93

; Remove last two items
PLA
PLA

; Print stack
LDA #$fe
STA $df94
STX $df93

; Print status
LDA #$ff
STA $df94
STX $df93

; Dump memory
LDA #$fd
STA $df94
STX $df93

; Print stack
LDA #$fe
STA $df94
STX $df93



; End execution
.byte $db



; Finish cartridge
.dsb    $fffa-*, $ff
* = $fffa
.word begin
.word begin
.word begin

