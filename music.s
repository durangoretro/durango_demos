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
IOBeep=$DFB0
nota=0
duracion=32
TEMP1=$05
TEMP2=$06

.(
JSR LAB_BEEP
end: BRA end
.)

; perform BEEP d,n (len/25, note 0=F3 ~ 42=B6 (ZX Spectrum value+7))
LAB_BEEP:
	;JSR LAB_GTBY		; length
    ; Duracion (multiplos de 2) en X
    LDX #duracion
	STX TEMP1			; outside any register
	;JSR LAB_SCGB		; note
	; Nota en X
    LDX #nota
    ; Periodo onda
    LDY fr_Tab, X		; period
	; Factor ajuste
    LDA cy_Tab, X		; base cycles
	STA TEMP2		; eeek
	; Periodo en A
    TYA
	; Deshabilitar interrupcion
    SEI
LAB_BRPT:
	LDX TEMP2		; retrieve repetitions...
LAB_BLNG:
	TAY					; ...and period
LAB_BCYC:
	JSR LAB_BDLY		; waste 12 cyles...
	NOP					; ...and another 2
	DEY
	BNE LAB_BCYC		; total 19t per iteration
	DEX
	STX IOBeep			; toggle speaker
	BNE LAB_BLNG
	DEC TEMP1			; repeat until desired length
	BNE LAB_BRPT
	CLI					; restore interrupts!
LAB_BDLY:
	RTS




; *** Durango-X BEEP specific, table of notes and cycles ***
fr_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt						232,219,206,195,184,173,164		; octave 3
	.byt	155,146,138,130,123,116,109,103, 97, 92, 87, 82		; octave 4
	.byt	 77, 73, 69, 65, 61, 58, 55, 52, 49, 46, 43, 41		; octave 5
	.byt	 39, 36, 34, 32, 31, 29, 27, 26, 24, 23, 22, 20		; octave 6
	
cy_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B		repetitions for a normalised 20 ms length
	.byt						  6,  8,  8,  8,  8, 10, 10		; octave 3
	.byt	 10, 12, 12, 12, 14, 14, 14, 16, 16, 18, 18, 20		; octave 4
	.byt	 20, 22, 24, 24, 26, 28, 30, 30, 32, 34, 38, 38		; octave 5
	.byt	 40, 44, 46, 50, 52, 56, 58, 60, 66, 68, 72, 78		; octave 6




; ----------------------------------------



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


	LDY #78
    LDA #4
    LDX #4
    JMP tocar


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
	STA TEMP1
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
		DEC TEMP1
		BNE long			; el tiempo de arriba será ~ constante, multiplicado por el valor original de A
	;CLI
	RTS
    
; ** tablas de notas **
periodo:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt	147,139,131,123,116,110,104, 98, 92, 87, 82, 78; octava 6
	.byt	 73, 69, 65, 62, 58, 55, 52, 49, 46, 44, 41, 39; octava 7
	.byt	 37, 35, 33, 31, 29, 27, 26, 24, 23, 22, 21, 19; octava 8 (dudosa)

; *** compensación de duraciones *** producto ~4800, cada nota dura ~16 ms
cic:
;			C	C#	D	D#	E	F	F#	 G	G#	A	A#	B
	.byt	 1, 1, 1, 1, 1, 1, 1, 254,   100, 100, 100, 100; octava 6
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
