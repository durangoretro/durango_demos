*=$8000

;====== DXHEAD =========================================================
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
.byt $00,$80,$00,$00
;]
;=======================================================================

;========= INITIALIZATION ==============================================
begin:
; Initialize 6502    
SEI ; Disable interrupts
CLD ; Clear decimal mode
LDX #$FF ; Initialize stack pointer to $01FF
TXS
; Set up IRQ subroutine
LDA #<irq_int
STA IRQ_ADDR
LDA #>irq_int
STA IRQ_ADDR+1
; Set up NMI subroutine
LDA #<nmi_int
STA NMI_ADDR
LDA #>nmi_int
STA NMI_ADDR+1
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
;=======================================================================

; ===== DCLIB CONSTANTS ================================================
VMEM_POINTER = $10 ; $11
DATA_POINTER = $12 ; $13
RESOURCE_POINTER = $14 ; $15
BACKGROUND_POINTER = $16; $17
RANDOM_SEED = $18; $19
COLOUR = $1A
PAPER = $1B
X_COORD = $1C
Y_COORD = $1D
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
TEMP1 = $28
TEMP2 = $29
TEMP3 = $2A
TEMP4 = $2B
TEMP5 = $2C
TEMP6 = $2D
TEMP7 = $2E
TEMP8 = $2F
IOBEEP=$DFB0
IRQ_ADDR = $0200
NMI_ADDR = $0202
PSV = $df93
PSV_CONFIG = $df94
PSV_RAW_INIT  = $20
PSV_RAW_SEEK  = $21
PSV_RAW_READ  = $22
PSV_RAW_WRITE = $23
PSV_RAW_CLOSE = $24
;=======================================================================

;============= LOADER ==================================================
; Load binary at $2000
LOAD_ADDR = $2000
.(
; Set up Load Address variable
LDA #<LOAD_ADDR
STA DATA_POINTER
LDA #>LOAD_ADDR
STA DATA_POINTER+1
; Set up file block number variable
STZ X_COORD

; Load 48 blocks (24K)
loop:
JSR read_block
INC DATA_POINTER+1
INC DATA_POINTER+1
INC X_COORD
LDA X_COORD
CMP #49
BNE loop

; Run loaded code
JMP $2100

end: BRA end
.)

read_block:
.(
; Open PSV file
LDY #PSV_RAW_INIT
STY PSV_CONFIG
; Raw seek
LDA #PSV_RAW_SEEK
STA PSV_CONFIG
;BUFFER
LDA DATA_POINTER
STA PSV
LDA DATA_POINTER+1
STA PSV
;BLOCK
LDA #0
STA PSV
STA PSV
STA PSV
LDA X_COORD
STA PSV
; Run read
LDA #PSV_RAW_READ
STA PSV_CONFIG
; PSV raw file Close
LDY #PSV_RAW_CLOSE
STY PSV_CONFIG
; Return
RTS
.)
;=======================================================================



; =============== LIBRARY ==============================================
;Melody data must be on DATA_POINTER
_play_melody:
.(
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
.)

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
.(
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
	STX IOBEEP			; toggle speaker
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
	STZ IOBEEP			; toggle speaker
	BNE LAB_BLNGS
	DEC X_COORD			; repeat until desired length
	BNE LAB_BRPTS
    LAB_BDLYS:
	RTS
.)


; *** Durango-X BEEP specific, table of notes and cycles ***
fr_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	.byte						232,219,206,195,184,173,164		; octave 3
	.byte	155,146,138,130,123,116,109,103, 97, 92, 87, 82		; octave 4
	.byte   77, 73, 69, 65, 61, 58, 55, 52, 49, 46, 43, 41		; octave 5
	.byte	39, 36, 34, 32, 31, 29, 27, 26, 24, 23, 22, 20		; octave 6
    .byte   0
	
cy_Tab:
;			C	C#	D	D#	E	F	F#	G	G#	A	A#	B		repetitions for a normalised 20 ms length
	.byte						  6,  8,  8,  8,  8, 10, 10		; octave 3
	.byte	 10, 12, 12, 12, 14, 14, 14, 16, 16, 18, 18, 20		; octave 4
	.byte	 20, 22, 24, 24, 26, 28, 30, 30, 32, 34, 38, 38		; octave 5
	.byte	 40, 44, 46, 50, 52, 56, 58, 60, 66, 68, 72, 78		; octave 6
    .byte    20
; ================ LIBRARY END =========================================


; ======== RESERVED IO SPACE ($df00 - $dfff) ===========================
#if(*>$df00)
#echo Previous segment is too big df00
#endif
.dsb $e000-*, $ff
; ======================================================================

; == Some empty space, maybe for contants or tables ($e000 - $fc00) ====
; ======================================================================

; ======= Function calls ===============================================
#if(*>$fc00)
#echo Previous segment is too big fc00
#endif
.dsb $fc00-*, $ff
; $FC00 -> play_melody
JMP _play_melody
; $FC03
; $FC06
; $FC09
; $FC0C
; ======================================================================

; ============= Vectors ================================================
irq_int:
RTS
nmi_int:
RTS
nmi:
JMP (NMI_ADDR)
irq:
JMP (IRQ_ADDR)
.dsb    $fffa-*, $ff    ; filling
.word nmi
.word begin
.word irq
; ======================================================================
