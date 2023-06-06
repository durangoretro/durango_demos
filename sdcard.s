*=$c000

;------ DXHEAD------------------------------------------------------

; 8 bytes
.byt $00
.byt "dX"
.byt "****"
.byt $0d

; 222 bytes
; TITLE_COMMENT[
.byt $00, $00
.byt "################################################"
.byt "##################################################"
.byt "##################################################"
.byt "##################################################"
.byt "######################";]


; 18 bytes
;DCLIB_COMMIT[
.byt "LLLLLLLL"
;]
;MAIN_COMMIT[
.byt "MMMMMMMM"
;]
;VERSION[
.byt "VV"
;]

; 8 bytes
;TIME[
.byt "TT"
;]
;DATE[
.byt "DD"
;]
;FILEZISE[
.byt $00,$40,$00,$00
;]
;---------------------------------------------------------------

begin:

; Initialize 6502    
SEI ; Disable interrupts
CLD ; Clear decimal mode
LDX #$FF ; Initialize stack pointer to $01FF
TXS

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


; DCLIB CONSTANTS ----------------------------
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


; ****************************************************************
; We are ready for actual work -----------------------------------


; ---- MAIN ----
JSR sd_idle
BNE nosd
LDA #$11
STA $6000
STA $6001
STA $6002
STA $6003

JSR sd_setup_interface
BNE nosd
LDA #$11
STA $6006
STA $6007
STA $6008
STA $6009

LDA #$60
STA RESOURCE_POINTER+1
STZ RESOURCE_POINTER
JSR sd_ssec_rd
BNE nosd
LDA #$11
STA $600C
STA $600D
STA $600E
STA $600F

wait: BRA wait


nosd:
STA $7000
LDA #$22
paint:

STA $6030
STA $6031
STA $6032
STA $6033


end: bra end
;---------------





mosi=TEMP1
arg=TEMP2; - TEMP5
miso=TEMP6
crc=TEMP7
tmpba=TEMP8
res=X_COORD
sd_ver=Y_COORD
token=X2_COORD



; ***********************************
; *** hardware-specific SD driver by Carlos Santiesteban (MODIFIED to be used with c65) ***
; ***********************************
; SD interface definitions
#define	SD_CLK		%00000001
#define	SD_MOSI		%00000010
#define	SD_CS		%00000100
#define	SD_MISO		%10000000
#define	IOCart		$DFC0
#define	CMD0		0
#define	CMD0_CRC	$94
#define	CMD8		8
#define	CMD8_ARG	$01AA
#define	CMD8_CRC	$86
#define	SDIF_ERR	1
#define	ECHO_ERR	2
#define	CMD55		55
#define	ACMD41		41
#define	ACMD41_ARG	$40
#define	INIT_ERR	3
#define	CMD58		58
#define	READY_ERR	4
#define	CMD16		16
#define	CMD16_ARG	$0200
#define	CMD17		17
#define	SD_MAX_READ_ATTEMPTS	203

; *** send data in A, return received data in A *** nominally ~4.4 kiB/s
sd_spi_tr:
	STA mosi
	LDY #8					; x = 8;
	LDA #SD_CLK
	TRB IOCart				; digitalWrite(SCK, 0); (13t)
    tr_l:						; while (x)
		ASL mosi
		LDA IOCart
		AND #SD_MOSI^$FF
		BCC mosi_set
			ORA #SD_MOSI
    mosi_set:
		STA IOCart			; digitalWrite(MOSI, data & 128); data <<= 1;
		INC IOCart			; digitalWrite(SCK, 1);	** assume SD_CLK  is   1 **
		ASL					; in <<= 1;				** assume SD_MISO is $80 **
		ROL miso			; if(digitalRead(MISO)) in++;
		DEC IOCart			; digitalWrite(SCK, 0);	** assume SD_CLK  is   1 **
		DEY					; x--;
		BNE tr_l			; (worst case, 8*43 = 344t)
	LDA miso				; return in; (total including call overhead = 372t, ~242 µs)
	RTS


; *** enable card transfer ***
sd_cs_enable:
	LDA #$FF
	JSR sd_spi_tr				; sd_spi_transfer(0xFF);
	LDA #SD_CS
	TRB IOCart				; sd_cs_enable();
	LDA #$FF
	JMP sd_spi_tr				; sd_spi_transfer(0xFF); ...and return

; *** disable card transfer ***
sd_cs_disable:
	LDA #$FF
	JSR sd_spi_tr				; sd_spi_transfer(0xFF);
	LDA #SD_CS
	TSB IOCart				; sd_cs_disable();
	LDA #$FF
	JMP sd_spi_tr				; sd_spi_transfer(0xFF); ...and return

; ***************************
; *** standard SD library ***
; ***************************

; *** send command in A to card *** arg.l, crc.b
sd_cmd:
    ; send command header
	ORA #$40
	JSR sd_spi_tr				; sd_spi_transfer(cmd|0x40);
    ; send argument
	LDA arg
	JSR sd_spi_tr				; sd_spi_transfer((u_int8_t)(arg >> 24));
	LDA arg+1
	JSR sd_spi_tr				; sd_spi_transfer((u_int8_t)(arg >> 16));
	LDA arg+2
	JSR sd_spi_tr				; sd_spi_transfer((u_int8_t)(arg >> 8));
	LDA arg+3
	JSR sd_spi_tr				; sd_spi_transfer((u_int8_t)(arg));
    ; send CRC
	LDA crc
	ORA #1
	JMP sd_spi_tr				; sd_spi_transfer(crc|0x01); ...and return

; *** *** special version of the above, in case SDSC is byte-addressed, CMD17 and CMD24 only *** ***
sd_ba_cmd:
    ; send command header
	ORA #$40
	JSR sd_spi_tr				; sd_spi_transfer(cmd|0x40);
    ; precompute byte-addressed sector
	LDA arg+3
	ASL
	STA tmpba+1
	LDA arg+2
	ROL
	STA tmpba
	LDA arg+1
	ROL						; A holds MSB
    ; send argument
	JSR sd_spi_tr
	LDA tmpba
	JSR sd_spi_tr
	LDA tmpba+1
	JSR sd_spi_tr
	LDA #0					; always zero as 512 bytes/sector
	JSR sd_spi_tr
    ; send CRC
	LDA crc
	ORA #1
	JMP sd_spi_tr				; sd_spi_transfer(crc|0x01); ...and return


; *** read R1 response *** return result in res and A
sd_rd_r1:
	PHX						; eeeeeeeek
	LDX #8					; u_int8_t i = 0, res1;
    ; keep polling until actual data received
    r1_l:
		LDA #$FF
		JSR sd_spi_tr
		CMP #$FF
	BNE r1_got				; while((res1 = sd_spi_transfer(0xFF)) == 0xFF)
		DEX					; i++;
		BNE r1_l			; if(i > 8) break;
    r1_got:
	STA res					; return res1; (also in A)
	PLX
	RTS


; *** read R7 response *** return result in res[]
sd_rd_r7:
	JSR sd_rd_r1				; res[0] = SD_readRes1();
	CMP #2
	BCS r7end				; if(res[0] > 1) return; {in case of error}
    ; read remaining bytes
		LDX #1
    r7loop:
			LDA #$FF
			JSR sd_spi_tr
			STA res, X		; res[ X ] = sd_spi_transfer(0xFF);
			INX
			CPX #5
			BNE r7loop
    r7end:
	RTS


sd_idle:
    ; ** SD_powerUpSeq is inlined here **
	JSR sd_cs_disable			; for compatibility
	LDX #220				; 1 ms delay
    sdpu_dl:
		NOP
		DEX
		BNE sdpu_dl
    ; continue with powerup sequence
	LDX #9					; one less as sd_cs_disable sends another byte
    sd80c:
		LDA #$FF
		JSR sd_spi_tr
		DEX
		BNE sd80c			; this sends 80 clocks to synchronise
	JSR sd_cs_disable
    ; command card to idle
	LDX #10
    set_idle:
    ; ** SD_goIdleState is inlined here **
		JSR sd_cs_enable		; assert chip select
    ; send CMD0
		STZ arg
		STZ arg+1
		STZ arg+2
		STZ arg+3			; ** assume CMD0_ARG is 0 *
		LDA #CMD0_CRC
		STA crc
		LDA #CMD0
		JSR sd_cmd			; SD_command(CMD0, CMD0_ARG, CMD0_CRC);
    ; read response
		JSR sd_rd_r1
		JSR sd_cs_disable

    ; continue set_idle loop
		LDA res
		CMP #1
	BEQ is_idle				; already idle...
		DEX					; ...or continue until timeout
		BNE set_idle
	LDA #1			; *** ERROR 1 ***
	RTS				; failed to set idle
    is_idle:
    LDA #0
    RTS


sd_setup_interface:
    JSR sd_cs_enable			; assert chip select
    ; send CMD8
	STZ arg
	STZ arg+1				; CMD8_ARG upper 16 bits are zero
	LDA #>CMD8_ARG
	STA arg+2
	LDA #<CMD8_ARG
	STA arg+3
	LDA #CMD8_CRC
	STA crc
	LDA #CMD8
	JSR sd_cmd				; SD_command(CMD8, CMD8_ARG, CMD8_CRC);
    ; read response
	JSR sd_rd_r7
	JSR sd_cs_disable			; deassert chip select

	STZ sd_ver				; ### default (0) is modern SD card ###
	LDA res
	LDX #SDIF_ERR			; moved here
	CMP #1					; check valid response
	BEQ sdic_ok
    ; ### if error, might be 1.x card, notify and skip to CMD58 or ACMD41 ###
    ;		LDX #OLD_SD			; ### message for older cards ###
		STX sd_ver			; ### store as flag ### (non-zero)
    ;		JSR disp_code
    ;		LDY #13
    ;		JSR conio
		BRA not_cmd8
    sdptec:
		; Fail, return value in X
        TXA
        RTS
    sdic_ok:
    ;	JSR pass_x				; *** PASS 1 in white ***
    ; check pattern echo
	LDX #ECHO_ERR			; *** ERROR 2 in red ***
	LDA res+4
	CMP #$AA
		BNE sdptec			; SD_ERROR;
    ;	JSR pass_x				; *** PASS 2 in white ***
    ; ### jump here for 1.x cards ###
    not_cmd8:
    ; attempt to initialize card *** could add CMD58 for voltage check
	LDX #101				; cmdAttempts = 0;
    sd_ia:
    ; send app cmd
    ; ** res[0] = SD_sendApp() inlined here **
		JSR sd_cs_enable		; assert chip select
    ; send CMD55
		STZ arg
		STZ arg+1
		STZ arg+2
		STZ arg+3
		STZ crc				; ** assume CMD55_ARG and CMD55_CRC are 0 **
		LDA #CMD55
		JSR sd_cmd			; SD_command(CMD55, CMD55_ARG, CMD55_CRC);
    ; read response
		JSR sd_rd_r1
		JSR sd_cs_disable		; deassert chip select
		LDA res				; return res1;

    ; if no error in response
		CMP #2
		BCS sa_err
    ; ** res[0] = SD_sendOpCond() inlined here **
			JSR sd_cs_enable	; assert chip select
    ; send CMD55
			LDA #ACMD41_ARG	; only MSB is not zero
			STA arg
			STZ arg+1
			STZ arg+2
			STZ arg+3
			STZ crc			; ** assume rest of ACMD41_ARG and ACMD41_CRC are 0 **
			LDA #ACMD41
			JSR sd_cmd		; SD_command(ACMD41, ACMD41_ARG, ACMD41_CRC);
    ; read response
			JSR sd_rd_r1
			JSR sd_cs_disable	; deassert chip select
    sa_err:
		LDA res				; return res1; (needed here in case of error)
	BEQ apc_rdy				; while(res[0] != SD_READY);
    ; wait 10 ms
		LDA #12
    d10m:
				INY
				BNE d10m
			DEC
			BNE d10m		; 10 ms delay;
		DEX					; up to 100 times
		BNE sd_ia
	LDX #INIT_ERR			; *** ERROR 3 in red ***
	TXA
    RTS
    apc_rdy:
    ;	LDX #INIT_ERR
    ;	JSR pass_x				; *** PASS 3 in white ***
    ; ### old SD cards are always SC ###
	LDA sd_ver
		BNE sd_sc
    ; read OCR
    ; ** SD_readOCR(res) is inlined here **
	JSR sd_cs_enable			; assert chip select
    ; send CMD58
	STZ arg
	STZ arg+1
	STZ arg+2
	STZ arg+3
	STZ crc					; ** assume CMD58_ARG and CMD58_CRC are 0 **
	LDA #CMD58
	JSR sd_cmd				; SD_command(CMD58, CMD58_ARG, CMD58_CRC);
    ; read response
	JSR sd_rd_r7
	JSR sd_cs_disable			; deassert chip select

    ; check whether card is ready
	LDX #READY_ERR			; *** ERROR 4 in red ***
	BIT res+1				; eeeeeeeeek ### will check CCS as well ###
	BMI card_rdy			; eeeeeeeeek
	TXA         			; if(!(res[1] & 0x80)) return SD_ERROR;
    RTS
    card_rdy:					; * SD_init OK! *
    ; ### but check whether standard or HC/XC, as the former needs asserting 512-byte block size ###
    ; ### if V is set then notify and skip CMD16 ###
	BVS hcxc
    ; ### set 512-byte block size ###
    sd_sc:
		SEC
		ROR sd_ver			; *** attempt of marking D7 for SDSC cards, byte-addressed!
		JSR sd_cs_enable		; assert chip select ### eeeeeeeeek
		STZ arg
		STZ arg+1			; assume CMD16_ARG upper 16 bits are zero
		LDA #>CMD16_ARG		; actually 2 for 512 bytes per sector
		STA arg+2
		STZ arg+3			; assume CMD16_ARG LSB is zero (512 mod 256)
		LDA #$FF
		STA crc				; assume CMD16_CRC is zero... or not? ***
		LDA #CMD16
		JSR sd_cmd
    ; should I check errors?
		JSR sd_rd_r1
		JSR sd_cs_disable		; deassert chip select ###
    ;		LDA res				; *** wait for zero response
    ;	BNE sd_sc				; *** maybe a timeout would be desired too

    ;		LDX #READY_ERR		; ### display standard capacity message and finish ###
    ;		BRA card_ok
    hcxc:
    ;	LDX #HC_XC				; ### notify this instead ###
    card_ok:
    ;	JMP pass_x				; *** PASS 4 in white ***
    ; *** card properly inited***
    LDA #0
	RTS





; **************************
; *** read single sector ***
sd_ssec_rd:
    ; should look for 'durango.av' file but, this far, from the very first sector of card instead
	STZ arg
	STZ arg+1
	STZ arg+2
	STZ arg+3				; assume reading from the very first sector
    ; * intended to read at $0300 *
	STZ RESOURCE_POINTER
    ; * standard sector read, assume arg set with sector number *
    ; set token to none
	LDA #$FF
	STA token
	JSR sd_cs_enable			; assert chip select
    ; send CMD17 (sector already at arg.l)
	STZ crc					; ** assume CMD17_CRC is 0 **
	LDA #CMD17
	BIT sd_ver				; *** check whether SC or HC/XC
	BPL is_hcxc
		JSR sd_ba_cmd			; SD_command(CMD17, sector, CMD17_CRC); *** a special version for SDSC cards is needed
		BRA cmd_ok
    is_hcxc:
	JSR sd_cmd				; SD_command(CMD17, sector, CMD17_CRC); *** regular block-addressed version
    cmd_ok:
    ; read response
	JSR sd_rd_r1
	CMP #$FF
	BEQ no_res
    
    ; if response received from card wait for a response token (timeout = 100ms)
		LDX #SD_MAX_READ_ATTEMPTS
    rd_wtok:
			DEX
		BEQ chk_tok			; this is done twice for a single-byte timeout loop
			LDA #$FF
			JSR sd_spi_tr
			CMP #$FF
		BNE chk_tok
			LDA #$FF
			JSR sd_spi_tr
			CMP #$FF
			BEQ rd_wtok		; if((read = SPI_transfer(0xFF)) != 0xFF)		break; (759t ~494µs)
    chk_tok:
		STA res
		CMP #$FE
		BNE set_tk
        ;-----
    PHA
    LDA #$33
    STA $6012
    STA $6013
    STA $6014
    STA $6015
    PLA
    ;-----
        
        
    
    ; read 512 byte block
    block:
			LDX #0			; 256-times loop reading 2-byte words => 512 bytes/sector
    byte_rd:
				LDA #$FF
				JSR sd_spi_tr
				STA (RESOURCE_POINTER)	; get one byte
				INC RESOURCE_POINTER		; won't do any page crossing here, as long as the base address is EVEN
				LDA #$FF
				JSR sd_spi_tr
				STA (RESOURCE_POINTER)	; get a second byte
				INC RESOURCE_POINTER
				BNE brd_nw
					INC RESOURCE_POINTER+1
    ; cannot reach I/O page as this loads to RAM only
    brd_nw:
				INX
				BNE byte_rd
    ; discard 16-bit CRC
    rd_crc:
			LDA #$FF
			JSR sd_spi_tr
			LDA #$FF
			JSR sd_spi_tr
			LDA res
    set_tk:
    ; set token to card response
		STA token
    no_res:
	JSR sd_cs_disable			; deassert chip select
    LDA token
	RTS




; ****************************************************************
; End of actual work -------------------------------------
; Tail
; Dev-Cart JMP at $FFE1
.dsb    $ffe1-*, $ff
JMP($FFFC)

; Vectors
.dsb    $fffa-*, $ff    ; filling
.word begin
.word begin
.word begin
