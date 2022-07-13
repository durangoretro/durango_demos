; ROM addr
*=$8000

begin:
    ; Set video mode
    ; [HiRes Invert S1 S0    RGB LED NC NC]
    LDA #$88
    STA $df80


    ; FIRST SCREEN
    ; Store at $10 video memory pointer
    LDA #$00
    STA $11
    LDA #$00
    STA $10 ; Current video memory position

    ; Store at $12 current color
    LDA #$e7
    STA $12

end: JMP end


; filling
.dsb $fffa-*, $ff

; Start vectors
* = $fffa
.word begin
.word begin
.word begin
