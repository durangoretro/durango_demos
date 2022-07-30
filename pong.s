; -----------------------------------------------
; Constants
ROM_START = $c000
NEGRO = $00
VERDE = $01
ROJO = $02
NARANJA = $03
BOTELLA = $04
LIMA = $05
LADRILLO = $06
AMARILLO = $07
AZUL = $08
CELESTE = $09
MAGENTA = $0a
ROSITA = $0b
AZUR = $0c
CIAN = $0d
FUCSIA = $0e
BLANCO = $ff
; Functions pointers
VMEM_POINTER = $10 ; $11
X_COORD = $16
Y_COORD = $17
CURRENT_COLOR = $06
; Game pointers
p1_begin = $00


; -----------------------------------------------

; -- main --
*=ROM_START
_main:


; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3F
STA $df80


; Set coords
LDA #$10
STA X_COORD
LDA #$20
STA Y_COORD

JSR convert_coords_to_mem

; Draw pixel
LDA #$11
STA CURRENT_COLOR
STA (VMEM_POINTER), Y

end: JMP end

; ------- FUNCTIONS --------------------------------


; X_COORD, Y_COORD pixel coords
; VMEM_POINTER VMEM_POINTER+1 current video memory pointer
convert_coords_to_mem:
LDX #$00
; Multiply y coord by 64 (64 bytes each row)
LDA Y_COORD
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
ASL
; Also shift more sig byte
TAY
TXA
ROL
TAX
TYA
; Shift less sig byte
; Add to initial memory address, and save it
CLC
ADC VMEM_POINTER
STA VMEM_POINTER

; If overflow, add one to more sig byte
BCC conv_coor_mem_01
INX
conv_coor_mem_01:
; Add calculated offset to VMEM_POINTER+1 (more sig)
TXA
CLC
ADC VMEM_POINTER+1
STA VMEM_POINTER+1

; Calculate X coord
; Divide x coord by 2 (2 pixel each byte)
LDA X_COORD
LSR
; Add to memory address
CLC
ADC VMEM_POINTER
; Store in video memory position
STA VMEM_POINTER
; If overflow, increment left byte
BCC conv_coor_mem_02
INC VMEM_POINTER+1
conv_coor_mem_02:
RTS
; --- end convert_coords_to_mem ---




; --------------------------------------------------

; Fill unused ROM
.dsb $fffa-*, $00

; Set initial PC
* = $fffa
    .word end ; NMI vector
    .word _main ; Reset vector
    .word end ; IRQ/BRK vector
    
