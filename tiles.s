begin:

    ; Generate tiles
    JSR generate_tiles
    JSR generate_tilemap


    ; Set video mode
    LDA #$3F
    STA $df80

; Set map to draw
    LDA #$E2
    STA $15    
; Set tile bank
    LDA #$E0
    STA $13

; Set where to draw
    LDA #$60
    STA $11
    LDA #$00
    STA $10 ; Current video memory position

JSR draw_tilemap
end: JMP end

; $14, $15 -> current tile (private), tilemap to use
; $12, $13 -> tile number (private), tile bank to use
; $10,$11 -> screen position
draw_tilemap:
    ; Init $14 to zero
    LDA #$00
    STA $14
loop_tilemap:     
    ; Load zero to Y
    LDY #$00  
    ; Load tile index to draw from tilemap
    LDA ($14), Y
    ; Convert tile index to tile memory offset by adding 0x20 for each tile
    TAX
    LDA #$00
    CLC
loop_tilemap_2:    
    ADC #$20
    DEX
    BNE loop_tilemap_2
    ; Store tile to draw into $12 to call draw_tile method
    STA $12
    ; Draw tile
    JSR draw_back_tile
    
    ; Go to next tile in tilemap
    INC $14
    

RTS


;$12, $13 -> tile number, tile bank
;$10,$11 -> screen position
draw_back_tile:
; Save screen position
LDA $10
STA $09
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
LDA $10; Increment using acumulator less significative screen pos ($10)
CLC
ADC #$40; Each row is 0x40 (64) bytes 
STA $10
LDA $12; Increment first tile byte position ($12), so it points to next byte
CLC
ADC #$04; Increment by 4 (already drawn 8 pixels)
STA $12
LDY #$00; Initialize pixel counter to 0
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
CLC
ADC #$40
STA $10
INC $11; Each 4 rows, high significative byte should be increased
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


; Finalize tile drawing
LDA $12; Go to next tile by incrementing $12 by 0x04 (already drawn 8 pixels)
CLC
ADC #$04
DEC $11; Restore $11 to original value, so next tile is at same row
LDA $09; Restore $10 using backup and add 0x04 to set at next screen position 
CLC
ADC #$04
STA $10
RTS



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
LDY #$10; count items

LDA #$33
loop3:
STA $E000,X
INX
DEY
BNE loop3

LDA #$44
LDY #$10; count items
loop4:
STA $E000,X
INX
DEY
BNE loop4
RTS

generate_tilemap:
LDX #$00; Memory iterator
LDY #$10; count items
loop5:
LDA #$00
STA $E200,X
INX
LDA #$01
STA $E200,X
INX
BNE loop5
; Second tilemap
LDX #$00; Memory iterator
LDY #$10; count items
loop6:
LDA #$01
STA $E300,X
INX
LDA #$00
STA $E300,X
INX
BNE loop6
RTS
