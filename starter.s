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
