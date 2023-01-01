*=$c000

begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10001100
STA $df80

; Wait some time
.(
LDA #$00
LDX #$00
LDY #$00
wait_loop:
INX
BNE wait_loop
INY
BNE wait_loop
INA
BNE wait_loop
.)

; Quick led flash
.(
LDA $df80
LDX #$00
LDY #$00
wait_loop:
INX
BNE wait_loop
INY
BNE wait_loop
EOR #$04
STA $df80
BRA wait_loop
.)

end: JMP end


; === FILLING ===
.dsb    $fffa-*, $ff
* = $fffa
; === VECTORS ===
.word $0000 ; NMI vector
.word begin ; Reset vector
.word $0000 ; IRQ/BRK vector
