*=$c000

;------ DXHEAD------------------------------------------------------

; 8 bytes
.byt $00
.byt "dX"
.byt "****"
.byt $0d

; 222 bytes
; TITLE_COMMENT[
.byt "##################################################"
.byt "##################################################"
.byt "##################################################"
.byt "##################################################"
.byt "######################";]


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
;---------------------------------------------------------------

begin:

; Initialize 6502    
SEI ; Disable interrupts
CLD ; Clear decimal mode
LDX #$FF ; Initialize stack pointer to $01FF
TXS

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3F
STA $df80

; Clean screen
LDA #$00
LDX #$60
STX $01
LDY #$00
STY $00
loopcs:
STA ($00), Y
INY
BNE loopcs
INC $01
BPL loopcs

; We are ready for actual work -----------------------------------

nota=0
duracion=8
temp=$05

; redonda	= 32
; blanca	= 16
; negra		= 8
; corchea	= 4
; semicor	= 2


; Music lib by Carlos J. Santisteban

; duración notas (para negra~120/minuto)
; redonda	= 128
; blanca	= 64
; negra		= 32
; corchea	= 16
; semicor.	= 8
; fusa		= 4
; semifusa	= 2

; ejemplo de uso:
	LDY #0				; índice de escala cromática
	LDX #duracion			; normalmente potencias de dos
    JSR tocar_nota
    
    LDY #2
	LDX #duracion
    JSR tocar_nota
    
    LDY #4
	LDX #duracion
    JSR tocar_nota
    
    LDY #5
	LDX #duracion
    JSR tocar_nota
    
    LDY #7
	LDX #duracion
    JSR tocar_nota
    
    LDY #9
	LDX #duracion
    JSR tocar_nota
    
    LDY #11
	LDX #duracion
    JSR tocar_nota
    
    LDY #12
	LDX #duracion
    JSR tocar_nota


end: BRA end

; Y Indice nota
; X Duracion nota
tocar_nota:
    LDA periodo,Y; (param Y)
    PHA; (param Y)
    LDA cic,Y; (Param X)
    PHX; (param A)
    TAX; (Param X)
    PLA; (param A)
    PLY; (param Y)
    JMP tocar

; A -> Duracion nota en potencias de 2 (tabla duracion notas)
; Y -> Duracion del semiperiodo obtenido de la tabla periodos
; X -> factor de ajuste de duracion obtenido de la tabla cic
; Duracion (en tiempo) = A
; Factor conversion t->n: X
; Duracion (en ondas) = a*x
tocar:
	STA temp
	SEI
	TYA
long:
			TAY				; (2)
ciclo:
; posible retardo extra aquí
				DEY			; (2)
				BNE ciclo	; (3) bucle interior, i=5*Y-1
			DEX				; (2)
			STX $DFB0		; (4)
			BNE long		; (3) total bucle exterior, (11+i)*X-1
		DEC temp
		BNE long			; el tiempo de arriba será ~ constante, multiplicado por el valor original de A
	CLI
	RTS
    
; ** tablas de notas **
periodo:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt	147,139,131,123,116,110,104, 98, 92, 87, 82, 78; octava 6
	.byt	 73, 69, 65, 62, 58, 55, 52, 49, 46, 44, 41, 39; octava 7
	.byt	 37, 35, 33, 31, 29, 27, 26, 24, 23, 22, 21, 19; octava 8 (dudosa)

; *** compensación de duraciones *** producto ~4800, cada nota dura ~16 ms
cic:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt	 33, 35, 37, 39, 41, 44, 46, 49, 52, 55, 58, 62; octava 6
	.byt	 65, 69, 73, 78, 82, 87, 92, 98,104,110,116,123; octava 7
	.byt	131,139,147,155,165,175,185,196,208,220,223,247; octava 8





; Dev-Cart JMP at $FFE1
.dsb    $ffe1-*, $ff
JMP($FFFC)

; Vectors
.dsb    $fffa-*, $ff    ; filling
.word begin
.word begin
.word begin
