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
TILE_TO_DRAW = $12 ; $13
MAP_TO_DRAW = $14 ; 15
X_COORD = $16
Y_COORD = $17
SQ_WIDTH = $18
SQ_HEIGHT = $19
DRAW_BUFFER = $1a
CURRENT_COLOR = $1b
TEMP1 = $1c

; -- Global Game constants --
PADDLE_WIDTH = 8
PADDLE_HEIGHT =32
BACKGROUND = ROSITA
; -- Global Game vars pointers --
p1_vertical_x = $00
p2_vertical_x = $01
p1_vertical_y = $02
p2_vertical_y = $03
p1_horizontal_x = $04
p2_horizontal_x = $05
p1_horizontal_y = $06
p2_horizontal_y = $07

; == 16K ROM. FIRST 8K BLOCK ==
*=$c000
JMP _main

.asc "#game#"
; -- main method --
_main:
.(
	; Set video mode
	LDA #(RGB | SCREEN_3 | LED)
	STA VIDEO_MODE
    LDA #$60
    STA DRAW_BUFFER
	
	; Display title for 120 frames
    JSR _draw_title
	JSR _wait_start
    
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
	JSR _wait_frames
	; loop
	JMP gameloop

	; End main
	end: JMP end
.)
; -- end main method --

_init_game_data:
.(
                        ; usando distintos registros se puede reutilizar uno que contenga este 5, y si decides usar otro valor se puede añadir LD?#
                        ; lo mismo de antes, no hay obligación de usar A en todas las cargas
    LDA #2
    STA p1_vertical_x
    LDX #5
    STX p1_vertical_y    
    LDY #118
    STY p2_vertical_x
    STX p2_vertical_y
    
    STX p1_horizontal_y
    LDY #50
    STY p1_horizontal_x
    STY p2_horizontal_x
    
    LDY #120
    STY p2_horizontal_y
    
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
    ; Set color
    LDA #VERDE
    STA CURRENT_COLOR
    
    ; Set player
    LDX #0
    
    JMP _draw_player_internal
.)

_draw_second_player:
.(
    ; Set color
    LDA #ROJO
    STA CURRENT_COLOR
    
    ; Set player
    LDX #1
    
    JMP _draw_player_internal
.)

; todas estas funciones son básicamente iguales a diferencia del color y, en el caso de los dos jugadores, también las coordenadas
; para el color, si para las transferencias usas otros registros, puedes simplemente llamar a una función común cargando en A el color deseado, sea ROJO, VERDE o BACKGROUND
; pero para las distintas coordenadas, si las dispones como arrays de dos elementos (p1_vertical_x vaya seguida de p2_vertical_x, y así)
;  puedes cargar un registro índice (ej. X) con 0 o 1 para seleccionar el jugador, usando direccionamiento indexado (ej. LDY p_vertical_x, X  ...que deja libre A para el color)
_draw_player_internal:
.(
    ; Set coords
    LDY p1_vertical_x, X
    STY X_COORD
    LDY p1_vertical_y, X
    STY Y_COORD
    
    ; Set size
    LDY #PADDLE_WIDTH
    STY SQ_WIDTH
    LDY #PADDLE_HEIGHT
    STY SQ_HEIGHT

    PHA
    PHX
    PHY
    JSR _draw_square
    PLY
    PLX
    PLA
    
    ; Set coords		; esta parte no la entiendo, por qué se pinta el jugador 1 otra vez con otras coordenadas?
						; VALE, ya lo pillo, el jugador 1 puede moverse horizontalmente! El 2 no puede hacerlo?
    LDY p1_horizontal_x, X
    STY X_COORD
    LDY p1_horizontal_y, X
    STY Y_COORD
    
    ; Set size
    LDY #PADDLE_HEIGHT
    STY SQ_WIDTH
    LDY #PADDLE_WIDTH
    STY SQ_HEIGHT
    
    JMP _draw_square
.)

_undraw_first_player:
.(
    ; Set color
    LDA #BACKGROUND
    STA CURRENT_COLOR
    
    ; Set player
    LDX #0
    
    JMP _draw_player_internal
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
    JSR _player1_up		; imagino que tocará A (y de todo), de lo contrario en CMOS es posible hacer un único LDA CONTROLLER_1 y sucesivos BIT #BUTTON...
						; alternativamente, ir haciendo LSR y en las condiciones usar BCC en vez de BEQ (de nuevo con un único LDA CONTROLLER_1)
						; pero nada de esto es aplicable si A no se preserva al llamar _player1_up
						; Hay otras ideas muy locas que no te comentaré de momento ;-)

    down1:
    LDA #BUTTON_DOWN
    BIT CONTROLLER_1
    BEQ left1
    JSR _player1_down
    
    left1:
    LDA #BUTTON_LEFT
    BIT CONTROLLER_1
    BEQ right1
    JSR _player1_left
    
    right1:
    LDA #BUTTON_RIGHT
    BIT CONTROLLER_1
    BEQ up2
    JSR _player1_right
    
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

; Player 1 moves up		; de nuevo, up/down son comunes a ambos jugadores, si usas los arrays anteriores puede ser función común especificando jugador en p. ej. X
						; aunque quizá convenga salvarlo por si _undraw (que debería ser comun draw/undraw para todos los jugadores) altera X, en CMOS es fácil (PHX, PLX)
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

; Player 1 moves left
_player1_left:
.(
    ; Erase current paddle
    JSR _undraw_first_player
    ; Move paddle
    DEC p1_horizontal_x
    ; Draw current paddle & Return
    JMP _draw_first_player
.)

; Player 1 moves right
_player1_right:
.(
    ; Erase current paddle
    JSR _undraw_first_player
    ; Move paddle
    INC p1_horizontal_x
    ; Draw current paddle & Return
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

_draw_title:
.(
    ; $14, $15 tilemap to draw
    LDA #>title ; MSB
    STA MAP_TO_DRAW+1
    LDA #<title ; LSB
    STA MAP_TO_DRAW
    ; Draw map 1
    JMP draw_map
.)

.asc "#end game#"
.dsb $ca00-*, $ff
title:
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$04,$00,$05,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$08,$09,$0A,$02,$0B,$0C,$00,$00,
.byt $00,$00,$00,$00,$0D,$0E,$0F,$10,$11,$12,$13,$14,$00,$15,$00,$00,$00,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$00,$00,$00,$00,
.byt $00,$21,$22,$23,$24,$25,$26,$27,$28,$00,$00,$00,$00,$00,$00,$00,$00,$29,$2A,$00,$2B,$2C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$2D,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
.byt $00,$00,$2E,$2F,$2F,$30,$31,$32,$33,$34,$35,$36,$37,$38,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,


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
								; por mucho que se optimice (a menos que uses tablas ;-) esta conversión es MUY lenta
								; si los movimientos no son "aleatorios" y se van a hacer de uno en uno (como parece), casi mejor NO trabajar con coordenadas X/Y
								; sino directamente con direcciones, Y+1 sería +$40 etc
	; Load height in x
	LDX SQ_HEIGHT
	paint_row:
	; Divide width by 2			; correcto, aunque puedes plantearte si la anchura va a tener precisión de píxel (parece que no, porque ignoras C), mejor expresarla en bytes
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
	BNE paint:					; en la etiqueta de los saltos no se pone 'dos puntos' ;-)
								; FALLO! te va a pintar la cosa DOS PÍXELES A LA DERECHA de lo especificado
								; si eran p.ej. 4 px de ancho, Y=2 (2 bytes) y el bucle va a escribir en (VMEM_POINTER)+2 y (VMEM_POINTER)+1, al llegar a 0 no se ejecuta
								; para bucles "pequeños" carga Y con uno MENOS del total y usa BPL en vez de BNE en el bucle, así las iteraciones anteriores serían 1 y 0, que es lo correcto
	; Next row
	LDA VMEM_POINTER
	CLC
	ADC #$40
	STA VMEM_POINTER
	BCC skip_upper				; MUY BIEN, la alternativa de usar ADC #0 es más lenta y pesada... sólo interesa si necesitas que se ejecute en tiempo constante
	INC VMEM_POINTER+1
 	skip_upper:
	DEX
	BNE paint_row				; no hay problema aquí porque no se usa como índice, vas avanzando líneas con el ADC #$40
								; si por uniformidad con la anchura prefieres especificar la altura como un píxel menos (0...n-1), úsese BPL en su lugar
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
    STX VMEM_POINTER			; correcto, aunque en CMOS tenemos STZ y no necesitas usar X
    ; Multiply y coord by 64 (64 bytes each row)
    LDA Y_COORD
    LSR
    STA VMEM_POINTER+1			; empiezas bien, pero por qué lo escribes en memoria AHORA? vas a seguir desplazándolo, lo suyo para 16 bits es uno en memoria y otro en A (preferiblemente el que antes se vaya a seguir procesando)
    ROR VMEM_POINTER
    ; Sencond shift
    LSR VMEM_POINTER+1			; lo dicho, debería seguir en A
    ROR VMEM_POINTER			; si VMEM_POINTER se puso a 0, tras rotarlo dos veces es SEGURO que Carry es 0!
    
    ; Add base memory address
    CLC							; afinando mucho, en virtud de lo anterior no es necesario
    LDA VMEM_POINTER+1			; de nuevo, este valor lo habrías tenido ya en A, no necesitarías cargarlo
    ADC DRAW_BUFFER
    STA VMEM_POINTER+1
    LDA VMEM_POINTER			; ERROR! El Carry va del byte bajo al alto, NUNCA al revés. En tu caso jamás se produciría C, por lo que no notarías el fallo 
    ADC #$00					;  pero precisamente por eso estas tres instrucciones sobran
    STA VMEM_POINTER
    
    ; Calculate X coord
    ; Divide x coord by 2 (2 pixel each byte)
    LDA X_COORD
    LSR
    ; Add to memory address
    CLC
    ADC VMEM_POINTER
    STA VMEM_POINTER
    LDA VMEM_POINTER+1			; de nuevo, suele traer cuenta hacer el BCC que se salte un INC
    ADC #$00
    STA VMEM_POINTER+1
    
    RTS
.)
; --- end convert_coords_to_mem ---


; Fill screen with solid color
fill_screen:
.(
    ; Init video pointer
    LDA DRAW_BUFFER
    STA VMEM_POINTER+1
    LDA #$00					; puedes usar Y para el byte bajo... y ya tienes el índice del bucle cargado
    STA VMEM_POINTER
loop2:
    ; Load current color
    LDA CURRENT_COLOR			; como te comenté en la Jaquería, si respetas A esto debe ir FUERA del bucle
    ; Iterate over less significative memory address
    LDY #$00					; no debería hacer falta, en cada iteración mayor se garantiza que Y es 0
loop:
    STA (VMEM_POINTER), Y
    INY
    BNE loop
								; si llega aquí, es SEGURO que Y=0
    ; Iterate over more significative memory address
    INC VMEM_POINTER+1 ; Increment memory pointer Hi address using accumulator
    LDA #$80 ; Compare with end memory position
								; simplemente usando LDX# (QUE DEBE ESTAR FUERA DE TODO BUCLE) y luego CPX se respeta A
    CMP VMEM_POINTER+1
								; pero si es seguro que va a ser en la pantalla 3 estándar, como $80 es el "primer" número negativo, basta con usar BPL en vez de BNE
    BNE loop2					; debería ser la misma etiqueta
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
    STA CONTROLLER_2			; OK, aunque creo que tampoco pasa nada por usar un bucle... preferiblemente con X, que ya ha salvado la ISR
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
    wait_loop:
    BIT CONTROLLER_1
    BVC wait_loop		; BRAVO! MUY FINO! ;-) ;-)
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
    LDA #$00
    STA VMEM_POINTER				; STZ se puede usar
    
    ; $07 tiles rows counter
    ;LDA #$a0
    LDA #$10 ; Count 16 with temp1
    STA TEMP1
    draw_map_loop1:
    ; First tiles row
    ; tile 0
    JSR convert_tile_index_to_mem	; en general, repetir código que llama a funciones lentas no vale la pena, mejor un bucle; la ventaja en velocidad así es pírrica
    JSR draw_back_tile
    ; tile 1
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 2
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 3
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 4
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 5
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 6
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 7
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 8
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 9
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 10
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 11
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 12
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 13
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 14
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    ; tile 15
    INC MAP_TO_DRAW
    JSR convert_tile_index_to_mem
    JSR draw_back_tile
    INC MAP_TO_DRAW

    ; Change row
    LDA #$00
    STA VMEM_POINTER		; CMOS puede usar STZ
    INC VMEM_POINTER+1
    INC VMEM_POINTER+1
    DEC TEMP1				; muy bien, los bucles lentos pueden estar en memoria; al no usar el índice, va bien el BEQ
    BEQ draw_map_end
    JMP draw_map_loop1		; (quizá con bucles interiores podrías saltar directamente con BNE)
    draw_map_end:
    RTS
.)
;------------------------------------------------------

; Input $14 $15 Tilemap position
; DRAW_MAP, DRAW_MAP+1 tilemap to draw
; output $12, $13 tile to draw (initial position in mem
; TILE_TO_DRAW, TILE_TO_DRAW+1 tile to draw (initial position in mem
; TEMP2 internal, backup of current tile index
convert_tile_index_to_mem:
.(
    ; Load tile index in X
    LDY #$00
    LDA (MAP_TO_DRAW), Y	; en CMOS es posible hacer LDA (MAP_TO_DRAW) sin indexar... con permiso de CA65 >-(
    ;$08 backup of current tile index ($14)		; deuda técnica!
    PHA
    ; Calculate tile memory position by multiplying (shifting) tile number * 0x20
    ASL						; curiosa forma de obtener los dos bytes...
    ASL						; ...pero en general no trae cuenta hacer más de 4 desplazamientos
    ASL
    ASL
    ASL
    ; Store tile memory position in TILE_TO_DRAW
    STA TILE_TO_DRAW

    ; Calculate more significative tile memory position ($13)
    ;$07 backup of current tile index ($13)		; deuda técnica! conviene eliminar los comentarios que no procedan
    ;LDA $13
    ;STA $07
    PLA
    LSR
    LSR
    LSR
    CLC
    ADC #>TILESET_START		; asumimos que <TILESET_START es siempre cero?
    STA TILE_TO_DRAW+1
							; en general correcto, tenía la duda sobre su rendimiento...
							; esta versión son 21 bytes, 40 ciclos (37 si usas TAX/TXA en vez de PHA/PLA)
							; mi propuesta (17 bytes, 34 ciclos) sería
							;	STZ TILE_TO_DRAW
							;	LDA (MAP_TO_DRAW)
							;	LSR
							;	ROR TILE_TO_DRAW
							;	LSR
							;	ROR TILE_TO_DRAW
							;	LSR
							;	ROR TILE_TO_DRAW	; puesto a cero, tras 3 rotaciones C es cero SEGURO
							;	ADC #>TILESET_START	; no necesita CLC por lo anterior
							;	STA TILE_TO_DRAW+1
    RTS
.)
; --------------------------------------------------------

;TILE_TO_DRAW, TILE_TO_DRAW+1 -> tile number, tile bank
;VMEM_POINTER,VMEM_POINTER+1 -> screen position
;$09 backup of VMEM_POINTER original value
draw_back_tile:
.(
    ; Save screen position as backup in $09
    LDA VMEM_POINTER
    PHA
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
    LDA VMEM_POINTER; Increment using acumulator less significative screen pos (VMEM_POINTER)
    CLC
    ADC #$40; Each row is 0x40 (64) bytes 
    STA VMEM_POINTER
    LDA TILE_TO_DRAW; Increment first tile byte position (TILE_TO_DRAW), so it points to next byte
    CLC
    ADC #$04; Increment by 4 (already drawn 8 pixels)
    STA TILE_TO_DRAW
    LDY #$00; Initialize pixel counter to 0	; ...pero el resto seguro que se puede compactar con bucles, sin pérdida apreciable de velocidad
    ; Second row
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
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    ; Third row
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
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    ; Fourth row
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
    ; Change row and block
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    INC VMEM_POINTER+1; Each 4 rows, high significative byte should be increased	; el carry del anterior lo determina, fácilmente integrable en el bucle
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    ; Fith row
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
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    ; Sixth row
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
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
    ; Seventh row
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
    ; Change row
    LDA VMEM_POINTER
    CLC
    ADC #$40
    STA VMEM_POINTER
    LDA TILE_TO_DRAW
    CLC
    ADC #$04
    STA TILE_TO_DRAW
    LDY #$00
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
    LDA TILE_TO_DRAW; Go to next tile by incrementing TILE_TO_DRAW by 0x04 (already drawn 8 pixels)
    CLC
    ADC #$04
    DEC VMEM_POINTER+1; Restore VMEM_POINTER+1 to original value, so next tile is at same row
    PLA ; Restore VMEM_POINTER using backup and add 0x04 to set at next screen position 
    CLC
    ADC #$04
    STA VMEM_POINTER
    RTS
.)
;--------------------------------------------------------


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
    CLI       ; Enable interrupts	; no necesitas inicializar ninguna otra cosa para ejecutar las interrupciones, verdad?
    JMP $c000
.)
_stop:
.(
    end: JMP end					; BRA es posible en CMOS
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
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $00
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$44, ; Tile $01
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00, ; Tile $02
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44, ; Tile $03
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44,$44,$40,$00, ; Tile $04
.byt $00,$00,$04,$BB,$00,$00,$4B,$FF,$00,$00,$4B,$FF,$00,$00,$04,$BF,$00,$00,$04,$BF,$00,$00,$04,$BB,$00,$00,$00,$4B,$00,$00,$00,$4B, ; Tile $05
.byt $B4,$00,$00,$00,$B4,$00,$00,$00,$BB,$40,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00,$FB,$B4,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$00,$00, ; Tile $06
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$44,$00,$00,$4B,$BB,$00,$00,$4B,$FF, ; Tile $07
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$40,$00,$00,$44,$B4,$00,$00,$4B,$B4,$00,$00,$4B, ; Tile $08
.byt $00,$04,$44,$BB,$04,$4B,$BB,$FF,$44,$BB,$FF,$FB,$4B,$FF,$BB,$B4,$BF,$FB,$B4,$40,$BF,$BB,$40,$00,$FF,$B4,$00,$00,$FF,$B4,$00,$00, ; Tile $09
.byt $BB,$BB,$B4,$00,$FF,$FF,$BB,$40,$BB,$BB,$BB,$40,$44,$44,$B4,$40,$00,$04,$44,$00,$00,$00,$00,$00,$00,$00,$04,$44,$00,$44,$4B,$BB, ; Tile $0A
.byt $00,$00,$00,$4B,$00,$00,$00,$04,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $0B
.byt $BF,$BB,$40,$00,$BF,$FB,$40,$00,$BF,$FB,$40,$00,$4B,$FB,$40,$00,$4B,$BB,$40,$00,$04,$44,$40,$00,$00,$44,$44,$00,$00,$4B,$BB,$40, ; Tile $0C
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$44,$00,$44,$4B,$BB,$04,$BB,$BF,$FF, ; Tile $0D
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44,$40,$00,$00,$BB,$B4,$40,$00,$FF,$BB,$B4,$00, ; Tile $0E
.byt $00,$00,$44,$40,$04,$4B,$BB,$44,$04,$BB,$FF,$BB,$04,$BF,$FF,$FB,$04,$BF,$FF,$FF,$04,$BB,$FF,$FF,$00,$4B,$FF,$BB,$00,$4B,$FF,$BB, ; Tile $0F
.byt $00,$00,$4B,$FF,$00,$00,$44,$BF,$40,$00,$04,$BF,$B4,$00,$04,$BF,$BB,$40,$04,$4B,$FB,$B4,$00,$4B,$FF,$BB,$40,$4B,$BF,$FB,$B4,$44, ; Tile $10
.byt $B4,$00,$00,$4B,$FB,$40,$00,$4B,$FB,$40,$00,$4B,$FB,$40,$00,$4B,$FF,$B4,$00,$4B,$FF,$B4,$00,$4B,$FF,$B4,$00,$04,$BF,$FB,$40,$04, ; Tile $11
.byt $FF,$B4,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$40,$00,$BF,$FB,$40,$00,$BF,$FB,$B4,$00,$BB,$FF,$B4,$40, ; Tile $12
.byt $44,$BB,$BF,$FF,$4B,$FF,$FF,$FF,$4B,$BB,$BB,$FF,$44,$B4,$4B,$BF,$00,$00,$04,$BF,$00,$00,$04,$BF,$00,$00,$04,$BF,$00,$04,$4B,$BF, ; Tile $13
.byt $B4,$00,$00,$00,$B4,$00,$00,$00,$B4,$00,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00, ; Tile $14
.byt $04,$BB,$FB,$40,$00,$4B,$FB,$44,$00,$4B,$BB,$40,$00,$04,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $15
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44,$00,$00,$4B,$BB,$00,$04,$BB,$FF, ; Tile $16
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44,$00,$04,$44,$BB,$44,$BB,$BB,$BB,$BB,$FF,$FF,$FF,$FF,$FB,$BB,$BB,$FF, ; Tile $17
.byt $00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$4B,$00,$00,$00,$4B,$00,$00,$04,$BB,$44,$00,$04,$BF,$B4,$00,$04,$BF,$FB,$40,$04,$BF, ; Tile $18
.byt $4B,$BF,$FF,$BB,$BB,$FF,$BB,$BB,$BF,$BB,$44,$44,$FF,$B4,$00,$00,$FB,$B4,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00,$FB,$40,$00,$00, ; Tile $19
.byt $FF,$FF,$BB,$40,$BB,$BF,$FB,$B4,$44,$BB,$FF,$B4,$00,$4B,$FF,$FB,$00,$04,$BF,$FB,$00,$04,$BF,$FF,$00,$00,$4B,$FF,$00,$00,$4B,$FF, ; Tile $1A
.byt $00,$4B,$BF,$BB,$00,$04,$BF,$FB,$00,$04,$BF,$FB,$40,$04,$BB,$FB,$40,$00,$4B,$FF,$B4,$00,$4B,$FF,$B4,$00,$4B,$BF,$B4,$00,$04,$BF, ; Tile $1B
.byt $BB,$FF,$BB,$44,$44,$BF,$FB,$B4,$44,$4B,$FF,$BB,$44,$44,$BF,$FF,$B4,$04,$4B,$FF,$B4,$00,$44,$BF,$BB,$40,$00,$4B,$FB,$40,$00,$04, ; Tile $1C
.byt $BF,$FB,$40,$00,$BF,$FB,$40,$00,$BB,$FF,$B4,$00,$BB,$FF,$B4,$00,$FF,$FF,$B4,$00,$FF,$FF,$FB,$40,$BF,$FF,$FB,$40,$BB,$FF,$FB,$40, ; Tile $1D
.byt $4B,$FF,$FB,$B4,$04,$BF,$FF,$FB,$04,$4B,$BF,$FF,$00,$04,$4B,$BB,$00,$00,$44,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $1E
.byt $44,$4B,$BB,$FF,$BB,$BF,$FF,$BB,$FF,$FF,$BB,$B4,$BB,$BB,$44,$40,$44,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $1F
.byt $B4,$40,$00,$00,$44,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $20
.byt $00,$04,$BF,$FF,$00,$04,$BF,$FB,$00,$04,$4B,$FF,$00,$00,$4B,$FF,$00,$00,$4B,$FF,$00,$00,$44,$BF,$00,$00,$04,$BF,$00,$00,$04,$BF, ; Tile $21
.byt $BB,$44,$4B,$BF,$44,$00,$04,$BF,$B4,$00,$00,$BB,$B4,$00,$04,$BB,$B4,$00,$44,$BF,$FB,$44,$BB,$FF,$FB,$BB,$BF,$FB,$FF,$FF,$FF,$BB, ; Tile $22
.byt $FB,$40,$04,$BF,$FB,$B4,$04,$BF,$FF,$B4,$04,$BB,$FB,$B4,$00,$4B,$FB,$40,$00,$4B,$FB,$40,$00,$04,$B4,$00,$00,$04,$44,$00,$00,$00, ; Tile $23
.byt $FB,$40,$00,$00,$FB,$44,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$40,$00,$FF,$FB,$40,$00,$BF,$FB,$B4,$40,$BB,$FF,$BB,$44,$4B,$BF,$FF,$BB, ; Tile $24
.byt $00,$00,$4B,$FF,$00,$00,$4B,$FF,$00,$00,$4B,$FF,$00,$00,$4B,$FF,$00,$04,$BB,$FB,$00,$44,$BF,$FB,$44,$BB,$FF,$BB,$BB,$FF,$FB,$B4, ; Tile $25
.byt $B4,$00,$04,$BF,$B4,$00,$04,$BB,$B4,$00,$00,$4B,$B4,$00,$00,$4B,$B4,$00,$00,$04,$40,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00, ; Tile $26
.byt $FB,$40,$00,$00,$FF,$B4,$00,$00,$FF,$B4,$00,$00,$BB,$B4,$00,$00,$BB,$40,$00,$00,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $27
.byt $4B,$BB,$B4,$40,$04,$44,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $28
.byt $00,$00,$04,$4B,$00,$00,$00,$4B,$00,$00,$00,$4B,$00,$00,$00,$04,$00,$00,$00,$04,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $29
.byt $FF,$FB,$BB,$44,$FF,$BB,$44,$00,$FF,$B4,$40,$00,$BF,$FB,$40,$00,$BF,$FB,$40,$00,$BF,$FB,$44,$00,$4B,$FF,$B4,$00,$4B,$FF,$B4,$00, ; Tile $2A
.byt $04,$BB,$FF,$FF,$00,$44,$BB,$BB,$00,$00,$44,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $2B
.byt $FF,$FB,$BB,$40,$BB,$B4,$44,$00,$44,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $2C
.byt $4B,$BF,$B4,$00,$04,$BB,$44,$00,$00,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $2D
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0B,$B0,$BF,$0B,$04,$F0,$FF,$4B,$00,$F4,$BB,$BF,$00,$BF,$B4,$FF,$00,$BF,$40,$FB, ; Tile $2E
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$BB,$B0,$BF,$0B,$B4,$F0,$FF,$4B,$40,$F4,$BB,$BF,$00,$BF,$B4,$FF,$00,$BF,$40,$FB, ; Tile $2F
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$B0,$00,$BF,$FB,$B0,$0B,$F4,$4B,$40,$0B,$FF,$FF,$00,$0B,$F4,$00,$0F,$40,$BF,$FF, ; Tile $30
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$44,$FB,$FF,$BF,$B4,$FB,$4F,$F4,$B4,$F0,$0B,$B0,$04,$F0,$0B,$B0,$B4,$F0,$0B,$B0, ; Tile $31
.byt $00,$04,$F0,$4F,$00,$00,$00,$4F,$00,$00,$00,$4F,$FB,$04,$F0,$4F,$BF,$04,$F0,$4F,$0F,$04,$F0,$4F,$0F,$04,$F0,$4F,$0F,$04,$F0,$4F, ; Tile $32
.byt $04,$F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$F0,$0B,$FF,$04,$F0,$BF,$44,$04,$F0,$BB,$00,$04,$F0,$BF,$44,$04,$F0,$0B,$FF, ; Tile $33
.byt $00,$4F,$04,$F0,$00,$4F,$04,$F0,$00,$4F,$04,$F0,$B0,$4F,$04,$F0,$FB,$4F,$04,$F0,$BB,$4F,$04,$F0,$FB,$4F,$04,$F0,$B0,$4F,$04,$F0, ; Tile $34
.byt $4F,$00,$00,$4F,$4F,$00,$00,$4F,$4F,$00,$00,$4F,$4F,$BF,$F4,$4F,$4F,$B4,$BB,$4F,$4F,$00,$4F,$4F,$4F,$B4,$BB,$4F,$4F,$BF,$F4,$4F, ; Tile $35
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$BF,$F4,$00,$04,$B4,$BB,$00,$04,$00,$4F,$00,$04,$B4,$BB,$00,$04,$BF,$F4,$0F,$44, ; Tile $36
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FB,$FF,$40,$BF,$FB,$4B,$BB,$F4,$F0,$0B,$BB,$FF,$F0,$0B,$BB,$F4,$F0,$0B,$B0,$BF, ; Tile $37
.byt $00,$00,$00,$00,$00,$04,$F0,$00,$00,$04,$F0,$00,$FB,$4F,$FF,$F0,$4B,$B4,$F0,$00,$FF,$B4,$F0,$00,$00,$04,$F4,$00,$FF,$B0,$BF,$F0, ; Tile $38

.dsb $fffa-*, $ff
; === END OF SECOND 8K BLOCK ===


; === VECTORS ===
* = $fffa
    .word _nmi_int ; NMI vector
    .word _init ; Reset vector
    .word _irq_int ; IRQ/BRK vector
    
