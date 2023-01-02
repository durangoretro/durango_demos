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
VMEM_POINTER = $00
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
VMEM_POINTER = $00
SCREEN_START = $0002
LDA #$00
LDX #>SCREEN_START
STX VMEM_POINTER+1
LDY #<SCREEN_START
STY VMEM_POINTER
loop:
STA (VMEM_POINTER),Y
INY
BNE loop
INC VMEM_POINTER+1
BPL loop
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
