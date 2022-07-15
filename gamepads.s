; OPCODES: http://www.6502.org/tutorials/6502opcodes.html
;----------------------------
ROM_START = $c000
TILESET_START = ROM_START
TILEMAP_START = TILESET_START + $2000
;----------------------------
RED = $22
DARK_GREEN = $44

; Tiles position (0xc000 - 0xdfff)
*=ROM_START
; ----- TILES ------
tiles:
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $00
.byt $00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88, ; Tile $01
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88, ; Tile $02
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $03
.byt $99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$98,$88,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $04
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $05
.byt $88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $06
.byt $99,$99,$88,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88, ; Tile $07
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$9F,$FF,$99,$99,$9F,$44,$99,$99,$9F,$44,$99,$99,$9F,$44,$99,$99,$9F,$44, ; Tile $08
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$FF,$FF,$F9,$44,$44,$44,$F9,$44,$44,$44,$F9,$44,$44,$44,$F9,$44,$44,$44,$F9, ; Tile $09
.byt $99,$99,$98,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$98,$88,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $0A
.byt $88,$88,$88,$99,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $0B
.byt $99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$98,$88, ; Tile $0C
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$F4, ; Tile $0D
.byt $99,$99,$9F,$44,$99,$99,$9F,$44,$FF,$FF,$FF,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44, ; Tile $0E
.byt $44,$44,$44,$F9,$44,$44,$44,$F9,$44,$44,$44,$FF,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44, ; Tile $0F
.byt $99,$99,$99,$99,$99,$99,$99,$99,$FF,$FF,$FF,$99,$44,$44,$4F,$99,$44,$44,$4F,$99,$44,$44,$4F,$99,$44,$44,$4F,$99,$44,$44,$4F,$99, ; Tile $10
.byt $99,$99,$98,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$98,$88,$99,$99,$99,$99,$99,$99,$98,$88, ; Tile $11
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$88,$88,$88,$88, ; Tile $12
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$88,$88,$86,$88, ; Tile $13
.byt $88,$88,$88,$99,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$99,$99,$99,$99,$99,$88,$88,$88,$99, ; Tile $14
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$9F,$FF,$99,$99,$FF,$FF, ; Tile $15
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF, ; Tile $16
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$99,$99,$FF,$FF,$99,$9F,$FF, ; Tile $17
.byt $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$FF,$99,$99,$99,$FF,$F9,$99,$99, ; Tile $18
.byt $99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$F4,$99,$99,$99,$FF,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $19
.byt $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$FF,$FF,$FF,$44,$99,$99,$9F,$44,$99,$99,$9F,$44,$99,$99,$9F,$44, ; Tile $1A
.byt $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$FF,$44,$44,$44,$F9,$44,$44,$44,$F9,$44,$44,$44,$F9, ; Tile $1B
.byt $44,$44,$4F,$99,$44,$44,$4F,$99,$44,$44,$4F,$99,$44,$44,$4F,$99,$FF,$FF,$FF,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $1C
.byt $99,$99,$98,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$88,$88, ; Tile $1D
.byt $88,$86,$66,$66,$88,$86,$66,$66,$88,$86,$66,$66,$88,$88,$88,$88,$84,$44,$44,$44,$44,$44,$44,$44,$84,$44,$44,$44,$88,$44,$44,$44, ; Tile $1E
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$44,$88,$88,$88,$44,$48,$88,$88,$44,$88,$88,$88,$48,$88,$88,$88, ; Tile $1F
.byt $88,$88,$86,$68,$88,$88,$86,$66,$88,$88,$86,$68,$88,$88,$86,$88,$84,$44,$44,$44,$44,$44,$44,$44,$84,$44,$44,$44,$88,$44,$44,$44, ; Tile $20
.byt $88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$44,$88,$88,$89,$44,$48,$88,$89,$44,$88,$88,$89,$48,$88,$88,$89, ; Tile $21
.byt $99,$99,$FF,$FF,$99,$99,$FF,$FF,$99,$99,$FF,$F4,$99,$99,$FF,$44,$99,$99,$FF,$44,$99,$99,$FF,$44,$99,$99,$FF,$44,$99,$99,$FF,$44, ; Tile $22
.byt $FF,$44,$4F,$FF,$44,$44,$44,$4F,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44, ; Tile $23
.byt $FF,$F9,$9F,$FF,$FF,$F9,$9F,$FF,$FF,$F9,$9F,$F4,$4F,$F9,$9F,$44,$4F,$F9,$9F,$44,$4F,$F9,$9F,$44,$4F,$F9,$9F,$44,$4F,$F9,$9F,$44, ; Tile $24
.byt $FF,$F9,$99,$99,$FF,$F9,$99,$99,$FF,$F9,$99,$99,$4F,$F9,$99,$99,$4F,$F9,$99,$99,$4F,$F9,$99,$99,$4F,$F9,$99,$99,$4F,$F9,$99,$99, ; Tile $25
.byt $99,$99,$9F,$44,$99,$99,$9F,$44,$99,$99,$9F,$44,$99,$99,$9F,$FF,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $26
.byt $44,$44,$44,$F9,$44,$44,$44,$F9,$44,$44,$44,$F9,$FF,$FF,$FF,$F9,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $27
.byt $99,$99,$88,$88,$99,$99,$88,$88,$99,$99,$98,$88,$99,$99,$98,$88,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$88,$88, ; Tile $28
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$88,$88,$88,$88, ; Tile $29
.byt $88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$89,$88,$88,$88,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$88,$88,$88,$89, ; Tile $2A
.byt $99,$99,$FF,$F4,$99,$99,$FF,$FF,$99,$99,$FF,$FF,$99,$99,$FF,$FF,$99,$99,$9F,$FF,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99, ; Tile $2B
.byt $44,$44,$44,$44,$44,$44,$44,$4F,$FF,$44,$44,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$99,$99,$99,$99,$99,$99,$99,$96,$99,$99,$99,$96, ; Tile $2C
.byt $FF,$F9,$9F,$F4,$FF,$F9,$9F,$FF,$FF,$F9,$9F,$FF,$FF,$F9,$9F,$FF,$FF,$99,$99,$FF,$99,$99,$99,$99,$66,$99,$99,$99,$99,$69,$99,$99, ; Tile $2D
.byt $FF,$F9,$99,$99,$FF,$F9,$99,$99,$FF,$F9,$99,$99,$FF,$F9,$99,$99,$FF,$99,$99,$99,$99,$99,$99,$99,$66,$69,$99,$99,$99,$69,$99,$99, ; Tile $2E
.byt $00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $2F
.byt $99,$99,$99,$99,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $30
.byt $99,$99,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $31
.byt $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $32
.byt $88,$88,$88,$89,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $33
.byt $99,$99,$99,$96,$88,$88,$88,$86,$88,$88,$88,$86,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $34
.byt $66,$99,$99,$99,$88,$68,$88,$88,$66,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $35
.byt $66,$69,$99,$99,$88,$68,$88,$88,$88,$68,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $36
.byt $99,$99,$98,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $37
.byt $00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA, ; Tile $38
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA, ; Tile $39
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $3A
.byt $BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $3B
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $3C
.byt $AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $3D
.byt $BB,$BB,$AA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA, ; Tile $3E
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BF,$FF,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44, ; Tile $3F
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF,$FF,$FB,$44,$44,$44,$FB,$44,$44,$44,$FB,$44,$44,$44,$FB,$44,$44,$44,$FB, ; Tile $40
.byt $BB,$BB,$BA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $41
.byt $AA,$AA,$AA,$BB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $42
.byt $BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA, ; Tile $43
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4, ; Tile $44
.byt $BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$FF,$FF,$FF,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44, ; Tile $45
.byt $44,$44,$44,$FB,$44,$44,$44,$FB,$44,$44,$44,$FF,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44, ; Tile $46
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF,$FF,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB, ; Tile $47
.byt $BB,$BB,$BA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BA,$AA, ; Tile $48
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$AA,$AA,$AA,$AA, ; Tile $49
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$AA,$AA,$A6,$AA, ; Tile $4A
.byt $AA,$AA,$AA,$BB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$AA,$AA,$AA,$BB, ; Tile $4B
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BF,$FF,$BB,$BB,$FF,$FF, ; Tile $4C
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF, ; Tile $4D
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$BB,$BB,$FF,$FF,$BB,$BF,$FF, ; Tile $4E
.byt $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$FF,$BB,$BB,$BB,$FF,$FB,$BB,$BB, ; Tile $4F
.byt $BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$F4,$BB,$BB,$BB,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $50
.byt $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$FF,$FF,$FF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44, ; Tile $51
.byt $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$FF,$44,$44,$44,$FB,$44,$44,$44,$FB,$44,$44,$44,$FB, ; Tile $52
.byt $44,$44,$4F,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB,$44,$44,$4F,$BB,$FF,$FF,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $53
.byt $BB,$BB,$BA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA, ; Tile $54
.byt $AA,$A6,$66,$66,$AA,$A6,$66,$66,$AA,$A6,$66,$66,$AA,$AA,$AA,$AA,$A4,$44,$44,$44,$44,$44,$44,$44,$A4,$44,$44,$44,$AA,$44,$44,$44, ; Tile $55
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$44,$AA,$AA,$AA,$44,$4A,$AA,$AA,$44,$AA,$AA,$AA,$4A,$AA,$AA,$AA, ; Tile $56
.byt $AA,$AA,$A6,$6A,$AA,$AA,$A6,$66,$AA,$AA,$A6,$6A,$AA,$AA,$A6,$AA,$A4,$44,$44,$44,$44,$44,$44,$44,$A4,$44,$44,$44,$AA,$44,$44,$44, ; Tile $57
.byt $AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$44,$AA,$AA,$AB,$44,$4A,$AA,$AB,$44,$AA,$AA,$AB,$4A,$AA,$AA,$AB, ; Tile $58
.byt $BB,$BB,$FF,$FF,$BB,$BB,$FF,$FF,$BB,$BB,$FF,$F4,$BB,$BB,$FF,$44,$BB,$BB,$FF,$44,$BB,$BB,$FF,$44,$BB,$BB,$FF,$44,$BB,$BB,$FF,$44, ; Tile $59
.byt $FF,$FB,$BF,$FF,$FF,$FB,$BF,$FF,$FF,$FB,$BF,$F4,$4F,$FB,$BF,$44,$4F,$FB,$BF,$44,$4F,$FB,$BF,$44,$4F,$FB,$BF,$44,$4F,$FB,$BF,$44, ; Tile $5A
.byt $FF,$FB,$BB,$BB,$FF,$FB,$BB,$BB,$FF,$FB,$BB,$BB,$4F,$FB,$BB,$BB,$4F,$FB,$BB,$BB,$4F,$FB,$BB,$BB,$4F,$FB,$BB,$BB,$4F,$FB,$BB,$BB, ; Tile $5B
.byt $BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$44,$BB,$BB,$BF,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $5C
.byt $44,$44,$44,$FB,$44,$44,$44,$FB,$44,$44,$44,$FB,$FF,$FF,$FF,$FB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $5D
.byt $BB,$BB,$AA,$AA,$BB,$BB,$AA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$AA,$AA, ; Tile $5E
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$AA,$AA,$AA,$AA, ; Tile $5F
.byt $AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$AB,$AA,$AA,$AA,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$AA,$AA,$AA,$AB, ; Tile $60
.byt $BB,$BB,$FF,$F4,$BB,$BB,$FF,$FF,$BB,$BB,$FF,$FF,$BB,$BB,$FF,$FF,$BB,$BB,$BF,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB, ; Tile $61
.byt $44,$44,$44,$44,$44,$44,$44,$4F,$FF,$44,$44,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$B6,$BB,$BB,$BB,$B6, ; Tile $62
.byt $FF,$FB,$BF,$F4,$FF,$FB,$BF,$FF,$FF,$FB,$BF,$FF,$FF,$FB,$BF,$FF,$FF,$BB,$BB,$FF,$BB,$BB,$BB,$BB,$66,$BB,$BB,$BB,$BB,$6B,$BB,$BB, ; Tile $63
.byt $FF,$FB,$BB,$BB,$FF,$FB,$BB,$BB,$FF,$FB,$BB,$BB,$FF,$FB,$BB,$BB,$FF,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$66,$6B,$BB,$BB,$BB,$6B,$BB,$BB, ; Tile $64
.byt $00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $65
.byt $BB,$BB,$BB,$BB,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $66
.byt $BB,$BB,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $67
.byt $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $68
.byt $AA,$AA,$AA,$AB,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $69
.byt $BB,$BB,$BB,$B6,$AA,$AA,$AA,$A6,$AA,$AA,$AA,$A6,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $6A
.byt $66,$BB,$BB,$BB,$AA,$6A,$AA,$AA,$66,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $6B
.byt $66,$6B,$BB,$BB,$AA,$6A,$AA,$AA,$AA,$6A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $6C
.byt $BB,$BB,$BA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00, ; Tile $6D
; Fill unused tiles
.dsb TILEMAP_START-*, $ff; tiles in 0xc000 - 0xdfff

; ----- MAP ------
; First map 0xe000
tilemap:
.byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
.byt $01,$03,$03,$03,$03,$04,$05,$05,$05,$06,$03,$03,$03,$03,$03,$07,$01,$03,$08,$09,$03,$0A,$05,$05,$05,$0B,$03,$03,$03,$03,$03,$0C,
.byt $01,$0D,$0E,$0F,$10,$11,$12,$12,$13,$14,$15,$16,$17,$16,$18,$0C,$01,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$23,$25,$0C,
.byt $01,$03,$26,$27,$03,$28,$29,$29,$29,$2A,$2B,$2C,$2D,$2C,$2E,$0C,$2F,$30,$30,$30,$30,$31,$32,$32,$32,$33,$30,$34,$35,$34,$36,$37,
.byt $38,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$39,$38,$3A,$3A,$3A,$3A,$3B,$3C,$3C,$3C,$3D,$3A,$3A,$3A,$3A,$3A,$3E,
.byt $38,$3A,$3F,$40,$3A,$41,$3C,$3C,$3C,$42,$3A,$3A,$3A,$3A,$3A,$43,$38,$44,$45,$46,$47,$48,$49,$49,$4A,$4B,$4C,$4D,$4E,$4D,$4F,$43,
.byt $38,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$23,$5A,$23,$5B,$43,$38,$3A,$5C,$5D,$3A,$5E,$5F,$5F,$5F,$60,$61,$62,$63,$62,$64,$43,
.byt $65,$66,$66,$66,$66,$67,$68,$68,$68,$69,$66,$6A,$6B,$6A,$6C,$6D,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,


begin:
; $e300

; Set video mode
; [HiRes Invert S1 S0    RGB LED NC NC]
LDA #$3F
STA $df80

; $10 $11 current video memory pointer
LDA #$60
STA $11
LDA #$00
STA $10

; $14, $15 tilemap to draw
;LDA #$e0
LDA #>tilemap
STA $15
;LDA #$00
LDA #<tilemap
STA $14

; Draw map 1
JSR draw_map


; $10 $11 Set video pointer
LDA #$60
STA $11
LDA #$00
STA $10

; $6 current color
LDA #RED
STA $06

; 16, 17 x,y pixel coords
LDA #$00
STA $16
LDA #$40
STA $17

;JSR draw_square
JSR draw_square

end: JMP end


;18 19 -> video memory backup
draw_square:
; Backup video memory position
LDA $10
STA $18
LDA $11
STA $19
JSR draw_pixel
INC $17
; Restore video memory position
LDA $18
STA $10
LDA $19
STA $11
JSR draw_pixel
RTS

draw_pixel:
JSR convert_coords_to_mem
; Load current color
LDA $06
; Store at video position
LDY #$00
STA ($10), Y
RTS



; 16, 17 x,y pixel coords
; $10 $11 current video memory pointer
convert_coords_to_mem:
; Multiply y coord by 64 (64 bytes each row)
LDA $17
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_01
INC $11
conv_coor_mem_01:
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_02
INC $11
conv_coor_mem_02:
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_03
INC $11
conv_coor_mem_03:
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_04
INC $11
conv_coor_mem_04:
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_05
INC $11
conv_coor_mem_05:
ASL
; If overflow, rotate left byte
BCC conv_coor_mem_06
INC $11
conv_coor_mem_06:
; Add to initial memory address, and save it
STA $10
RTS
; Divide x coord by 2 (2 pixel each byte)
LDA $16
LSR
; Add to memory address
CLC
ADC $10
; Store in video memory position
STA $10
; If overflow, increment left byte
BCC conv_coor_mem_07
INC $10
conv_coor_mem_07:
RTS




; -- -- -- -- -- -- 
; $14, $15 tilemap to draw
draw_map:
; $07 tiles rows counter
;LDA #$a0
LDA #$10
STA $07
draw_map_loop1:
; First tiles row
; tile 0
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 1
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 2
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 3
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 4
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 5
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 6
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 7
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 8
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 9
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 10
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 11
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 12
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 13
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 14
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
; tile 15
INC $14
JSR convert_tile_index_to_mem
JSR draw_back_tile
INC $14

; Change row
LDA #$00
STA $10
INC $11
INC $11
DEC $07
BEQ draw_map_end
JMP draw_map_loop1
draw_map_end:
RTS
;------------------------------------------------------


; Input $14 $15 Tilemap position
; output $12, $13 tile to draw (initial position in mem
; $08 internal, backup of current tile index
convert_tile_index_to_mem:
; Load tile index in X
LDY #$00
LDA ($14), Y
;$08 backup of current tile index ($14)
STA $08
; Calculate tile memory position by multiplying (shifting) tile number * 0x20
ASL
ASL
ASL
ASL
ASL
; Store tile memory position in $12
STA $12

; Calculate more significative tile memory position ($13)
;$07 backup of current tile index ($13)
;LDA $13
;STA $07
LDA $08
LSR
LSR
LSR
CLC
ADC #>TILESET_START
STA $13
RTS
; --------------------------------------------------------







;$12, $13 -> tile number, tile bank
;$10,$11 -> screen position
;$09 backup of $10 original value
draw_back_tile:
; Save screen position as backup in $09
LDA $10
STA $09
; First row
LDY #$00
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10; Increment using acumulator less significative screen pos ($10)
CLC
ADC #$40; Each row is 0x40 (64) bytes 
STA $10
LDA $12; Increment first tile byte position ($12), so it points to next byte
CLC
ADC #$04; Increment by 4 (already drawn 8 pixels)
STA $12
LDY #$00; Initialize pixel counter to 0
; Second row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Third row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Fourth row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row and block
LDA $10
CLC
ADC #$40
STA $10
INC $11; Each 4 rows, high significative byte should be increased
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Fith row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Sixth row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Seventh row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
; Change row
LDA $10
CLC
ADC #$40
STA $10
LDA $12
CLC
ADC #$04
STA $12
LDY #$00
; Eight row
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y
INY
LDA ($12), Y
STA ($10), Y

; Finalize tile drawing
LDA $12; Go to next tile by incrementing $12 by 0x04 (already drawn 8 pixels)
CLC
ADC #$04
DEC $11; Restore $11 to original value, so next tile is at same row
LDA $09; Restore $10 using backup and add 0x04 to set at next screen position 
CLC
ADC #$04
STA $10
RTS
;--------------------------------------------------------



; Fill unused ROM
.dsb $fffa-*, $00

; Set initial PC
* = $fffa
    .word begin
    .word begin
    .word begin
