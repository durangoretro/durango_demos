; Rom initial address
*=$C000

begin:
    ; Set video mode
    ; [HiRes Invert S1 S0    RGB LED NC NC]
    LDA #$bF
    STA $df80

    ; Store at $10 video memory pointer
    LDA #$60
    STA $11
    LDA #$00
    STA $10 ; Current video memory position

    ; Store at $12 current color
    LDA #$e7
    STA $12

loop3:
    ; Init memory position
    LDA #$60
    STA $11

loop2:
    ; Load color into accumulator
    LDA $12

    ; Iterate over less significative memory address
    LDY #$00
loop:
    STA ($10), Y
    INY
    BNE loop

    ; Increment color
    LDA $12
    CLC
    ADC #$11
    ;STA $12

    ; Iterate over more significative memory address
    LDA $11 ; Increment memory pointer Hi address using accumulator
    CLC
    ADC #$1
    STA $11
    CMP #$80; Compare with end memory position
    BNE loop2

; Fill unused ROM
.dsb $fffa-*, $00

; Set initial PC
* = $fffa
    .word begin
    .word begin
    .word begin
    

