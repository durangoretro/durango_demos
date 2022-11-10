*=$c000

begin:
; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10111000
STA $df80

loop:
LDY #1
STY $DF9B
LDA $DF9B
STA $6000

BRA loop



.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
