; == 16K ROM. FIRST 8K BLOCK ==
*=$c000
begin:
.asc "First block"
nop
nop


#if(*>$df80)
#echo First segment is too big!
#endif
.dsb $df80-*, $ff
*=$df80
; === END OF FIRST 8K BLOCK ===

; === RESERVED IO SPACE ($df80 - $dfff) ===
;* = $df80
.asc "DURANGO"
.byte $00
.byte $00
.asc "ROM cooked by emiliollbb"
.dsb $e000-*, $ff
; === END OF RESERVED IO SPACE ===

; === 16K ROM. SECOND 8K BLOCK ===
.asc "Second block"
.dsb $fffa-*, $ff
nop
nop
; === END OF SECOND 8K BLOCK ===


; === VECTORS ===
;* = $fffa
    .word begin ; NMI vector
    .word begin ; Reset vector
    .word begin ; IRQ/BRK vector
    

