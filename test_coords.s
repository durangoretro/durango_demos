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

LDA #$33
STA Y_COORD
STA VMEM_POINTER+1

LDA #120
STA X_COORD


JSR _convert_coords_to_mem

end: JMP end


; Converts x,y coord into memory pointer.
; X_COORD, Y_COORD pixel coords
; VMEM_POINTER VMEM_POINTER+1 current video memory pointer
_convert_coords_to_mem:
.(
    ; Clear X reg
    LDX #$00
    ; Multiply y coord by 64 (64 bytes each row)
    LDA Y_COORD
    LSR
    STA VMEM_POINTER+1
    ROR VMEM_POINTER    
    ; Sencond shift
    LSR VMEM_POINTER+1
    ROR VMEM_POINTER
    
    JSR debug2
        
    ; Add base memory address
    CLC
    LDA VMEM_POINTER+1
    ADC #$60
    STA VMEM_POINTER+1
    LDA VMEM_POINTER
    ADC #$00
    STA VMEM_POINTER
    
    JSR debug2
    
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
    
    JSR debug2
    
    RTS
.)
; --- end convert_coords_to_mem ---

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


.dsb    $fffa-*, $ff    ; filling
* = $fffa
    .word begin
    .word begin
    .word begin
