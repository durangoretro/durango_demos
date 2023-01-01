*=$c000

begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10001100
STA $df80

end: JMP end

.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
