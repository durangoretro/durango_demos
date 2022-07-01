begin:

    ; Generate tiles
    JSR generate_tiles
    JSR generate_tilemap    

    ; Set video mode
    LDA #$3F
    STA $df80

    ; Store at $10 video memory pointer
    LDA #$60
    STA $11
    LDA #$00
    STA $10 ; Current video memory position

    ; Set tile to draw
    LDA #$E0
    STA $13
    LDA #$00
    STA $12

    JSR draw_back_tile

; Set Second tile to draw
    LDA #$E1
    STA $13
    LDA #$00
    STA $12
; Set second tile position
; Store at $10 video memory pointer
    LDA #$60
    STA $11
    LDA #$04
    STA $10 ; Current video memory position


    JSR draw_back_tile

end: JMP end


draw_back_tile:
; First row
LDY #$00
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Second row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Third row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Fourth row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row and block
LDA $10
STA $10
INC $11
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Fith row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Sixth row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Seventh row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Eight row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y



generate_tiles:
LDX #$00; Memory iterator
LDY #$10; count items

LDA #$11
loop:
STA $E000,X
INX
DEY
BNE loop

LDA #$22
LDY #$10; count items
loop2:
STA $E000,X
INX
DEY
BNE loop2

; Second tile
LDX #$00; Memory iterator
LDY #$10; count items

LDA #$33
loop3:
STA $E100,X
INX
DEY
BNE loop3

LDA #$44
LDY #$10; count items
loop4:
STA $E100,X
INX
DEY
BNE loop4
RTS

generate_tilemap:
LDX #$00; Memory iterator
LDY #$10; count items
loop5:
LDA #$01
STA $E200,X
INX
LDA #$02
STA $E200,X
INX
BNE loop5
; Second tilemap
LDX #$00; Memory iterator
LDY #$10; count items
loop6:
LDA #$02
STA $E300,X
INX
LDA #$01
STA $E300,X
INX
BNE loop6
RTS
