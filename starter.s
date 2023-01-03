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

; 1. Quick led flash
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

; 3. Fill up screen 0
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

; 4. Fill up screen 1
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

; 4. Fill up screen 2
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

; 4. Fill up screen 3
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

; 2. Play tone
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
loop:
STA ($00),Y
JSR wait_vsync
INY
BNE loop
INC $01
BPL loop
CLC
wait: BCC wait
.)

; Test video modes
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
	LDA $00
	CLC
	ADC #4
	STA $00
	BCC skip
	INC $01
	skip:
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
loop:
STA ($00)
INC $00
BNE end
INC $01
end:
RTI
.)

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
