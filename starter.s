MAP_TO_DRAW=$10
VMEM_POINTER=$00
CONTROLLER_1 = $20
CONTROLLER_2 = $21
RED = $22
DARK_GREEN = $44


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
LDA #>background
STA MAP_TO_DRAW+1
LDA #<background
STA MAP_TO_DRAW
JSR draw_background

loop:
JSR read_gamepads
JSR draw_gamepads
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

draw_gamepads:
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

; P1 RIGHT
LSR
JSR load_carry_color
STX 24576+(22*64+32/2)
STX 24576+(23*64+32/2)
; P1 DOWN
LSR
JSR load_carry_color
STX 24576+(30*64+22/2)
STX 24576+(31*64+22/2)
; P1 LEFT
LSR
JSR load_carry_color
STX 24576+(22*64+14/2)
STX 24576+(23*64+14/2)
; P1 UP
LSR
JSR load_carry_color
STX 24576+(12*64+22/2)
STX 24576+(13*64+22/2)
; P1 SELECT
LSR
JSR load_carry_color
STX $6004
STX $6044
; P1 B
LSR
JSR load_carry_color
STX $6005
STX $6045
; P1 START
LSR
JSR load_carry_color
STX $6006
STX $6046
; A
LSR
JSR load_carry_color
STX $6007
STX $6047

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
