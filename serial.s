*=$c000

begin:

VIRTUAL_SERIAL_PORT = $df93
LDX #$00
loop:
STX VIRTUAL_SERIAL_PORT
INX
BNE loop

end: JMP end


.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
