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
KEYBOARD = $df9b
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
KEY_1 = $01
KEY_Q = $02
KEY_0 = $08
KEY_P = $10
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
VMEM_POINTER = $a0 ; $a1
TILE_TO_DRAW = $a2 ; $a3
MAP_TO_DRAW = $a4 ; a5
X_COORD = $a6
Y_COORD = $a7
SQ_WIDTH = $a8
SQ_HEIGHT = $a9
DRAW_BUFFER = $aa
CURRENT_COLOR = $ab
TEMP1 = $ac
TEMP2 = $ad
GAMEPAD_CLEAN1 = $b0
GAMEPAD_CLEAN2 = $b1
GAMEPAD1 = $b2
GAMEPAD2 = $b3
KEYBOARD_CACHE = $b4
RANDOM = $b5

; -- Global Game constants --
PADDLE_WIDTH = 8
PADDLE_WIDTH_HALF = PADDLE_WIDTH / 2
PADDLE_HEIGHT =32
BACKGROUND = ROSITA
SCORES = MAGENTA
SCORES_HEIGHT = 8
; -- Global Game vars pointers --
p1_vertical_x = $0200
p2_vertical_x = $0201
p1_vertical_y = $0202
p2_vertical_y = $0203
p1_horizontal_x = $0204
p2_horizontal_x = $0205
p1_horizontal_y = $0206
p2_horizontal_y = $0207
p1vertxmem = $00 ; $01
p1vertxmem2 = $02 ; $03
p2vertxmem = $04 ; 05
p2vertxmem2 = $06 ; 07
ballmem = $08; 09
ball_x = $0a
ball_y = $0b
ball_vx = $0c
ball_vy = $0d
p1_score = $0e
p2_score = $0f
level = $10

; == 16K ROM. FIRST 8K BLOCK ==
*=$c000

; ------------------ HEADER ---------------------------------------
; 8 bytes
.byt $00
.byt "dX"
.byt "****"
.byt $0d

; 222 bytes
; TITLE_COMMENT[
.byt "PONG"
.byt $00
.byt "Classic pong game"
.byt $00
.byt "##################################################"
.byt "##################################################"
.byt "##################################################"
.byt "#################################################";]


; 18 bytes
;DCLIB_COMMIT[
.byt "LLLLLLLL"
;]
;MAIN_COMMIT[
.byt "MMMMMMMM"
;]
;VERSION[
.byt "VV"
;]

; 8 bytes
;TIME[
.byt "TT"
;]
;DATE[
.byt "DD"
;]
;FILEZISE[
.byt $00,$40,$00,$00
;]
; -----------------------------------------------------------------

.asc "#game#"
; -- main method --
_main:
.(
	; Set video mode
	LDA #(RGB | SCREEN_3 | LED)
	STA VIDEO_MODE
    LDA #$60
    STA DRAW_BUFFER
    
    ; Enable debug
    LDA #$F2
    STA $df94
    
    ; Initialize level
    LDA #1
    STA level
	
	; Display title for 120 frames
    JSR _draw_title
	JSR _wait_start
    
    ; Init
	JSR _init_game
	
gameloop:
	; Wait vsync
	JSR _wait_vsync
	; Run game
	JSR _update_game
	; Wait vsync end
	JSR _wait_vsync_end
	; loop
	JMP gameloop
.)
; -- end main method --

_init_game:
.(
    ; Fill bacground
    LDA #BACKGROUND
    JSR fill_screen
    
    ; Scores
    JSR _draw_scores
    
    ; Set size
    LDY #PADDLE_WIDTH
    STY SQ_WIDTH
    LDY #PADDLE_HEIGHT
    STY SQ_HEIGHT
    
    ; Draw paddles
    LDA #2
    STA p1_vertical_x
    STA X_COORD
    LDA #40
    STA p1_vertical_y 
    STA p2_vertical_y
    STA Y_COORD    
    JSR _convert_coords_to_mem
    LDA VMEM_POINTER
    LDX VMEM_POINTER+1
    STA p1vertxmem
    STX p1vertxmem+1
    LDA #VERDE
    JSR _draw_square    
    LDA VMEM_POINTER
    LDX VMEM_POINTER+1
    STA p1vertxmem2
    STX p1vertxmem2+1
    
    ; Second player
    LDA #118
    STA p2_vertical_x
    STA X_COORD
    JSR _convert_coords_to_mem
    LDA VMEM_POINTER
    LDX VMEM_POINTER+1
    STA p2vertxmem
    STX p2vertxmem+1
    LDA #ROJO
    JSR _draw_square    
    LDA VMEM_POINTER
    LDX VMEM_POINTER+1
    STA p2vertxmem2
    STX p2vertxmem2+1
    
    ; Init ball
    JMP _init_ball
.)

_draw_scores:
.(
    ; Init scores data
    LDA #4
    STA p1_score
    LDA #116
    STA p2_score
    
    ; Scores section background
    LDA #SCORES
    LDY #128
    STY SQ_WIDTH
    LDY #SCORES_HEIGHT
    STY SQ_HEIGHT
    LDX DRAW_BUFFER
    STX VMEM_POINTER+1
    STZ VMEM_POINTER
    JSR _draw_square
    
    LDX #4
loop:        
    TXA
    PHX
    LDY #1
    STA X_COORD
    STY Y_COORD    
    JSR _convert_coords_to_mem
    LDA #SCORES_HEIGHT-2
    STA SQ_WIDTH
    STA SQ_HEIGHT
    LDA #BACKGROUND
    JSR _draw_square
    
    PLA
    ADC #8
    TAX
    CPX #124
    BNE loop
    
    RTS
.)

_draw_point:
.(
    STX X_COORD
    PHA
    LDY #1
    STY Y_COORD
    JSR _convert_coords_to_mem
    LDA #SCORES_HEIGHT-2
    STA SQ_WIDTH
    STA SQ_HEIGHT
    PLA
    JMP _draw_square
    RTS
.)

_point1p:
.(
    LDX p1_score
    LDA #VERDE
    JSR _draw_point
    
    LDA p1_score
    CLC
    ADC #8
    STA p1_score
      
    RTS
.)

_point2p:
.(
    LDX p2_score
    LDA #ROJO
    JSR _draw_point
    
    LDA p2_score
    SEC
    SBC #8
    STA p2_score
      
    RTS
.)

_init_ball:
.(
    LDX RANDOM
    LDY level
    BEQ easy
    LDA vx_table,X
    BRA next
    easy:
    LDA vy_table,X
    next:
    LDY vy_table,X
	STA ball_vx
	STY ball_vy    
    LDA #62
    STA ball_x
    STA ball_y    
    JMP _draw_ball
.)

vx_table: .byt $02, $fe, $02, $fe
vy_table: .byt $01, $ff, $ff, $01

_draw_ball:
.(
    LDA ball_x
    LDX ball_y
    STA X_COORD
    STX Y_COORD    
    JSR _convert_coords_to_mem
	LDA VMEM_POINTER
    LDX VMEM_POINTER+1
	STA ballmem
    STX ballmem+1
    
    LDA #4
    STA SQ_WIDTH
    STA SQ_HEIGHT
    LDA #AZUR
    JMP _draw_square

    RTS
.)

_update_game:
.(	
	; Player 1
    up1:
    LDA #BUTTON_UP
    BIT GAMEPAD1
    BEQ kup1
    JSR _player1_up
	JSR _player1_up
    
    kup1:
    LDA #KEY_1
    BIT KEYBOARD_CACHE
    BEQ down1
    JSR _player1_up
	JSR _player1_up 

    down1:
    LDA #BUTTON_DOWN
    BIT GAMEPAD1
    BEQ kdown1
    JSR _player1_down
	JSR _player1_down
    
    kdown1:
    LDA #KEY_Q
    BIT KEYBOARD_CACHE
    BEQ up2
    JSR _player1_down
	JSR _player1_down
    
    up2:
    LDA #BUTTON_UP
    BIT GAMEPAD2
    BEQ Kup2
    JSR _player2_up
	JSR _player2_up
    
    Kup2:
    LDA #KEY_0
    BIT KEYBOARD_CACHE
    BEQ down2
    JSR _player2_up
	JSR _player2_up

    down2:
    LDA #BUTTON_DOWN
    BIT GAMEPAD2
    BEQ Kdown2
    JSR _player2_down
	JSR _player2_down
    
    Kdown2:
    LDA #KEY_P
    BIT KEYBOARD_CACHE
    BEQ end
    JSR _player2_down
	JSR _player2_down

	end:    
	JSR _check_collisions
	JMP _move_ball    
.)

_update_level:
.(
    LDA KEYBOARD_CACHE
    ASL
    BCC skip
    LDX #1
    STX level
    skip:
    
    ASL
    ASL
    BCC skip2
    STZ level
    skip2:
    
    RTS
.)

; Player 1 moves up
_player1_up:
.(
    ; Check not game end
    LDA ball_vx
    BNE ingame
    RTS
    ingame:

    LDA p1_vertical_y
    CMP #SCORES_HEIGHT
    BNE ok
    RTS
    ok:    
    
    DEC p1_vertical_y
    
    SEC
    LDA p1vertxmem
    SBC #$40
    STA p1vertxmem
    BCS skip1
    DEC p1vertxmem+1
    skip1:
    
    SEC
    LDA p1vertxmem2
    SBC #$40
    STA p1vertxmem2
    BCS skip2
    DEC p1vertxmem2+1
    skip2: 
    
    LDA #VERDE
    LDY #PADDLE_WIDTH_HALF
    DEY
    PHY
loop:
    STA (p1vertxmem),Y
    DEY
    BPL loop
    PLY
    LDA #BACKGROUND
loop2:
    STA (p1vertxmem2),Y
    DEY
    BPL loop2    
    RTS
.)

; Player 1 moves down
_player1_down:
.(
    ; Check not game end
    LDA ball_vx
    BNE ingame
    RTS
    ingame:
    
    LDA #96
    CMP p1_vertical_y
    BNE ok
    RTS
    ok:
    
    INC p1_vertical_y
    
    LDA #BACKGROUND
    LDY #PADDLE_WIDTH_HALF
    DEY
    PHY
loop:
    STA (p1vertxmem),Y
    DEY
    BPL loop
    PLY
    LDA #VERDE
loop2:
    STA (p1vertxmem2),Y
    DEY
    BPL loop2    
    
    CLC
    LDA p1vertxmem
    ADC #$40
    STA p1vertxmem
    BCC skip1
    INC p1vertxmem+1
    skip1:
    
    CLC
    LDA p1vertxmem2
    ADC #$40
    STA p1vertxmem2
    BCC skip2
    INC p1vertxmem2+1
    skip2: 
    
    RTS
.)

_player2_up:
.(
    ; Check not game end
    LDA ball_vx
    CMP #SCORES_HEIGHT
    BNE ingame
    RTS
    ingame:
    
    LDA p2_vertical_y
    CMP #SCORES_HEIGHT
    BNE ok
    RTS
    ok: 
    
    DEC p2_vertical_y
    
    SEC
    LDA p2vertxmem
    SBC #$40
    STA p2vertxmem
    BCS skip1
    DEC p2vertxmem+1
    skip1:
    
    SEC
    LDA p2vertxmem2
    SBC #$40
    STA p2vertxmem2
    BCS skip2
    DEC p2vertxmem2+1
    skip2: 
    
    LDA #ROJO
    LDY #PADDLE_WIDTH_HALF
    DEY
    PHY
loop:
    STA (p2vertxmem),Y
    DEY
    BPL loop
    PLY
    LDA #BACKGROUND
loop2:
    STA (p2vertxmem2),Y
    DEY
    BPL loop2
    RTS
.)
_player2_down:
.(
    ; Check not game end
    LDA ball_vx
    BNE ingame
    RTS
    ingame:
    
    LDA #96
    CMP p2_vertical_y
    BNE ok
    RTS
    ok:
    
    INC p2_vertical_y
    
    LDA #BACKGROUND
    LDY #PADDLE_WIDTH_HALF
    DEY
    PHY
loop:
    STA (p2vertxmem),Y
    DEY
    BPL loop
    PLY
    LDA #ROJO
loop2:
    STA (p2vertxmem2),Y
    DEY
    BPL loop2    
    
    CLC
    LDA p2vertxmem
    ADC #$40
    STA p2vertxmem
    BCC skip1
    INC p2vertxmem+1
    skip1:
    
    CLC
    LDA p2vertxmem2
    ADC #$40
    STA p2vertxmem2
    BCC skip2
    INC p2vertxmem2+1
    skip2:
    
    RTS
.)

_clean_ball:
.(
    ; Clean old ball
    LDA ballmem
    LDX ballmem+1
    STA VMEM_POINTER
    STX VMEM_POINTER+1
    LDA #4
    STA SQ_WIDTH
    STA SQ_HEIGHT
    LDA #BACKGROUND
    JMP _draw_square  
.)

_reset_ball:
.(
    JSR _clean_ball
    JMP _init_ball
.)

_move_ball:
.(
    ; Clean old ball
    JSR _clean_ball    

    ; Update x coord
    LDA ball_x
    CLC
    ADC ball_vx
    STA ball_x

    ; Update y coord
    LDA ball_y
    CLC
    ADC ball_vy
    STA ball_y

    ; Draw new ball
    JMP _draw_ball
.)

_check_collisions:
.(
    ; End game
    LDA p2_score
    CMP p1_score
    BCS not_end
    JMP _stop
    not_end:

    ; Check right paddle
    right_paddle:
    LDX ball_x
    CPX #114
    BNE left_paddle
    LDX ball_y
    CPX p2_vertical_y
    BCC right_crash
    LDA p2_vertical_y
    CLC
    ADC #PADDLE_HEIGHT
    CMP ball_y
    BCC right_crash
    LDA level
    BEQ easy
    LDA #$fe
    BRA next
    easy:
    LDA #$ff
    next:
    STA ball_vx
    BRA left_paddle
    right_crash:
    LDA #0
    STA ball_vx
    STA ball_vy
    JSR _point1p
    JSR _wait_start
    JSR _reset_ball
    
    ; Check left paddle
    left_paddle:
    LDX ball_x
    CPX #2+PADDLE_WIDTH
    BNE top
    LDX ball_y
    CPX p1_vertical_y
    BCC left_crash
    LDA p1_vertical_y
    CLC
    ADC #PADDLE_HEIGHT
    CMP ball_y
    BCC left_crash
    LDA level
    BEQ easy2
    LDA #2
    BRA next2
    easy2:
    LDA #1    
    next2:
    STA ball_vx
    BRA top
    left_crash:
    LDA #0
    STA ball_vx
    STA ball_vy
    JSR _point2p
    JSR _wait_start
    JSR _reset_ball

    ; check top collision
    top:
    LDA ball_y
    CMP #SCORES_HEIGHT
    BNE bottom
    LDA #1
    STA ball_vy
    
    ; check bottom collision
    bottom:
    LDX ball_y
    CPX #124
    BNE left
    LDA #$ff
    STA ball_vy

    ; check left collision
    left:
    LDX ball_x
    BNE end
    LDA #2
    STA ball_vx

    
    
    end:
    RTS
.)


_draw_title:
.(
    ; $14, $15 tilemap to draw
    LDA #>pong_img ; MSB
    STA MAP_TO_DRAW+1
    LDA #<pong_img ; LSB
    STA MAP_TO_DRAW
    ; Draw map 1
    JMP _draw_image
.)

.asc "#end game#"


.dsb $d000-*, $ff
; ============
; --- LIBS ---
; ============
.asc "#dglib#"

; Draw square
; X_COORD, Y_COORD, SQ_WIDTH, SQ_HEIGHT
; TEMP1
_draw_square:
.(
    PHA 
    ; Divide width by 2
	LDA SQ_WIDTH
	LSR
    STA TEMP1    
    PLA

	; Load height in x
	LDX SQ_HEIGHT
	paint_row:
    LDY TEMP1
	; Draw as many pixels as Y register says
    DEY
	paint:
	STA (VMEM_POINTER), Y
	DEY
	BPL paint

	; Next row
	PHA
    LDA VMEM_POINTER
	CLC
	ADC #$40
	STA VMEM_POINTER
	BCC skip_upper
	INC VMEM_POINTER+1
 	skip_upper:
	PLA
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
    ; Calculate Y coord
    ; Clear VMEM_POINTER
    STZ VMEM_POINTER
    ; Multiply y coord by 64 (64 bytes each row)
    LDA Y_COORD
    LSR
    ROR VMEM_POINTER
    LSR
    ROR VMEM_POINTER
    
    ; Add base memory address
    ADC DRAW_BUFFER
    STA VMEM_POINTER+1
        
    ; Calculate X coord
    ; Divide x coord by 2 (2 pixel each byte)
    LDA X_COORD
    LSR
    ; Add to memory address
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:

	RTS
.)
; --- end convert_coords_to_mem ---


; Fill screen with solid color
fill_screen:
.(
    ; Init video pointer
    LDX DRAW_BUFFER
    STX VMEM_POINTER+1
    LDY #$00
    STY VMEM_POINTER
    ; Load current color
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.)
;-- end fill screen ---

; Fetch gamepads
_fetch_gamepads:
.(
    ; 1. write into $DF9C
    STA CONTROLLER_1
    ; 2. write into $DF9D 8 times
    LDX #8
    loop:
    STA CONTROLLER_2			; OK, aunque creo que tampoco pasa nada por usar un bucle... preferiblemente con X, que ya ha salvado la ISR
    DEX
    BNE loop
    LDA CONTROLLER_1
    EOR GAMEPAD_CLEAN1
    STA GAMEPAD1
    LDA CONTROLLER_2
    EOR GAMEPAD_CLEAN2
    STA GAMEPAD2
    RTS
.)

_fetch_keyboard:
.(
    LDA #1
    STA KEYBOARD
    LDA KEYBOARD
    STA KEYBOARD_CACHE
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

; Wait for vsync end.
_wait_vsync_end:
.(
    wait_loop:
    BIT $DF88
    BVS wait_loop
    RTS
.)

; Wait frames in X
_wait_frames:
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

; Wait START button
_wait_start:
.(
    loop:
    INC RANDOM
    BIT GAMEPAD1
    BMI exit_loop
    BVS exit_loop
    BIT GAMEPAD2
    BMI exit_loop
    BVS exit_loop
    LDA KEYBOARD_CACHE
    ASL
    ASL
    BCS exit_loop
    BRA loop
    exit_loop:
    LDA RANDOM
    AND #$03
    STA RANDOM
    RTS
.)



; -- -- -- -- -- -- 
; $14, $15 tilemap to draw
; MAP_TO_DRAW, MAP_TO_DRAW+1 tilemap to draw
draw_map:
.(
    ; Init video pointer
    LDA DRAW_BUFFER
    STA VMEM_POINTER+1
    STZ VMEM_POINTER				; STZ se puede usar *** insisto ;-)
    
    ; $07 tiles rows counter
    ;LDA #$a0
    LDA #$10 ; Count 16 with temp1
    STA TEMP1
    draw_map_loop1:
    ; First tiles row. 16 tiles
    LDX #15							; *** CUIDADO! si son 16 iteraciones, o pones BPL en el bucle (recomendado), o cargas con 16 y usas BNE
    ; Draw tile
    row_loop:
    PHX								; *** correcto, también puede ponerse en memoria, aunque tal vez no valga la pena
    JSR convert_tile_index_to_mem	; en general, repetir código que llama a funciones lentas no vale la pena, mejor un bucle; la ventaja en velocidad así es pírrica *** OK
    JSR draw_back_tile
    PLX
    INC MAP_TO_DRAW
    DEX
    BNE row_loop					; *** véase nota anterior, tal vez debas usar BPL
    
    INC MAP_TO_DRAW

    ; Change row
    STZ VMEM_POINTER		; CMOS puede usar STZ *** OK
    INC VMEM_POINTER+1
    INC VMEM_POINTER+1
    DEC TEMP1				; muy bien, los bucles lentos pueden estar en memoria; al no usar el índice, va bien el BEQ
    BEQ draw_map_end		; *** no tiene sentido este BEQ/BNE ahora que el código es más compacto, quita esta línea
    BNE draw_map_loop1		; (quizá con bucles interiores podrías saltar directamente con BNE) *** OK
    draw_map_end:
  
    RTS
.)
;------------------------------------------------------

; Input MAP_TO_DRAW, MAP_TO_DRAW+1 tilemap to draw
; output TILE_TO_DRAW, TILE_TO_DRAW+1 tile to draw (initial position in mem)
convert_tile_index_to_mem:
.(
    STZ TILE_TO_DRAW    
    ; Load tile index in X
    LDA (MAP_TO_DRAW)	; en CMOS es posible hacer LDA (MAP_TO_DRAW) sin indexar... con permiso de CA65 >-( *** OK
    
    LSR
	ROR TILE_TO_DRAW
	LSR
	ROR TILE_TO_DRAW
	LSR
	ROR TILE_TO_DRAW	; puesto a cero, tras 3 rotaciones C es cero SEGURO
    
    ADC #>TILESET_START		; asumimos que <TILESET_START es siempre cero?
    STA TILE_TO_DRAW+1

    RTS
.)
; --------------------------------------------------------

;TILE_TO_DRAW, TILE_TO_DRAW+1 -> tile number, tile bank
;VMEM_POINTER,VMEM_POINTER+1 -> screen position
;$09 backup of VMEM_POINTER original value
draw_back_tile:
.(
    ; Save screen position and backup in stash
    LDA VMEM_POINTER
    PHA
    LDX #7
    loop:
    ; First row
    LDY #$00
    LDA (TILE_TO_DRAW), Y		; esta parte es buena que no sea bucle, porque afectaría mucho al rendimiento (13t + 3 del bucle)
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    BCC skip_upper1
    INC VMEM_POINTER+1
    skip_upper1:
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    DEX
    BNE loop
    
    ; Eight row
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y
    INY
    LDA (TILE_TO_DRAW), Y
    STA (VMEM_POINTER), Y

    ; Finalize tile drawing
    DEC VMEM_POINTER+1; Restore VMEM_POINTER+1 to original value, so next tile is at same row
    PLA ; Restore VMEM_POINTER using backup and add 0x04 to set at next screen position 
    CLC
    ADC #$04
    STA VMEM_POINTER
    RTS
.)

_draw_image:
.(
    ; Init video pointer
    LDA DRAW_BUFFER
    STA VMEM_POINTER+1
    STZ VMEM_POINTER
rle_loop:
		LDY #0				; always needed as part of the loop
		LDA (MAP_TO_DRAW), Y		; get command
		INC MAP_TO_DRAW				; advance read pointer
		BNE rle_0
			INC MAP_TO_DRAW+1
rle_0:
		TAX					; command is just a counter
			BMI rle_u		; negative count means uncompressed string
; * compressed string decoding ahead *
		BEQ rle_exit		; 0 repetitions means end of 'file'
; multiply next byte according to count
		LDA (MAP_TO_DRAW), Y		; read immediate value to be repeated
rc_loop:
			STA (VMEM_POINTER), Y	; store one copy
			INY				; next copy, will never wrap as <= 127
			DEX				; one less to go
			BNE rc_loop
; burst generated, must advance to next command!
		INC MAP_TO_DRAW
		BNE rle_next		; usually will skip to common code
			INC MAP_TO_DRAW+1
			BNE rle_next	; no need for BRA
; alternate code, more compact but a bit slower
;		LDA #1
;		BNE rle_adv			; just advance source by 1 byte
; * uncompressed string decoding ahead *
rle_u:
			LDA (MAP_TO_DRAW), Y	; read immediate value to be sent, just once
			STA (VMEM_POINTER), Y	; store it just once
			INY				; next byte in chunk, will never wrap as <= 127
			INX				; one less to go
			BNE rle_u
		TYA					; how many were read?
rle_adv:
		CLC
		ADC MAP_TO_DRAW				; advance source pointer accordingly (will do the same with destination)
		STA MAP_TO_DRAW
		BCC rle_next		; check possible carry
			INC MAP_TO_DRAW+1
; * common code for destination advence, either from compressed or un compressed
rle_next:
		TYA					; once again, these were the transferred/repeated bytes
		CLC
		ADC VMEM_POINTER				; advance desetination pointer accordingly
		STA VMEM_POINTER
		BCC rle_loop		; check possible carry
			INC VMEM_POINTER+1
		BNE rle_loop		; no need for BRA
; *** end of code ***
rle_exit:
RTS
.)
;--------------------------------------------------------


.asc "#dclib#"
; ===== DCLIB CONSTANTS ================================================
INT_ENABLE = $DFA0
VSP = $DF93
VSP_CONFIG = $DF94
SYNC = $DF88
IOBEEP=$DFB0
GAMEPAD_MODE1 = $00
GAMEPAD_MODE2 = $01
GAMEPAD_VALUE1 = $02
GAMEPAD_VALUE2 = $03
IRQ_ADDR = $0200
NMI_ADDR = $0202
INT_COUNTER = $0206
KEY_PRESSED = $020A
SIGNATURE = $FFAB
BUILD_HASH = $C0E6
DATA_POINTER = $12 ; $13
RESOURCE_POINTER = $14 ; $15
BACKGROUND_POINTER = $16; $17
RANDOM_SEED = $18; $19
COLOUR = $1A
PAPER = $1B
X2_COORD = $1E
Y2_COORD = $1F
X3_COORD = $20
Y3_COORD = $21
X4_COORD = $22
Y4_COORD = $23
HEIGHT = $24
WIDTH = $25
HEIGHT2 = $26
WIDTH2 = $27
TEMP3 = $2A
TEMP4 = $2B
TEMP5 = $2C
TEMP6 = $2D
TEMP7 = $2E
TEMP8 = $2F
TEMP11 = $020A
TEMP12 = $020B
TEMP13 = $020C
TEMP14 = $020D
TEMP15 = $020E
TEMP16 = $020F
TEMP17 = $0210
TEMP18 = $0211
TEMP19 = $0212
TEMP20 = $0213
VSP_FOPEN = $11
VSP_FREAD = $12
VSP_FWRITE = $13
VSP_FCLOSE = $1F
PSV_RAW_INIT  = $20
PSV_RAW_SEEK  = $21
PSV_RAW_READ  = $22
PSV_RAW_WRITE = $23
PSV_RAW_CLOSE = $24
VSP_HEX = $F0
VSP_ASCII = $F1
VSP_BINARY = $F2
VSP_DECIMAL = $F3
VSP_INT16 = $F4
VSP_HEX16 = $F5
VSP_INT8  = $F6
VSP_INT32 = $F7
VSP_STOPWATCH_START = $FB
VSP_STOPWATCH_STOP = $FC
VSP_DUMP = $FD
VSP_STACK = $FE
VSP_STAT = $FF
BLACK = $00
GREEN = $11
RED = $22
ORANGE = $33
PHARMACY_GREEN = $44
LIME = $55
MYSTIC_RED = $66
YELLOW = $77
BLUE = $88
DEEP_SKY_BLUE = $99
LAVENDER_ROSE = $bb
NAVY_BLUE = $cc
PINK_FLAMINGO = $ee
WHITE = $ff
;=======================================================================
; === PROCEDURES FROM DCLIB ============================================
; --- common.s ----
coords2mem:
.(
    ; Calculate Y coord
    STZ VMEM_POINTER
    LDA Y_COORD
    LSR
    ROR VMEM_POINTER
    LSR
    ROR VMEM_POINTER
    ADC #$60
    STA VMEM_POINTER+1
    ; Calculate X coord
    LDA X_COORD
    LSR
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    BCC skip_upper
    INC VMEM_POINTER+1
    skip_upper:
    RTS
.)
readchar:
.(
    ; Load keyboard status
    LDA KEYBOARD_CACHE
    STA TEMP11    
    LDA KEYBOARD_CACHE+1
    STA TEMP12    
    LDA KEYBOARD_CACHE+2
    STA TEMP13    
    LDA KEYBOARD_CACHE+3
    STA TEMP14    
    LDA KEYBOARD_CACHE+4
    STA TEMP15
    LDX #0
    LDY #40

    loop:
    ; Rotate
    ASL TEMP15
    ROL TEMP14
    ROL TEMP13
    ROL TEMP12
    ROL TEMP11
    BCS end
    INX
    DEY
    BNE loop
    LDA #0
    RTS
    
    end:
    LDA keymap,X
    RTS

	keymap:
	; SPACE, INTRO, SHIFT, P,  O,   A,   Q,   1
	.byte $20, $0a, $00, $50, $30, $41, $51, $31
	;   ALT,    L,   Z,   0,   9,   S,   W,   2
	.byte $00, $4c, $5a, $4f, $39, $53, $57, $32
	;      M,   K,   X,   I,  8,    D,   E,   3
	.byte $4d, $4b, $58, $49, $38, $44, $45, $33
	;      N,   J,   C,   U,   7,   F,   R,   4
	.byte $4e, $4a, $43, $55, $37, $46, $52, $34
	;      B,   H,   V,   Y,   6,   G,   T,   5
	.byte $42, $48, $56, $59, $36, $47, $54, $35
.)

; ---glyph.s -----

; X_COORD
; Y_COORD
; COLOUR
; PAPER
; DATA_POINTER: pointer to string
_printStr:
.(
    ; Load default font
	LDA #<default_font
    STA RESOURCE_POINTER    
    LDA #>default_font
    STA RESOURCE_POINTER+1      

    ; Calculate coords
    JSR coords2mem
	STZ TEMP1
    
	; Draw string
    JSR draw_str
	RTS
.)
draw_str:
.(
	; Backup resource pointer
    LDX RESOURCE_POINTER
	STX TEMP3
	LDX RESOURCE_POINTER+1
	STX TEMP4
    
    ; Iterate string
    LDY #$00
    loop:
    LDA (DATA_POINTER),Y
    BEQ end
    PHY
    JSR find_letter
	JSR type_letter
	; Restore resource pointer
	LDX TEMP3
	STX RESOURCE_POINTER
	LDX TEMP4
	STX RESOURCE_POINTER+1
    PLY
    INY
    BNE loop
    end:
    RTS
.)
find_letter:
.(
	TAX
	BEQ end
	LDA RESOURCE_POINTER
	loop:
	CLC
	ADC #5
	STA RESOURCE_POINTER
	BCC skip
	INC RESOURCE_POINTER+1
	skip:
	DEX
	BNE loop
	end:
	RTS
.)
type_letter:
.(
	; Save vmem pointer
	LDA VMEM_POINTER
	PHA
	LDA VMEM_POINTER+1
	PHA
	
	; Load First byte
	LDY #$00
	LDA (RESOURCE_POINTER),Y
	; Type row 1
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry

	; Type row 2
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$01
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 3
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 4
	JSR next_row
	ASL
	JSR type_carry
	LDY #$02
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 5
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$03
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	
	; Type row 6
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 7
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	LDY #$04
	LDA (RESOURCE_POINTER),Y
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Type row 8
	JSR next_row
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	ASL
	JSR type_carry
	
	; Restore VMEM POINTER
	PLA
	STA VMEM_POINTER+1
	PLA
	STA VMEM_POINTER
	
	JMP next_letter
.)
next_row:
.(
	PHA
	STZ TEMP1
	LDA VMEM_POINTER
	CLC
	ADC #62
	STA VMEM_POINTER
	BCC skip
	INC VMEM_POINTER+1	
	skip:
	PLA
	RTS
.)
type_carry:
.(
	; Keep A
	PHA
	; If carry set
	BCC carry_set
		; Load ink color
		LDA COLOUR
	; else
	BRA end
	carry_set:
		; Load paper color
		LDA PAPER
	;end if
	end:
	JSR type
	; Restore A
	PLA
	RTS
.)
next_letter:
.(
	STZ TEMP1
	LDA VMEM_POINTER
	CLC
	ADC #3
	STA VMEM_POINTER
	BCC skip
	INC VMEM_POINTER+1	
	skip:
	RTS
.)
type:
.(
	; If left pixel
	BIT TEMP1
	BMI right_pixel
	; then
		; Keep left pixel from color
		AND #$F0
		; Store single color in temp2
		STA TEMP2
		; Load original pixel pair
		LDA (VMEM_POINTER)
		; Clear left pixel
		AND #$0F
		; Paint left pixel
		ORA TEMP2
		; Save pixel pair
		STA (VMEM_POINTER)
		; Increment position
		CLC
		LDA #%10000000
		ADC TEMP1
		STA TEMP1
	; else
	BRA end
	right_pixel:
	; then
		; Keep right pixel from color
		AND #$0F
		; Store single color in temp2
		STA TEMP2
		; Load original pixel pair
		LDA (VMEM_POINTER)
		; Clear right pixel
		AND #$F0
		; Paint left pixel
		ORA TEMP2
		; Save pixel pair
		STA (VMEM_POINTER)
		; Increment position
		CLC
		LDA #%10000000
		ADC TEMP1
		STA TEMP1
		INC VMEM_POINTER
		BNE end
		INC VMEM_POINTER+1
	; end if
	end:
	RTS
.)
; -- qgraph.s
; COLOUR
_fillScreen:
.(
    ; Init video pointer
    LDX #$60
    STX VMEM_POINTER+1
    LDY #$00
    STY VMEM_POINTER
    ; Load current color
	LDA COLOUR
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
	INC VMEM_POINTER+1
    BPL loop
    RTS
.)

;-- Font --
default_font:
.byt $FC,$63,$18,$C6,$3F,$30,$84,$21,$08,$4F,$F8,$43,$F8,$42,$1F,$F8,$43,$F0,$84,$3F,$8C,$63,$F0,$84,$21,$FC,$21,$F0,$84,$3F,$FC,$21,
.byt $0F,$C6,$3F,$F8,$42,$10,$84,$21,$FC,$63,$F8,$C6,$3F,$FC,$63,$F0,$84,$21,$FC,$63,$F8,$C6,$31,$84,$21,$0F,$C6,$3F,$FC,$61,$08,$42,
.byt $3F,$08,$42,$1F,$C6,$3F,$FC,$21,$E8,$42,$1F,$FC,$21,$E8,$42,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$21,$08,$42,$10,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$8C,$08,$84,$42,$11,$10,$FC,$63,$18,$C6,$3F,$E5,$08,$42,$10,$9F,$F8,$43,$F8,$42,$1F,$F8,
.byt $43,$F0,$84,$3F,$8C,$63,$F0,$84,$21,$FC,$21,$F0,$84,$3F,$FC,$21,$0F,$C6,$3F,$F8,$42,$10,$84,$21,$FC,$63,$F8,$C6,$3F,$FC,$63,$F0,
.byt $84,$21,$03,$18,$06,$30,$00,$03,$18,$06,$30,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $FC,$62,$1F,$C6,$3F,$FC,$63,$1F,$C6,$31,$C5,$29,$8A,$4A,$98,$FC,$21,$08,$42,$1F,$E4,$A3,$18,$C6,$5C,$FC,$21,$E8,$42,$1F,$FC,$21,
.byt $E8,$42,$10,$FC,$21,$0F,$C6,$3F,$8C,$63,$F8,$C6,$31,$F9,$08,$42,$10,$9F,$08,$42,$18,$C6,$3F,$8C,$A9,$8C,$52,$51,$84,$21,$08,$42,
.byt $1F,$8E,$EB,$18,$C6,$31,$8E,$6B,$5A,$D6,$71,$FC,$63,$18,$C6,$3F,$FC,$63,$F8,$42,$10,$FC,$63,$59,$FC,$21,$FC,$63,$FA,$52,$51,$FC,
.byt $21,$F0,$84,$3F,$FD,$48,$42,$10,$84,$8C,$63,$18,$C6,$3F,$8C,$63,$18,$C5,$44,$8C,$6B,$5A,$D6,$AA,$8A,$88,$42,$11,$51,$8C,$62,$A2,
.byt $10,$84,$F8,$44,$42,$22,$1F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1F,
.byt $00,$00,$00,$00,$00,$07,$E2,$1F,$C6,$3F,$04,$21,$0F,$4A,$5E,$00,$01,$F8,$42,$1F,$08,$42,$1F,$C6,$3F,$07,$E3,$1F,$C2,$1F,$39,$08,
.byt $E2,$10,$84,$FC,$63,$F0,$86,$C8,$84,$21,$0F,$C6,$31,$20,$00,$42,$10,$84,$00,$02,$14,$C6,$3F,$84,$AD,$8A,$4A,$30,$61,$08,$42,$10,
.byt $86,$00,$01,$FA,$D6,$B5,$00,$01,$F8,$C6,$31,$00,$01,$F8,$C6,$3F,$00,$3D,$2F,$42,$10,$00,$3F,$1A,$FC,$41,$08,$88,$42,$10,$84,$00,
.byt $01,$F8,$7C,$3F,$01,$08,$E2,$10,$86,$00,$00,$A5,$29,$4E,$00,$01,$18,$C5,$44,$00,$01,$1A,$D6,$BF,$00,$01,$15,$11,$51,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
; ======================================================================


; --- Aux methods ---
; ===================
_init:
.(
    ; Disable interrupts
    SEI
    ; Initialize stack pointer to $01FF
    LDX #$FF
    TXS
    ; Clear decimal mode
    CLD
    ; Init gamepads
    STA CONTROLLER_1
    LDX #8
    loop:
    STA CONTROLLER_2
    DEX
    BNE loop
    LDA CONTROLLER_1
    LDX CONTROLLER_2
    STA GAMEPAD_CLEAN1
    STX GAMEPAD_CLEAN2
    ; Enable Durango interrupts
    LDA #$01
    STA $DFA0
    ; Enable interrupts
    CLI
    JMP _main
.)
_stop:
.(
    end: BRA end					; BRA es posible en CMOS *** OK
.)
_nmi_int:
.(
    BRK    							; una posibilidad es apuntar NMI al RTI final de IRQ, para que no haga absolutamente nada.
    RTI
.)
_irq_int:
.(
    ; Filter interrupt
    PHA         ; Save accumulator contents to stack
    PHX         ; Save X register contents to stack
    TSX         ; Transfer stack pointer to X    
    LDA $103,X  ; Load status register contents
    AND #$10    ; Isolate B status bit
    BNE _stop   ; If B = 1, BRK detected	; todo OK, pero dado que el BRK será algo catastrófico, casi mejor detectarlo al final de la rutina
    
    ; Actual interrupt code
    JSR _fetch_gamepads						; correcto, pero recuerda que esa rutina no podrá afectar Y, pues no se ha salvado
    JSR _fetch_keyboard
    JSR _update_level
    
    ; Return from interrupt
    PLX                    ; Restore X register contents
    PLA                    ; Restore accumulator contents
    RTI                    ; Return from all IRQ interrupts
.)
; --------------------------------------------------

						; buena idea ésta!
#if(*>$df00)
#echo First segment is too big!
#endif
.dsb $df00-*, $ff

; Metadata area			; esta parte es LEGIBLE por la CPU de Durango
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.asc "BUILD:["
.byt $00,$00,$00,$00,$00,$00,$00
.ASC "]$"
.asc "SIGNATURE:["
.byt $00,$00
.ASC "]$$"


.dsb $df80-*, $ff
; === END OF FIRST 8K BLOCK ===

; === RESERVED IO SPACE ($df80 - $dfff) ===		; esta parte NO es legible por la CPU
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
TILESET_START:
pong_img:
.byt $7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,
.byt $FB,$00,$00,$04,$44,$40,$3D,$00,$FD,$04,$BB,$B4,$3D,$00,$FD,$4B,$FF,$B4,$3D,$00,$FC,$4B,$FF,$BB,$40,$3C,$00,$FC,$04,$BF,$FB,$40,
.byt $3C,$00,$FC,$04,$BF,$FB,$40,$3C,$00,$FC,$04,$BB,$FB,$B4,$3D,$00,$FD,$4B,$FF,$B4,$31,$00,$03,$44,$FF,$40,$08,$00,$FD,$4B,$FF,$B4,
.byt $2F,$00,$FE,$04,$44,$03,$BB,$FF,$B4,$08,$00,$FC,$4B,$BF,$BB,$40,$2D,$00,$FD,$04,$4B,$BB,$03,$FF,$FE,$BB,$40,$07,$00,$FC,$04,$BF,
.byt $FB,$40,$2D,$00,$FC,$44,$BB,$FF,$FB,$03,$BB,$FF,$40,$07,$00,$FC,$04,$BF,$FB,$40,$2D,$00,$F8,$4B,$FF,$BB,$B4,$44,$44,$B4,$40,$08,
.byt $00,$FD,$4B,$FB,$40,$2C,$00,$F8,$04,$BF,$FB,$B4,$40,$00,$04,$44,$09,$00,$FD,$4B,$BB,$40,$27,$00,$F7,$04,$44,$40,$00,$00,$44,$BF,
.byt $BB,$40,$0D,$00,$FD,$04,$44,$40,$27,$00,$F8,$4B,$BB,$B4,$00,$00,$4B,$FF,$B4,$04,$00,$FE,$04,$44,$09,$00,$FE,$44,$44,$27,$00,$F8,
.byt $4B,$FF,$B4,$00,$00,$4B,$FF,$B4,$03,$00,$FC,$44,$4B,$BB,$40,$08,$00,$FD,$4B,$BB,$40,$22,$00,$ED,$44,$40,$00,$00,$4B,$FF,$B4,$00,
.byt $00,$4B,$FF,$B4,$00,$00,$44,$BB,$BF,$FF,$B4,$07,$00,$FC,$04,$BB,$FB,$40,$20,$00,$EF,$04,$4B,$BB,$44,$00,$00,$44,$BF,$FB,$40,$00,
.byt $4B,$FF,$B4,$00,$00,$4B,$03,$FF,$FF,$B4,$08,$00,$FD,$4B,$FB,$44,$20,$00,$EB,$04,$BB,$FF,$BB,$40,$00,$04,$BF,$FB,$40,$00,$4B,$FF,
.byt $B4,$00,$00,$4B,$BB,$BB,$FF,$B4,$08,$00,$FD,$4B,$BB,$40,$20,$00,$EA,$04,$BF,$FF,$FB,$B4,$00,$04,$BF,$FB,$40,$00,$4B,$FF,$B4,$00,
.byt $00,$44,$B4,$4B,$BF,$FB,$40,$07,$00,$FE,$04,$44,$21,$00,$F1,$04,$BF,$FF,$FF,$BB,$40,$04,$4B,$FF,$B4,$00,$4B,$FF,$B4,$40,$03,$00,
.byt $FC,$04,$BF,$FB,$40,$24,$00,$EB,$04,$44,$44,$40,$00,$00,$04,$BB,$FF,$FF,$FB,$B4,$00,$4B,$FF,$B4,$00,$4B,$BF,$FB,$40,$03,$00,$FC,
.byt $04,$BF,$FB,$40,$23,$00,$EA,$44,$4B,$BB,$BB,$B4,$40,$00,$00,$4B,$FF,$BB,$FF,$BB,$40,$4B,$FF,$B4,$00,$04,$BF,$FB,$B4,$03,$00,$FC,
.byt $04,$BF,$FB,$40,$22,$00,$E2,$04,$BB,$BF,$FF,$FF,$BB,$B4,$00,$00,$4B,$FF,$BB,$BF,$FB,$B4,$44,$BF,$FB,$40,$04,$BB,$FF,$B4,$40,$00,
.byt $04,$4B,$BF,$FB,$40,$22,$00,$E2,$4B,$BF,$FF,$BB,$FF,$FF,$BB,$40,$00,$4B,$BF,$BB,$BB,$FF,$BB,$44,$BF,$FB,$40,$00,$4B,$FF,$FB,$B4,
.byt $44,$4B,$BB,$FF,$B4,$40,$21,$00,$FD,$04,$BB,$FF,$03,$BB,$E8,$BF,$FB,$B4,$00,$04,$BF,$FB,$44,$BF,$FB,$B4,$BF,$FB,$40,$00,$04,$BF,
.byt $FF,$FB,$BB,$BF,$FF,$BB,$44,$22,$00,$FD,$4B,$BF,$BB,$03,$44,$EE,$BB,$FF,$B4,$00,$04,$BF,$FB,$44,$4B,$FF,$BB,$BB,$FF,$B4,$00,$04,
.byt $4B,$BF,$03,$FF,$FD,$BB,$B4,$40,$1D,$00,$FF,$44,$04,$00,$FD,$4B,$FF,$B4,$03,$00,$EE,$4B,$FF,$FB,$40,$04,$BB,$FB,$44,$44,$BF,$FF,
.byt $BB,$FF,$B4,$00,$00,$04,$4B,$03,$BB,$FE,$44,$40,$1C,$00,$F6,$04,$44,$BB,$44,$00,$00,$04,$BB,$FB,$B4,$03,$00,$F6,$04,$BF,$FB,$40,
.byt $00,$4B,$FF,$B4,$04,$4B,$03,$FF,$FF,$B4,$03,$00,$04,$44,$1D,$00,$FF,$44,$04,$BB,$FA,$44,$00,$04,$BF,$FB,$40,$03,$00,$F1,$04,$BF,
.byt $FF,$B4,$00,$4B,$FF,$B4,$00,$44,$BF,$FF,$FF,$FB,$40,$22,$00,$FE,$4B,$BB,$04,$FF,$FA,$B4,$00,$04,$BF,$FB,$40,$04,$00,$F2,$4B,$FF,
.byt $B4,$00,$4B,$BF,$BB,$40,$00,$4B,$BF,$FF,$FB,$40,$21,$00,$F3,$04,$BB,$FF,$FB,$BB,$BB,$FF,$FB,$40,$04,$BF,$FB,$40,$04,$00,$F2,$4B,
.byt $FF,$B4,$00,$04,$BF,$FB,$40,$00,$04,$BB,$FF,$FB,$40,$21,$00,$F3,$04,$BF,$FF,$BB,$44,$4B,$BF,$FB,$40,$04,$BF,$FB,$40,$04,$00,$F2,
.byt $4B,$FF,$B4,$00,$04,$BF,$FB,$40,$00,$00,$4B,$BB,$B4,$40,$21,$00,$F3,$04,$BF,$FB,$44,$00,$04,$BF,$FB,$B4,$04,$BF,$FB,$44,$04,$00,
.byt $F3,$4B,$FF,$B4,$00,$04,$BB,$FF,$B4,$00,$00,$04,$44,$40,$22,$00,$F3,$04,$4B,$FF,$B4,$00,$00,$BB,$FF,$B4,$04,$BB,$FF,$B4,$04,$00,
.byt $F8,$4B,$FF,$B4,$00,$00,$4B,$FF,$B4,$28,$00,$F3,$4B,$FF,$B4,$00,$04,$BB,$FB,$B4,$00,$4B,$FF,$B4,$40,$03,$00,$F8,$4B,$FF,$B4,$00,
.byt $00,$4B,$BB,$B4,$28,$00,$E8,$4B,$FF,$B4,$00,$44,$BF,$FB,$40,$00,$4B,$FF,$FB,$40,$00,$00,$04,$BB,$FB,$B4,$00,$00,$04,$BB,$40,$28,
.byt $00,$ED,$44,$BF,$FB,$44,$BB,$FF,$FB,$40,$00,$04,$BF,$FB,$B4,$40,$00,$44,$BF,$FB,$40,$03,$00,$FF,$44,$29,$00,$ED,$04,$BF,$FB,$BB,
.byt $BF,$FB,$B4,$00,$00,$04,$BB,$FF,$BB,$44,$44,$BB,$FF,$BB,$40,$2D,$00,$FE,$04,$BF,$03,$FF,$FE,$BB,$44,$03,$00,$F8,$4B,$BF,$FF,$BB,
.byt $BB,$FF,$FB,$B4,$2E,$00,$FA,$04,$4B,$FF,$FB,$BB,$44,$04,$00,$FE,$04,$BB,$03,$FF,$FD,$FB,$BB,$40,$2F,$00,$FC,$4B,$FF,$BB,$44,$06,
.byt $00,$FF,$44,$03,$BB,$FE,$B4,$44,$30,$00,$FC,$4B,$FF,$B4,$40,$07,$00,$03,$44,$FF,$40,$31,$00,$FC,$04,$BF,$FB,$40,$3C,$00,$FC,$04,
.byt $BF,$FB,$40,$3C,$00,$FC,$04,$BF,$FB,$44,$3D,$00,$FD,$4B,$FF,$B4,$3D,$00,$FD,$4B,$FF,$B4,$3D,$00,$FD,$4B,$BF,$B4,$3D,$00,$FD,$04,
.byt $BB,$44,$3E,$00,$FF,$44,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$7F,$00,
.byt $7F,$00,$7F,$00,$22,$00,$FB,$04,$F0,$4F,$04,$F0,$03,$00,$F9,$4F,$04,$F0,$4F,$00,$00,$4F,$33,$00,$FF,$4F,$05,$00,$F9,$4F,$04,$F0,
.byt $4F,$00,$00,$4F,$09,$00,$FE,$04,$F0,$28,$00,$FF,$4F,$05,$00,$F9,$4F,$04,$F0,$4F,$00,$00,$4F,$09,$00,$FE,$04,$F0,$11,$00,$D0,$0B,
.byt $B0,$BF,$0B,$BB,$B0,$BF,$0B,$BB,$B0,$BF,$0B,$B0,$00,$BF,$FB,$44,$FB,$FF,$BF,$FB,$04,$F0,$4F,$04,$F0,$0B,$FF,$B0,$4F,$04,$F0,$4F,
.byt $BF,$F4,$4F,$BF,$F4,$00,$04,$FB,$FF,$40,$BF,$FB,$4F,$FF,$F0,$10,$00,$D1,$04,$F0,$FF,$4B,$B4,$F0,$FF,$4B,$B4,$F0,$FF,$4B,$B0,$0B,
.byt $F4,$4B,$B4,$FB,$4F,$F4,$BF,$04,$F0,$4F,$04,$F0,$BF,$44,$FB,$4F,$04,$F0,$4F,$B4,$BB,$4F,$B4,$BB,$00,$04,$FB,$4B,$BB,$F4,$4B,$B4,
.byt $F0,$12,$00,$D2,$F4,$BB,$BF,$40,$F4,$BB,$BF,$40,$F4,$BB,$BF,$40,$0B,$FF,$FF,$B4,$F0,$0B,$B0,$0F,$04,$F0,$4F,$04,$F0,$BB,$00,$BB,
.byt $4F,$04,$F0,$4F,$00,$4F,$4F,$00,$4F,$00,$04,$F0,$0B,$BB,$FF,$FF,$B4,$F0,$12,$00,$D2,$BF,$B4,$FF,$00,$BF,$B4,$FF,$00,$BF,$B4,$FF,
.byt $00,$0B,$F4,$00,$04,$F0,$0B,$B0,$0F,$04,$F0,$4F,$04,$F0,$BF,$44,$FB,$4F,$04,$F0,$4F,$B4,$BB,$4F,$B4,$BB,$00,$04,$F0,$0B,$BB,$F4,
.byt $00,$04,$F4,$12,$00,$D1,$BF,$40,$FB,$00,$BF,$40,$FB,$00,$BF,$40,$FB,$0F,$40,$BF,$FF,$B4,$F0,$0B,$B0,$0F,$04,$F0,$4F,$04,$F0,$0B,
.byt $FF,$B0,$4F,$04,$F0,$4F,$BF,$F4,$4F,$BF,$F4,$0F,$44,$F0,$0B,$B0,$BF,$FF,$B0,$BF,$F0,$7F,$00,$7F,$00,$7F,$00,$7F,$00,$0C,$00,$00,

.dsb $ffe1-*, $ff
JMP ($FFFC)
.dsb $fffa-*, $ff
; === END OF SECOND 8K BLOCK ===


; === VECTORS ===
.word _nmi_int ; NMI vector
.word _init ; Reset vector
.word _irq_int ; IRQ/BRK vector
    
