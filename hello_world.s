*=$c000

begin:
; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3F
STA $df80

; Write first two pixel in green
LDA #$11
STA $6000



.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
