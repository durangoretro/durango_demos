*=$c000
begin:



; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3c
STA $df80


; Debug hex value
LDA #$00
STA $df94
LDX #$11
STX $df93
INX
STX $df93
INX
STX $df93
INX
STX $df93
INX
STX $df93

; ASCII mode. Letter
LDA #$01
STA $df94
LDX #'a'
STX $df93


; ASCII mode. String
LDA #$01
STA $df94
LDX #$00
LDA my_text,X
STA $df93
INX
LDA my_text,X
STA $df93
INX
LDA my_text,X
STA $df93
INX
LDA my_text,X
STA $df93

; ASCII mode. Full String
JSR _print_string

; Stat
LDA #$ff
STA $df94
STX $df93
STX $df93
STX $df93

; End execution
.byte $db


; String
_print_string
LDA #$01
STA $df94
LDX #$00
loop:
LDA my_text2,X
BEQ end
STA $df93
INX
BNE loop
end:
RTS




my_text: .asc "Hello"
.byt $00

my_text2: .asc "This is a demo."
.byte $00


; Finish cartridge
.dsb    $fffa-*, $ff
* = $fffa
.word begin
.word begin
.word begin

