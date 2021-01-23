SECTION "WRAM Bank 0", WRAM0

wRAMStart::

; Every 4-byte group is a metatile.
wMetatiles:: ; $c000
	ds $400

wMetatileCollisionAttributes:: ; $c400
	ds $100

wMetatileRowPointers:: ; $c500
	ds $100

wLevelMap:: ; $c600
	ds $a00

SECTION "WRAM Bank 1", WRAMX
	ds $500 ; wLevelMap continues until $d500

wLevelEntities:: ; $d500
	ds $400

	ds $100

wGBCTileAttributes:: ; $da00
	ds $100

	ds $42

wMusicPaused:: ; $db42
	ds 1

	ds $260

wAnimatedTilesPointer:: ; $dda3
	ds 2

	ds $3d

; $ff if in credits scene, $00 otherwise.
wInCreditsScene:: ; $dde2
	ds 1

	ds 5

; If this is set to non-zero, press start + select will skip the current level.
; This is enabled with a secret dev password. See data/passwords.asm
wEnableLevelSkip:: ; $dde8
	ds 1

; This holds the tile attribute (just the palette, really) for all the tiles in the
; HUD area during normal level gameplay.
wHUDTileAttribute:: ; $dde9
	ds 1

	ds $18

; Pointer to the current music command for the active sound effect.
wSoundEffectCommandPointer:: ; $de02
	ds 2

	ds $6

wSoundEffectDuration:: ; $de0a
	ds 1

	ds $1c

; ID of the active sound effect.
wActiveSoundEffect:: ; $de27
	ds 1

	ds $5e

wQueuedTileGfx:: ; $de86
	ds 16 * 3
wQueuedTileGfxEnd:: ; $deb6

	ds $31

wPasswordEntryCursor:: ; $dee7
	ds 1
wPasswordCharacters:: ; $dee8
	ds 3

; 0 = Easy Mode, $FF = Hard Mode
wDifficultySetting:: ; $deeb
	ds 1

; 0 = English, 1 = Spanish, 2 = French
wLanguageSetting:: ; $deec
	ds 1

	ds $c

wHeldKeys:: ; $def9
	ds 1
wNewKeys:: ; $defa
	ds 1

	ds 3

wDisableMusic:: ; $defe
	ds 1

wCurScreen:: ; $deff
	ds 1

wOAMBuffer:: ; $df00
	ds $a0
wOAMBufferEnd:: ; $dfa0

SECTION "Stack", WRAMX[$dfa0], BANK[1]
	ds $60
wStack:: ; $e000 echo
