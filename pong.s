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
p1_vertical_x = $00
p1_vertical_y = $01
p2_vertical_x = $02
p2_vertical_y = $03

; == 16K ROM. FIRST 8K BLOCK ==
*=$c000
JMP _main

; -- main method --
_main:
.(
	; Set video mode
	LDA #(RGB | SCREEN_3)
	STA VIDEO_MODE
	
	; Init variables
	JSR _init_game_data
	JSR _init_game_screen
	
gameloop:
	; Wait vsync
	JSR _wait_vsync
	; Run game
	JSR _update_game
	; Wait 1 frame
	LDX #$01
	JSR _waitFrames
	; loop
	JMP gameloop

	; End main
	end: JMP end
.)
; -- end main method --

_init_game_data:
.(
    LDA #2
    STA p1_vertical_x
    LDA #5
    STA p1_vertical_y    
    LDA #118
    STA p2_vertical_x
    LDA #5
    STA p2_vertical_y
    RTS
.)

; Init game screen
_init_game_screen:
.(
    JSR _draw_background
    JSR _draw_first_player
    JMP _draw_second_player
.)

; --- Draw background. ---
_draw_background:
.(
    ; Set back color
    LDA #BACKGROUND
    STA CURRENT_COLOR
    JMP fill_screen
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

    JMP _draw_square
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

    JMP _draw_square
.)

_draw_second_player:
.(
    ; Set coords
    LDA p2_vertical_x
    STA X_COORD
    LDA p2_vertical_y
    STA Y_COORD
    
    ; Set size
    LDA #PADDLE_WIDTH
    STA SQ_WIDTH
    LDA #PADDLE_HEIGHT
    STA SQ_HEIGHT

    ; Set color
    LDA #ROJO
    STA CURRENT_COLOR

    JMP _draw_square
.)

_undraw_second_player:
.(
    ; Set coords
    LDA p2_vertical_x
    STA X_COORD
    LDA p2_vertical_y
    STA Y_COORD
    
    ; Set size
    LDA #PADDLE_WIDTH
    STA SQ_WIDTH
    LDA #PADDLE_HEIGHT
    STA SQ_HEIGHT

    ; Set color
    LDA #BACKGROUND
    STA CURRENT_COLOR

    JMP _draw_square
.)

_update_game:
.(	
    ; Player 1
    up1:
    LDA #BUTTON_UP
    BIT CONTROLLER_1
    BEQ down1
    JSR _player1_up

    down1:
    LDA #BUTTON_DOWN
    BIT CONTROLLER_1
    BEQ up2
    JSR _player1_down
    
    up2:
    LDA #BUTTON_UP
    BIT CONTROLLER_2
    BEQ down2
    JSR _player2_up

    down2:
    LDA #BUTTON_DOWN
    BIT CONTROLLER_2
    BEQ end
    JSR _player2_down

    end:
    RTS
.)

; Player 1 moves up
_player1_up:
.(
    ; Erase current paddle
    JSR _undraw_first_player
    ; Move paddle
    DEC p1_vertical_y
    ; Draw current paddle & Return
    JMP _draw_first_player
.)

; Player 1 moves down
_player1_down:
.(
    ; Erase current paddle
    JSR _undraw_first_player
    ; Move paddle
    INC p1_vertical_y
    ; Draw current paddle
    JMP _draw_first_player
.)

; Player 2 moves up
_player2_up:
.(
    ; Erase current paddle
    JSR _undraw_second_player
    ; Move paddle
    DEC p2_vertical_y
    ; Draw current paddle
    JMP _draw_second_player
.)

; Player 2 moves down
_player2_down:
.(
    ; Erase current paddle
    JSR _undraw_second_player
    ; Move paddle
    INC p2_vertical_y
    ; Draw current paddle
    JMP _draw_second_player
.)


.dsb $d000-*, $ff
; ============
; --- LIBS ---
; ============
.asc "#dglib#"

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
    RTS
.)

; Wait for vsync.
_wait_vsync:
.(
    wait_loop:
    BIT $DF88
    BVC wait_loop
    RTS
.)

; Wait frames in X
_waitFrames:
.(
    wait_vsync_end:
    BIT $DF88
    BVS wait_vsync_end
    wait_vsync_begin:
    BIT $DF88
    BVC wait_vsync_begin   
    DEX
    BNE wait_vsync_end
    RTS
.)


; --- Aux methods ---
; ===================
_init:
.(
    SEI	      ; Disable interrupts
    LDX #$FF  ; Initialize stack pointer to $01FF
    TXS
    CLD       ; Clear decimal mode
    LDA #$01
    STA $DFA0
    CLI       ; Enable interrupts
    JMP $c000
.)
_stop:
.(
    end: JMP end
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
    JSR _fetch_gamepads
    
    ; Return from interrupt
    PLA                    ; Restore accumulator contents
    PLX                    ; Restore X register contents
    RTI                    ; Return from all IRQ interrupts
.)
; --------------------------------------------------


#if(*>$df80)
#echo First segment is too big!
#endif
.dsb $df80-*, $ff
; === END OF FIRST 8K BLOCK ===

; === RESERVED IO SPACE ($df80 - $dfff) ===
* = $df80
.asc "DURANGO"
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.asc "*ROM cooked by:*"
.asc "** emiliollbb **"
; === END OF RESERVED IO SPACE ===

; === 16K ROM. SECOND 8K BLOCK ===
.asc "Second block"
.dsb $fffa-*, $ff
; === END OF SECOND 8K BLOCK ===


; === VECTORS ===
* = $fffa
    .word _nmi_int ; NMI vector
    .word _init ; Reset vector
    .word _irq_int ; IRQ/BRK vector
    
