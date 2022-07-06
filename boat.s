; Tiles position (0x8000 - 0x9fff)
*=$8000
#include "boat_tiles.s"
; First map 0xa000
#include "boat_maps.s"

begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3F
STA $df80

; $10 $11 current video memory pointer
LDA #$60
STA $11
LDA #$00
STA $10

; $12, $13 tile to draw (initial position in mem)
LDA #$80
STA $13
LDA #$00
STA $12

; $14, $15 tilemap to draw
LDA #$a0
STA $15
LDA #$00
STA $14

; Load tile index in X
LDY #$00
LDA ($14), Y
TAX
; Calculate tile memory position using accumulator and x
LDA #$00
CPX #$00
BEQ end_loop_tilemap1
end_loop_tilemap2:
CLC
ADC #$20
DEX
BNE end_loop_tilemap2
end_loop_tilemap1:
; Store tile memory position in $12
LDA ($14), Y
STA $12
JSR draw_back_tile





end: JMP end






;$12, $13 -> tile number, tile bank
;$10,$11 -> screen position
;$09 backup of $10 original value
draw_back_tile:
; Save screen position as backup in $09
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
;--------------------------------------------------------



; Fill unused ROM
.dsb $fffa-*, $00

; Set initial PC
* = $fffa
    .word begin
    .word begin
    .word begin
