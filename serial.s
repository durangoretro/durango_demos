PSV_FOPEN = $11
PSV_FREAD = $12
PSV_FWRITE = $13
PSV_FCLOSE = $1F
PSV_HEX = $F0
PSV_ASCII = $F1
PSV = $df93
PSV_CONFIG = $df94
BUFFER = $0200

*=$c000

begin:

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #%10000100
STA $df80

; Set mode OPEN
LDY #PSV_FOPEN
STY PSV_CONFIG
; Send filename
.(
LDX #$61
loop:
STX PSV
INX
CPX #$65
BNE loop
.)

; Set mode WRITE
LDY #PSV_FWRITE
STY PSV_CONFIG
; Write to file
.(
LDX #$41
loop:
STX PSV
INX
CPX #$5B
BNE loop
.)

; Set mode CLOSE
LDY #PSV_FCLOSE
STY PSV_CONFIG


; Set mode OPEN
LDY #PSV_FOPEN
STY PSV_CONFIG
; Send filename
.(
LDX #$61
loop:
STX PSV
INX
CPX #$65
BNE loop
.)

; Read from file
.(
; Set mode READ
LDY #PSV_FREAD
LDX #$00
loop:
; Send read
STY PSV_CONFIG
; Read data
LDA PSV
STA BUFFER,X
INX
CPX #26
BNE loop
.)

; Set mode CLOSE
LDY #PSV_FCLOSE
STY PSV_CONFIG


; Set mode HEX output
LDY #PSV_ASCII
STY PSV_CONFIG
; Print data
LDX #$00
.(
loop:
LDA BUFFER,X
STA PSV
INX
CPX #26
BNE loop
.)


STP

.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
