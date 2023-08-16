*=$C000

;====== DXHEAD =========================================================
; 8 bytes
.byt $00
.byt "dX"
.byt "****"
.byt $0d
; 222 bytes
; TITLE_COMMENT[
.byt "LOADER 16K"
.byt $00, $00
.byt "######################################"
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


; ===== DCLIB CONSTANTS ================================================
VIDEO_MODE = $DF80
INT_ENABLE = $DFA0
KEYBOARD = $DF9B
GAMEPAD1 = $DF9C
GAMEPAD2 = $DF9D
VSP = $DF93
VSP_CONFIG = $DF94
SYNC = $DF88
IOBEEP=$DFB0
SCREEN_0 = $0000
SCREEN_1 = $2000
SCREEN_2 = $4000
SCREEN_3 = $6000
GAMEPAD_MODE1 = $00
GAMEPAD_MODE2 = $01
GAMEPAD_VALUE1 = $02
GAMEPAD_VALUE2 = $03
KEYBOARD_CACHE = $04; $05; $06; $07; $08
IRQ_ADDR = $0200
NMI_ADDR = $0202
INT_COUNTER = $0206
KEY_PRESSED = $020A
SIGNATURE = $FFAB
BUILD_HASH = $C0E6
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
;=======================================================================
; === DURANGO COLORS ===================================================
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
MAGENTA = $aa
LAVENDER_ROSE = $bb
NAVY_BLUE = $cc
CIAN = $dd
PINK_FLAMINGO = $ee
WHITE = $ff
;=======================================================================

; ===== RAM LOADER =====================================================
reset:
.(
; Init source pointer
LDX #$C0
STX RESOURCE_POINTER+1
LDY #$00
STY RESOURCE_POINTER
; Init destination pointer
LDX #$20
STX DATA_POINTER+1
LDY #$00
STY DATA_POINTER

; Copy data from source pointer to destination pointer
; until source pointer overflows to zero
loop:
LDA (RESOURCE_POINTER), Y
STA (DATA_POINTER), Y
INY
BNE loop
INC DATA_POINTER+1
INC RESOURCE_POINTER+1
BNE loop
.)

; Run loaded code from RAM
JMP $2200
; Padding
.dsb $C200-*, $ff
*=$2200
;=======================================================================

;========= INITIALIZATION ==============================================
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

; ============= ACTUAL CODE TO BE RAN ON MEMORY ========================
LDA #BLACK
STA COLOUR
JSR _fillScreen
LDA #BLACK
STA PAPER
LDA #WHITE
STA COLOUR

LDA #10
STA X_COORD
LDA #10
STA Y_COORD
LDA #<uno
STA DATA_POINTER
LDA #>uno
STA DATA_POINTER+1
JSR _printStr



forever:
bra forever

LDA #1
STA $DFFF

hello_world:
.asc "Hello World"
.byt $00

uno:
.asc "1."
.byt $00

; ======================================================================

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


; ============= Vectors ================================================
irq_int:
RTI
nmi_int:
RTI
nmi:
JMP (NMI_ADDR)
irq:
JMP (IRQ_ADDR)
.dsb    $5ffa-*, $ff    ; filling
.word nmi
.word reset
.word irq
; ======================================================================
