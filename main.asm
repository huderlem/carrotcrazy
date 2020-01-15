INCLUDE "hardware.inc"
INCLUDE "vram.asm"
INCLUDE "macros.asm"
INCLUDE "charmap.asm"
INCLUDE "constants.asm"

SECTION "ROM Bank $00", ROM0[$00]

Func_0:
	ld de, MBC5RomBank
	ld a, $06 ; TODO: Bank(?)
	ld [de], a
	ld a, [hli]
	ld [$dde9], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hGameBoyColorDetection]
	cp GBC_MODE
	ret nz
	push hl
	ld a, Bank(Func_1a902)
	ld [de], a
	jp Func_1a902

; Adds a BCD value to the player's score.
; Input: c = value to add
AddScore:
	ld a, [hScore]
	add c
	daa
	ld [hScore], a
	ld a, [hScore + 1]
	adc b
	daa
	ld [hScore + 1], a
	ret

; Waits for VBlank period or immediately returns if LCD is disabled.
WaitUntilSafeToAccessVRAM:
	ld a, [rLCDC]
	add a
	ret nc ; return if LCD is disabled
	call WaitVBlank
	sub a
	ld [rLCDC], a
	ret

WaitHBlankStart:
	; Waits for the next HBlank period to begin.
	ld a, [rSTAT]
	and STATF_LCD
	jr z, WaitHBlankStart ; If we're already in the middle of HBlank, wait until it's over.
	; fallthrough

SECTION "rst 38", ROM0 [$38]

WaitNextHBlank_:
	ld a, [rSTAT]
	and STATF_LCD
	jr nz, WaitNextHBlank_
	ret

WaitNextHBlank:
	rst $38

; Hardware interrupts
SECTION "vblank", ROM0 [$40]
	reti

INCBIN "baserom.gbc", $41, $48 - $41

SECTION "hblank", ROM0 [$48]
	reti

INCBIN "baserom.gbc", $49, $50 - $49

SECTION "timer",  ROM0 [$50]
	reti

INCBIN "baserom.gbc", $51, $58 - $51

SECTION "serial", ROM0 [$58]
	reti

INCBIN "baserom.gbc", $59, $60 - $59

SECTION "joypad", ROM0 [$60]
	reti

SECTION "Home", ROM0 [$61]

INCBIN "baserom.gbc", $61, $68 - $61

; Waits until the VBlank period is entered.
WaitVBlank:
	ld a, [rLY]
	cp SCRN_Y + 1
	jr c, WaitVBlank
	ret

UpdateFrameCounter:
	ld a, [hPaused]
	and a
	ret nz
	ld hl, hFrameCounter
	inc [hl]
	ret

ResetFrameCounter:
	sub a
	ld [hFrameCounter], a
	ret

LoadCGBPalettesHome:
	ld a, Bank(LoadCGBPalettes)
	ld [MBC5RomBank], a
	jp LoadCGBPalettes

; The Warner Bros. Background banner graphics are only stored in ROM
; with the top-left quadrant. Since the other three quadrants are symmetric,
; this code unpacks the tiledata as such.
LoadWarnerBrosBannerQuadrants:
	push hl
	ld bc, $8830
	ld de, $8940
.asm_8b
	ld l, $09
.asm_8d
	ld a, [bc]
	inc bc
	add a
	rr h
	add a
	rr h
	add a
	rr h
	add a
	rr h
	add a
	rr h
	add a
	rr h
	add a
	rr h
	add a
	rr h
	ld a, h
	ld [de], a
	inc de
	ld a, c
	and $0f
	jr nz, .asm_8d
	ld a, e
	sub $20
	ld e, a
	ld a, d
	sbc $00
	ld d, a
	dec l
	jr nz, .asm_8d
	ld a, c
	add $90
	ld c, a
	ld a, b
	adc $00
	ld b, a
	ld a, e
	add $b0
	ld e, a
	ld a, d
	adc $01
	ld d, a
	ld a, b
	cp $90
	jr nz, .asm_8b
	ld bc, $8830
	ld de, $96de
	ld h, $07
.asm_d7
	ld l, $12
.asm_d9
	ld a, [bc]
	inc bc
	ld [de], a
	inc de
	ld a, [bc]
	inc bc
	ld [de], a
	dec de
	dec de
	dec de
	ld a, c
	and $0f
	jr nz, .asm_d9
	ld a, e
	add $20
	ld e, a
	ld a, d
	adc $00
	ld d, a
	dec l
	jr nz, .asm_d9
	ld a, e
	sub $40
	ld e, a
	ld a, d
	sbc $02
	ld d, a
	dec h
	jr nz, .asm_d7
	pop hl
	ret

INCBIN "baserom.gbc", $100, $3eca - $100

INCLUDE "home/load.asm"

INCBIN "baserom.gbc", $3ff1, $4000 - $3ff1

SECTION "ROM Bank $01", ROMX[$4000], BANK[$1]

INCBIN "baserom.gbc", $4000, $8000 - $4000

SECTION "ROM Bank $02", ROMX[$4000], BANK[$2]

INCBIN "baserom.gbc", $8000, $C000 - $8000

SECTION "ROM Bank $03", ROMX[$4000], BANK[$3]

WarnerBrosCopyrightLogoTiles:
	INCBIN "gfx/warner_bros_copyright/logo.interleave.2bpp.lz"
WarnerBrosCopyrightTrademarkTiles:
	INCBIN "gfx/warner_bros_copyright/trademark.2bpp.lz"
WarnerBrosCopyrightLolaBunnyTiles:
	INCBIN "gfx/warner_bros_copyright/lola_bunny.2bpp.lz"

INCBIN "baserom.gbc", $c765, $ccff - $c765

FarmSceneTiles:
	INCBIN "gfx/titlescreen/background.2bpp.lz"

INCBIN "baserom.gbc", $d674, $da76 - $d674

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

INCBIN "baserom.gbc", $18000, $1a89f - $18000

; Loads common sprite palettes and the specified BG and
; sprite palettes. Also clears the BG map attributes.
; Input: hl = pointer to palette data structure
LoadCGBPalettes:
	ld a, [hGameBoyColorDetection]
	cp GBC_MODE
	ret nz
	ld a, (1 << 7) | $28
	ld [rOCPS], a
	ld de, CommonSpritePalettes
	ld b, 3 ; number of palettes
.commonSpritePaletteLoop
	ld c, 6 ; number of color bytes
	sub a
	ld [rOCPD], a ; First two bytes are the transparent color in the sprite palette.
	ld [rOCPD], a
.commonSpriteColorLoop
	ld a, [de]
	inc de
	ld [rOCPD], a
	dec c
	jr nz, .commonSpriteColorLoop
	dec b
	jr nz, .commonSpritePaletteLoop
	ld a, $80
	ld [rBCPS], a
	ld a, [hli]
	ld b, a ; number of palettes
.backgroundPaletteLoop
	ld a, b
	and a
	jr z, .loadSpritePalettes
	dec b
	ld c, 8
.backgroundColorLoop
	ld a, [hli]
	ld [rBCPD], a
	dec c
	jr nz, .backgroundColorLoop
	jr .backgroundPaletteLoop
.loadSpritePalettes
	ld a, $80
	ld [rOCPS], a
	ld a, [hli]
	ld b, a
.spritePaletteLoop
	ld a, b
	and a
	jr z, .clearBank1BGMap
	dec b
	ld c, 6 ; number of color bytes
	sub a
	ld [rOCPD], a ; First two bytes are the transparent color in the sprite palette.
	ld [rOCPD], a
.spriteColorLoop
	ld a, [hli]
	ld [rOCPD], a
	dec c
	jr nz, .spriteColorLoop
	jr .spritePaletteLoop
.clearBank1BGMap
	ld a, 1
	ld [rVBK], a
	ld hl, vBGMap
	ld bc, $800
.clearLoop
	sub a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .clearLoop
	sub a
	ld [rVBK], a
	ret

Func_1a902:
	ld h, b
	ld l, c
	ld a, $80
	ld [rBCPS], a
	ld a, [hli]
	ld b, a
.paletteLoop
	ld a, b
	and a
	jr z, .done
	dec b
	ld c, 8
.colorLoop
	ld a, [hli]
	ld [rBCPD], a
	dec c
	jr nz, .colorLoop
	jr .paletteLoop
.done
	call ReadAndLoadCGBpalettes
	pop hl
	ret

ReadAndLoadCGBpalettes:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp LoadCGBPalettesHome

INCBIN "baserom.gbc", $1a924, $1af18 - $1a924

; This only holds colors 1-3. The first transparent color is hardcoded
; in LoadCGBPalettes.
CommonSpritePalettes:
	; OBJ Palette 5
	RGB(31, 31, 31)
	RGB(14, 14, 14)
	RGB(0, 0, 0)

	; OBJ Palette 6
	RGB(31, 27, 0)
	RGB(19, 7, 0)
	RGB(0, 0, 0)

	; OBJ Palette 7
	RGB(31, 28, 20)
	RGB(31, 8, 0)
	RGB(0, 0, 0)

INCBIN "baserom.gbc", $1af2a, $1bcb0 - $1af2a

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

INCBIN "baserom.gbc", $24000, $27c51 - $24000

WarnerBrosCopyrightEdgeTiles:
	INCBIN "gfx/warner_bros_copyright/edge.2bpp.lz"

INCBIN "baserom.gbc", $27ced, $28000 - $27ced

SECTION "ROM Bank $0A", ROMX[$4000], BANK[$A]

INCBIN "baserom.gbc", $28000, $2C000 - $28000

SECTION "ROM Bank $0B", ROMX[$4000], BANK[$B]

INCBIN "baserom.gbc", $2C000, $30000 - $2C000

SECTION "ROM Bank $0C", ROMX[$4000], BANK[$C]

INCBIN "baserom.gbc", $30000, $34000 - $30000

SECTION "ROM Bank $0D", ROMX[$4000], BANK[$D]

INCBIN "baserom.gbc", $34000, $38000 - $34000

SECTION "ROM Bank $0E", ROMX[$4000], BANK[$E]

INCBIN "baserom.gbc", $38000, $3bd22 - $38000

WarnerBrosCopyrightBugsBunnyTiles:
	INCBIN "gfx/warner_bros_copyright/bugs_bunny.2bpp.lz"

InfogramesCopyrightTilemap:
	INCBIN "gfx/infogrames_copyright/background.tilemap.lz"

SECTION "ROM Bank $0F", ROMX[$4000], BANK[$F]

INCBIN "baserom.gbc", $3C000, $3fceb - $3C000

WarnerBrosCopyrightTiles:
	INCBIN "gfx/warner_bros_copyright/background.2bpp.lz"

INCBIN "baserom.gbc", $3ff8c, $40000 - $3ff8c

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
