*=$c000
begin:

LDA #$77
end: JMP end




.dsb    $fffa-*, $ff    ; filling

* = $fffa
    .word begin
    .word begin
    .word begin
