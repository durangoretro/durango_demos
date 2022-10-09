PSV_FOPEN = $11
PSV_FREAD = $12
PSV_FWRITE = $13
PSV_FCLOSE = $1F
PSV = $df93
PSV_CONFIG = $df94

*=$c000

begin:

LDY #PSV_FOPEN
STY PSV_CONFIG

.(
LDX #$61
loop:
STX PSV
INX
CPX #$65
BNE loop
.)

LDY #PSV_FWRITE
STY PSV_CONFIG

.(
LDX #$41
loop:
STX PSV
INX
CPX #$5A
BNE loop
.)


LDY #PSV_FCLOSE
STY PSV_CONFIG


end: JMP end


.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
