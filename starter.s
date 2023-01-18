MAP_TO_DRAW=$10
VMEM_POINTER=$00
VMEM_POINTER2=$02
CONTROLLER_1 = $20
CONTROLLER_2 = $21
KEYBOARD_1 = $22
KEYBOARD_2 = $23
KEYBOARD_3 = $24
KEYBOARD_4 = $25
KEYBOARD_5 = $26
RED = $22
DARK_GREEN = $44

#define mempos(x,y) 24576+(y*64+x/2)

P1_UP=mempos(22, 12)
P1_DOWN=mempos(22, 30)
P1_LEFT=mempos(14, 22)
P1_RIGHT=mempos(32,22)

P2_UP=mempos(22, 57)
P2_DOWN=mempos(22, 76)
P2_LEFT=mempos(14, 66)
P2_RIGHT=mempos(32, 66)

P1_A=mempos(104, 28)
P1_B=mempos(88, 28)
P1_SELECT=mempos(50, 28)
P1_START=mempos(66, 28)

P2_A=mempos(104, 73)
P2_B=mempos(88, 73)
P2_SELECT=mempos(50, 73)
P2_START=mempos(66, 73)

KEY_1=mempos(22, 93)
KEY_Q=mempos(22, 103)
KEY_A=mempos(22, 112)
KEY_SHIFT=mempos(22, 121)
KEY_0=mempos(104, 93)
KEY_P=mempos(104, 103)
KEY_INTRO=mempos(104, 112)
KEY_SPACE=mempos(104, 120)

KEY_2=mempos(32, 93)
KEY_W=mempos(32, 103)
KEY_S=mempos(32, 112)
KEY_Z=mempos(32, 121)
KEY_9=mempos(94, 93)
KEY_O=mempos(94, 103)
KEY_L=mempos(94, 112)
KEY_ALT=mempos(94, 120)

KEY_3=mempos(40, 93)
KEY_E=mempos(40, 103)
KEY_D=mempos(40, 112)
KEY_X=mempos(40, 121)
KEY_8=mempos(86, 93)
KEY_I=mempos(86, 103)
KEY_K=mempos(86, 112)
KEY_M=mempos(86, 120)

KEY_4=mempos(50, 93)
KEY_R=mempos(50, 103)
KEY_F=mempos(50, 112)
KEY_C=mempos(50, 121)
KEY_7=mempos(76, 93)
KEY_U=mempos(76, 103)
KEY_J=mempos(76, 112)
KEY_N=mempos(76, 120)

KEY_5=mempos(58, 93)
KEY_T=mempos(58, 103)
KEY_G=mempos(58, 112)
KEY_V=mempos(58, 121)
KEY_6=mempos(68, 93)
KEY_Y=mempos(68, 103)
KEY_H=mempos(68, 112)
KEY_B=mempos(68, 120)


*=$c000

begin:

; Initialize regs
.(
SEI
CLD
LDX #$FF
TXS
LDA #$00
STA $dfa0
.)

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10001100
STA $df80

; Quick led flash
.(
CLC
wait_loop:
INX
BNE wait_loop
INY
BNE wait_loop
EOR #$04
STA $df80
BCC wait_loop
LDA #%10001100
STA $df80
.)

; Play tone
.(
LDX #$ff     ; Duration
dur_loop:
STX $dfb0
LDY #63    ; Frequency
loop:
DEY
BNE loop
DEX
BPL dur_loop
.)

; Fill up screen 0
.(
LDA #$FF
LDY #$00
STY $01
LDX #$02
STX $00
loop:
STA ($00),Y
INY
BNE loop
INC $01
BPL loop
STA $00
STA $01
CLC
wait: BCC wait
.)
; Clear screen 0
.(
LDA #$00
LDY #$00
STY $01
LDX #$02
STX $00
loop:
STA ($00),Y
INY
BNE loop
INC $01
BPL loop
STA $00
STA $01
CLC
wait: BCC wait
.)
; Draw version
.(
; Draw version
LDA #<version
STA MAP_TO_DRAW
LDA #>version
STA MAP_TO_DRAW+1
LDA #$10
JSR draw_text
; Wait NMI
CLC
wait: BCC wait
.)


; Fill up screen 1
.(
LDA #%00011000
STA $df80
LDA #$11
LDX #$20
STX $01
LDY #$00
STY $00
loop:
STA ($00),Y
INY
BNE loop
INC $01
BPL loop

; Draw screen number 1
LDA #<sc1_title
STA MAP_TO_DRAW
LDA #>sc1_title
STA MAP_TO_DRAW+1
LDA #$30
JSR draw_color_text

CLC
wait: BCC wait
.)

; Fill up screen 2
.(
LDA #%00101000
STA $df80
LDA #$22
LDX #$40
STX $01
LDY #$00
STY $00
loop:
STA ($00),Y
INY
BNE loop
INC $01
BPL loop

; Draw screen number 2
LDA #<sc2_title
STA MAP_TO_DRAW
LDA #>sc2_title
STA MAP_TO_DRAW+1
LDA #$50
JSR draw_color_text

CLC
wait: BCC wait
.)

; Fill up screen 3
.(
LDA #%00111000
STA $df80
LDA #$33
LDX #$60
STX $01
LDY #$00
STY $00
loop:
STA ($00),Y
INY
BNE loop
INC $01
BPL loop

; Draw screen number 3
LDA #<sc1_title
STA MAP_TO_DRAW
LDA #>sc3_title
STA MAP_TO_DRAW+1
LDA #$70
JSR draw_color_text

CLC
wait: BCC wait
.)

; Test IRQ
.(
LDA #%00111100
STA $df80
LDX #$60
STX $01
LDY #$00
STY $00 
LDA #$44
CLI
LDY #$01
STY $dfa0
wait:
LDX $01
BPL wait
SEI
LDY #$00
STY $dfa0

; Draw IRQ title
LDA #<irq_title
STA MAP_TO_DRAW
LDA #>irq_title
STA MAP_TO_DRAW+1
LDA #$70
JSR draw_color_text

CLC
waitnmi: BCC waitnmi
.)

; Test HSync
.(
LDA #$55
LDX #$60
STX $01
LDY #$00
STY $00
loop:
STA ($00),Y
JSR wait_hsync
INY
BNE loop
INC $01
BPL loop

; Draw HSYNC title
LDA #<hsync_title
STA MAP_TO_DRAW
LDA #>hsync_title
STA MAP_TO_DRAW+1
LDA #$70
JSR draw_color_text

CLC
wait: BCC wait
.)

; Test VSync
.(
LDA #$66
LDX #$60
STX $01
LDY #$00
STY $00
LDX #127
loop:
jSR draw_line
JSR wait_vsync
DEX
BPL loop

; Draw VSYNC title
LDA #<vsync_title
STA MAP_TO_DRAW
LDA #>vsync_title
STA MAP_TO_DRAW+1
LDA #$70
JSR draw_color_text

CLC
wait: BCC wait
.)

; Draw bn palette
.(

LDX #$20
STX $01
LDY #$00
STY $00
LDX #64
loop:
LDA #%10101010
JSR draw_line
LDA #%01010101
JSR draw_line
DEX
BNE loop
.)
; Draw grayscale palette
.(

LDX #$40
STX $01
LDY #$00
STY $00
LDX #128
loop:
JSR draw_bn_line
DEX
BNE loop
.)
; Draw color palette
.(
LDX #$60
STX $01
LDY #$00
STY $00
LDX #128
loop:
JSR draw_colors_line
DEX
BNE loop

CLC
wait: BCC wait
.)

; Invert
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%01111000
STA $df80
CLC
wait: BCC wait
.)

; Grayscale
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%00100100
STA $df80
CLC
wait: BCC wait
.)

; Grayscale Invert
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%01100000
STA $df80
CLC
wait: BCC wait
.)

; Black White
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10010100
STA $df80
CLC
wait: BCC wait
.)

; Black White Invert
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%11010000
STA $df80
CLC
wait: BCC wait
.)

; Input
.(
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%00111100
STA $df80
; Draw inputs background
LDA #>background
STA MAP_TO_DRAW+1
LDA #<background
STA MAP_TO_DRAW
JSR draw_background
JSR draw_keyless_background

loop:
JSR read_gamepads
JSR read_keyboard
JSR draw_gamepads
JSR draw_keyboard
BRA loop
.)


forever: JMP forever


wait_vsync:
.(
    vstart:
    BIT $DF88
    BVS vstart
    vend:
    BIT $DF88
    BVC vend
    RTS
.)

wait_hsync:
.(
    vstart:
    BIT $DF88
    BMI vstart
    vend:
    BIT $DF88
    BPL vend
    RTS
.)

draw_segment:
.(
	LDY #3
	loop:
	STA ($00),Y
	DEY
	BPL loop
	PHA
	LDA $00
	CLC
	ADC #4
	STA $00
	BCC skip
	INC $01
	skip:
	PLA
	RTS
.)

draw_line:
.(
	LDY #63
	loop:
	STA ($00),Y
	DEY
	BPL loop
	PHA
	LDA $00
	CLC
	ADC #64
	STA $00
	BCC skip
	INC $01
	skip:
	PLA
	RTS
.)

draw_colors_line:
.(
LDA #$00
JSR draw_segment
LDA #$11
JSR draw_segment
LDA #$22
JSR draw_segment
LDA #$33
JSR draw_segment
LDA #$44
JSR draw_segment
LDA #$55
JSR draw_segment
LDA #$66
JSR draw_segment
LDA #$77
JSR draw_segment
LDA #$88
JSR draw_segment
LDA #$99
JSR draw_segment
LDA #$AA
JSR draw_segment
LDA #$BB
JSR draw_segment
LDA #$CC
JSR draw_segment
LDA #$DD
JSR draw_segment
LDA #$EE
JSR draw_segment
LDA #$FF
JSR draw_segment
RTS
.)

draw_bn_line:
.(
LDA #$00
JSR draw_segment
LDA #$88
JSR draw_segment
LDA #$44
JSR draw_segment
LDA #$CC
JSR draw_segment
LDA #$22
JSR draw_segment
LDA #$AA
JSR draw_segment
LDA #$66
JSR draw_segment
LDA #$EE
JSR draw_segment
LDA #$11
JSR draw_segment
LDA #$99
JSR draw_segment
LDA #$55
JSR draw_segment
LDA #$DD
JSR draw_segment
LDA #$33
JSR draw_segment
LDA #$BB
JSR draw_segment
LDA #$77
JSR draw_segment
LDA #$FF
JSR draw_segment
RTS
.)

draw_background:
.(
    ; Init video pointer
LDA #$60
STA VMEM_POINTER+1
STZ VMEM_POINTER
rle_loop:
LDY #0
LDA (MAP_TO_DRAW), Y
INC MAP_TO_DRAW
BNE rle_0
INC MAP_TO_DRAW+1
rle_0:
TAX
BMI rle_u
BEQ rle_exit
LDA (MAP_TO_DRAW), Y
rc_loop:
STA (VMEM_POINTER), Y
INY
DEX
BNE rc_loop
INC MAP_TO_DRAW
BNE rle_next
INC MAP_TO_DRAW+1
BNE rle_next
rle_u:
LDA (MAP_TO_DRAW), Y
STA (VMEM_POINTER), Y
INY
INX
BNE rle_u
TYA
rle_adv:
CLC
ADC MAP_TO_DRAW
STA MAP_TO_DRAW
BCC rle_next
INC MAP_TO_DRAW+1
rle_next:
TYA
CLC
ADC VMEM_POINTER
STA VMEM_POINTER
BCC rle_loop
INC VMEM_POINTER+1
BNE rle_loop
rle_exit:
RTS
.)

draw_keyless_background:
.(
LDA #$60
STA VMEM_POINTER+1
STZ VMEM_POINTER
LDA #$40
STA VMEM_POINTER2+1
STZ VMEM_POINTER2

loop:
LDA (VMEM_POINTER)
STA (VMEM_POINTER2)

INC VMEM_POINTER
INC VMEM_POINTER2
BNE skip
INC VMEM_POINTER2+1
INC VMEM_POINTER+1
BMI end
skip:
BRA loop
end:

LDA #$56
STA VMEM_POINTER2+1
STZ VMEM_POINTER2
LDY #0
loop2:
LDA #$77
STA (VMEM_POINTER2),Y
INY
BNE loop2
INC VMEM_POINTER2+1
LDA #$60
CMP VMEM_POINTER2+1
BNE loop2

RTS
.)

read_gamepads:
.(
; 1. write into $DF9C
STX $DF9C
; 2. write into $DF9D 8 times
STX $DF9D
STX $DF9D
STX $DF9D
STX $DF9D
STX $DF9D
STX $DF9D
STX $DF9D
STX $DF9D
; 3. read first controller in $DF9C
LDX $DF9C
STX CONTROLLER_1
; 4. read second controller in $DF9D
LDX $DF9D
STX CONTROLLER_2
RTS
.)

read_keyboard:
.(
LDA #1
STA $DF9B
LDX $DF9B
STX KEYBOARD_1

ASL
STA $DF9B
LDX $DF9B
STX KEYBOARD_2

ASL
STA $DF9B
LDX $DF9B
STX KEYBOARD_3

ASL
STA $DF9B
LDX $DF9B
STX KEYBOARD_4

ASL
STA $DF9B
LDX $DF9B
STX KEYBOARD_5

RTS
.)

draw_gamepads:
.(
JSR draw_gamepad1
JMP draw_gamepad2
.)

draw_gamepad1:
.(
LDA CONTROLLER_1

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
; hex(0x6000+(y*64+x/2))
; 24576+(y*64+x/2)

; P1 RIGHT
LSR
JSR load_carry_color
STX P1_RIGHT
STX P1_RIGHT+64
STX P1_RIGHT-$2000
STX P1_RIGHT+64-$2000
; P1 DOWN
LSR
JSR load_carry_color
STX P1_DOWN
STX P1_DOWN+64
STX P1_DOWN-$2000
STX P1_DOWN+64-$2000
; P1 LEFT
LSR
JSR load_carry_color
STX P1_LEFT
STX P1_LEFT+64
STX P1_LEFT-$2000
STX P1_LEFT+64-$2000
; P1 UP
LSR
JSR load_carry_color
STX P1_UP
STX P1_UP+64
STX P1_UP-$2000
STX P1_UP+64-$2000
; P1 SELECT
LSR
JSR load_carry_color
STX P1_SELECT
STX P1_SELECT+64
STX P1_SELECT-$2000
STX P1_SELECT+64-$2000
; P1 B
LSR
JSR load_carry_color
STX P1_B
STX P1_B+64
STX P1_B-$2000
STX P1_B+64-$2000
; P1 START
LSR
JSR load_carry_color
STX P1_START
STX P1_START+64
STX P1_START-$2000
STX P1_START+64-$2000
; A
LSR
JSR load_carry_color
STX P1_A
STX P1_A+64
STX P1_A-$2000
STX P1_A+64-$2000

RTS
.)

draw_gamepad2:
.(
LDA CONTROLLER_2
; 24576+(y*64+x/2)

; P2 RIGHT
LSR
JSR load_carry_color
STX P2_RIGHT
STX P2_RIGHT+64
STX P2_RIGHT-$2000
STX P2_RIGHT+64-$2000
; P2 DOWN
LSR
JSR load_carry_color
STX P2_DOWN
STX P2_DOWN+64
STX P2_DOWN-$2000
STX P2_DOWN+64-$2000
; P2 LEFT
LSR
JSR load_carry_color
STX P2_LEFT
STX P2_LEFT+64
STX P2_LEFT-$2000
STX P2_LEFT+64-$2000
; P2 UP
LSR
JSR load_carry_color
STX P2_UP
STX P2_UP+64
STX P2_UP-$2000
STX P2_UP+64-$2000
; P2 SELECT
LSR
JSR load_carry_color
STX P2_SELECT
STX P2_SELECT+64
STX P2_SELECT-$2000
STX P2_SELECT+64-$2000
; P2 B
LSR
JSR load_carry_color
STX P2_B
STX P2_B+64
STX P2_B-$2000
STX P2_B+64-$2000
; P2 START
LSR
JSR load_carry_color
STX P2_START
STX P2_START+64
STX P2_START-$2000
STX P2_START+64-$2000
; A
LSR
JSR load_carry_color
STX P2_A
STX P2_A+64
STX P2_A-$2000
STX P2_A+64-$2000

RTS
.)

draw_keyboard:
.(
LDA #32
STA $DF9B
LDA $DF9B
CMP #$2C
BEQ keyboard_present
LDA #%00101100
STA $df80
RTS
keyboard_present:
LDA #%00111100
STA $df80
JSR draw_keyboard1
JSR draw_keyboard2
JSR draw_keyboard3
JSR draw_keyboard4
JMP draw_keyboard5
.)

draw_keyboard1:
.(
LDA KEYBOARD_1
; 1
LSR
JSR load_carry_color_kb
STX KEY_1
STX KEY_1+64
; Q
LSR
JSR load_carry_color_kb
STX KEY_Q
STX KEY_Q+64
; A
LSR
JSR load_carry_color_kb
STX KEY_A
STX KEY_A+64
; 0
LSR
JSR load_carry_color_kb
STX KEY_0
STX KEY_0+64
; P
LSR
JSR load_carry_color_kb
STX KEY_P
STX KEY_P+64
; SHIFT
LSR
JSR load_carry_color_kb
STX KEY_SHIFT
STX KEY_SHIFT+64
; INTRO
LSR
JSR load_carry_color_kb
STX KEY_INTRO
STX KEY_INTRO+64
; SPACE
LSR
JSR load_carry_color_kb
STX KEY_SPACE
STX KEY_SPACE+64

RTS
.)

draw_keyboard2:
.(
LDA KEYBOARD_2
; 2
LSR
JSR load_carry_color_kb
STX KEY_2
STX KEY_2+64
; W
LSR
JSR load_carry_color_kb
STX KEY_W
STX KEY_W+64
; S
LSR
JSR load_carry_color_kb
STX KEY_S
STX KEY_S+64
; 9
LSR
JSR load_carry_color_kb
STX KEY_9
STX KEY_9+64
; O
LSR
JSR load_carry_color_kb
STX KEY_O
STX KEY_O+64
; Z
LSR
JSR load_carry_color_kb
STX KEY_Z
STX KEY_Z+64
; L
LSR
JSR load_carry_color_kb
STX KEY_L
STX KEY_L+64
; ALT
LSR
JSR load_carry_color_kb
STX KEY_ALT
STX KEY_ALT+64
RTS
.)

draw_keyboard3:
.(
LDA KEYBOARD_3
; 3
LSR
JSR load_carry_color_kb
STX KEY_3
STX KEY_3+64
; E
LSR
JSR load_carry_color_kb
STX KEY_E
STX KEY_E+64
; D
LSR
JSR load_carry_color_kb
STX KEY_D
STX KEY_D+64
; 8
LSR
JSR load_carry_color_kb
STX KEY_8
STX KEY_8+64
; I
LSR
JSR load_carry_color_kb
STX KEY_I
STX KEY_I+64
; X
LSR
JSR load_carry_color_kb
STX KEY_X
STX KEY_X+64
; K
LSR
JSR load_carry_color_kb
STX KEY_K
STX KEY_K+64
; M
LSR
JSR load_carry_color_kb
STX KEY_M
STX KEY_M+64
RTS
.)
draw_keyboard4:
.(
LDA KEYBOARD_4
; 4
LSR
JSR load_carry_color_kb
STX KEY_4
STX KEY_4+64
; R
LSR
JSR load_carry_color_kb
STX KEY_R
STX KEY_R+64
; F
LSR
JSR load_carry_color_kb
STX KEY_F
STX KEY_F+64
; 7
LSR
JSR load_carry_color_kb
STX KEY_7
STX KEY_7+64
; U
LSR
JSR load_carry_color_kb
STX KEY_U
STX KEY_U+64
; C
LSR
JSR load_carry_color_kb
STX KEY_C
STX KEY_C+64
; J
LSR
JSR load_carry_color_kb
STX KEY_J
STX KEY_J+64
; N
LSR
JSR load_carry_color_kb
STX KEY_N
STX KEY_N+64
RTS
.)
draw_keyboard5:
.(
LDA KEYBOARD_5
; 5
LSR
JSR load_carry_color_kb
STX KEY_5
STX KEY_5+64
; T
LSR
JSR load_carry_color_kb
STX KEY_T
STX KEY_T+64
; G
LSR
JSR load_carry_color_kb
STX KEY_G
STX KEY_G+64
; 6
LSR
JSR load_carry_color_kb
STX KEY_6
STX KEY_6+64
; Y
LSR
JSR load_carry_color_kb
STX KEY_Y
STX KEY_Y+64
; V
LSR
JSR load_carry_color_kb
STX KEY_V
STX KEY_V+64
; H
LSR
JSR load_carry_color_kb
STX KEY_H
STX KEY_H+64
; B
LSR
JSR load_carry_color_kb
STX KEY_B
STX KEY_B+64
RTS
.)

load_carry_color:
.(
BCC key_down
LDX #DARK_GREEN
BRA end
key_down:
LDX #RED
end:
RTS
.)
load_carry_color_kb:
.(
BCC key_down
LDX #RED
BRA end
key_down:
LDX #DARK_GREEN
end:
RTS
.)

draw_text:
.(
STA VMEM_POINTER+1
LDA #$00
STA VMEM_POINTER
LDY #0
loop:
LDA (MAP_TO_DRAW),Y
STA (VMEM_POINTER),Y
INY
BNE loop
RTS
.)

draw_color_text:
.(
STA VMEM_POINTER+1
LDA #$00
STA VMEM_POINTER
LDX #2
LDY #0
loop:
LDA (MAP_TO_DRAW),Y
STA (VMEM_POINTER),Y
INY
BNE loop
INC VMEM_POINTER+1
INC MAP_TO_DRAW+1
DEX
BNE loop
RTS
.)


nmi:
.(
	BCS end
        PHA
	PHX
	TSX
	LDA $103,X
	ORA #$01
	STA $103,X

	PLX
	PLA
        end:
	RTI
.)

irq:
.(
JSR draw_line
RTI
.)

; ======================== BINARY RESOURCES ========================================================================================
background:
.byt $7F,$77,$FE,$77,$77,$3E,$88,$FE,$77,$77,$3E,$88,$FE,$77,$77,$3E,$88,$FC,$77,$77,$88,$88,$3A,$99,$FA,$98,$88,$77,$77,$88,$88,$3A,
.byt $99,$FA,$98,$88,$77,$77,$88,$88,$12,$99,$FF,$98,$10,$88,$17,$99,$FA,$98,$88,$77,$77,$88,$88,$12,$99,$11,$88,$FF,$89,$16,$99,$FA,
.byt $98,$88,$77,$77,$88,$88,$12,$99,$11,$88,$FF,$89,$16,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$FF,$FF,$F9,$06,$99,$11,
.byt $88,$FF,$89,$16,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$11,$88,$FF,$89,$16,$99,$FA,$98,$88,$77,
.byt $77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$FF,$98,$10,$88,$17,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,
.byt $FF,$F9,$2E,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$2E,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,
.byt $04,$44,$FF,$F9,$06,$99,$FF,$98,$10,$88,$17,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$11,$88,$FF,
.byt $89,$16,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$04,$FF,$04,$44,$04,$FF,$03,$99,$11,$88,$FF,$89,$16,$99,$FA,$98,$88,$77,$77,$88,
.byt $88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$11,$88,$FF,$89,$16,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,
.byt $03,$99,$11,$88,$FF,$89,$16,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$FF,$98,$10,$88,$17,$99,$FA,
.byt $98,$88,$77,$77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$17,$99,$FF,$9F,$06,$FF,$FE,$99,$99,$06,$FF,$05,$99,$FA,$98,$88,$77,$77,
.byt $88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$FF,$98,$0B,$88,$FF,$86,$04,$88,$03,$99,$07,$FF,$FE,$99,$9F,$06,$FF,$FF,$F9,$04,
.byt $99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$FA,$98,$88,$88,$86,$66,$66,$06,$88,$FE,$86,$68,$03,$88,
.byt $FD,$89,$99,$99,$03,$FF,$F3,$44,$4F,$FF,$FF,$F9,$9F,$FF,$FF,$44,$4F,$FF,$FF,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$FF,
.byt $F4,$0A,$44,$FF,$4F,$03,$99,$03,$88,$FD,$86,$66,$66,$06,$88,$FE,$86,$66,$03,$88,$FB,$89,$99,$99,$FF,$FF,$03,$44,$FB,$4F,$FF,$F9,
.byt $9F,$FF,$03,$44,$FD,$4F,$FF,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$03,$88,$FD,$86,$66,
.byt $66,$06,$88,$FE,$86,$68,$03,$88,$FB,$89,$99,$99,$FF,$F4,$04,$44,$FC,$FF,$F9,$9F,$F4,$04,$44,$FE,$FF,$F9,$04,$99,$FA,$98,$88,$77,
.byt $77,$88,$88,$03,$99,$FF,$F4,$0A,$44,$FF,$4F,$03,$99,$0C,$88,$FF,$86,$04,$88,$FC,$89,$99,$99,$FF,$05,$44,$FD,$4F,$F9,$9F,$05,$44,
.byt $FE,$4F,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$03,$99,$04,$FF,$04,$44,$04,$FF,$03,$99,$FD,$88,$88,$84,$04,$44,$03,$88,$FF,$84,
.byt $04,$44,$FA,$88,$88,$89,$99,$99,$FF,$05,$44,$FD,$4F,$F9,$9F,$05,$44,$FE,$4F,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,
.byt $9F,$04,$44,$FF,$F9,$06,$99,$FE,$88,$88,$05,$44,$FD,$48,$88,$88,$05,$44,$FA,$48,$88,$89,$99,$99,$FF,$05,$44,$FD,$4F,$F9,$9F,$05,
.byt $44,$FE,$4F,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$FD,$88,$88,$84,$04,$44,$03,$88,$FF,
.byt $84,$04,$44,$FA,$88,$88,$89,$99,$99,$FF,$05,$44,$FD,$4F,$F9,$9F,$05,$44,$FE,$4F,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,
.byt $FF,$9F,$04,$44,$FF,$F9,$06,$99,$03,$88,$03,$44,$FF,$48,$04,$88,$03,$44,$F9,$48,$88,$88,$89,$99,$99,$FF,$05,$44,$FD,$4F,$F9,$9F,
.byt $05,$44,$FE,$4F,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$11,$88,$FB,$89,$99,$99,$FF,$F4,
.byt $04,$44,$FC,$FF,$F9,$9F,$F4,$04,$44,$FE,$FF,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$44,$FF,$F9,$06,$99,$11,
.byt $88,$FB,$89,$99,$99,$FF,$FF,$03,$44,$FB,$4F,$FF,$F9,$9F,$FF,$03,$44,$FD,$4F,$FF,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,
.byt $FF,$9F,$04,$44,$FF,$F9,$06,$99,$FF,$98,$10,$88,$FD,$89,$99,$99,$03,$FF,$F3,$44,$44,$FF,$FF,$F9,$9F,$FF,$FF,$44,$44,$FF,$FF,$F9,
.byt $04,$99,$FA,$98,$88,$77,$77,$88,$88,$06,$99,$FF,$9F,$04,$FF,$FF,$F9,$06,$99,$FF,$98,$10,$88,$03,$99,$07,$FF,$FE,$F9,$9F,$06,$FF,
.byt $FF,$F9,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$26,$99,$FF,$9F,$06,$FF,$FE,$99,$99,$06,$FF,$05,$99,$FA,$98,$88,$77,$77,$88,$88,$3A,
.byt $99,$FA,$98,$88,$77,$77,$88,$88,$2B,$99,$FE,$96,$66,$06,$99,$FD,$96,$66,$69,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$12,$99,$11,$88,
.byt $FF,$89,$07,$99,$FD,$96,$99,$69,$05,$99,$FD,$96,$99,$69,$04,$99,$FA,$98,$88,$77,$77,$88,$88,$12,$99,$11,$88,$FF,$89,$07,$99,$FE,
.byt $96,$66,$06,$99,$FD,$96,$66,$69,$04,$99,$FC,$98,$88,$77,$77,$2D,$88,$FD,$86,$88,$68,$05,$88,$FD,$86,$88,$68,$06,$88,$FE,$77,$77,
.byt $2D,$88,$FE,$86,$66,$06,$88,$FD,$86,$88,$68,$06,$88,$FE,$77,$77,$3E,$88,$FE,$77,$77,$3E,$88,$7F,$77,$03,$77,$3E,$AA,$FE,$77,$77,
.byt $3E,$AA,$FE,$77,$77,$3E,$AA,$FE,$77,$77,$3E,$AA,$FC,$77,$77,$AA,$AA,$3A,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$3A,$BB,$FA,$BA,$AA,$77,
.byt $77,$AA,$AA,$12,$BB,$FF,$BA,$10,$AA,$17,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$12,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,
.byt $AA,$12,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$FF,$FF,$FB,$06,$BB,$11,$AA,$FF,$AB,$16,$BB,
.byt $FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,
.byt $FF,$BF,$04,$44,$FF,$FB,$06,$BB,$FF,$BA,$10,$AA,$17,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$2E,$BB,$FA,
.byt $BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$2E,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,
.byt $BB,$FF,$BA,$10,$AA,$17,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,
.byt $AA,$77,$77,$AA,$AA,$03,$BB,$04,$FF,$04,$44,$04,$FF,$03,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,$F4,
.byt $0A,$44,$FF,$4F,$03,$BB,$11,$AA,$FF,$AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,$03,$BB,$11,$AA,$FF,
.byt $AB,$16,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,$03,$BB,$FF,$BA,$10,$AA,$17,$BB,$FA,$BA,$AA,$77,$77,$AA,
.byt $AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,$17,$BB,$FF,$BF,$06,$FF,$FE,$BB,$BB,$06,$FF,$05,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,
.byt $F4,$0A,$44,$FF,$4F,$03,$BB,$FF,$BA,$0B,$AA,$FF,$A6,$04,$AA,$03,$BB,$07,$FF,$FE,$BB,$BF,$06,$FF,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,
.byt $77,$AA,$AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,$03,$BB,$FA,$BA,$AA,$AA,$A6,$66,$66,$06,$AA,$FE,$A6,$6A,$03,$AA,$FD,$AB,$BB,$BB,$03,
.byt $FF,$F3,$44,$4F,$FF,$FF,$FB,$BF,$FF,$FF,$44,$4F,$FF,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,
.byt $03,$BB,$03,$AA,$FD,$A6,$66,$66,$06,$AA,$FE,$A6,$66,$03,$AA,$FB,$AB,$BB,$BB,$FF,$FF,$03,$44,$FB,$4F,$FF,$FB,$BF,$FF,$03,$44,$FD,
.byt $4F,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$FF,$F4,$0A,$44,$FF,$4F,$03,$BB,$03,$AA,$FD,$A6,$66,$66,$06,$AA,$FE,$A6,
.byt $6A,$03,$AA,$FB,$AB,$BB,$BB,$FF,$F4,$04,$44,$FC,$FF,$FB,$BF,$F4,$04,$44,$FE,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,
.byt $FF,$F4,$0A,$44,$FF,$4F,$03,$BB,$0C,$AA,$FF,$A6,$04,$AA,$FC,$AB,$BB,$BB,$FF,$05,$44,$FD,$4F,$FB,$BF,$05,$44,$FE,$4F,$FB,$04,$BB,
.byt $FA,$BA,$AA,$77,$77,$AA,$AA,$03,$BB,$04,$FF,$04,$44,$04,$FF,$03,$BB,$FD,$AA,$AA,$A4,$04,$44,$03,$AA,$FF,$A4,$04,$44,$FA,$AA,$AA,
.byt $AB,$BB,$BB,$FF,$05,$44,$FD,$4F,$FB,$BF,$05,$44,$FE,$4F,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,
.byt $06,$BB,$FE,$AA,$AA,$05,$44,$FD,$4A,$AA,$AA,$05,$44,$FA,$4A,$AA,$AB,$BB,$BB,$FF,$05,$44,$FD,$4F,$FB,$BF,$05,$44,$FE,$4F,$FB,$04,
.byt $BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,$BB,$FD,$AA,$AA,$A4,$04,$44,$03,$AA,$FF,$A4,$04,$44,$FA,$AA,
.byt $AA,$AB,$BB,$BB,$FF,$05,$44,$FD,$4F,$FB,$BF,$05,$44,$FE,$4F,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,
.byt $FB,$06,$BB,$03,$AA,$03,$44,$FF,$4A,$04,$AA,$03,$44,$F9,$4A,$AA,$AA,$AB,$BB,$BB,$FF,$05,$44,$FD,$4F,$FB,$BF,$05,$44,$FE,$4F,$FB,
.byt $04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,$BB,$11,$AA,$FB,$AB,$BB,$BB,$FF,$F4,$04,$44,$FC,$FF,$FB,
.byt $BF,$F4,$04,$44,$FE,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,$FB,$06,$BB,$11,$AA,$FB,$AB,$BB,$BB,
.byt $FF,$FF,$03,$44,$FB,$4F,$FF,$FB,$BF,$FF,$03,$44,$FD,$4F,$FF,$FB,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$44,$FF,
.byt $FB,$06,$BB,$FF,$BA,$10,$AA,$FD,$AB,$BB,$BB,$03,$FF,$F3,$44,$44,$FF,$FF,$FB,$BF,$FF,$FF,$44,$44,$FF,$FF,$FB,$04,$BB,$FA,$BA,$AA,
.byt $77,$77,$AA,$AA,$06,$BB,$FF,$BF,$04,$FF,$FF,$FB,$06,$BB,$FF,$BA,$10,$AA,$03,$BB,$07,$FF,$FE,$FB,$BF,$06,$FF,$FF,$FB,$04,$BB,$FA,
.byt $BA,$AA,$77,$77,$AA,$AA,$26,$BB,$FF,$BF,$06,$FF,$FE,$BB,$BB,$06,$FF,$05,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$3A,$BB,$FA,$BA,$AA,$77,
.byt $77,$AA,$AA,$2B,$BB,$FE,$B6,$66,$06,$BB,$FD,$B6,$66,$6B,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$12,$BB,$11,$AA,$FF,$AB,$07,$BB,$FD,
.byt $B6,$BB,$6B,$05,$BB,$FD,$B6,$BB,$6B,$04,$BB,$FA,$BA,$AA,$77,$77,$AA,$AA,$12,$BB,$11,$AA,$FF,$AB,$07,$BB,$FE,$B6,$66,$06,$BB,$FD,
.byt $B6,$66,$6B,$04,$BB,$FC,$BA,$AA,$77,$77,$2D,$AA,$FD,$A6,$AA,$6A,$05,$AA,$FD,$A6,$AA,$6A,$06,$AA,$FE,$77,$77,$2D,$AA,$FE,$A6,$66,
.byt $06,$AA,$FD,$A6,$AA,$6A,$06,$AA,$FE,$77,$77,$3E,$AA,$FE,$77,$77,$3E,$AA,$7F,$77,$0C,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,
.byt $44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,
.byt $FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,
.byt $FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,
.byt $47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,
.byt $77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,
.byt $74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,
.byt $03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,
.byt $03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$7F,$77,$15,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,
.byt $74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,
.byt $03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,
.byt $03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,
.byt $44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,
.byt $FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,
.byt $FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,
.byt $47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,
.byt $77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,
.byt $74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$7F,$77,$15,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,
.byt $FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,
.byt $47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,
.byt $77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,
.byt $74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,
.byt $03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,
.byt $03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,
.byt $44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,
.byt $FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,
.byt $FF,$77,$03,$44,$FE,$47,$74,$03,$44,$7F,$77,$15,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,
.byt $44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,
.byt $FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,
.byt $FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,
.byt $47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,
.byt $77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,
.byt $74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,
.byt $03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$14,$77,$03,$44,$FE,$47,$74,
.byt $03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,$44,$FE,$47,$74,$03,$44,$FF,$77,$03,
.byt $44,$FE,$47,$74,$03,$44,$7F,$77,$4B,$77,$00,
; ===================================================================================================================================
version:
.byt %11100000,%00000111,%01111100,%00000000,%11111111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %01110000,%00001110,%00011100,%00000000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00111000,%00011100,%00011100,%00000000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00011100,%00111000,%00011100,%00000000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00001110,%01110000,%00011100,%00000000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00000111,%11100000,%00011100,%00000000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00000011,%11000000,%11111111,%00011000,%11100111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byt %00000001,%10000000,%11111111,%00011000,%11111111,%00000000,%00000000,%00000000 ,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

sc1_title:
.byt $FF,$FF,$FF, $11, $FF,$FF,$FF, $11, $FF,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $FF,$11,$11, $11, $FF,$FF,$FF, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $FF,$11,$11, $11, $FF,$11,$11, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $FF,$FF,$FF, $11, $FF,$11,$11, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $11,$11,$FF, $11, $FF,$11,$11, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $11,$11,$FF, $11, $FF,$11,$11, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $11,$11,$FF, $11, $FF,$FF,$FF, $11, $11,$FF,$11, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byt $FF,$FF,$FF, $11, $FF,$FF,$FF, $11, $FF,$FF,$FF, $11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11

sc2_title:
.byt $FF,$FF,$FF, $22, $FF,$FF,$FF, $22, $FF,$FF,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $FF,$22,$22, $22, $FF,$FF,$FF, $22, $FF,$FF,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $FF,$22,$22, $22, $FF,$22,$22, $22, $22,$22,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $FF,$FF,$FF, $22, $FF,$22,$22, $22, $FF,$FF,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $22,$22,$FF, $22, $FF,$22,$22, $22, $FF,$FF,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $22,$22,$FF, $22, $FF,$22,$22, $22, $FF,$22,$22, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $22,$22,$FF, $22, $FF,$FF,$FF, $22, $FF,$22,$22, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
.byt $FF,$FF,$FF, $22, $FF,$FF,$FF, $22, $FF,$FF,$FF, $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22

sc3_title:
.byt $FF,$FF,$FF, $33, $FF,$FF,$FF, $33, $FF,$FF,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $FF,$33,$33, $33, $FF,$FF,$FF, $33, $33,$33,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $FF,$33,$33, $33, $FF,$33,$33, $33, $33,$33,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $FF,$FF,$FF, $33, $FF,$33,$33, $33, $FF,$FF,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$FF, $33, $FF,$33,$33, $33, $FF,$FF,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$FF, $33, $FF,$33,$33, $33, $33,$33,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$FF, $33, $FF,$FF,$FF, $33, $33,$33,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $FF,$FF,$FF, $33, $FF,$FF,$FF, $33, $FF,$FF,$FF, $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33

irq_title:
.byt $FF,$FF,$FF, $44, $FF,$FF,$FF, $44, $FF,$FF,$FF,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $FF,$FF,$FF, $44, $FF,$44,$FF, $44, $FF,$44,$44,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $44,$FF,$44, $44, $FF,$44,$FF, $44, $FF,$44,$44,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $44,$FF,$44, $44, $FF,$FF,$FF, $44, $FF,$F4,$44,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $44,$FF,$44, $44, $FF,$4F,$F4, $44, $FF,$4F,$44,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $44,$FF,$44, $44, $FF,$4F,$F4, $44, $FF,$44,$F4,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $FF,$FF,$FF, $44, $FF,$44,$FF, $44, $FF,$44,$4F,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
.byt $FF,$FF,$FF, $44, $FF,$44,$FF, $44, $FF,$FF,$FF,$FF, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44

#if(*>$df00)
#echo First segment is too big!
#endif
.dsb $df00-*, $ff
.dsb $dfff-*, $ff
; === END OF FIRST 8K BLOCK ===

hsync_title:
.byt $FF,$55,$55,$FF, $55, $FF,$FF,$FF, $55, $FF,$55,$55,$55,$5F,$F5, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$55,$55,$FF, $55, $FF,$55,$55, $55, $5F,$F5,$55,$55,$FF,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$FF,$FF,$FF, $55, $FF,$55,$55, $55, $55,$FF,$55,$5F,$F5,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$FF,$FF,$FF, $55, $FF,$FF,$FF, $55, $55,$5F,$F5,$FF,$55,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$55,$55,$FF, $55, $55,$55,$FF, $55, $55,$55,$FF,$F5,$55,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$55,$55,$FF, $55, $55,$55,$FF, $55, $55,$55,$5F,$F5,$55,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$55,$55,$FF, $55, $55,$55,$FF, $55, $55,$55,$5F,$F5,$55,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
.byt $FF,$55,$55,$FF, $55, $FF,$FF,$FF, $55, $55,$55,$5F,$F5,$55,$55, $55, $55,$55,$55,$55, $55, $55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55


vsync_title:
.byt $FF,$66,$66,$FF, $66, $FF,$FF,$FF, $66, $FF,$66,$66,$66,$6F,$F6, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $FF,$66,$66,$FF, $66, $FF,$66,$66, $66, $6F,$F6,$66,$66,$FF,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $6F,$F6,$6F,$66, $66, $FF,$66,$66, $66, $66,$FF,$66,$6F,$F6,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $6F,$F6,$6F,$66, $66, $FF,$FF,$FF, $66, $66,$6F,$F6,$FF,$66,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $66,$F6,$6F,$66, $66, $66,$66,$FF, $66, $66,$66,$FF,$F6,$66,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $66,$F6,$6F,$66, $66, $66,$66,$FF, $66, $66,$66,$6F,$F6,$66,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $66,$6F,$F6,$66, $66, $66,$66,$FF, $66, $66,$66,$6F,$F6,$66,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66
.byt $66,$6F,$F6,$66, $66, $FF,$FF,$FF, $66, $66,$66,$6F,$F6,$66,$66, $66, $66,$66,$66,$66, $66, $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66






.byt $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
.byt $33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33

; === FILLING ===
#echo done!
used_space = *-begin
#print used_space
.dsb    $fffa-*, $ff
* = $fffa
; === VECTORS ===
.word nmi ; NMI vector
.word begin ; Reset vector
.word irq ; IRQ/BRK vector
