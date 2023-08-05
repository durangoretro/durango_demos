*=$C000

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
JMP $2080
; Padding
.dsb $C080-*, $ee
*=$2080
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
; Some dummy code, fill screen
LDX #$60
STX VMEM_POINTER+1
LDY #$00
STY VMEM_POINTER
LDA #GREEN
fill_loop:
STA (VMEM_POINTER), Y
INY
BNE fill_loop
INC VMEM_POINTER+1
BPL fill_loop
forever:
bra forever

; ======================================================================

; === PROCEDURES FROM DCLIB ============================================
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


default_font:
.byt $FF,$81,$BD,$BD,$BD,$BD,$81,$FF,$00,$00,$24,$48,$FE,$48,$24,$00,$00,$08,$1E,$3E,$7E,$3E,$1E,$08,$00,$10,$54,$92,$92,$44,$38,$00,
.byt $81,$41,$25,$15,$0D,$3D,$01,$FF,$00,$00,$24,$12,$FF,$12,$24,$00,$00,$10,$78,$7C,$7E,$7C,$78,$10,$00,$10,$7C,$7C,$7C,$FE,$30,$20,
.byt $00,$1F,$21,$55,$89,$55,$21,$1F,$00,$02,$0A,$06,$7E,$06,$0A,$02,$00,$7C,$7C,$FE,$7C,$38,$10,$00,$00,$10,$38,$7C,$FE,$7C,$7C,$00,
.byt $00,$F8,$94,$92,$9E,$82,$82,$FE,$00,$04,$04,$14,$24,$78,$20,$10,$00,$10,$08,$FC,$02,$FC,$08,$10,$00,$10,$20,$7E,$80,$7E,$20,$10,
.byt $00,$6C,$FE,$FE,$7C,$38,$10,$00,$00,$10,$10,$D6,$38,$10,$28,$44,$04,$08,$11,$22,$44,$68,$70,$00,$00,$10,$38,$7C,$FE,$7C,$38,$10,
.byt $00,$10,$38,$54,$FE,$54,$10,$38,$FF,$80,$BC,$B0,$A8,$A4,$82,$81,$00,$10,$54,$38,$10,$54,$38,$10,$00,$10,$38,$7C,$FE,$54,$10,$38,
.byt $00,$40,$50,$60,$7E,$60,$50,$40,$00,$10,$38,$54,$10,$38,$54,$10,$18,$7E,$FF,$81,$81,$FF,$7E,$18,$00,$7C,$78,$7C,$7E,$5F,$0E,$04,
.byt $01,$03,$07,$0F,$1F,$3F,$7F,$FF,$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF,$00,$22,$00,$88,$00,$22,$00,$88,$55,$AA,$55,$AA,$55,$AA,$55,$AA,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$10,$10,$10,$00,$10,$00,$00,$24,$24,$00,$00,$00,$00,$00,$00,$24,$7E,$24,$24,$7E,$24,$00,
.byt $00,$08,$3E,$28,$3E,$0A,$3E,$08,$00,$62,$64,$08,$10,$26,$46,$00,$00,$10,$28,$10,$2A,$44,$3A,$00,$00,$10,$10,$00,$00,$00,$00,$00,
.byt $00,$04,$08,$08,$08,$08,$04,$00,$00,$20,$10,$10,$10,$10,$20,$00,$00,$00,$14,$08,$3E,$08,$14,$00,$00,$00,$08,$08,$3E,$08,$08,$00,
.byt $00,$00,$00,$00,$00,$08,$08,$10,$00,$00,$00,$00,$3E,$00,$00,$00,$00,$00,$00,$00,$00,$18,$18,$00,$00,$00,$02,$04,$08,$10,$20,$00,
.byt $00,$3C,$46,$4A,$52,$62,$3C,$00,$00,$18,$28,$08,$08,$08,$3E,$00,$00,$3C,$42,$02,$3C,$40,$7E,$00,$00,$3C,$42,$0C,$02,$42,$3C,$00,
.byt $00,$08,$18,$28,$48,$7E,$08,$00,$00,$7E,$40,$7C,$02,$42,$3C,$00,$00,$3C,$40,$7C,$42,$42,$3C,$00,$00,$7E,$02,$04,$08,$10,$10,$00,
.byt $00,$3C,$42,$3C,$42,$42,$3C,$00,$00,$3C,$42,$42,$3E,$02,$3C,$00,$00,$00,$00,$10,$00,$00,$10,$00,$00,$00,$10,$00,$00,$10,$10,$20,
.byt $00,$00,$04,$08,$10,$08,$04,$00,$00,$00,$00,$3E,$00,$3E,$00,$00,$00,$00,$10,$08,$04,$08,$10,$00,$00,$3C,$42,$04,$08,$00,$08,$00,
.byt $00,$3C,$4A,$56,$5E,$40,$3C,$00,$00,$3C,$42,$42,$7E,$42,$42,$00,$00,$7C,$42,$7C,$42,$42,$7C,$00,$00,$3C,$42,$40,$40,$42,$3C,$00,
.byt $00,$78,$44,$42,$42,$44,$78,$00,$00,$7E,$40,$7C,$40,$40,$7E,$00,$00,$7E,$40,$7C,$40,$40,$40,$00,$00,$3C,$42,$40,$4E,$42,$3C,$00,
.byt $00,$42,$42,$7E,$42,$42,$42,$00,$00,$3E,$08,$08,$08,$08,$3E,$00,$00,$02,$02,$02,$42,$42,$3C,$00,$00,$44,$48,$70,$48,$44,$42,$00,
.byt $00,$40,$40,$40,$40,$40,$7E,$00,$00,$42,$66,$5A,$42,$42,$42,$00,$00,$42,$62,$52,$4A,$46,$42,$00,$00,$3C,$42,$42,$42,$42,$3C,$00,
.byt $00,$7C,$42,$42,$7C,$40,$40,$00,$00,$3C,$42,$42,$4A,$44,$3A,$00,$00,$7C,$42,$42,$7C,$44,$42,$00,$00,$3C,$40,$3C,$02,$42,$3C,$00,
.byt $00,$7C,$10,$10,$10,$10,$10,$00,$00,$42,$42,$42,$42,$42,$3C,$00,$00,$42,$42,$42,$42,$24,$18,$00,$00,$42,$42,$42,$42,$5A,$24,$00,
.byt $00,$42,$24,$18,$18,$24,$42,$00,$00,$82,$44,$28,$10,$10,$10,$00,$00,$7E,$04,$08,$10,$20,$7E,$00,$00,$0E,$08,$08,$08,$08,$0E,$00,
.byt $00,$00,$40,$20,$10,$08,$04,$00,$00,$70,$10,$10,$10,$10,$70,$00,$00,$10,$28,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,
.byt $00,$10,$08,$00,$00,$00,$00,$00,$00,$00,$38,$04,$3C,$44,$3C,$00,$00,$20,$20,$3C,$22,$22,$3C,$00,$00,$00,$1C,$20,$20,$20,$1C,$00,
.byt $00,$04,$04,$3C,$44,$44,$3C,$00,$00,$00,$38,$44,$78,$40,$3C,$00,$00,$0C,$10,$18,$10,$10,$10,$00,$00,$00,$3C,$44,$44,$3C,$04,$38,
.byt $00,$40,$40,$78,$44,$44,$44,$00,$00,$10,$00,$30,$10,$10,$38,$00,$00,$08,$00,$08,$08,$08,$48,$30,$00,$20,$20,$28,$30,$30,$28,$00,
.byt $00,$10,$10,$10,$10,$10,$0C,$00,$00,$00,$68,$54,$54,$54,$54,$00,$00,$00,$78,$44,$44,$44,$44,$00,$00,$00,$38,$44,$44,$44,$38,$00,
.byt $00,$00,$78,$44,$44,$78,$40,$40,$00,$00,$3C,$44,$44,$3C,$04,$06,$00,$00,$1C,$20,$20,$20,$20,$00,$00,$00,$38,$40,$38,$04,$78,$00,
.byt $00,$10,$38,$10,$10,$10,$0C,$00,$00,$00,$44,$44,$44,$44,$38,$00,$00,$00,$44,$44,$28,$28,$10,$00,$00,$00,$44,$54,$54,$54,$28,$00,
.byt $00,$00,$44,$28,$10,$28,$44,$00,$00,$00,$44,$44,$44,$3C,$04,$38,$00,$00,$7C,$08,$10,$20,$7C,$00,$00,$02,$04,$18,$04,$04,$02,$00,
.byt $08,$08,$08,$08,$08,$08,$08,$08,$00,$40,$20,$18,$20,$20,$40,$00,$00,$14,$28,$00,$00,$00,$00,$00,$00,$FE,$82,$AA,$92,$AA,$82,$FE,
.byt $00,$00,$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$00,$00,$F0,$F0,$F0,$F0,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00,
.byt $00,$00,$00,$00,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F,$FF,$FF,$FF,$FF,$0F,$0F,$0F,$0F,
.byt $00,$00,$00,$00,$F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$FF,$FF,$FF,$FF,$F0,$F0,$F0,$F0,
.byt $00,$00,$00,$00,$FF,$FF,$FF,$FF,$0F,$0F,$0F,$0F,$FF,$FF,$FF,$FF,$F0,$F0,$F0,$F0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
.byt $00,$00,$34,$48,$48,$34,$00,$00,$00,$00,$02,$04,$08,$50,$20,$00,$00,$7C,$40,$40,$40,$40,$40,$00,$00,$00,$02,$7C,$A8,$28,$28,$00,
.byt $7E,$20,$10,$08,$10,$20,$7E,$00,$00,$00,$00,$3C,$48,$48,$30,$00,$00,$04,$08,$10,$20,$7C,$00,$7C,$00,$00,$02,$7C,$90,$10,$08,$00,
.byt $00,$40,$20,$10,$08,$7C,$00,$7C,$00,$18,$24,$42,$7E,$42,$24,$18,$38,$44,$82,$82,$44,$28,$EE,$00,$10,$10,$08,$38,$44,$44,$38,$00,
.byt $00,$00,$00,$6C,$92,$92,$6C,$00,$00,$00,$32,$4C,$00,$32,$4C,$00,$00,$1E,$20,$40,$7E,$40,$20,$1E,$00,$00,$18,$24,$24,$24,$00,$00,
.byt $FF,$81,$81,$81,$81,$81,$81,$FF,$00,$08,$00,$08,$08,$08,$08,$00,$00,$08,$1C,$28,$28,$28,$1C,$08,$00,$1C,$22,$78,$20,$20,$7E,$00,
.byt $00,$3C,$42,$F8,$40,$F8,$42,$3C,$00,$44,$28,$7C,$10,$7C,$10,$00,$00,$08,$08,$08,$00,$08,$08,$08,$00,$0C,$10,$3C,$42,$3C,$08,$30,
.byt $00,$24,$00,$00,$00,$00,$00,$00,$3C,$42,$99,$A1,$A1,$99,$42,$3C,$60,$10,$70,$70,$00,$70,$00,$00,$00,$00,$12,$24,$48,$24,$12,$00,
.byt $00,$00,$00,$7E,$02,$02,$00,$00,$00,$00,$08,$7C,$10,$7C,$20,$00,$3C,$42,$B9,$A5,$B9,$A5,$42,$3C,$FF,$00,$00,$00,$00,$00,$00,$00,
.byt $30,$48,$30,$00,$00,$00,$00,$00,$00,$00,$10,$38,$10,$00,$38,$00,$70,$10,$70,$40,$70,$00,$00,$00,$70,$10,$70,$10,$70,$00,$00,$00,
.byt $08,$10,$00,$00,$00,$00,$00,$00,$00,$00,$48,$48,$74,$40,$40,$00,$00,$3F,$4A,$3A,$0A,$0A,$0A,$00,$00,$00,$00,$00,$10,$00,$00,$00,
.byt $00,$00,$00,$44,$82,$92,$6C,$00,$00,$00,$10,$28,$44,$FE,$00,$00,$70,$70,$00,$70,$00,$00,$00,$00,$00,$00,$48,$24,$12,$24,$48,$00,
.byt $00,$3C,$7E,$7E,$7E,$7E,$3C,$00,$00,$00,$6C,$92,$9C,$90,$6E,$00,$00,$00,$78,$44,$44,$44,$04,$08,$00,$10,$00,$10,$20,$42,$3C,$00,
.byt $10,$08,$3C,$42,$7E,$42,$42,$00,$08,$10,$3C,$42,$7E,$42,$42,$00,$18,$24,$00,$3C,$42,$7E,$42,$00,$14,$28,$00,$3C,$42,$7E,$42,$00,
.byt $24,$00,$3C,$42,$7E,$42,$42,$00,$18,$24,$18,$3C,$42,$7E,$42,$00,$00,$7E,$90,$FC,$90,$90,$9E,$00,$00,$3C,$42,$40,$42,$3C,$08,$10,
.byt $10,$08,$7E,$40,$7C,$40,$7E,$00,$08,$10,$7E,$40,$7C,$40,$7E,$00,$18,$24,$00,$7E,$40,$7C,$40,$7E,$24,$00,$7E,$40,$7C,$40,$7E,$00,
.byt $10,$08,$3E,$08,$08,$08,$3E,$00,$04,$08,$3E,$08,$08,$08,$3E,$00,$08,$14,$00,$3E,$08,$08,$08,$3E,$14,$00,$3E,$08,$08,$08,$3E,$00,
.byt $00,$78,$44,$E2,$42,$44,$78,$00,$14,$28,$42,$62,$52,$4A,$46,$42,$10,$08,$3C,$42,$42,$42,$3C,$00,$08,$10,$3C,$42,$42,$42,$3C,$00,
.byt $18,$24,$00,$3C,$42,$42,$42,$3C,$14,$28,$00,$3C,$42,$42,$42,$3C,$24,$00,$3C,$42,$42,$42,$3C,$00,$00,$00,$00,$28,$10,$28,$00,$00,
.byt $01,$3E,$46,$4A,$52,$62,$7C,$80,$10,$4A,$42,$42,$42,$42,$3C,$00,$08,$52,$42,$42,$42,$42,$3C,$00,$18,$24,$00,$42,$42,$42,$42,$3C,
.byt $42,$00,$42,$42,$42,$42,$3C,$00,$08,$92,$44,$28,$10,$10,$10,$00,$00,$40,$40,$7C,$42,$7C,$40,$40,$00,$30,$48,$50,$48,$48,$50,$00,
.byt $10,$08,$38,$04,$3C,$44,$3C,$00,$08,$10,$38,$04,$3C,$44,$3C,$00,$10,$28,$00,$38,$04,$3C,$44,$3C,$14,$28,$00,$38,$04,$3C,$44,$3C,
.byt $28,$00,$38,$04,$3C,$44,$3C,$00,$10,$28,$10,$38,$04,$3C,$44,$3C,$00,$00,$6C,$12,$7C,$90,$7E,$00,$00,$1C,$20,$20,$20,$1C,$08,$10,
.byt $10,$08,$38,$44,$78,$40,$3C,$00,$08,$10,$38,$44,$78,$40,$3C,$00,$10,$28,$00,$38,$44,$78,$40,$3C,$28,$00,$38,$44,$78,$40,$3C,$00,
.byt $20,$10,$00,$30,$10,$10,$38,$00,$08,$10,$00,$30,$10,$10,$38,$00,$10,$28,$00,$30,$10,$10,$38,$00,$00,$28,$00,$30,$10,$10,$38,$00,
.byt $00,$04,$0E,$04,$3C,$44,$3C,$00,$38,$00,$78,$44,$44,$44,$44,$00,$10,$08,$38,$44,$44,$44,$38,$00,$08,$10,$38,$44,$44,$44,$38,$00,
.byt $10,$28,$00,$38,$44,$44,$44,$38,$14,$28,$00,$38,$44,$44,$44,$38,$28,$00,$38,$44,$44,$44,$38,$00,$00,$00,$10,$00,$7C,$00,$10,$00,
.byt $00,$02,$3C,$4C,$54,$64,$78,$80,$20,$10,$44,$44,$44,$44,$38,$00,$08,$10,$44,$44,$44,$44,$38,$00,$10,$28,$00,$44,$44,$44,$44,$38,
.byt $28,$00,$44,$44,$44,$44,$38,$00,$08,$10,$44,$44,$44,$3C,$04,$38,$00,$20,$38,$24,$24,$38,$20,$00,$28,$00,$44,$44,$44,$3C,$04,$38,
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
