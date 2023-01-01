*=$c000

begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10001100
STA $df80

wait_loop:
INX
BNE wait_loop
INY
BNE wait_loop
EOR #$04
STA $df80
BRA wait_loop

end: JMP end

.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
