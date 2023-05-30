*=$c000

;------ DXHEAD------------------------------------------------------

; 8 bytes
.byt $00
.byt "dX"
.byt "****"
.byt $0d

; 222 bytes
; TITLE_COMMENT[
.byt $00, $00
.byt "################################################"
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
DATA_POINTER=$01; $02
TEMP1=$03
X_COORD=$04; duracion
X2_COORD=$05
Y_COORD=$06; nota


DO0=0
DOS0=1
RE0=2
RES0=3
MI0=4
FA0=5
FAS0=6
SOL0=7
SOLS0=8
LA0=9
SI0=10

DO1=11
DOS1=12
RE1=13
RES1=14
MI1=15
FA1=16
FAS1=17
SOL1=18
SOLS1=19
LA1=20
SI1=21

DO2=22
DOS2=23
RE2=24
RES2=25
MI2=26
FA2=27
FAS2=28
SOL2=29
SOLS2=30
LA2=31
SI2=32


; MAIN -----
LDA #$F3
STA $df94
LDX #$00
STX $df93




LDA #<melodia
STA DATA_POINTER
LDA #>melodia
STA DATA_POINTER+1

JSR tocar_melodia

.(
end: BRA end
.)


tocar_melodia:
loop:
LDY #0
LDA (DATA_POINTER),Y
STA $df93
BMI end
STA Y_COORD
INY
LDA (DATA_POINTER),Y
STA X_COORD

JSR LAB_BEEP

INC DATA_POINTER
INC DATA_POINTER
BNE skip
INC DATA_POINTER+1
skip:
BRA loop
end:
RTS

; Music lib by Carlos J. Santisteban

; duración notas (para negra~120/minuto)
; redonda	= 128
; blanca	= 64
; negra		= 32
; corchea	= 16
; semicor.	= 8
; fusa		= 4
; semifusa	= 2

; perform BEEP d,n (len/25, note 0=F3 ~ 42=B6 (ZX Spectrum value+7))
LAB_BEEP:
	; Nota en X
    LDX Y_COORD
    ; Periodo onda
    LDY fr_Tab, X		; period
	; Factor ajuste
    LDA cy_Tab, X		; base cycles
	STA X2_COORD		; eeek
	; Periodo en A
    TYA
	; Deshabilitar interrupcion
    SEI
LAB_BRPT:
	LDX X2_COORD		; retrieve repetitions...
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
	DEC X_COORD			; repeat until desired length
	BNE LAB_BRPT
	CLI					; restore interrupts!
LAB_BDLY:
	RTS




; *** Durango-X BEEP specific, table of notes and cycles ***
fr_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt	155,146,138,130,123,116,109,103, 97, 92, 87, 82		; octave 4
	.byt	 77, 73, 69, 65, 61, 58, 55, 52, 49, 46, 43, 41		; octave 5
	.byt	 39, 36, 34, 32, 31, 29, 27, 26, 24, 23, 22, 20		; octave 6
	
cy_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B		repetitions for a normalised 20 ms length
	.byt	 10, 12, 12, 12, 14, 14, 14, 16, 16, 18, 18, 20		; octave 4
	.byt	 20, 22, 24, 24, 26, 28, 30, 30, 32, 34, 38, 38		; octave 5
	.byt	 40, 44, 46, 50, 52, 56, 58, 60, 66, 68, 72, 78		; octave 6




melodia:
.byt DO0, 32, RE0, 32, MI0, 32, FA0, 32, SOL0, 32, LA0, 32, SI0, 32
.byt DO1, 32, RE1, 32, MI1, 32, FA1, 32, SOL1, 32, LA1, 32, SI1, 32
.byt DO2, 32, RE2, 32, MI2, 32, FA2, 32, SOL2, 32, LA2, 32, SI2, 32 
.byt $FF, $FF




; Dev-Cart JMP at $FFE1
.dsb    $ffe1-*, $ff
JMP($FFFC)

; Vectors
.dsb    $fffa-*, $ff    ; filling
.word begin
.word begin
.word begin
