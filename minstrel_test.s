*=$c000

begin:
; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10111000
STA $df80

loop:
LDA #1
STA $DF9B
LDX $DF9B
STX $6000

ASL
STA $DF9B
LDX $DF9B
STX $6040

ASL
STA $DF9B
LDX $DF9B
STX $6080

ASL
STA $DF9B
LDX $DF9B
STX $60C0

ASL
STA $DF9B
LDX $DF9B
STX $6100



BRA loop



.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
