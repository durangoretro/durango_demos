*=$C000

; ===== DCLIB CONSTANTS ================================================
VMEM_POINTER = $10 ; $11
DATA_POINTER = $12 ; $13
RESOURCE_POINTER = $14 ; $15
IRQ_ADDR = $0200
NMI_ADDR = $0202
;=======================================================================


; ===== RAM LOADER =====================================================
reset:
; Init source pointer
LDX #$C0
STX RESOURCE_POINTER+1
LDY #$00
STY RESOURCE_POINTER
; Init destination pointer
LDX #$20
STX DATA_POINTER+1
LDY #$00
STY DATA_POINTER

; Copy data from source pointer to destination pointer
; until source pointer overflows to zero
loop:
LDA (RESOURCE_POINTER), Y
STA (DATA_POINTER), Y
INY
BNE loop
INC DATA_POINTER+1
INC RESOURCE_POINTER+1
BNE loop

; Run loaded code from RAM
JMP $2020

; Padding to 256 bytes
;.dsb $C030-*, $ff
;=======================================================================

;========= INITIALIZATION ==============================================
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
;=======================================================================

; ============= ACTUAL CODE TO BE RAN ON MEMORY ========================
; Some dummy code, fill screen
LDX #$60
STX VMEM_POINTER+1
LDY #$00
STY VMEM_POINTER
LDA #$22
fill_loop:
STA (VMEM_POINTER), Y
INY
BNE fill_loop
INC VMEM_POINTER+1
BPL fill_loop
forever:
bra forever

; ======================================================================


; ============= Vectors ================================================
irq_int:
RTI
nmi_int:
RTI
nmi:
JMP (NMI_ADDR)
irq:
JMP (IRQ_ADDR)
.dsb    $ffea-*, $ff    ; filling
.word nmi
.word reset
.word irq
; ======================================================================
