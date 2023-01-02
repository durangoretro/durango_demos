*=$c000

begin:

; Initialize regs
.(
SEI
CLD
LDX #$FF
TXS
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

; 2. Play tone

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

; 4. Fill up screen 2
.(
LDA #%00101000
STA $df80
LDA #$22
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

; 4. Fill up screen 3
.(
LDA #%00111000
STA $df80
LDA #$33
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

forever: JMP forever

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

; === FILLING ===
.dsb    $fffa-*, $ff
* = $fffa
; === VECTORS ===
.word nmi ; NMI vector
.word begin ; Reset vector
.word $0000 ; IRQ/BRK vector
