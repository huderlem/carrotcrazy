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

SECTION "Entry", ROM0 [$100]

Func_100:
	nop
	jp Start


SECTION "Header", ROM0 [$104]

	; The header is generated by rgbfix.
	; The space here is allocated to prevent code from being overwritten.
	ds $150 - $104

SECTION "Main", ROM0

Start:
	ld [hGameBoyColorDetection], a
Start_:
	di
	ld sp, wStack
	ld a, Bank(ResetInitialData)
	ld [MBC5RomBank], a
	call ResetInitialData
	call ResetPlayerData
	call Func_3e31
	call SetInitialScreen
	jp InitNextScreen

INCBIN "baserom.gbc", $16a, $4f8 - $16a

InitInfogramesCopyrightScreen:
	call Func_fb4
	call Func_3dce
	call ResetFrameCounter
	sub a
	ld [rSCY], a
	ld [rSCX], a
	ld hl, InfogramesCopyrightScreenGBCPalettes
	call LoadCGBPalettesHome
	ld hl, vBGMap
	ld bc, $400
	call Func_10e9
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJOFF | LCDCF_BGON
	ld [rLCDC], a
.delayFrame
	call WaitVBlank
	call Func_3dc6
	call UpdateFrameCounter
	sub a
.delayNextVBlank
	dec a
	jr nz, .delayNextVBlank
	ld a, [hFrameCounter]
	and a
	jr nz, .delayFrame
	call Func_3ddc
	jr .delayFrame

InitWarnerBrosCopyrightScreen:
	call LoadWarnerBrosBannerQuadrants
	call Func_3e51
	call Func_3bb4
	call WriteDMACodeToHRAM
	call Func_3dce
	sub a
	ld [rSCY], a
	ld [rSCX], a
	ld hl, WarnerBrosCopyrightScreenGBCPalettes
	call LoadCGBPalettesHome
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_WINOFF | LCDCF_BG8800 | LCDCF_BG9800 | LCDCF_OBJ16 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
.asm_54e
	call Func_3dfb
	call Func_3a82
	call WaitVBlank
	ld a, [$deee]
	cp $c5
	jr nc, .asm_56c
	ld a, $05
	ld [MBC5RomBank], a
	ld hl, $7861
	ld bc, $5c39
	call Func_3ca6
.asm_56c
	call Func_3d96
	call Func_3dc6
	ld a, %10010000
	ld [rOBP0], a
	ld a, [$def2]
	and a
	jr nz, .asm_54e
	ld hl, $def6
	dec [hl]
	jr nz, .asm_54e
	call Func_3ddc
	jr .asm_54e

INCBIN "baserom.gbc", $587, $fb4 - $587

Func_fb4:
	ld bc, $da00
	ld de, $da80
.asm_fba
	ld a, [bc]
	ld [$ff8a], a
	ld a, [de]
	ld [bc], a
	inc c
	ld a, [$ff8a]
	ld [de], a
	inc e
	jr nz, .asm_fba
	ld bc, $d900
	ld de, $d980
.asm_fcc
	ld a, [bc]
	ld [$ff8a], a
	ld a, [de]
	ld [bc], a
	inc c
	ld a, [$ff8a]
	ld [de], a
	inc e
	jr nz, .asm_fcc
	ret

INCBIN "baserom.gbc", $fd9, $10e9 - $fd9

Func_10e9:
	ld a, [hGameBoyColorDetection]
	cp GBC_MODE
	ret nz
	ld d, $d9
.loop
	sub a
	ld [rVBK], a
	ld e, [hl]
	ld a, 1
	ld [rVBK], a
	ld a, [de]
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .loop
	sub a
	ld [rVBK], a
	ret

INCBIN "baserom.gbc", $1103, $322f - $1103

ResetPlayerData:
	ld a, [wDifficultySetting]
	ld bc, $505
	ld d, 4
	and a
	jr z, .setData
	ld bc, $404
	ld d, 3
.setData
	ld a, b
	ld [hCurHealth], a
	ld a, c
	ld [hMaxHealth], a
	ld a, d
	ld [hNumLives], a
	sub a
	ld [hScore], a
	ld [hScore + 1], a
	ret

INCBIN "baserom.gbc", $324e, $3a82 - $324e

Func_3a82:
	ld a, $05
	ld [MBC5RomBank], a
	ld hl, $731c
	ld bc, $0
	call Func_3ca6
	ld hl, $deed
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld [$ff8a], a
	ld a, [hli]
	add a
	jr nc, .asm_3ae5
.asm_3aa2
	call WaitHBlankStart
	ld a, [bc]
	inc c
	ld [de], a
	inc e
	ld a, [bc]
	ld [de], a
	ld hl, $f
	add hl, bc
	ld b, h
	ld c, l
	ld hl, $f
	add hl, de
	ld d, h
	ld e, l
	ld a, [$ff8a]
	dec a
	ld [$ff8a], a
	jr nz, .asm_3aa2
	ld hl, $def3
	dec [hl]
	jp z, .asm_3b4c
	ld hl, $deed
	ld a, c
	and $0f
	cp $0e
	jr nz, .asm_3ade
	ld a, c
	sub $0e
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, [hl]
	add $12
	ld [hli], a
	ld a, [hl]
	adc $01
	ld [hl], a
	ret
.asm_3ade
	inc [hl]
	inc [hl]
	inc l
	inc l
	inc [hl]
	inc [hl]
	ret
.asm_3ae5
	add a
	jr nc, .asm_3b54
	ld a, [hl]
	and $07
	add $8e
	ld l, a
	ld a, $73
	adc $00
	ld h, a
	ld a, [hl]
	ld [$ff8b], a
.asm_3af6
	call WaitHBlankStart
	ld a, [$ff8b]
	ld l, a
	cpl
	ld h, a
	push hl
	ld a, [bc]
	inc c
	and l
	ld l, a
	ld a, [de]
	and h
	or l
	ld [de], a
	inc e
	pop hl
	ld a, [bc]
	inc bc
	and l
	ld l, a
	ld a, [de]
	and h
	or l
	ld [de], a
	inc de
	ld a, c
	and $0f
	jr nz, .asm_3b28
	ld hl, $def4
	ld a, [hli]
	add c
	ld c, a
	ld a, [hl]
	adc b
	ld b, a
	ld a, e
	add $10
	ld e, a
	ld a, d
	adc $01
	ld d, a
.asm_3b28
	ld a, [$ff8a]
	dec a
	ld [$ff8a], a
	jr nz, .asm_3af6
	ld hl, $def3
	dec [hl]
	jr z, .asm_3b4c
	ld a, [hl]
	and $07
	ret nz
	ld hl, $deed
	ld bc, $10
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hli], a
	ld a, [hl]
	add c
	ld [hli], a
	ld a, [hl]
	adc b
	ld [hl], a
	ret
.asm_3b4c
	ld hl, $def2
	ld a, [hl]
	and $3f
	ld [hl], a
	ret
.asm_3b54
	add a
	ret nc
	ld hl, $def6
	dec [hl]
	ret nz
	inc l
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld bc, $deed
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, [hli]
	ld e, a
	swap a
	and $f0
	ld [$ff8e], a
	ld a, e
	swap a
	and $0f
	ld [$ff8f], a
	ld a, [hli]
	ld d, a
	bit 7, [hl]
	jr z, .asm_3b8c
	sla d
	sla d
	sla d
	ld a, e
	jr .asm_3b97
.asm_3b8c
	sla e
	sla e
	sla e
	ld a, d
	ld d, e
	add a
	add a
	add a
.asm_3b97
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, d
	ld [bc], a
	inc c
	ld a, [$ff8e]
	sub $10
	ld [bc], a
	inc c
	ld a, [$ff8f]
	sbc $00
	ld [bc], a
	inc c
	ld a, [hli]
	ld [bc], a
	inc c
	ld a, l
	ld [bc], a
	inc c
	ld a, h
	ld [bc], a
	ret

Func_3bb4:
	ld a, $06
	ld [MBC5RomBank], a
	ld a, [hli]
	ld [$def7], a
	ld a, [hli]
	ld [$def8], a
	push hl
	ld hl, vBGMap
	ld bc, $400
.asm_3bc8
	ld a, $7f
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, .asm_3bc8
	ld hl, $9841
	ld bc, $e
	ld a, $83
	ld d, $0e
.asm_3bda
	ld e, $12
.asm_3bdc
	ld [hli], a
	inc a
	dec e
	jr nz, .asm_3bdc
	add hl, bc
	dec d
	jr nz, .asm_3bda
	ld a, $05
	ld [MBC5RomBank], a
	ld hl, $def7
	ld a, [hli]
	ld h, [hl]
	ld l, a
.asm_3bf0
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld [$ff8a], a
	ld a, [hli]
	ld [$ff8b], a
	push hl
.asm_3bff
	ld a, [$ff8a]
	ld [$ff8c], a
.asm_3c03
	ld h, b
	ld l, c
.asm_3c05
	ld a, [hli]
	and a
	jr nz, .asm_3c19
	ld a, l
	and $0f
	jr nz, .asm_3c05
.asm_3c0e
	ld a, [de]
	inc de
	ld [bc], a
	inc bc
	ld a, c
	and $0f
	jr nz, .asm_3c0e
	jr .asm_3c25
.asm_3c19
	ld hl, $10
	add hl, bc
	ld b, h
	ld c, l
	ld hl, $10
	add hl, de
	ld d, h
	ld e, l
.asm_3c25
	ld a, [$ff8c]
	dec a
	ld [$ff8c], a
	jr nz, .asm_3c03
	ld a, [$ff8a]
	cpl
	inc a
	ld l, a
	ld h, $ff
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld de, $120
	add hl, de
	ld d, h
	ld e, l
	ld a, [$ff8b]
	dec a
	ld [$ff8b], a
	jr nz, .asm_3bff
	pop hl
	ld a, [hli]
	inc hl
	and $20
	jr nz, .asm_3bf0
	ld a, $20
	ld [$def2], a
	ld a, $3c
	ld [$def6], a
	pop hl
	ret

INCBIN "baserom.gbc", $3c58, $3ca6 - $3c58

Func_3ca6:
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push de
	ld a, [$ff93]
	ld e, a
	ld d, $df
	ret

INCBIN "baserom.gbc", $3cb1, $3d96 - $3cb1

Func_3d96:
	ld a, Bank(Func_175a6)
	ld [MBC5RomBank], a
	jp Func_175a6

WriteDMACodeToHRAM:
	ld hl, DMARoutine
	ld c, (hDMARoutine & $ff)
	ld b, 10
.loop
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, .loop
	ld hl, wOAMBuffer
	ld b, wOAMBufferEnd - wOAMBuffer
	sub a
.clear
	ld [hli], a
	dec b
	jr nz, .clear
	call hDMARoutine
	sub a
	ld [$ff93], a
	ret

DMARoutine:
	ld a, wOAMBuffer >> 8
	ld [rDMA], a
	ld a, $28
.waitLoop
	dec a
	jr nz, .waitLoop
	ret

Func_3dc6:
	ld a, Bank(Func_17568)
	ld [MBC5RomBank], a
	jp Func_17568

Func_3dce:
	call Func_3e3d
	ld a, Bank(Func_1759b)
	ld [MBC5RomBank], a
	ld bc, $1fd
	jp Func_1759b

Func_3ddc:
	ld a, [$defc]
	and a
	ret nz
	call Func_3e47
	ld a, Bank(Func_1759b)
	ld [MBC5RomBank], a
	ld bc, $ff0c
	jp Func_1759b

INCBIN "baserom.gbc", $3def, $3dfb - $3def

Func_3dfb:
	ld a, Bank(Func_804a)
	ld [MBC5RomBank], a
	jp Func_804a

INCBIN "baserom.gbc", $3e03, $3e13 - $3e03

Func_3e13:
	ld a, Bank(Func_8053)
	ld [MBC5RomBank], a
	jp Func_8053

INCBIN "baserom.gbc", $3e1b, $3e31 - $3e1b

Func_3e31:
	sub a
	ld [$defe], a
	ld a, Bank(Func_8059)
	ld [MBC5RomBank], a
	jp Func_8059

Func_3e3d:
	ld a, Bank(Func_805c)
	ld [MBC5RomBank], a
	ld a, $04
	jp Func_805c

Func_3e47:
	ld a, Bank(Func_805f)
	ld [MBC5RomBank], a
	ld a, $04
	jp Func_805f

Func_3e51:
	ld a, [$defe]
	and a
	jr z, .asm_3e5a
	inc hl
	inc hl
	ret
.asm_3e5a
	ld a, $06
	ld [MBC5RomBank], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push hl
	ld a, $02
	ld [MBC5RomBank], a
	ld de, $3e6f
	push de
	push bc
	ret

INCBIN "baserom.gbc", $3e6f, $3e8b - $3e6f

InitNextScreen:
	sub a
	ld [hPaused], a
	ld sp, wStack
	call Func_3e13
	call WriteDMACodeToHRAM
	call WaitUntilSafeToAccessVRAM
	ld hl, wCurScreen
	inc [hl]
	ld a, [hl]
	add a
	ld c, a
	ld b, $00
	ld a, [hGameBoyColorDetection]
	cp GBC_MODE
	ld hl, Data_1af94
	jr nz, .load
	ld hl, Data_1b030
.load
	add hl, bc
	ld a, Bank(Data_1af94)
	ld [MBC5RomBank], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jp z, Start_
	call LoadData
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	push bc
	ret

SetInitialScreen:
	sub a
	ld [wCurScreen], a
	ret

INCLUDE "home/load.asm"

INCBIN "baserom.gbc", $3ff1, $4000 - $3ff1

SECTION "ROM Bank $01", ROMX[$4000], BANK[$1]

INCBIN "baserom.gbc", $4000, $7dfc - $4000

ResetInitialData:
	call WaitUntilSafeToAccessVRAM
	sub a
	ld [rIF], a
	ld [$ffff], a
	ld [rSC], a
	ld [rTAC], a
	ld [rSTAT], a
	ld a, $30
	ld [rP1], a
	ld hl, vTilesOB
	ld bc, $2000
	call ClearData
	ld hl, wRAMStart
	ld bc, wStack - wRAMStart - 4
	call ClearData
	ld hl, _HRAM
	ld bc, $7e
	call ClearData
	sub a
	ld [$deec], a
	ld [wDifficultySetting], a
	ld [$deb6], a
	ld [$dde8], a
	ld hl, wPasswordCharacters
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

; Fills a data region with 0 values.
; Input: hl = destination
;        bc = number of bytes to clear
ClearData:
	sub a
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, ClearData
	ret

INCBIN "baserom.gbc", $7e45, $8000 - $7e45

SECTION "ROM Bank $02", ROMX[$4000], BANK[$2]

INCBIN "baserom.gbc", $8000, $804a - $8000

Func_804a:
	jp Func_80e6

INCBIN "baserom.gbc", $804d, $8053 - $804d

Func_8053:
	jp Func_853d

INCBIN "baserom.gbc", $8056, $8059 - $8056

Func_8059:
	jp Func_8522

Func_805c:
	jp Func_895d

Func_805f:
	jp Func_8957

INCBIN "baserom.gbc", $8062, $80e6 - $8062

Func_80e6:
	ld a, [$db42]
	and a
	jp nz, Func_81c1
	ld h, $db
	call Func_81de
	inc h
	call Func_81de
	inc h
	call Func_81de
	inc h
	call Func_81de
	call Func_8a7f
	ld hl, $db25
	ld l, $25
	ld e, [hl]
	inc l
	ld d, [hl]
	ld l, $05
	ld a, [hli]
	add e
	ld [$ff13], a
	ld a, [hli]
	adc d
	ld b, [hl]
	cp b
	jr z, Func_8122
	ld b, a
	ld [hl], a
	ld l, $33
	ld a, b
	ld c, [hl]
	inc c
	dec c
	jr z, Func_8131
	jp Func_8128
Func_8122:
	ld l, $33
	ld a, [hl]
	and a
	jr z, Func_8133
Func_8128:
	ld [hl], $00
	dec l
	ld a, [hl]
	ld [$ff12], a
	ld a, b
	or $80
Func_8131:
	ld [$ff14], a
Func_8133:
	inc h
	ld l, $25
	ld e, [hl]
	inc l
	ld d, [hl]
	ld l, $05
	ld a, [hli]
	add e
	ld [$ff18], a
	ld a, [hli]
	adc d
	ld b, [hl]
	cp b
	jr z, .asm_8152
	ld b, a
	ld [hl], a
	ld l, $33
	ld a, b
	ld c, [hl]
	inc c
	dec c
	jr z, Func_8161
	jp Func_8158
.asm_8152
	ld l, $33
	ld a, [hl]
	and a
	jr z, Func_asm_8163
Func_8158:
	ld [hl], $00
	dec l
	ld a, [hl]
	ld [$ff17], a
	ld a, b
	or $80
Func_8161
	ld [$ff19], a
Func_asm_8163
	ld hl, $de27
	ld a, [hl]
	and a
	jr nz, Func_816b
	dec h
Func_816b:
	ld l, $25
	ld e, [hl]
	inc l
	ld d, [hl]
	ld l, $05
	ld a, [hli]
	add e
	ld [$ff1d], a
	ld a, [hli]
	adc d
	cp [hl]
	jr z, .asm_817e
	ld [$ff1e], a
	ld [hl], a
.asm_817e
	inc l
	ld a, [hl]
	add $ce
	ld l, a
	adc $41
	sub l
	ld h, a
	ld a, [$db44]
	cp [hl]
	jr z, Func_8193
	ld a, [hl]
	ld [$db44], a
	ld [$ff1c], a
Func_8193:
	ld hl, $db38
	ld c, [hl]
	inc h
	ld a, [hl]
	rlc a
	or c
	ld c, a
	inc h
	ld a, [$de27]
	and a
	jr z, .asm_81a5
	inc h
.asm_81a5
	ld l, $38
	ld a, [hl]
	rlc a
	rlc a
	or c
	ld c, a
	ld a, [$db46]
	or c
	ld c, a
	ld a, [$db43]
	and a
	ld a, c
	jr nz, .asm_81bc
	ld a, $ff
.asm_81bc
	ld [$ff25], a
	jp Func_86ca

Func_81c1:
	call Func_86ca
	ld h, $de
	call Func_81de
	call Func_816b
	jr Func_8193

INCBIN "baserom.gbc", $81ce, $81de - $81ce

Func_81de:
	ld l, $27
	ld a, [hl]
	and a
	ret z
	ld l, $2f
	ld a, [hl]
	and a
	call nz, Func_866d
	ld l, $2c
	ld a, [hl]
	and a
	call nz, Func_863c
	ld l, $02
	ld e, [hl]
	inc l
	ld d, [hl]
	ld l, $0a
	dec [hl]
	call z, $427f
	ld l, $04
	bit 0, [hl]
	jr nz, .asm_8266
.asm_8202
	ld l, $0b
	ld a, [hli]
	add [hl]
	ld [hli], a
	add [hl]
	inc l
	add [hl]
	inc l
	add [hl]
	cp $50
	jr c, .asm_8211
	xor a
.asm_8211
	add a
	ld c, a
	ld b, $48
	ld l, $05
	ld a, [bc]
	inc c
	ld [hli], a
	ld a, [bc]
	ld [hl], a
	call $48a2
	call $4447
	ld l, $04
	bit 3, [hl]
	ret z
	ld l, $21
	ld a, [hl]
	and a
	jr z, .asm_822f
	dec [hl]
	ret
.asm_822f
	ld l, $04
	bit 4, [hl]
	jr z, .asm_824c
	ld l, $23
	dec [hl]
	jr nz, .asm_8242
	inc l
	ld a, [hld]
	ld [hl], a
	ld l, $04
	res 4, [hl]
	ret
.asm_8242
	ld l, $22
	ld a, [hl]
	ld l, $25
	add [hl]
	ld [hli], a
	ret nc
	inc [hl]
	ret
.asm_824c
	ld l, $23
	dec [hl]
	jr nz, .asm_8259
	inc l
	ld a, [hld]
	ld [hl], a
	ld l, $04
	set 4, [hl]
	ret
.asm_8259
	ld l, $22
	ld c, [hl]
	ld l, $25
	ld a, [hl]
	sub c
	ld [hli], a
	ret nc
	dec [hl]
	ret
.asm_8264
	ld [hl], $00
.asm_8266
	ld l, $1d
	ld a, [hli]
	ld b, [hl]
	inc l
	add [hl]
	ld c, a
	jr nc, .asm_8270
	inc b
.asm_8270
	ld a, [bc]
	cp $6a
	jr z, .asm_8264
	cp $ff
	jr z, .asm_8202
	inc [hl]
	ld l, $0e
	ld [hl], a
	jr .asm_8202

INCBIN "baserom.gbc", $827f, $8522 - $827f

Func_8522:
	ld a, $ff
	ld [rNR52], a
	ld a, $70
	ld [$db4b], a
	ld a, $c5
	ld [$db4a], a
	xor a
	ld [$db45], a
	ld [$db42], a
	ld [$db47], a
	ld [$db5d], a
Func_853d:
	ld a, $70
	ld [$db49], a
	ld a, $20
	ld [$db48], a
	xor a
	ld [rNR12], a
	ld [rNR22], a
	ld [rNR32], a
	ld [rNR42], a
	ld [rNR14], a
	ld [rNR24], a
	ld [rNR34], a
	ld [rNR44], a
	ld [$db65], a
	ld [$db52], a
	ld [$db5c], a
	ld a, $88
	ld [$db46], a
	ld a, $77
	ld [rNR50], a
	ld h, $db
	call .asm_857b
	inc h
	call .asm_857b
	inc h
	call .asm_857b
	inc h
	jr .asm_857b
	pop af
.asm_857b
	ld a, h
	cp $de
	jr z, .asm_85aa
	xor a
	ld l, $38
	ld [hl], $11
	dec l
	ld [hl], a
	ld l, $27
	ld [hl], a
	ld l, $08
	ld [hl], a
	ld l, $04
	ld [hl], a
	ld l, $2f
	ld [hl], a
	ld l, $2c
	ld [hl], a
	ld l, $37
	ld [hl], a
	ld l, $0f
	ld [hld], a
	ld [hld], a
	ld [hl], $f4
	dec l
	dec l
	ld [hld], a
	inc a
	ld [hl], a
	ld l, $33
	ld [hld], a
	dec a
	ld [hl], a
	ret
.asm_85aa
	xor a
	ld [$de27], a
	ld [$de08], a
	ld [$db5e], a
	ld [$db5f], a
	dec a
	ld [$db44], a
	jp Func_876e

INCBIN "baserom.gbc", $85be, $863c - $85be

Func_863c:
	ld l, $2d
	dec [hl]
	ret nz
	ld l, $2c
	ld a, [hli]
	ld [hli], a
	ld a, [hl]
	inc a
	ld [hl], a
	dec a
	jr z, .asm_8655
	dec a
	jr z, .asm_865a
	dec a
	jr z, .asm_8655
	dec a
	jr z, .asm_865f
	ld [hl], $01
.asm_8655
	ld l, $38
	ld [hl], $11
	ret
.asm_865a
	ld l, $38
	ld [hl], $01
	ret
.asm_865f
	ld l, $38
	ld [hl], $10
	ret

INCBIN "baserom.gbc", $8664, $866d - $8664

Func_866d:
	ld l, $30
	dec [hl]
	ret nz
	ld l, $2f
	ld a, [hli]
	ld [hli], a
	ld a, [hl]
	inc a
	ld [hl], a
	dec a
	jr z, .asm_8686
	dec a
	jr z, .asm_868a
	dec a
	jr z, .asm_868e
	dec a
	jr z, .asm_868a
	ld [hl], $01
.asm_8686
	ld l, $80
	jr .asm_8690
.asm_868a
	ld l, $c0
	jr .asm_8690
.asm_868e
	ld l, $00
.asm_8690
	ld a, h
	cp $db
	jr nz, .asm_8699
	ld a, l
	ld [rNR11], a
	ret
.asm_8699
	ld a, l
	ld [rNR21], a
	ret

Func_869d:
	ld [$db64], a
	ld a, l
	ld [$db60], a
	ld a, h
	ld [$db61], a
	jr .asm_86b9
	ld a, [de]
	ld [$db64], a
	inc de
	ld a, [de]
	ld [$db60], a
	inc de
	ld a, [de]
	ld [$db61], a
	inc de
.asm_86b9
	xor a
	ld [$db62], a
	ld [$db63], a
	inc a
	ld [$db65], a
	ret

Func_86c5:
	xor a
	ld [$db65], a
	ret

Func_86ca:
	ld a, [$db65]
	and a
	jr nz, .asm_86d9
	ld a, [rNR50]
	and a
	ret z
	ld a, $77
	ld [rNR50], a
	ret
.asm_86d9
	ld a, [$db63]
	and a
	jr z, .asm_86e4
	dec a
	ld [$db63], a
	ret
.asm_86e4
	ld hl, $db60
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [$db62]
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	cp $6a
	jr z, .asm_870b
	cp $ff
	jr z, Func_86c5
	ld [rNR50], a
	ld a, [$db62]
	inc a
	ld [$db62], a
	ld a, [$db64]
	ld [$db63], a
	ret
.asm_870b
	xor a
	ld [$db62], a
	jr .asm_86e4

INCBIN "baserom.gbc", $8711, $876e - $8711

Func_876e:
	xor a
	ld [rNR30], a
	ld c, (_AUD3WAVERAM & $ff)
	ld hl, $db4c
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	ld a, [hl]
	ld [$ff00+c], a
	ld a, [$db42]
	and a
	ret nz
	ld a, $80
	ld [$dd07], a
	ld [rNR30], a
	ld [rNR34], a
	ret

INCBIN "baserom.gbc", $87b7, $8957 - $87b7

Func_8957:
	ld hl, $77ee
	jp Func_869d

Func_895d:
	ld hl, $77f7
	jp Func_869d

INCBIN "baserom.gbc", $8963, $8a7f - $8963

Func_8a7f:
	ld a, [$db47]
	and a
	jr z, .asm_8a89
	dec a
	ld [$db47], a
.asm_8a89
	ld hl, $db54
	dec [hl]
	call z, $4994
	ld a, [$db5c]
	and a
	ret z
	ld a, [$db5e]
	and a
	jr z, .asm_8aa0
	dec a
	ld [$db5e], a
	ret
.asm_8aa0
	ld a, [$db5f]
	ld [$db5e], a
	ld a, [$db57]
	ld h, a
	ld a, [$db58]
	ld l, a
	ld a, [$db5b]
	ld e, a
	inc a
	ld [$db5b], a
	ld d, $00
	add hl, de
	ld a, [hl]
	cp $ff
	jr z, .asm_8b1b
	ld [$ff22], a
	ld a, [$db59]
	and a
	jr z, .asm_8aea
	ld h, a
	ld a, [$db5a]
	ld l, a
	add hl, de
	ld c, $00
	ld a, [$db47]
	and a
	jr nz, .asm_8ad8
	ld a, [$db5d]
	ld c, a
.asm_8ad8
	ld a, [hl]
	cp $ff
	jr z, .asm_8aea
	swap c
	sub c
	jr nc, .asm_8ae4
	and $0f
.asm_8ae4
	ld [rNR42], a
	ld a, $80
	ld [rNR44], a
.asm_8aea
	ld a, [$db47]
	and a
	ret nz
	ld a, [$db4e]
	and a
	ret z
	ld b, a
	ld a, [$db5b]
	dec a
	jr nz, .asm_8b01
	ld a, $88
	ld [$db46], a
	ret
.asm_8b01
	sub b
	jr nz, .asm_8b0a
	ld a, $08
	ld [$db46], a
	ret
.asm_8b0a
	sub b
	jr nz, .asm_8b13
	ld a, $80
	ld [$db46], a
	ret
.asm_8b13
	sub b
	ret nz
	ld a, $88
	ld [$db46], a
	ret
.asm_8b1b
	xor a
	ld [$db5b], a
	ld [$db5c], a
	ret

INCBIN "baserom.gbc", $8b23, $C000 - $8b23

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

INCBIN "baserom.gbc", $dc9f, $f545 - $dc9f

WarnerBrosCopyrightAmpersandTiles:
	INCBIN "gfx/warner_bros_copyright/ampersand.2bpp"

INCBIN "baserom.gbc", $f585, $10000 - $f585

SECTION "ROM Bank $04", ROMX[$4000], BANK[$4]

INCBIN "baserom.gbc", $10000, $14000 - $10000

SECTION "ROM Bank $05", ROMX[$4000], BANK[$5]

INCBIN "baserom.gbc", $14000, $16e8c - $14000

INCLUDE "data/passwords.asm"

INCBIN "baserom.gbc", $16eab, $17568 - $16eab

Func_17568:
	ld a, [hPaused]
	and a
	ret nz
Func_1756c:
	ld hl, $defb
	dec [hl]
	ret nz
	ld a, $08
	ld [hli], a
	ld a, [hli]
	add a
	ld a, [hl]
	jr c, .asm_17586
	ret z
	add a, $03
	cp $0c
	jr nz, .asm_17589
	dec l
	sub a
	ld [hl], a
	ret
.asm_17586
	sub $03
	jp c, InitNextScreen
.asm_17589
	ld [hl], a
	ld hl, $3def
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hli]
	ld [rBGP], a
	ld a, [hli]
	ld [rOBP0], a
	ld a, [hl]
	ld [rOBP1], a
	ret

Func_1759b:
	ld hl, $defb
	ld a, $01
	ld [hli], a
	ld a, b
	ld [hli], a
	ld [hl], c
	jr Func_1756c

Func_175a6:
	ld a, [hPaused]
	and a
	ret nz
	call hDMARoutine
	ld a, [$ff93]
	cp $a1
	jr c, .asm_175b5
	ld a, $a0
.asm_175b5
	srl a
	srl a
	ld b, a
	add a
	add b
	sub $79
	cpl
	ld hl, .asm_175c8
	ld c, a
	ld b, $00
	add hl, bc
	sub a
	jp hl
.asm_175c8
	ld [$df9c], a
	ld [$df98], a
	ld [$df94], a
	ld [$df90], a
	ld [$df8c], a
	ld [$df88], a
	ld [$df84], a
	ld [$df80], a
	ld [$df7c], a
	ld [$df78], a
	ld [$df74], a
	ld [$df70], a
	ld [$df6c], a
	ld [$df68], a
	ld [$df64], a
	ld [$df60], a
	ld [$df5c], a
	ld [$df58], a
	ld [$df54], a
	ld [$df50], a
	ld [$df4c], a
	ld [$df48], a
	ld [$df44], a
	ld [$df40], a
	ld [$df3c], a
	ld [$df38], a
	ld [$df34], a
	ld [$df30], a
	ld [$df2c], a
	ld [$df28], a
	ld [$df24], a
	ld [$df20], a
	ld [$df1c], a
	ld [$df18], a
	ld [$df14], a
	ld [$df10], a
	ld [$df0c], a
	ld [$df08], a
	ld [$df04], a
	ld [$df00], a
	ld [$ff93], a
	ret

INCBIN "baserom.gbc", $17643, $17dd6 - $17643

SECTION "ROM Bank $06", ROMX[$4000], BANK[$6]

INCBIN "baserom.gbc", $18000, $1a5a3 - $18000

WarnerBrosCopyrightInteractiveEntertainmentTiles:
	INCBIN "gfx/warner_bros_copyright/interactive_entertainment.2bpp"

INCBIN "baserom.gbc", $1a663, $1a89f - $1a663

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

INCBIN "baserom.gbc", $1a924, $1a93a - $1a924

InfogramesCopyrightScreenGBCPalettes:
	db 8 ; num background palettes
	; BG Palette 0
	RGB(0, 0, 0)
	RGB(10, 10, 10)
	RGB(21, 21, 21)
	RGB(31, 31, 31)

	; BG Palette 1
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)

	; BG Palette 2
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)

	; BG Palette 3
	RGB(31, 31, 31)
	RGB(28, 0, 0)
	RGB(31, 31, 0)
	RGB(21, 0, 22)

	; BG Palette 4
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)
	RGB(0, 31, 0)

	; BG Palette 5
	RGB(0, 31, 0)
	RGB(31, 31, 31)
	RGB(16, 0, 16)
	RGB(0, 0, 0)

	; BG Palette 6
	RGB(31, 31, 31)
	RGB(0, 23, 0)
	RGB(0, 0, 23)
	RGB(0, 0, 0)

	; BG Palette 7
	RGB(31, 31, 31)
	RGB(0, 23, 0)
	RGB(31, 31, 0)
	RGB(0, 0, 23)

	db 0 ; num sprite palettes

WarnerBrosCopyrightScreenGBCPalettes:
	db 1 ; num background palettes
	; BG Palette 0
	RGB(31, 31, 31)
	RGB(31, 0, 0)
	RGB(15, 0, 0)
	RGB(7, 0, 0)

	db 2 ; num sprite palettes
	; OBJ Palette 0
	RGB(31, 0, 0)
	RGB(15, 0, 0)
	RGB(7, 0, 0)

	; OBJ Palette 1
	RGB(31, 31, 0)
	RGB(23, 8, 0)
	RGB(4, 4, 15)

INCBIN "baserom.gbc", $1a992, $1af18 - $1a992

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

INCBIN "baserom.gbc", $1af2a, $1af94 - $1af2a

Data_1af94:
	dw $ffff
	dw Data_1b0cc ; SCREEN_COPYRIGHT_INFOGRAMES
	dw Data_1b0d9 ; SCREEN_COPYRIGHT_WARNER_BROS
	dw $7129 ; SCREEN_LANGUAGE_SELECT
	dw $716f ; SCREEN_TITLESCREEN
	dw $7147 ; SCREEN_OPTIONS
	dw $7194 ; SCREEN_INTRO_SCENE
	dw $72ee ; SCREEN_STUDIO_ENTRANCE
	dw $71fc ; SCREEN_TREASURE_ISLAND_1_INTRO
	dw $73b6 ; SCREEN_TREASURE_ISLAND_1
	dw $7722 ; SCREEN_TREASURE_ISLAND_1_SUMMARY
	dw $7794 ; SCREEN_TREASURE_ISLAND_1_BONUS
	dw $720d ; SCREEN_TREASURE_ISLAND_2_INTRO
	dw $73ed ; SCREEN_TREASURE_ISLAND_2
	dw $7722 ; SCREEN_TREASURE_ISLAND_2_SUMMARY
	dw $779b ; SCREEN_TREASURE_ISLAND_2_BONUS
	dw $721e ; SCREEN_TREASURE_ISLAND_BOSS_INTRO
	dw $7472 ; SCREEN_TREASURE_ISLAND_BOSS
	dw $7722 ; SCREEN_TREASURE_ISLAND_BOSS_SUMMARY
	dw $77a2 ; SCREEN_TREASURE_ISLAND_BOSS_BONUS
	dw $7710 ; SCREEN_PASSWORD_1
	dw $7300 ; SCREEN_STUDIO_TREASURE_ISLAND
	dw $71c9 ; SCREEN_CRAZY_TOWN_1_INTRO
	dw $7348 ; SCREEN_CRAZY_TOWN_1
	dw $7722 ; SCREEN_CRAZY_TOWN_1_SUMMARY
	dw $77a9 ; SCREEN_CRAZY_TOWN_1_BONUS
	dw $71da ; SCREEN_CRAZY_TOWN_2_INTRO
	dw $737f ; SCREEN_CRAZY_TOWN_2
	dw $7722 ; SCREEN_CRAZY_TOWN_2_SUMMARY
	dw $77b0 ; SCREEN_CRAZY_TOWN_2_BONUS
	dw $71eb ; SCREEN_CRAZY_TOWN_BOSS_INTRO
	dw $7424 ; SCREEN_CRAZY_TOWN_BOSS
	dw $7722 ; SCREEN_CRAZY_TOWN_BOSS_SUMMARY
	dw $77b7 ; SCREEN_CRAZY_TOWN_BOSS_BONUS
	dw $7312 ; SCREEN_STUDIO_CRAZY_TOWN
	dw $722f ; SCREEN_TAZ_ZOO_1_INTRO
	dw $74c0 ; SCREEN_TAZ_ZOO_1
	dw $7722 ; SCREEN_TAZ_ZOO_1_SUMMARY
	dw $77be ; SCREEN_TAZ_ZOO_1_BONUS
	dw $7240 ; SCREEN_TAZ_ZOO_2_INTRO
	dw $74f7 ; SCREEN_TAZ_ZOO_2
	dw $7722 ; SCREEN_TAZ_ZOO_2_SUMMARY
	dw $77c5 ; SCREEN_TAZ_ZOO_2_BONUS
	dw $7251 ; SCREEN_TAZ_ZOO_BOSS_INTRO
	dw $752e ; SCREEN_TAZ_ZOO_BOSS
	dw $7722 ; SCREEN_TAZ_ZOO_BOSS_SUMMARY
	dw $77cc ; SCREEN_TAZ_ZOO_BOSS_BONUS
	dw $7719 ; SCREEN_PASSWORD_2
	dw $7324 ; SCREEN_STUDIO_TAZ_ZOO
	dw $7262 ; SCREEN_SPACE_STATION_1_INTRO
	dw $7588 ; SCREEN_SPACE_STATION_1
	dw $7722 ; SCREEN_SPACE_STATION_1_SUMMARY
	dw $77d3 ; SCREEN_SPACE_STATION_1_BONUS
	dw $7273 ; SCREEN_SPACE_STATION_2_INTRO
	dw $75bf ; SCREEN_SPACE_STATION_2
	dw $7722 ; SCREEN_SPACE_STATION_2_SUMMARY
	dw $77da ; SCREEN_SPACE_STATION_2_BONUS
	dw $7284 ; SCREEN_SPACE_STATION_BOSS_INTRO
	dw $75f6 ; SCREEN_SPACE_STATION_BOSS
	dw $7722 ; SCREEN_SPACE_STATION_BOSS_SUMMARY
	dw $77e1 ; SCREEN_SPACE_STATION_BOSS_BONUS
	dw $7336 ; SCREEN_STUDIO_SPACE_STATION
	dw $7295 ; SCREEN_FUDD_FOREST_1_INTRO
	dw $7638 ; SCREEN_FUDD_FOREST_1
	dw $7722 ; SCREEN_FUDD_FOREST_1_SUMMARY
	dw $77e8 ; SCREEN_FUDD_FOREST_1_BONUS
	dw $72a6 ; SCREEN_FUDD_FOREST_2_INTRO
	dw $766f ; SCREEN_FUDD_FOREST_2
	dw $7722 ; SCREEN_FUDD_FOREST_2_SUMMARY
	dw $77ef ; SCREEN_FUDD_FOREST_2_BONUS
	dw $72b7 ; SCREEN_FUDD_FOREST_BOSS_INTRO
	dw $76a6 ; SCREEN_FUDD_FOREST_BOSS
	dw $7722 ; SCREEN_FUDD_FOREST_BOSS_SUMMARY
	dw $7764 ; SCREEN_PROLOGUE_SCENE
	dw $777d ; SCREEN_CREDITS
	dw $0000
	dw $7113 ; SCREEN_GAME_OVER
	dw $0000

Data_1b030:
	dw $ffff
	dw Data_1bcb0 ; SCREEN_COPYRIGHT_INFOGRAMES
	dw Data_1b0d9 ; SCREEN_COPYRIGHT_WARNER_BROS
	dw $7129 ; SCREEN_LANGUAGE_SELECT
	dw $7c63 ; SCREEN_TITLESCREEN
	dw $7147 ; SCREEN_OPTIONS
	dw $7c8d ; SCREEN_INTRO_SCENE
	dw $72ee ; SCREEN_STUDIO_ENTRANCE
	dw $71fc ; SCREEN_TREASURE_ISLAND_1_INTRO
	dw $7891 ; SCREEN_TREASURE_ISLAND_1
	dw $7722 ; SCREEN_TREASURE_ISLAND_1_SUMMARY
	dw $7794 ; SCREEN_TREASURE_ISLAND_1_BONUS
	dw $720d ; SCREEN_TREASURE_ISLAND_2_INTRO
	dw $78cd ; SCREEN_TREASURE_ISLAND_2
	dw $7722 ; SCREEN_TREASURE_ISLAND_2_SUMMARY
	dw $779b ; SCREEN_TREASURE_ISLAND_2_BONUS
	dw $721e ; SCREEN_TREASURE_ISLAND_BOSS_INTRO
	dw $79d9 ; SCREEN_TREASURE_ISLAND_BOSS
	dw $7722 ; SCREEN_TREASURE_ISLAND_BOSS_SUMMARY
	dw $77a2 ; SCREEN_TREASURE_ISLAND_BOSS_BONUS
	dw $7710 ; SCREEN_PASSWORD_1
	dw $7300 ; SCREEN_STUDIO_TREASURE_ISLAND
	dw $71c9 ; SCREEN_CRAZY_TOWN_1_INTRO
	dw $7819 ; SCREEN_CRAZY_TOWN_1
	dw $7722 ; SCREEN_CRAZY_TOWN_1_SUMMARY
	dw $77a9 ; SCREEN_CRAZY_TOWN_1_BONUS
	dw $71da ; SCREEN_CRAZY_TOWN_2_INTRO
	dw $7855 ; SCREEN_CRAZY_TOWN_2
	dw $7722 ; SCREEN_CRAZY_TOWN_2_SUMMARY
	dw $77b0 ; SCREEN_CRAZY_TOWN_2_BONUS
	dw $71eb ; SCREEN_CRAZY_TOWN_BOSS_INTRO
	dw $7909 ; SCREEN_CRAZY_TOWN_BOSS
	dw $7722 ; SCREEN_CRAZY_TOWN_BOSS_SUMMARY
	dw $77b7 ; SCREEN_CRAZY_TOWN_BOSS_BONUS
	dw $7312 ; SCREEN_STUDIO_CRAZY_TOWN
	dw $722f ; SCREEN_TAZ_ZOO_1_INTRO
	dw $7961 ; SCREEN_TAZ_ZOO_1
	dw $7722 ; SCREEN_TAZ_ZOO_1_SUMMARY
	dw $77be ; SCREEN_TAZ_ZOO_1_BONUS
	dw $7240 ; SCREEN_TAZ_ZOO_2_INTRO
	dw $799d ; SCREEN_TAZ_ZOO_2
	dw $7722 ; SCREEN_TAZ_ZOO_2_SUMMARY
	dw $77c5 ; SCREEN_TAZ_ZOO_2_BONUS
	dw $7251 ; SCREEN_TAZ_ZOO_BOSS_INTRO
	dw $7bcd ; SCREEN_TAZ_ZOO_BOSS
	dw $7722 ; SCREEN_TAZ_ZOO_BOSS_SUMMARY
	dw $77cc ; SCREEN_TAZ_ZOO_BOSS_BONUS
	dw $7719 ; SCREEN_PASSWORD_2
	dw $7324 ; SCREEN_STUDIO_TAZ_ZOO
	dw $7262 ; SCREEN_SPACE_STATION_1_INTRO
	dw $7a35 ; SCREEN_SPACE_STATION_1
	dw $7722 ; SCREEN_SPACE_STATION_1_SUMMARY
	dw $77d3 ; SCREEN_SPACE_STATION_1_BONUS
	dw $7273 ; SCREEN_SPACE_STATION_2_INTRO
	dw $7a71 ; SCREEN_SPACE_STATION_2
	dw $7722 ; SCREEN_SPACE_STATION_2_SUMMARY
	dw $77da ; SCREEN_SPACE_STATION_2_BONUS
	dw $7284 ; SCREEN_SPACE_STATION_BOSS_INTRO
	dw $7aad ; SCREEN_SPACE_STATION_BOSS
	dw $7722 ; SCREEN_SPACE_STATION_BOSS_SUMMARY
	dw $77e1 ; SCREEN_SPACE_STATION_BOSS_BONUS
	dw $7336 ; SCREEN_STUDIO_SPACE_STATION
	dw $7295 ; SCREEN_FUDD_FOREST_1_INTRO
	dw $7afb ; SCREEN_FUDD_FOREST_1
	dw $7722 ; SCREEN_FUDD_FOREST_1_SUMMARY
	dw $77e8 ; SCREEN_FUDD_FOREST_1_BONUS
	dw $72a6 ; SCREEN_FUDD_FOREST_2_INTRO
	dw $7b37 ; SCREEN_FUDD_FOREST_2
	dw $7722 ; SCREEN_FUDD_FOREST_2_SUMMARY
	dw $77ef ; SCREEN_FUDD_FOREST_2_BONUS
	dw $72b7 ; SCREEN_FUDD_FOREST_BOSS_INTRO
	dw $7b73 ; SCREEN_FUDD_FOREST_BOSS
	dw $7722 ; SCREEN_FUDD_FOREST_BOSS_SUMMARY
	dw $7cc2 ; SCREEN_PROLOGUE_SCENE
	dw $777d ; SCREEN_CREDITS
	dw $0000
	dw $7113 ; SCREEN_GAME_OVER
	dw $0000

Data_1b0cc:
	compressed_data InfogramesCopyrightTiles, $9550
	compressed_data InfogramesCopyrightTilemap, $9800
	db $ff
	dw InitInfogramesCopyrightScreen

Data_1b0d9:
	compressed_data WarnerBrosCopyrightTiles, $8830
	compressed_data WarnerBrosCopyrightEdgeTiles, $8000
	uncompressed_data WarnerBrosCopyrightUnderLicenseByTiles, $c000, $80
	uncompressed_data WarnerBrosCopyrightInteractiveEntertainmentTiles, $c080, $c0
	compressed_data WarnerBrosCopyrightTrademarkTiles, $c200
	compressed_data WarnerBrosCopyrightBugsBunnyTiles, $c560
	uncompressed_data WarnerBrosCopyrightAmpersandTiles, $c8e0, $40
	compressed_data WarnerBrosCopyrightLolaBunnyTiles, $c920
	compressed_data WarnerBrosCopyrightLogoTiles, $81C0
	db $ff
	dw InitWarnerBrosCopyrightScreen

INCBIN "baserom.gbc", $1b10f, $1bcb0 - $1b10f

Data_1bcb0:
	compressed_data InfogramesCopyrightGBCTiles, $9550
	compressed_data InfogramesCopyrightGBCTilemap, $9800
	compressed_data InfogramesCopyrightGBCAttributesTilemap, $d9d5
	db $ff
	dw InitInfogramesCopyrightScreen

INCBIN "baserom.gbc", $1bcc2, $1c000 - $1bcc2

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

INCBIN "baserom.gbc", $28000, $2bf2a - $28000

WarnerBrosCopyrightUnderLicenseByTiles:
	INCBIN "gfx/warner_bros_copyright/under_license_by.2bpp"

INCBIN "baserom.gbc", $2bfaa, $2C000 - $2bfaa

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
