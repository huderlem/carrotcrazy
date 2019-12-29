INCLUDE "hardware.inc"
INCLUDE "macros.asm"
INCLUDE "charmap.asm"
INCLUDE "constants.asm"

SECTION "ROM Bank $00", ROM0[$0]

INCBIN "baserom.gbc", $0, $4000 - $0

SECTION "ROM Bank $01", ROMX[$4000], BANK[$1]

INCBIN "baserom.gbc", $4000, $8000 - $4000

SECTION "ROM Bank $02", ROMX[$4000], BANK[$2]

INCBIN "baserom.gbc", $8000, $C000 - $8000

SECTION "ROM Bank $03", ROMX[$4000], BANK[$3]

INCBIN "baserom.gbc", $C000, $10000 - $C000

SECTION "ROM Bank $04", ROMX[$4000], BANK[$4]

INCBIN "baserom.gbc", $10000, $14000 - $10000

SECTION "ROM Bank $05", ROMX[$4000], BANK[$5]

INCBIN "baserom.gbc", $14000, $16e8c - $14000

INCLUDE "data/passwords.asm"

INCBIN "baserom.gbc", $16eab, $17dd6 - $16eab

SECTION "ROM Bank $06", ROMX[$4000], BANK[$6]

INCBIN "baserom.gbc", $18000, $1C000 - $18000

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

INCBIN "baserom.gbc", $38000, $3C000 - $38000

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

INCBIN "baserom.gbc", $58000, $5C000 - $58000

SECTION "ROM Bank $17", ROMX[$4000], BANK[$17]

INCBIN "baserom.gbc", $5C000, $60000 - $5C000

SECTION "ROM Bank $18", ROMX[$4000], BANK[$18]

INCBIN "baserom.gbc", $60000, $64000 - $60000

SECTION "ROM Bank $19", ROMX[$4000], BANK[$19]

INCBIN "baserom.gbc", $64000, $68000 - $64000

SECTION "ROM Bank $1A", ROMX[$4000], BANK[$1A]

INCBIN "baserom.gbc", $68000, $6C000 - $68000

SECTION "ROM Bank $1B", ROMX[$4000], BANK[$1B]

INCBIN "baserom.gbc", $6C000, $70000 - $6C000

SECTION "ROM Bank $1C", ROMX[$4000], BANK[$1C]

INCBIN "baserom.gbc", $70000, $74000 - $70000

SECTION "ROM Bank $1D", ROMX[$4000], BANK[$1D]

INCBIN "baserom.gbc", $74000, $78000 - $74000

SECTION "ROM Bank $1E", ROMX[$4000], BANK[$1E]

INCBIN "baserom.gbc", $78000, $7C000 - $78000

SECTION "ROM Bank $1F", ROMX[$4000], BANK[$1F]

INCBIN "baserom.gbc", $7C000, $80000 - $7C000

SECTION "ROM Bank $20", ROMX[$4000], BANK[$20]

INCBIN "baserom.gbc", $80000, $84000 - $80000

SECTION "ROM Bank $21", ROMX[$4000], BANK[$21]

INCBIN "baserom.gbc", $84000, $88000 - $84000

SECTION "ROM Bank $22", ROMX[$4000], BANK[$22]

INCBIN "baserom.gbc", $88000, $8C000 - $88000

SECTION "ROM Bank $23", ROMX[$4000], BANK[$23]

INCBIN "baserom.gbc", $8C000, $90000 - $8C000

SECTION "ROM Bank $24", ROMX[$4000], BANK[$24]

INCBIN "baserom.gbc", $90000, $94000 - $90000

SECTION "ROM Bank $25", ROMX[$4000], BANK[$25]

INCBIN "baserom.gbc", $94000, $98000 - $94000

SECTION "ROM Bank $26", ROMX[$4000], BANK[$26]

INCBIN "baserom.gbc", $98000, $9C000 - $98000

SECTION "ROM Bank $27", ROMX[$4000], BANK[$27]

INCBIN "baserom.gbc", $9C000, $A0000 - $9C000

SECTION "ROM Bank $28", ROMX[$4000], BANK[$28]

INCBIN "baserom.gbc", $A0000, $A4000 - $A0000

SECTION "ROM Bank $29", ROMX[$4000], BANK[$29]

INCBIN "baserom.gbc", $A4000, $A8000 - $A4000

SECTION "ROM Bank $2A", ROMX[$4000], BANK[$2A]

INCBIN "baserom.gbc", $A8000, $AC000 - $A8000

SECTION "ROM Bank $2B", ROMX[$4000], BANK[$2B]

INCBIN "baserom.gbc", $AC000, $B0000 - $AC000

SECTION "ROM Bank $2C", ROMX[$4000], BANK[$2C]

INCBIN "baserom.gbc", $B0000, $B4000 - $B0000

SECTION "ROM Bank $2D", ROMX[$4000], BANK[$2D]

INCBIN "baserom.gbc", $B4000, $B8000 - $B4000

SECTION "ROM Bank $2E", ROMX[$4000], BANK[$2E]

INCBIN "baserom.gbc", $B8000, $BC000 - $B8000

SECTION "ROM Bank $2F", ROMX[$4000], BANK[$2F]

INCBIN "baserom.gbc", $BC000, $C0000 - $BC000

SECTION "ROM Bank $30", ROMX[$4000], BANK[$30]

INCBIN "baserom.gbc", $C0000, $C4000 - $C0000

SECTION "ROM Bank $31", ROMX[$4000], BANK[$31]

INCBIN "baserom.gbc", $C4000, $C8000 - $C4000

SECTION "ROM Bank $32", ROMX[$4000], BANK[$32]

INCBIN "baserom.gbc", $C8000, $CC000 - $C8000

SECTION "ROM Bank $33", ROMX[$4000], BANK[$33]

INCBIN "baserom.gbc", $CC000, $D0000 - $CC000

SECTION "ROM Bank $34", ROMX[$4000], BANK[$34]

INCBIN "baserom.gbc", $D0000, $D4000 - $D0000

SECTION "ROM Bank $35", ROMX[$4000], BANK[$35]

INCBIN "baserom.gbc", $D4000, $D8000 - $D4000

SECTION "ROM Bank $36", ROMX[$4000], BANK[$36]

INCBIN "baserom.gbc", $D8000, $DC000 - $D8000

SECTION "ROM Bank $37", ROMX[$4000], BANK[$37]

INCBIN "baserom.gbc", $DC000, $E0000 - $DC000

SECTION "ROM Bank $38", ROMX[$4000], BANK[$38]

INCBIN "baserom.gbc", $E0000, $E4000 - $E0000

SECTION "ROM Bank $39", ROMX[$4000], BANK[$39]

INCBIN "baserom.gbc", $E4000, $E8000 - $E4000

SECTION "ROM Bank $3A", ROMX[$4000], BANK[$3A]

INCBIN "baserom.gbc", $E8000, $EC000 - $E8000

SECTION "ROM Bank $3B", ROMX[$4000], BANK[$3B]

INCBIN "baserom.gbc", $EC000, $F0000 - $EC000

SECTION "ROM Bank $3C", ROMX[$4000], BANK[$3C]

INCBIN "baserom.gbc", $F0000, $F4000 - $F0000

SECTION "ROM Bank $3D", ROMX[$4000], BANK[$3D]

INCBIN "baserom.gbc", $F4000, $F8000 - $F4000

SECTION "ROM Bank $3E", ROMX[$4000], BANK[$3E]

INCBIN "baserom.gbc", $F8000, $FC000 - $F8000

SECTION "ROM Bank $3F", ROMX[$4000], BANK[$3F]

INCBIN "baserom.gbc", $FC000, $100000 - $FC000
