; -- Constants --
VIDEO_MODE = $df80
HIRES = $80
INVERT = $40
SCREEN_0 = $00
SCREEN_1 = $10
SCREEN_2 = $20
SCREEN_3 = $30
RGB = $08
LED = $04
SERIAL_PORT = $df93
SERIAL_HEX = $00
SERIAL_ASCII = $01
SERIAL_BINARY = $02
SERIAL_DUMP = $fd
SERIAL_STACK = $fe
SERIAL_STAT = $ff
CONTROLLER_1 = $df9c
CONTROLLER_2 = $df9d
BUTTON_A = $80
BUTTON_START = $40
BUTTON_B = $20
BUTTON_SELECT = $10
BUTTON_UP = $08
BUTTON_LEFT = $04
BUTTON_DOWN = $02
BUTTON_RIGHT = $01
NEGRO = $00
VERDE = $11
ROJO = $22
NARANJA = $33
BOTELLA = $44
LIMA = $55
LADRILLO = $66
AMARILLO = $77
AZUL = $88
CELESTE = $99
MAGENTA = $aa
ROSITA = $bb
AZUR = $cc
CIAN = $dd
FUCSIA = $ee
BLANCO = $ff

; -- Functions args pointers --
VMEM_POINTER = $10 ; $11
X_COORD = $16
Y_COORD = $17
SQ_WIDTH = $08
SQ_HEIGHT = $09
CURRENT_COLOR = $06

; -- Global Game constants --
PADDLE_WIDTH = 6
PADDLE_HEIGHT =32
BACKGROUND = ROSITA
; -- Global Game vars pointers --
p1_vertical_x = 00
p1_vertical_y = 01
p2_vertical_x = 02
p2_vertical_y = 03

; == 16K ROM. FIRST 8K BLOCK ==
*=$c000
begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3c
STA $df80

LDA #5
STA Y_COORD
STA VMEM_POINTER+1

LDA #118
STA X_COORD




LDA #PADDLE_WIDTH
STA SQ_WIDTH
LDA #PADDLE_HEIGHT
STA SQ_HEIGHT
LDA #BLANCO
STA CURRENT_COLOR

;JSR debug3
JSR _convert_coords_to_mem
JSR debug2
JSR _draw_square

;JSR debug3
JSR _convert_coords_to_mem
JSR debug2
JSR _draw_square

end: JMP end


; Converts x,y coord into memory pointer.
; X_COORD, Y_COORD pixel coords
; VMEM_POINTER VMEM_POINTER+1 current video memory pointer
_convert_coords_to_mem:
.(
    ; Clear X reg
    LDX #$00
    ; Clear VMEM_POINTER
    STX VMEM_POINTER
    ; Multiply y coord by 64 (64 bytes each row)
    LDA Y_COORD
    LSR
    STA VMEM_POINTER+1
    ROR VMEM_POINTER
    ; Sencond shift
    LSR VMEM_POINTER+1
    ROR VMEM_POINTER
    
    ; Add base memory address
    CLC
    LDA VMEM_POINTER+1
    ADC #$60
    STA VMEM_POINTER+1
    LDA VMEM_POINTER
    ADC #$00
    STA VMEM_POINTER
    
    ; Calculate X coord
    ; Divide x coord by 2 (2 pixel each byte)
    LDA X_COORD
    LSR
    ; Add to memory address
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    LDA VMEM_POINTER+1
    ADC #$00
    STA VMEM_POINTER+1
    
    RTS
.)
; --- end convert_coords_to_mem ---

; Draw square
; X_COORD, Y_COORD, SQ_WIDTH, SQ_HEIGHT
; VMEM_POINTER VMEM_POINTER+1 final video memory pointer
_draw_square:
.(
	JSR _convert_coords_to_mem
	; Load height in x
	LDX SQ_HEIGHT
	paint_row:
	; Divide width by 2
	LDA SQ_WIDTH
	LSR
	; Store it in Y
	TAY
	; Load current color
	LDA CURRENT_COLOR
	; Draw as many pixels as Y register says
	paint:
	STA (VMEM_POINTER), Y
	DEY
	BNE paint:
	STA (VMEM_POINTER), Y
	; Next row
;	LDA VMEM_POINTER
;	CLC
;	ADC #$40
;	STA VMEM_POINTER
;	BCC skip_upper
;	INC VMEM_POINTER+1
;	skip_upper:
;	DEX
;	BNE paint_row
	RTS
.)
; --- end draw_square

debug:
.(
    PHA
    LDA #SERIAL_BINARY
    STA SERIAL_PORT+1
    LDA VMEM_POINTER+1
    STA SERIAL_PORT
    LDA VMEM_POINTER
    STA SERIAL_PORT
    PLA
    RTS
.)

debug2:
.(
    PHA
    LDA #SERIAL_HEX
    STA SERIAL_PORT+1
    LDA VMEM_POINTER+1
    STA SERIAL_PORT
    LDA VMEM_POINTER
    STA SERIAL_PORT
    PLA
    RTS
.)

debug3:
.(
    PHA
    LDA #SERIAL_HEX
    STA SERIAL_PORT+1
    LDA X_COORD
    STA SERIAL_PORT
    LDA Y_COORD
    STA SERIAL_PORT
    PLA
    RTS
.)

.dsb    $fffa-*, $ff    ; filling
* = $fffa
    .word begin
    .word begin
    .word begin
