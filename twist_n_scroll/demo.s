; Twist-and-Scroll demo for Durango-X
; (c) 2024 Carlos J. Santisteban
; Last modified 20240507-0028

; ****************************
; *** standard definitions ***
	fw_irq	= $0200
	fw_nmi	= $0202
	test	= 0
	posi	= $FB			; %11111011
	sysptr	= $FC			; %11111100
	systmp	= $FE			; %11111101
	himem	= $FF			; %11111111
	IO8mode	= $DF80
	IO8lf	= $DF88			; EEEEEEEK
	IOAen	= $DFA0
	IOBeep	= $DFB0
	screen1	= $2000
	screen2	= $4000
	screen3	= $6000
	scrl	= $7800			; top position of scrolled text
	ptr		= sysptr
	src		= systmp
	colour	= posi-1
	count	= posi
	text	= test
	colidx	= test+2
	glyph	= colidx+1
; ****************************

* = $8000					; this is gonna be big...

; ***********************
; *** standard header ***
; ***********************
rom_start:
; header ID
	.byt	0				; [0]=NUL, first magic number
	.asc	"dX"			; bootable ROM for Durango-X devCart
	.asc	"****"			; reserved
	.byt	13				; [7]=NEWLINE, second magic number
; filename
	.asc	"Twist'n'Scroll", 0			; C-string with filename @ [8], max 220 chars
	.byt	0				; optional C-string with comment after filename, filename+comment up to 220 chars
	.byt	0				; second terminator for optional comment, just in case

; advance to end of header
	.dsb	rom_start + $E6 - *, $FF

; NEW library commit (user field 2)
	.asc	"$$$$$$$$"
; NEW main commit (user field 1)
	.asc	"$$$$$$$$"
; NEW coded version number
	.word	$1003			; 1.0a3		%vvvvrrrrsshhbbbb, where revision = %hhrrrr, ss = %00 (alpha), %01 (beta), %10 (RC), %11 (final)

; date & time in MS-DOS format at byte 248 ($F8)
	.word	$B200			; time, 22.16		1011 0-010 000-0 0000
	.word	$58A6			; date, 2024/5/6	0101 100-0 101-0 0110
; filesize in top 32 bits (@ $FC) now including header ** must be EVEN number of pages because of 512-byte sectors
	.word	$10000-rom_start			; filesize (rom_end is actually $10000)
	.word	0							; 64K space does not use upper 16 bits, [255]=NUL may be third magic number

; ******************
; *** test suite *** FAKE
; ******************
reset:
	SEI						; usual 6502 stuff
	CLD
	LDX #$FF
	TXS
; Durango-X specific stuff
	LDA #$38				; flag init and interrupt disable
	STA IO8mode				; set colour mode
	STA IOAen				; disable hardware interrupt (LED turns on)
; disable NMI for safety
	LDY #<exit
	LDA #>exit
	STY fw_nmi
	STA fw_nmi+1
; ** zeropage test **
; make high pitched chirp during test (not actually done, just run for timing reasons)
	LDX #<test				; 6510-savvy...
zp_1:
		TXA
		STA 0, X			; try storing address itself (2+4)
		CMP 0, X			; properly stored? (4+2)
		NOP					;	BNE zp_bad
		LDA #0				; A=0 during whole ZP test (2)
		STA 0, X			; clear byte (4)
		CMP 0, X			; must be clear right now! sets carry too (4+2)
		NOP					;	BNE zp_bad
		LDY #10				; number of shifts +1 (2, 26t up here)
zp_2:
			DEY				; avoid infinite loop (2+2)
			NOP				;	BEQ zp_bad
			ROL 0, X		; rotate (6)
			BNE zp_2		; only zero at the end (3...)
			NOP				;BCC zp_bad		; C must be set at the end (...or 5 last time) (total inner loop = 119t)
		CPY #1				; expected value after 9 shifts (2+2)
		NOP					;	BNE zp_bad
		INX					; next address (2+4)
		STX IOBeep			; make beep at 158t ~4.86 kHz, over 11 kHz in TURBO!
		BNE zp_1			; complete page (3, post 13t)
	BEQ zp_ok
zp_bad:						; don't care about errors
zp_ok:

; * no mirroring/address lines test, as it's quite fast and barely noticeable *
	LDA #$7F				; last RAM page
 	STA himem

; ** RAM test **
; silent but will show up on screen
	LDA #$F0				; initial value
	LDY #0
	STY test				; standard pointer address
rt_1:
		LDX #1				; skip zeropage
		BNE rt_2
rt_1s:
		LDX #$60			; skip to begin of screen
rt_2:
			STX test+1		; update pointer
			STA (test), Y	; store...
			CMP (test), Y	; ...and check
			NOP				;BNE ram_bad	; don't care
			INY
			BNE rt_2
				INX			; next page
				STX test+1
				CPX himem	; should check against actual RAMtop
			BCC rt_2		; ends at whatever detected RAMtop...
			BEQ rt_2
				CPX #$60	; already at screen
				BCC rt_1s	; ...or continue with screen
			CPX #$80		; end of screen?
			BNE rt_2
		LSR					; create new value, either $0F or 0
		LSR
		LSR
		LSR
		BNE rt_1			; test with new value
		BCS rt_1			; EEEEEEEEEEEEK
	BCC ram_ok				; if arrived here SECOND time, C is CLEAR and A=0
ram_bad:					; none of this
ram_ok:

; ** ROM test ** NOPE

; show banner if ROM checked OK (now using RLE)
	LDY #<banner
	LDX #>banner
	STY src
	STX src+1				; set origin pointer
	LDY #<screen3			; actually 0
	LDX #>screen3			; $60
	STY ptr
	STX ptr+1				; set destination pointer
	JSR rle_loop			; display picture

; ** why not add a video mode flags tester? **
	LDX #0
	STX posi				; will store unresponding bits
mt_loop:
		STX IO8mode			; try setting this mode...
		TXA
		EOR IO8mode			; ...and compare to what is read...
		ORA posi
		STA posi			; ...storing differences
		INX
		BNE mt_loop
	LDY #$38				; * restore usual video mode, extra LED off *
	STY IO8mode				; back to original mode
	LDX #7					; maximum bit offset
mt_disp:
		LSR posi			; extract rightmost bit into C
		LDA #1				; green for responding bits...
		ADC #0				; ...or red for non-responding
		CPX #4				; rightmost 4 are not essential
		BCC mt_ess
			ORA #8			; add blue to non-essential
mt_ess:
		STA $66E8, X		; display dots to the right
		BIT #2				; recheck non-responding... CMOS!!!
		BEQ mt_bitok
			STA $6768, X	; mark them down again for clarity
mt_bitok:
		DEX
		BPL mt_disp

; ** next is testing for HSYNC and VSYNC ** nope, just display OK result 
; print initial GREEN banner
	LDX #2					; max. offset
lf_l:
		LDA sync_b, X		; put banner data...
		STA $6680, X		; ...in appropriate screen place
		LDA sync_b+3, X
		STA $66C0, X
		LDA sync_b+6, X
		STA $6700, X
		LDA sync_b+9, X
		STA $6740, X
		DEX
		BPL lf_l			; note offset-avoiding BPL

; * NMI test * just for the sake of it
; wait a few seconds for NMI
	LDY #<isr				; ISR address
	LDX #>isr
	STY fw_nmi				; standard-ish NMI vector
	STX fw_nmi+1
; print minibanner
	LDX #5					; max. horizontal offset
	STX IOAen				; hardware interrupt enable (LED goes off), will be needed for IRQ test
nt_b:
		LDA nmi_b, X		; copy banner data into screen
		STA $6B00, X
		LDA nmi_b+6, X
		STA $6B40, X
		DEX
		BPL nt_b			; no offset!
; proceed with timeout
	LDX #0					; reset timeout counters (might use INX as well)
	STX test				; reset interrupt counter
	TXA						; or whatever is zero
nt_1:
		JSR delay			; (48)
		INY					; (2)
		BNE nt_2			; (usually 3)
			INX
			BEQ nt_3		; this does timeout after ~2.5s
nt_2:
		CMP test			; NMI happened?
		BEQ nt_1			; nope
			LDY #0			; otherwise do some click
			STY IOBeep		; buzzer = 1
			JSR delay		; 50 �s pulse
			INY
			STY IOBeep		; turn off buzzer
			LDA test		; get new target
		BNE nt_1			; no need for BRA
; disable NMI again for safer IRQ test
	LDY #<exit
	LDA #>exit				; maybe the same
	STY fw_nmi
	STA fw_nmi+1
; display dots indicating how many times was called (button bounce)
nt_3:
	LDX test				; using amount as index
	BEQ irq_test			; did not respond, don't bother printing dots EEEEEEEK
		LDA #$0F			; nice white value in all modes
nt_4:
			STA $6B45, X	; place 'dot', note offset as zero does not count
			DEX
			BNE nt_4

; ** IRQ test ** fake
irq_test:
; prepare screen with minibanner
	LDX #4					; max. horizontal offset
it_b:
		LDA irq_b, X		; copy banner data into screen
		STA $6F40, X
		LDA irq_b+5, X
		STA $6F80, X
		LDA irq_b+10, X
		STA $6FC0, X
		DEX
		BPL it_b			; no offset!
; inverse video during test (brief flash)
	LDA #$78				; colour, inverse, RGB
	STA IO8mode				; eeeeek
; interrupt setup * nope
	LDY #32					; EXPECTED value
	STY test
; assume HW interrupt is on
	LDX #154				; about 129 ms, time for 32 interrupts v1
; this provides timeout
it_1:
			INY
			BNE it_1
		DEX
		BNE it_1
; back to true video
	LDX #$38
	STX IO8mode
; display dots indicating how many times IRQ happened
	LDX test				; eeeek
	LDA #$01				; nice mid green value in all modes
	STA $6FDF				; place index dot @32 eeeeeek
	LDA #$0F				; nice white value in all modes
it_2:
		STA $703F, X		; place 'dot', note offsets
		DEX
		BNE it_2
; compare results * nope

; ***************************
; *** all OK, end of test ***
; ***************************

; sweep sound, print OK banner and lock
	STX test				; sweep counter
	TXA						; X known to be zero, again
sweep:
		LDX #8				; sound length in half-cycles
beep_l:
			TAY				; determines frequency (2)
			STX IOBeep		; send X's LSB to beeper (4)
rb_zi:
				STY test+1	; small delay for 1.536 MHz! (3)
				DEY			; count pulse length (y*2)
				BNE rb_zi	; stay this way for a while (y*3-1)
			DEX				; toggles even/odd number (2)
			BNE beep_l		; new half cycle (3)
		STX IOBeep			; turn off the beeper!
		LDA test			; period goes down, freq. goes up
		SEC
		SBC #4				; frequency change rate
		STA test
		CMP #16				; upper limit
		BCS sweep
; sound done, may check CPU type too (from David Empson work)
	LDY #$00				; by default, NMOS 6502 (0)
	SED						; decimal mode
	LDA #$99				; load highest BCD number
	CLC						; prepare to add
	ADC #$01				; will wrap around in Decimal mode
	CLD						; back to binary
		BMI cck_set			; NMOS, N flag not affected by decimal add
	LDY #$03				; assume now '816 (3)
	LDX #$00				; sets Z temporarily
	.byt	$BB				; TYX, 65816 instruction will clear Z, NOP on all 65C02s will not
		BNE cck_set			; branch only on 65802/816
	DEY						; try now with Rockwell (2)
	STY $EA					; store '2' there, irrelevant contents
	.byt	$17, $EA		; RMB1 $EA, Rockwell R65C02 instruction will reset stored value, otherwise NOPs
	CPY $EA					; location $EA unaffected on other 65C02s
		BNE cck_set			; branch only on Rockwell R65C02 (test CPY)
	DEY						; revert to generic 65C02 (1)
		BNE cck_set			; cannot be zero, thus no need for BRA
cck_set:
	TYA						; A = 0...3 (NMOS/CMOS/Rockwell/816)
; display minibanner with CPU type, 5x16 pixels each
	LDX #7					; max. offset
	ASL
	ASL
	ASL			; times 8
	STA test
	ASL
	ASL			; times 32
	ADC test	; plus 8x (C was clear), it's times 40
	ADC #7		; base offset (C should be clear too)
	TAY			; reading index
cpu_loop:
		LDA cpu_n, Y
		STA $7400, X
		LDA cpu_n+8, Y
		STA $7440, X
		LDA cpu_n+16, Y
		STA $7480, X
		LDA cpu_n+24, Y
		STA $74C0, X
		LDA cpu_n+32, Y
		STA $7500, X
		DEY
		DEX
		BPL cpu_loop

; all ended, print GREEN banner
	LDX #3					; max. offset
ok_l:
		LDA ok_b, X			; put banner data...
		STA $77DC, X		; ...in appropriate screen place
		LDA ok_b+4, X
		STA $781C, X
		LDA ok_b+8, X
		STA $785C, X
		DEX
		BPL ok_l			; note offset-avoiding BPL
	LDA #$3C				; turn on extra LED
	STA IO8mode

; ***************************
; *** now the fun begins! ***
; ***************************

; decompress the standby picture on screen2
	LDY #<standby
	LDX #>standby
	STY src
	STX src+1				; set origin pointer
	LDY #<screen2			; actually 0
	LDX #>screen2			; $40
	STY ptr
	STX ptr+1				; set destination pointer
	JSR rle_loop			; decompress picture off-screen
; decompress the SMPTE bars on screen1
	LDY #<smpte
	LDX #>smpte
	STY src
	STX src+1				; set origin pointer
	LDY #<screen1			; actually 0
	LDX #>screen1			; $20
	STY ptr
	STX ptr+1				; set destination pointer
	JSR rle_loop			; decompress picture off-screen

;TEST CODE
	JMP scroller

; ********************************************
; *** miscelaneous stuff, may be elsewhere ***
; ********************************************

; *** interrupt handlers *** could be elsewhere, ROM only
irq:
	JMP (fw_irq)
nmi:
	JMP (fw_nmi)

; *** interrupt routine (for NMI test) *** could be elsewhere
isr:
	NOP						; make sure it takes over 13-15 �sec
	INC test				; increment standard zeropage address (no longer DEC)
	NOP
	NOP
exit:
	RTI

; *** delay routine *** (may be elsewhere)
delay:
	JSR dl_1				; (12)
	JSR dl_1				; (12)
	JSR dl_1				; (12... +12 total overhead =48)
dl_1:
	RTS						; for timeout counters

; *** RLE decompressor ***
; entry point, set src & ptr pointers
rle_loop:
		LDY #0				; always needed as part of the loop
		LDA (src), Y		; get command
		INC src				; advance read pointer
		BNE rle_0
			INC src+1
rle_0:
		TAX					; command is just a counter
			BMI rle_u		; negative count means uncompressed string
; * compressed string decoding ahead *
		BEQ rle_exit		; 0 repetitions means end of 'file'
; multiply next byte according to count
		LDA (src), Y		; read immediate value to be repeated
rc_loop:
			STA (ptr), Y	; store one copy
			INY				; next copy, will never wrap as <= 127
			DEX				; one less to go
			BNE rc_loop
; burst generated, must advance to next command!
		LDA #1
		BNE rle_adv			; just advance source by 1 byte
; * uncompressed string decoding ahead *
rle_u:
			LDA (src), Y	; read immediate value to be sent, just once
			STA (ptr), Y	; store it just once
			INY				; next byte in chunk, will never wrap as <= 127
			INX				; one less to go
			BNE rle_u
		TYA					; how many were read?
rle_adv:
		CLC
		ADC src				; advance source pointer accordingly (will do the same with destination)
		STA src
		BCC rle_next		; check possible carry
			INC src+1
; * common code for destination advance, either from compressed or uncompressed
rle_next:
		TYA					; once again, these were the transferred/repeated bytes
		CLC
		ADC ptr				; advance desetination pointer accordingly
		STA ptr
		BCC rle_loop		; check possible carry
			INC ptr+1
		BNE rle_loop		; no need for BRA
rle_exit:
	RTS

; *** text scroller ***
scroller:
	STZ colidx				; reset colour index
rst_text:
	LDY #<msg
	LDX #>msg				; back to text start
	STY text
	STX text+1				; restore pointer
sc_char:
; get char from text
		LDA (text)				; get character to be displayed (CMOS only)
	BEQ rst_text				; restart text if NUL
; compute glyph address
		STZ src+1				; will be shifted before adding font base address
		ASL
		ROL src+1
		ASL
		ROL src+1
		ASL
		ROL src+1				; times 8 rows per glyph
		CLC
		ADC #<font				; font base LSB
		STA src					; LSB pointer is ready
		LDA src+1
		ADC #>font				; font base MSB
		STA src+1				; glyph pointer is ready!
; copy glyph into buffer
		LDY #7					; max offset
		STY count				; will count 7...0
sb_loop:
			LDA (src), Y		; get glyph data
			STA glyph, Y		; store into buffer
			DEY
			BPL sb_loop
; maybe change colour here (per char)
		INC colidx				; advance colour
getcol:
		LDX colidx				; current colour index
		LDA coltab, X			; sorted colours
		BNE not_black
			STZ colidx			; black restarts list
			BRA getcol
not_black:
		STA colour
; * base update *
; displace 4 pixels (2 bytes) to the left on selected lines (every page start)
sc_column:
; if colour should change every column, do it here
			LDY #<scrl
			LDX #>scrl
			STY ptr
			INY
			INY						; source is 4 pixels (2 bytes) to the right
			STY src					; LSBs are set
sc_pg:
				STX ptr+1
				STX src+1			; MSBs are set and updated
				LDY #0
sc_loop:
					LDA (src), Y
					STA (ptr), Y	; copy active byte
					INY
					INY				; every two pixels
					CPY #62			; no more to be scrolled?
					BNE sc_loop
				INX
				BPL sc_pg
; now print next column of pixels from glyph at the rightmost useable column
			LDY #0					; reset glyph buffer index
			LDX #>scrl				; back to top row
			LDA #62					; this is rightmost column
			STA ptr					; offset is ready
sg_pg:
				STX ptr+1			; update row page EEEEK
				LDA glyph, Y		; get current glyph raster
				ASL					; shift to the left
				STA glyph, Y		; update
				LDA #0				; black background...
				BCC sg_cset			; ...will stay if no pixel there
					LDA colour		; otherwise get current colour
sg_cset:
				STA (ptr)			; set big pixel (CMOS only)
				INX					; next page on screen
				INY					; next raster on glyph
				CPY #8				; until the end
				BNE sg_pg
; * end of base update *
; column is done, count until 8 are done, then reload next character and store glyph into buffer
; maybe changing colour somehow
wait:
				BIT IO8lf
				BVS wait
sync:
				BIT IO8lf		; wait for vertical blanking
				BVC sync
			DEC count			; one less column (7...0)
			BPL sc_column		; or go to next character, forever!
		INC text				; next char in message
	BNE no_wrap
		INC text+1
no_wrap:
	JMP sc_char

; ********************
; *** *** data *** ***
; ********************

; *** mini banners *** could be elsewhere
sync_b:
	.byt	$10, $00, $11					; mid green 'LF'
	.byt	$10, $00, $10
	.byt	$10, $00, $11
	.byt	$11, $00, $10
nmi_b:
	.byt	$DD, $0D, $0D, $D0, $DD, $0D	; cyan 'NMI'
	.byt	$D0, $DD, $0D, $0D, $0D, $0D
irq_b:
	.byt	$60, $66, $60, $66, $60			; brick colour 'IRQ'
	.byt	$60, $66, $00, $60, $60
	.byt	$60, $60, $60, $66, $06
ok_b:
	.byt	$55, $50, $50, $50				; green 'OK'
	.byt	$50, $50, $55, $00
	.byt	$55, $50, $50, $50

cpu_n:
	.byt	$22, $20, $22, $20, $22, $20, $22, $20	; red (as in "not supported") 6502
	.byt	$20, $00, $20, $00, $20, $20, $00, $20
	.byt	$22, $20, $22, $20, $20, $20, $22, $20
	.byt	$20, $20, $00, $20, $20, $20, $20, $00
	.byt	$22, $20, $22, $20, $22, $20, $22, $20

cpu_c:
	.byt	$FF, $F0, $FF, $0F, $F0, $FF, $F0, $FF	; white 65C02 @ +40
	.byt	$F0, $00, $F0, $0F, $00, $F0, $F0, $0F
	.byt	$FF, $F0, $FF, $0F, $00, $F0, $F0, $FF
	.byt	$F0, $F0, $0F, $0F, $00, $F0, $F0, $F0
	.byt	$FF, $F0, $FF, $0F, $F0, $FF, $F0, $FF

cpu_r:
	.byt	$FF, $00, $F0, $FF, $0F, $FF, $0F, $F0	; white R'C02 @ +80
	.byt	$FF, $F0, $F0, $F0, $0F, $0F, $00, $F0
	.byt	$FF, $00, $00, $F0, $0F, $0F, $0F, $F0
	.byt	$F0, $F0, $00, $F0, $0F, $0F, $0F, $00
	.byt	$F0, $F0, $00, $FF, $0F, $FF, $0F, $F0

cpu_16:
	.byt	$AA, $A0, $AA, $0A, $AA, $0A, $0A, $AA	; pink 65816 @ +120
	.byt	$A0, $00, $A0, $0A, $0A, $0A, $0A, $00
	.byt	$AA, $A0, $AA, $0A, $AA, $0A, $0A, $AA
	.byt	$A0, $A0, $0A, $0A, $0A, $0A, $0A, $0A
	.byt	$AA, $A0, $AA, $0A, $AA, $0A, $0A, $AA

; *** sorted colour table ***
coltab:
	.byt	$FF, $77, $33, $66, $CC, $99, $DD
	.byt	$55, $11, $CC, $99, $DD, $77, $33, $66
	.byt	$AA, $EE, $BB, 0

; *** displayed text ***
msg:
	.asc	"* * * Durango�X: the 8-bit computer for the 21st Century! * * *    "
	.asc	"65C02 @ 1.536-3.5 MHz... 32K RAM... 32K ROM in cartridge... "
	.asc	"128x128/16 colour, or 256x256 mono video... 1-bit audio! * * *    "
	.asc	"Designed in Almer�a by @zuiko21 at LaJaquer�a.org   "
	.asc	"Big thanks to @emiliollbb and @zerasul, plus all the folks at 6502.org    "
	.asc	"* * *    P.S.: Learn to code in assembly!    * * *    ", 0

; BIG DATA perhaps best if page-aligned?

; *** font data ***
	.dsb	$CC00-*, $FF
font:
	.bin	0, 0, "8x8.fnt"				; 2 KiB, not worth compressing (~1.8 K)

; *** picture data *** RLE compressed
;	.dsb	$D400-*, $FF				; already there!
banner:
	.bin	0, 0, "durango-x.rle"		; 534 bytes ($216, 3 pages)

	.dsb	$D700-*, $FF
standby:
	.bin	0, 0, "standby.rle"			; 2031 bytes ($7EF, 8 pages but must skip $DF)
stby_end:								; check whether before $DF80!

	.dsb	$E200-*, $FF
smpte:
	.bin	0, 0, "smpte.rle"			; 3344 bytes ($D10, 14 pages)

	.dsb	$F000-*, $FF
kidding:
	.bin	0, 0, "kidding.rle"			; 4052 bytes ($FD4, 16 pages including last!)
pic_end:

; ****************************************
; *** padding, ID and hardware vectors ***
; ****************************************

	.dsb	$FFD6-*, $FF	; padding

	.asc	"DmOS"			; Durango-X cartridge signature
	.word	$FFFF			; extra padding
	.word	$FFFF
	.word	0				; this will hold checksum at $FFDE-$FFDF

	.byt	$FF
	JMP ($FFFC)				; devCart support!

	.dsb $FFFA-*, $FF

	.word	nmi
	.word	reset
	.word	irq
