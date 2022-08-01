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
SERIAL_PORT = $df93
CONTROLLER_1 = $df9c
CONTROLLER_2 = $df9d
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
p1_vertical_x = $00
p1_vertical_y = $01



; -- main method --
_main:
.(
	; Set video mode
	LDA #(RGB | SCREEN_3)
	STA VIDEO_MODE
	
	; Init variables
	JSR _init_game

	JSR _draw_background
	JSR _draw_first_player
	JSR _draw_second_player
loop:
	JSR _update_game

	JMP loop

	; End main
	end: JMP end
.)
; -- end main method --

_init_game:
.(
    LDA #2
    STA p1_vertical_x
    LDA #5
    STA p1_vertical_y 
	RTS
.)

; --- Draw background. ---
_draw_background:
.(
    ; Set back color
    LDA #BACKGROUND
    STA CURRENT_COLOR
    JSR fill_screen
	RTS
.)

_draw_first_player:
.(
    ; Set coords
    LDA p1_vertical_x
    STA X_COORD
    LDA p1_vertical_y
    STA Y_COORD
    
    ; Set size
    LDA #PADDLE_WIDTH
    STA SQ_WIDTH
    LDA #PADDLE_HEIGHT
    STA SQ_HEIGHT

    ; Set color
    LDA #VERDE
    STA CURRENT_COLOR

    JSR _draw_square
	RTS
.)

_undraw_first_player:
.(
    ; Set coords
    LDA p1_vertical_x
    STA X_COORD
    LDA p1_vertical_y
    STA Y_COORD
    
    ; Set size
    LDA #PADDLE_WIDTH
    STA SQ_WIDTH
    LDA #PADDLE_HEIGHT
    STA SQ_HEIGHT

    ; Set color
    LDA #BACKGROUND
    STA CURRENT_COLOR

    JSR _draw_square
	RTS
.)

_draw_second_player:
.(
	; Right
	; Set coords
    LDA #118
    STA X_COORD
    LDA #5
    STA Y_COORD

	; Set size
    LDA #PADDLE_WIDTH
    STA SQ_WIDTH
    LDA #PADDLE_HEIGHT
    STA SQ_HEIGHT

	; Set color
    LDA #ROJO
    STA CURRENT_COLOR

    JSR _draw_square
	RTS
.)

_update_game:
.(
	JSR _fetch_gamepads
	    ; Player 1
	    TXA	
	    ; A
	    ASL
	    BCC next1
	    ; START
    next1:	ASL
	    BCC next2
	    ; B
    next2:	ASL
	    BCC next3
	    ; SELECT
    next3:	ASL
	    BCC next4
	    ; UP
    next4:	ASL
	    BCC next5
	    JSR _player1_up
	    ; LEFT
    next5:	ASL
	    BCC next6
	    ; DOWN
    next6:	ASL
	    BCC next7
	    JSR _player1_down
	    ; RIGHT
    next7:	ASL
	    BCC next8
	    ; Player 2
	    TYA
	    ; A
    next8:	ASL
	    BCC next9
	    ; START
    next9:	ASL
	    BCC next10
	    ; B
    next10:	ASL
	    BCC next11
	    ; SELECT
    next11:	ASL
	    BCC next12
	    ; UP
    next12:	ASL
	    BCC next13
	    ; LEFT
    next13:	ASL
	    BCC next14
	    ; DOWN
    next14:	ASL
	    BCC next15
	    ; RIGHT
    next15:	ASL
	    BCC next16	    
    next16:
	    RTS
.)

; Player 1 moves up
_player1_up:
.(
	; Erase current paddle
	JSR _undraw_first_player
	; Move paddle
	DEC p1_vertical_y
	.byte $cb
	; Draw current paddle
	JSR _draw_first_player
	; Return
    RTS
.)

; Player 1 moves down
_player1_down:
.(
    ; Erase current paddle
	JSR _undraw_first_player
	; Move paddle
	INC p1_vertical_y
	; Draw current paddle
	JSR _draw_first_player
	; Return
    RTS
.)

; ============
; --- LIBS ---
; ============

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
	LDA VMEM_POINTER
	CLC
	ADC #$40
	STA VMEM_POINTER
	BCC skip_upper
	INC VMEM_POINTER+1
	skip_upper:
	DEX
	BNE paint_row
	RTS
.)
; --- end draw_square

; Converts x,y coord into memory pointer.
; X_COORD, Y_COORD pixel coords
; VMEM_POINTER VMEM_POINTER+1 current video memory pointer
_convert_coords_to_mem:
.(
    ; Init video pointer
    LDA #$60
    STA VMEM_POINTER+1
    LDA #$00
    STA VMEM_POINTER
    ; Clear X reg
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


; Fill screen with solid color
fill_screen:
.(
    ; Init video pointer
    LDA #$60
    STA VMEM_POINTER+1
    LDA #$00
    STA VMEM_POINTER
loop2:
	; Load current color
	LDA CURRENT_COLOR
    ; Iterate over less significative memory address
    LDY #$00
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop

    ; Iterate over more significative memory address
    INC VMEM_POINTER+1 ; Increment memory pointer Hi address using accumulator
	LDA #$80 ; Compare with end memory position
	CMP VMEM_POINTER+1
    BNE loop2
    RTS
.)
;-- end fill screen ---

; Fetch gamepads
_fetch_gamepads:
.(
	; ---- keys ----
	; A      -> #$80
	; START  -> #$40
	; B      -> #$20
	; SELECT -> #$10
	; UP     -> #$08
	; LEFT   -> #$04
	; DOWN   -> #$02
	; RIGHT  -> #$01
	; --------------
	
	; 1. write into $DF9C
	STA CONTROLLER_1
	; 2. write into $DF9D 8 times
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	STA CONTROLLER_2
	; 4. read first controller
	LDX CONTROLLER_1
	; 5. read second controller
	LDY CONTROLLER_2
	RTS
.)



; --- Aux methods ---
; ===================
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

; I/O->  $df80 - $dfff

; --- Fill unused ROM ---
.dsb $fffa-*, $ff

; --- Vectors ---
* = $fffa
    .word _nmi_int ; NMI vector
    .word _init ; Reset vector
    .word _irq_int ; IRQ/BRK vector
    
