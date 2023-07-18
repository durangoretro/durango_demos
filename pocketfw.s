*=$8000

;------ DXHEAD------------------------------------------------------
; 8 bytes
.byt $00
.byt "pX"
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
.byt $00,$80,$00,$00
;]
;---------------------------------------------------------------

;--------- INITIALIZE ------------------------------------------
begin:
; Initialize 6502    
SEI ; Disable interrupts
CLD ; Clear decimal mode
LDX #$FF ; Initialize stack pointer to $01FF
TXS
; Set up IRQ subroutine
LDA #<irq_int
STA IRQ_ADDR
LDA #>irq_int
STA IRQ_ADDR+1
; Set up NMI subroutine
LDA #<nmi_int
STA NMI_ADDR
LDA #>nmi_int
STA NMI_ADDR+1
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
;---------------------------------------------------------

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
IRQ_ADDR = $0200
NMI_ADDR = $0202
PSV = $df93
PSV_CONFIG = $df94
PSV_RAW_INIT  = $20
PSV_RAW_SEEK  = $21
PSV_RAW_READ  = $22
PSV_RAW_WRITE = $23
PSV_RAW_CLOSE = $24
;---------------------------------------------------------

;------------- LOADER ------------------------------------
; Load binary at $2000
LOAD_ADDR = $2000
; Set up Load Address variable
LDA #<LOAD_ADDR
STA DATA_POINTER
LDA #>LOAD_ADDR
STA DATA_POINTER+1
; Set up file block number variable
STZ X_COORD

; Load 48 blocks (24K)
loop:
JSR read_block
INC DATA_POINTER+1
INC DATA_POINTER+1
INC X_COORD
LDA X_COORD
CMP #49
BNE loop

; Run loaded code
JMP $2100

end: BRA end

read_block:
.(
; Open PSV file
LDY #PSV_RAW_INIT
STY PSV_CONFIG
; Raw seek
LDA #PSV_RAW_SEEK
STA PSV_CONFIG
;BUFFER
LDA DATA_POINTER
STA PSV
LDA DATA_POINTER+1
STA PSV
;BLOCK
LDA #0
STA PSV
STA PSV
STA PSV
LDA X_COORD
STA PSV
; Run read
LDA #PSV_RAW_READ
STA PSV_CONFIG
; PSV raw file Close
LDY #PSV_RAW_CLOSE
STY PSV_CONFIG
; Return
RTS
.)
;---------------------------------------------------------



; ------------- Vectors ----------------------------------
irq_int:
RTS
nmi_int:
RTS
nmi:
JMP (NMI_ADDR)
irq:
JMP (IRQ_ADDR)
.dsb    $fffa-*, $ff    ; filling
.word nmi
.word begin
.word irq
