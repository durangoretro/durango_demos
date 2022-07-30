; -- Constants --
ROM_START = $c000
*=ROM_START
VIDEO_MODE = $df80
HIRES = $80
INVERT = $40
SCREEN_0 = $00
SCREEN_1 = $10
SCREEN_2 = $20
SCREEN_3 = $30
RGB = $08
LED = $04
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
CURRENT_COLOR = $06

; -- Global Game vars pointers --
p1_begin = $00



; -- main method --
_main:
.(
    ; Set video mode
    LDA #(RGB | SCREEN_3)
    STA VIDEO_MODE
    ; Init video pointer
    LDA #$60
    STA VMEM_POINTER+1
    LDA #$00
    STA VMEM_POINTER

    ; Set coords
    LDA #10
    STA X_COORD
    LDA #20
    STA Y_COORD

    ; Set color
    LDA CIAN
    STA CURRENT_COLOR

    JSR _convert_coords_to_mem


    ; Draw pixel
    LDA #$11
    STA CURRENT_COLOR
    STA (VMEM_POINTER), Y

    end: JMP end
.)
; -- end main method --

; ------- FUNCTIONS --------------------------------


; X_COORD, Y_COORD pixel coords
; VMEM_POINTER VMEM_POINTER+1 current video memory pointer
_convert_coords_to_mem:
.(
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
.)
; --- end convert_coords_to_mem ---

_init:
.(
    LDX #$FF  ; Initialize stack pointer to $01FF
    TXS
    CLD       ; Clear decimal mode
    SEI       ; Disable interrupts
    JSR _main
.)

_stop:
.(
    .byte $DB
.)

_nmi_int:
.(
    BRK
    RTI
.)

_irq_int:
.(
    ; Filter interrupt
    PHX         ; Save X register contents to stack
    TSX         ; Transfer stack pointer to X
    PHA         ; Save accumulator contents to stack
    LDA $102,X  ; Load status register contents
    AND #$10    ; Isolate B status bit
    BNE _stop   ; If B = 1, BRK detected
    ; Actual interrupt code
    NOP
    ; Return from interrupt
    PLA                    ; Restore accumulator contents
    PLX                    ; Restore X register contents
    RTI                    ; Return from all IRQ interrupts
.)


; --------------------------------------------------

; Fill unused ROM
.dsb $fffa-*, $00

; Set initial PC
* = $fffa
    .word _nmi_int ; NMI vector
    .word _init ; Reset vector
    .word _irq_int ; IRQ/BRK vector
    
