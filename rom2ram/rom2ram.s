; ROM-to-RAM sample demo
; (c) 2025 Carlos J. Santisteban

; *** hardware definitions ***
IO8mode	= $DF80
IOAie	= $DFA0

* =		$c000				; 16K ROM

; *** memory usage ***
ptr		= $FE				; zeropage pointer
dest	= $0800				; destination address in RAM

; ***************************
; *** init and bootloader ***
; ***************************
reset:
	SEI						; usual 6502 init
	CLD
	LDX #$ff
	TXS
	STX IOAie				; LED off
	LDA #$38				; colour mode
	STA IO8mode
	ldx #d_end-dest			; copy into RAM this number of bytes
copy:
		LDA c_start-1, X	; get source from ROM
		STA dest-1, X		; copy into RAM
		DEX
		BNE copy
	JMP $800				; launch payload!
bootend:

; ***************
; *** payload ***
; ***************
c_start:
* =		dest				; RAM location
.(
	LDX #$60				; standard screen page
	LDY #0
	STY ptr					; reset index
page:
		STX ptr+1			; update page
loop:
			STA (ptr), Y	; fill screen
			INY
			BNE loop
		INX
		BPL page			; next page until screen is complete
	INC						; next value and repeat (CMOS only)
	BRA dest
.)
d_end:

; *** after payload, rest of the ROM ***

* =		c_start+d_end-dest	; back into ROM addressing space, note payload offset

	.dsb	$FFD6-*, $FF	; padding

; ****************************************
; *** usual Durango/minimOS compliance ***
; ****************************************
	.asc	"DmOS"			; standard footer
; *** dummy interrupt handlers ***
irq:
	RTI						; IRQ does nothing
nmi:
	BRA nmi					; NMI locks (CMOS only)

	.dsb	$FFE1-*, $FF
	JMP ($FFFC)				; ShadowRAM support

	.dsb $FFFA-*, $FF		; 6502 hard vectors
	.word	nmi
	.word	reset
	.word	irq
