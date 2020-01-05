INCLUDE "hardware.inc"
INCLUDE "macros.asm"
INCLUDE "charmap.asm"
INCLUDE "constants.asm"

SECTION "ROM Bank $00", ROM0[$0]

INCBIN "baserom.gbc", $0, $3eca - $0

INCLUDE "home/load.asm"

INCBIN "baserom.gbc", $3ff1, $4000 - $3ff1

SECTION "ROM Bank $01", ROMX[$4000], BANK[$1]

INCBIN "baserom.gbc", $4000, $8000 - $4000

SECTION "ROM Bank $02", ROMX[$4000], BANK[$2]

INCBIN "baserom.gbc", $8000, $C000 - $8000

SECTION "ROM Bank $03", ROMX[$4000], BANK[$3]

INCBIN "baserom.gbc", $c000, $da76 - $c000

InfogramesCopyrightTiles:
	INCBIN "gfx/infogrames_copyright/background.2bpp.lz"

INCBIN "baserom.gbc", $dc9f, $10000 - $dc9f

SECTION "ROM Bank $04", ROMX[$4000], BANK[$4]

INCBIN "baserom.gbc", $10000, $14000 - $10000

SECTION "ROM Bank $05", ROMX[$4000], BANK[$5]

INCBIN "baserom.gbc", $14000, $16e8c - $14000

INCLUDE "data/passwords.asm"

INCBIN "baserom.gbc", $16eab, $17dd6 - $16eab

SECTION "ROM Bank $06", ROMX[$4000], BANK[$6]

INCBIN "baserom.gbc", $18000, $1bcb0 - $18000

Data_1bcb0:
	db $16
	dw $5d9d
	dw $9550

	db $16
	dw $5fc2
	dw $9800

	db $16
	dw $6021
	dw $d9d5

	db $FF

INCBIN "baserom.gbc", $1bcc0, $1c000 - $1bcc0

SECTION "ROM Bank $07", ROMX[$4000], BANK[$7]

INCBIN "baserom.gbc", $1C000, $20000 - $1C000

SECTION "ROM Bank $08", ROMX[$4000], BANK[$8]

INCBIN "baserom.gbc", $20000, $24000 - $20000

SECTION "ROM Bank $09", ROMX[$4000], BANK[$9]

INCBIN "baserom.gbc", $24000, $28000 - $24000

SECTION "ROM Bank $0A", ROMX[$4000], BANK[$A]

INCBIN "baserom.gbc", $28000, $2C000 - $28000

SECTION "ROM Bank $0B", ROMX[$4000], BANK[$B]

INCBIN "baserom.gbc", $2C000, $30000 - $2C000

SECTION "ROM Bank $0C", ROMX[$4000], BANK[$C]

INCBIN "baserom.gbc", $30000, $34000 - $30000

SECTION "ROM Bank $0D", ROMX[$4000], BANK[$D]

INCBIN "baserom.gbc", $34000, $38000 - $34000

SECTION "ROM Bank $0E", ROMX[$4000], BANK[$E]

INCBIN "baserom.gbc", $38000, $3bf94 - $38000

InfogramesCopyrightTilemap:
	INCBIN "gfx/infogrames_copyright/background.tilemap.lz"

SECTION "ROM Bank $0F", ROMX[$4000], BANK[$F]

INCBIN "baserom.gbc", $3C000, $40000 - $3C000

SECTION "ROM Bank $10", ROMX[$4000], BANK[$10]

INCBIN "baserom.gbc", $40000, $44000 - $40000

SECTION "ROM Bank $11", ROMX[$4000], BANK[$11]

INCBIN "baserom.gbc", $44000, $48000 - $44000

SECTION "ROM Bank $12", ROMX[$4000], BANK[$12]

INCBIN "baserom.gbc", $48000, $4C000 - $48000

SECTION "ROM Bank $13", ROMX[$4000], BANK[$13]

INCBIN "baserom.gbc", $4C000, $50000 - $4C000

SECTION "ROM Bank $14", ROMX[$4000], BANK[$14]

INCBIN "baserom.gbc", $50000, $54000 - $50000

SECTION "ROM Bank $15", ROMX[$4000], BANK[$15]

INCBIN "baserom.gbc", $54000, $58000 - $54000

SECTION "ROM Bank $16", ROMX[$4000], BANK[$16]

INCBIN "baserom.gbc", $58000, $59d9d - $58000

InfogramesCopyrightGBCTiles:
	INCBIN "gfx/infogrames_copyright/background_gbc.2bpp.lz"
InfogramesCopyrightGBCTilemap:
	INCBIN "gfx/infogrames_copyright/background_gbc.tilemap.lz"
InfogramesCopyrightGBCAttributesTilemap:
	INCBIN "gfx/infogrames_copyright/background_gbc.attrmap.lz"

SECTION "ROM Bank $20", ROMX[$4000], BANK[$20]
; force 1MB ROM
