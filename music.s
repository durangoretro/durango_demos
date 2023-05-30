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

FA3=0
FAS3=1
SOL3=2
SOLS3=3
LA3=4
LAS3=5
SI3=6

DO4=7
DOS4=8
RE4=9
RES4=10
MI4=11
FA4=12
FAS4=13
SOL4=14
SOLS4=15
LA4=16
LAS4=17
SI4=18

DO5=19
DOS5=20
RE5=21
RES5=22
MI5=23
FA5=24
FAS5=25
SOL5=26
SOLS5=27
LA5=28
LAS5=29
SI5=30

DO6=31
DOS6=32
RE6=33
RES6=34
MI6=35
FA6=36
FAS6=37
SOL6=38
SOLS6=39
LA6=40
LAS6=41
SI6=42

SILENCIO=43

REDONDA = 128
BLANCA = 64
NEGRAP = 48
NEGRA = 32
CORCHEA = 16
SEMICORCHEA = 8
FUSA = 4
SEMIFUSA = 2


; MAIN -----
LDA #$F3
STA $df94


LDA #<melodia
STA DATA_POINTER
LDA #>melodia
STA DATA_POINTER+1
JSR tocar_melodia


LDA #<melodia2
STA DATA_POINTER
LDA #>melodia2
STA DATA_POINTER+1
JSR tocar_melodia

.(
end: BRA end
.)


tocar_melodia:
SEI
loop:
LDY #0
LDA (DATA_POINTER),Y
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
CLI
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
    BEQ silence
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
LAB_BDLY:
	RTS
silence:
LDA #77
LAB_BRPTS:
	LDX X2_COORD		; retrieve repetitions...
LAB_BLNGS:
	TAY					; ...and period
LAB_BCYCS:
	JSR LAB_BDLYS		; waste 12 cyles...
	NOP					; ...and another 2
	DEY
	BNE LAB_BCYCS		; total 19t per iteration
	DEX
	STZ IOBeep			; toggle speaker
	BNE LAB_BLNGS
	DEC X_COORD			; repeat until desired length
	BNE LAB_BRPTS
LAB_BDLYS:
	RTS



; *** Durango-X BEEP specific, table of notes and cycles ***
fr_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byt						232,219,206,195,184,173,164		; octave 3
	.byt	155,146,138,130,123,116,109,103, 97, 92, 87, 82		; octave 4
	.byt	 77, 73, 69, 65, 61, 58, 55, 52, 49, 46, 43, 41		; octave 5
	.byt	 39, 36, 34, 32, 31, 29, 27, 26, 24, 23, 22, 20		; octave 6
    .byt     0
	
cy_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B		repetitions for a normalised 20 ms length
	.byt						  6,  8,  8,  8,  8, 10, 10		; octave 3
	.byt	 10, 12, 12, 12, 14, 14, 14, 16, 16, 18, 18, 20		; octave 4
	.byt	 20, 22, 24, 24, 26, 28, 30, 30, 32, 34, 38, 38		; octave 5
	.byt	 40, 44, 46, 50, 52, 56, 58, 60, 66, 68, 72, 78		; octave 6
    .byt     20




melodia:
.byt DO4, CORCHEA, RE4, CORCHEA, MI4, CORCHEA, FA4, CORCHEA, SOL4, CORCHEA, LA4, CORCHEA, SI4, CORCHEA, SILENCIO ,NEGRA
.byt DO5, CORCHEA, RE5, CORCHEA, MI5, CORCHEA, FA5, CORCHEA, SOL5, CORCHEA, LA5, CORCHEA, SI5, CORCHEA, SILENCIO ,NEGRA
.byt DO6, CORCHEA, RE6, CORCHEA, MI6, CORCHEA, FA6, CORCHEA, SOL6, CORCHEA, LA6, CORCHEA, SI6, CORCHEA, SILENCIO ,NEGRA
.byt $FF, $FF

melodia2:
.byt MI4, CORCHEA, MI4, CORCHEA, SOL4, NEGRAP, MI4, CORCHEA, MI4, NEGRA, 
.byt SOL4, NEGRA, MI4, CORCHEA, SOL4, CORCHEA, DO5, NEGRA, SI4, NEGRA,
.byt SILENCIO, CORCHEA, LA4, CORCHEA,
.byt $FF, $FF


; Dev-Cart JMP at $FFE1
.dsb    $ffe1-*, $ff
JMP($FFFC)

; Vectors
.dsb    $fffa-*, $ff    ; filling
.word begin
.word begin
.word begin
