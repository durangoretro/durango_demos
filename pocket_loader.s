; minimal nanoBoot firmware *** now with devCart support on Durango-X
; v0.6b2
; (c) 2018-2023 Carlos J. Santisteban
; last modified 20230306-1918

; already NMOS-savvy EXCEPT the SD module

; *********************
; *** configuration ***
; *********************
; extra header checking
#define	SAFE	_SAFE

; timeout routines, will abort in ~0.9s @ 1 MHz
;#define	TIMEBOOT	_TIMEBOOT

; alternate version using /SO pin
;#define	SETOVER	_SETOVER

; progress display
#define	DISPLAY	_DISPLAY
; use LTC4622, otherwise Durango-X built-in display
;#define	LTC4622

; *************************************
; *** includes and system variables ***
; *************************************
;#include "../../OS/macros.h"
;#include "nanoboot.h"

; VARIABLES
;-------------------------------------
timeout	= 2					; timeout counter (6510-savvy)
nb_cur	= timeout+2			; selected anode on LTC4622 display (or digit)
nb_disp	= nb_cur+1			; bitmap patterns (including selected anode)
nb_rcv	= nb_disp+4			; received value
nb_flag	= nb_rcv+1			; a byte is ready when zero (must be preset every byte)
nb_ptr	= nb_flag+1			; initial address, will be used as pointer (will reuse for screen drawing)
nb_fin	= nb_ptr+2			; final address (consecutive) after downloaded chunk
nb_ex	= nb_fin+2			; copy of initial address
;-------------------------------------

; mimimal firmware variables!
; these should NOT go into zeropage, even if saving a few bytes
fw_isr	= $0200
fw_nmi	= $0202

; *************************
; *** boot ROM contents ***
; *************************
#ifndef	DISPLAY
* = $FF80					; 128 bytes will suffice, even with timeout!
#else
;* = $FF00					; display routines need much more space, but one page seems enough
* = $C000					; 16K ROM ready!
#endif

reset:
; standard 6502 init... NOT NEEDED
; * no adds or subtractions, thus decimal mode irrelevant
; * stack can be anywhere into page 1
;	CLD
;	LDX #$FF
;	TXS
#ifdef	DISPLAY
#ifndef	LTC4622
	SEI						; just in case of NMOS
; clear screen (Durango-X display only)
	LDA #$38				; lowres, RGB, usual screen 3
	STA $DF80				; set video mode
	LDY #0
	LDX #$60				; screen 3 start
	STX nb_ptr+1
	STY nb_ptr				; set ZP pointer
	TYA
dx_clr:
		STA (nb_ptr), Y		; clear screen byte (black)
		INY
		BNE dx_clr
	INC nb_ptr+1
	BPL dx_clr				; all pages
; Durango-X will set a blue strip at the bottom (ROM space)
dx_blue:
		LDA #$CC			; azur
		STA $7F80, Y		; last 128 bytes of screen (Y was known to be 0)
		LDA #0
		STA $DF00, Y		; clear unused IO space (as per Emilio's request)
		INY
		BPL dx_blue
#endif
#endif

; ...followed by code chunks
;#include "init.s"
;------ NANOBOOT ------------------------------------------------------;
; startup nanoBoot for 6502, v0.6b2
; (c) 2018-2023 Carlos J. Santisteban
; last modified 20230308-1823

; *** needed zeropage variables ***
; nb_rcv, received byte (no longer need to be reset!)
; nb_flag, counter of shifted bits, goes zero when a byte is received
; nb_ptr (word) for initial address, will use as pointer
; nb_fin (word) is final address, MUST be right after nb_ptr
; nb_ex (word) keeps initial address, should be consecutive
; *** will temporarily use 3 more bytes, the last one for checking valid header ***

; note new NBEXTRA for enhanced feedback, may impair performance
;#define	NBEXTRA	_NBEXTRA

nb_init:
	SEI						; make sure interrupts are off (2)

; ******************************
; *** set interrupt handlers ***
; ******************************
#ifndef	SETOVER
; regular NMI/IRQ version full install
	LDX #3					; copy 4 bytes (2)
nb_svec:
		LDA nb_tab, X		; get origin from table (4)
		STA fw_isr, X		; and write for FW (5)
#ifdef	DISPLAY
#ifdef	LTC4622
		LDA nb_boot, X		; while we are on it, prepare display message (4+4)
		STA nb_disp, X
#endif
#endif
		DEX					; next (2)
		BPL nb_svec			; no need to preset X (3)
#else
; *** alternate code in case /SO is used, no ISR is set ***
	CLV						; reset this ASAP!
	LDY #<nb_nmi			; copy routine address...
	LDA #>nb_nmi
	STY fw_nmi				; ...and store it into firmware
	STA fw_nmi+1
#endif
; *** wait for a valid nanoBoot link *** $4B, end.H, end.L, start.H, start.L
; 'end' is actually first free address after code
; note big-endian for simpler memory filling!
; the magic byte ($4B) could be ignored as well
; *** get nanoBoot header ***
	LDY #4					; will receive five bytes 0...4 (2)
nb_lnk:
; ************************************************************
; *** receive byte on A, perhaps with feedback and timeout *** affects X
; ************************************************************

; *** standard overhead per byte is 16t, or 24t with timeout ***
		LDX #8				; number of bits per byte (2)
		STX nb_flag			; preset bit counter (3)
#ifdef	TIMEBOOT
		LDX #0				; or use STZs (2)
		STX timeout			; preset timeout counter for ~0.92 s @ 1 MHz, more if display is used (3+3)
		STX timeout+1
nb_lbit:
; *** optional timeout adds typically 8 or 15 (0.4% of times) cycles to loop ***
			DEC timeout			; one less to go (5)
			BNE nb_cont			; if still within time, continue waiting after 8 extra cycles (3/2)
				DEC timeout+1	; update MSB too otherwise (5)
			BNE nb_cont			; not yet expired, continue after 15 extra cycles (3/2)
				PLA				; discard return address otherwise... (4+4)
				PLA
				JMP nb_exit		; ...and proceed with standard boot!
nb_cont:
#else
nb_lbit:
; *** base loop w/o feedback is 6 cycles, plus interrupts => 64t/bit => 512t/byte ***
; make that 84t/bit and 672t/byte if LTC display is enabled 
#endif
#ifdef	DISPLAY
#ifdef	LTC4622
			JSR ltc_up			; mux display, total 32t per bit
#endif
#endif
			LDX nb_flag			; received something? (3)
			BNE nb_lbit			; no, keep trying (3/2)
#ifdef	DISPLAY
#ifdef	LTC4622
#ifdef		NBEXTRA
	LDA #%11101000			; dot on second digit (will show .. during header, adds a lot of overhead but transmission is slow anyway)
	STA nb_disp+2
	LDA #%11100010			; dot on first digit
	STA nb_disp
	STX nb_disp+1			; clear remaining segments (known to be zero)
	STX nb_disp+3
#endif
#endif
#endif
		LDA nb_rcv			; get received (3)
; note regular NMI get inverted bytes, while SO version does not
#ifndef	SETOVER
;		EOR #$FF			; NOPE***must invert byte, as now works the opposite (2)
#endif
; **************************
; *** byte received in A ***
; **************************
		STA nb_ptr, Y		; store in variable (4)
		STA nb_ex, Y		; simpler way, nb_ex should be after both pointers (4)
		DEY					; next (2)
		BPL nb_lnk			; until done (3/2)
; *** may check here for a valid header ***
#ifdef	SAFE
	LDX nb_ex+4				; this holds the magic byte (3)
	CPX #$4B				; valid nanoBoot link? (2)
		BNE nb_err			; no, abort (2/3)
; could check for valid addresses as well
;	LDX nb_ptr+1
;	CPX nb_fin+1			; does it end before it starts?
;		BCC nb_ok			; no, proceed
;		BNE nb_err			; yes, abort
;	CMP nb_fin				; if equal MSB, check LSB (A known to have nb_ptr)
;		BCS nb_err			; nb_ptr cannot be higher neither equal than nb_fin
nb_ok:
; might also check for boundaries (system dependant)
#endif
; prepare variables for transfer
	LDX #0					; will be used later, remove if STZ is available
	STX nb_ptr				; ready for indirect-indexed (X known to be zero, or use STZ)
	TAY						; last byte loaded is the index! (2)
#ifdef	DISPLAY
; create acknowledge message while loading first page (12t + routine length)
#ifdef	LTC4622
	JSR show_pg
#else
; Durango-X may place a green dot on the last page position!
	LDX nb_fin+1			; finish page
	BEQ nb_rec				; show nothing for ROM images
		LDA #$55			; bright green eeeeek
		STA $7EFF, X		; indicate actual last page
#endif
#endif
; **************************************
; *** header is OK, execute transfer ***
; **************************************
nb_rec:
; **********************************************************
; *** receive byte on A, without any feedback or timeout *** simpler and faster
; **********************************************************
	LDX #8					; number of bits per byte (2)
	STX nb_flag				; preset bit counter (3)
; not really using timeout, as a valid server was detected
nb_gbit:
; feedback, if any, is updated after each received byte
		LDX nb_flag			; received something? (3)
		BNE nb_gbit			; no, keep trying (3/2)
	LDA nb_rcv				; get received (3)
#ifndef	SETOVER
;	EOR #$FF				; NOPE***must invert byte, as now works the opposite (2) NO LONGER, but check SO option
#endif
; **************************
; *** byte received in A ***
; **************************
		STA (nb_ptr), Y		; store at destination (5 or 6)
#ifdef	DISPLAY
#ifdef	LTC4622
		JSR ltc_up			; now adds 32t per BYTE, likely irrelevant
#endif
#endif
		INY					; next (2)
		BNE nbg_nw			; check MSB too (3/7)
			INC nb_ptr+1
; *** page has changed, may be reflected on display ***
		LDX nb_ptr+1		; check current page
		CPX #$DF			; is it IO page?
		BNE no_io
			INC nb_ptr+1	; skip it EEEEEEK
no_io:
#ifdef	DISPLAY
		JSR show_pg			; adds 12t + routine length every 256 bytes
#endif
nbg_nw:
		CPY nb_fin			; check whether ended (3)
		BNE nb_rec			; no, continue (3/11/10)
			LDA nb_ptr+1	; check MSB too
			CMP nb_fin+1
		BNE nb_rec			; no, continue
; ********************************************
; *** transfer ended, execute loaded code! ***
; ********************************************
#ifdef	DISPLAY
#ifdef	LTC4622
	LDA #$FF				; in case a TTL latch is used!
	STA $FFF0				; nice to turn off display!
#else
	LDX #0
	TXA
bot_clr:
		STA $7F00, X		; clear screen bottom
		INX
		BNE bot_clr
#endif
#endif
#ifdef	SAFE
; should I reset NMI/IRQ vectors?
#endif
;	JMP (nb_ex)				; go!
	JMP switch				; disable ROM and run from devCart RAM!

; **********************************************************************
; *** in case nonvalid header is detected, reset or continue booting ***
; **********************************************************************
nb_err:
#ifdef	DISPLAY
#ifdef	LTC4622
	LDA #%11100101			; dash on BOTH digits means ERROR
	BNE ltc_ab				; if no display, same as error
#endif
#endif
nb_exit:
#ifdef	DISPLAY
#ifdef	LTC4622
	LDA #$FF				; will clear display in case of timeout
							; might show '..' instead (%11101010)
ltc_ab:
	STA $FFF0				; put it on port
#endif
#endif
	JMP abort				; get out of here, just in case

; *************************************
; *** table with interrupt pointers *** and diverse data
; *************************************
#ifndef	SETOVER
nb_tab:
	.word	nb_irq
	.word	nb_nmi
#endif
#ifdef	DISPLAY
#ifdef	LTC4622
nb_boot:
	.byt	%11010010, %10100001, %11011000, %00000100	; patterns to show 'nb' on LTC display (integrated anodes)
nb_pat:						; segment patterns for hex numbers
	.byt	%00010001		; 0
	.byt	%10011111		; 1
	.byt	%00110010		; 2
	.byt	%00010110		; 3
	.byt	%10011100		; 4
	.byt	%01010100		; 5
	.byt	%01010000		; 6
	.byt	%00011111		; 7
	.byt	%00010000		; 8
	.byt	%00011100		; 9
	.byt	%00011000		; A
	.byt	%11010000		; B
	.byt	%01110001		; C
	.byt	%10010010		; D
	.byt	%01110000		; E
	.byt	%01111000		; F
; *******************************************************
; ** LTC display update routine, 20t plus 12t overhead **
ltc_up:
	LDX nb_cur			; current position (3)
	LDA nb_disp, X		; get pattern (4)
	STA $FFF0			; put on display (4)
	INX					; next anode (2+2)
	TXA
	AND #3				; four anodes on a single LTC4622 display (2)
	STA nb_cur			; update for next round (3)
	RTS
; ****************************************
; ** LTC page display, no longer inline **
show_pg:
#ifdef	NBEXTRA
; show page MSN, takes 41t  more each 256 bytes
	LDA nb_ptr+1	; get new page number (3)
	LSR				; MSN only (4x2)
	LSR
	LSR
	LSR
	TAX				; as index (2)
	LDA nb_pat, X	; low pattern first (4)
	AND #240		; MSN as cathodes (2)
	ORA #%0010		; enable first anode of first digit (2+3)
	STA nb_disp
	LDA nb_pat, X	; load again full pattern (4)
	ASL				; keep LSN only (2+2+2+2)
	ASL
	ASL
	ASL
	ORA #%0001		; enable second anode of first digit (2+3)
	STA nb_disp+1
#endif
; show page LSN, takes 35t each 256 bytes
	LDA nb_ptr+1	; get new page number (3)
	AND #15			; LSN only (2)
	TAX				; as index (2)
	LDA nb_pat, X	; low pattern first (4)
	AND #240		; MSN as cathodes (2)
	ORA #%1000		; enable first anode of second digit (2+3)
	STA nb_disp+2
	LDA nb_pat, X	; load again full pattern (4)
	ASL				; keep LSN only (2+2+2+2)
	ASL
	ASL
	ASL
	ORA #%0100		; enable second anode of second digit (2+3)
	STA nb_disp+3
	RTS
#else
; page display on Durango-X
show_pg:
	LDX nb_ptr+1			; current page (after switching)
	LDA #$FF				; elongated white dot
	STA $7EFF, X			; display on screen (finished page)
	RTS
#endif
#endif
#ifdef	DISPLAY
#ifndef	LTC4622
; *** picture data ***
	.dsb	$e000-*, $FF	; ROM padding skipping I/O!

rpi_end:
#endif
#endif
; *** all finished, continue execution if unsuccessful ***
abort:

;------------ END NANOBOOT --------------------------------------------;

; as this simple bootloader has nothing else to do, just lock (show red strip)
#ifdef	DISPLAY
#ifndef	LTC4622
	LDA #$22				; red as error
	LDY #0
dx_red:
		STA $7F00, Y		; last page of screen
		INY
		BNE dx_red
#endif
#endif
	LDA #>autoreset
	LDY #<autoreset
	STY fw_nmi
	STA fw_nmi+1			; NMI will trigger a soft reset
	BEQ *					; just lockout in the meanwhile


; *** nanoBoot interrupt service routines ***
#ifndef	SETOVER
; regular version
;------ NMI ROUTINE ----------
nb_nmi:
; received bits should be LSB first!
	CLC					; bits are *OFF* by default, will be inverted later (2)
	PHA					; preserve A, as ISR will change it! (3)
	CLI					; enable interrupts for a moment (2...)
; if /IRQ was low, ISR will *set* C, thus injecting a one
	SEI					; what happened? (2)
	PLA					; retrieve A, but C won't be affected (4)
	ROR nb_rcv			; inject C into byte, LSB first (5)
	DEC nb_flag			; this will turn 0 when done, if preloaded with 8 (5)
nb_rti:
	RTI					; (6) total 29, plus ISR
; ISR takes 7 clocks to acknowledge, plus 15 clocks itself, that's 22t for a grand total (including NMI ack) of 58 clocks per bit worst case
;------------- END NMI -------

;--------------- ISR ---------
nb_irq:
; *** this modifies A (and stored P), thus PHA is needed on NMI for proper operation ***
; since this has to set I flag anyway, clear stored C as received bit value
	PLA				; saved status... (4)
	ORA #%00000101	; ...now with I set *AND* C set (2)
	PHA				; restore all (A changed) (3)
	RTI				; (6) whole routine takes only 15 clocks
;------------- END ISR -------

#else
; /SO version
;#include "so_nmi.s"
#endif

; *** vectored interrupt handlers ***
nmi:
	JMP (fw_nmi)
irq:
	JMP (fw_isr)

_code_end:

; *** filling for ROM-ready files *** now with devCart support
	.dsb	$FFD6-*, $FF
	.asc	"DmOS"

	.dsb	$FFDC-*, $FF

switch:
	LDA #%01100100			; ROM disabled, protected RAM, and CD disabled just in case
do_sw:
	STA $DF93
; * = $FFE1
autoreset:
	JMP $2100				; RESET on loaded image *** mandatory instruction on any ROM image ***
 
	.dsb	$FFFA-*, $FF

; *****************************
; *** standard 6502 vectors ***
; *****************************
* = $FFFA
	.word	nmi
	.word	reset
	.word	irq
