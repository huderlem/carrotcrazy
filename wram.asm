SECTION "WRAM Bank 0", WRAM0

wRAMStart::

; Every 4-byte group is a metatile.
wMetatiles:: ; $c000
	ds $400

	ds $100

wMetatileRowPointers:: ; $c500
	ds $100

wLevelMap:: ; $c600
	ds $a00

SECTION "WRAM Bank 1", WRAMX
	ds $500 ; wLevelMap continues until $d500

wd500:
	ds $500

wGBCTileAttributes:: ; $da00
	ds $100

	ds $2e2

; $ff if in credits scene, $00 otherwise.
wInCreditsScene:: ; $dde2
	ds 1

	ds 5

; If this is set to non-zero, press start + select will skip the current level.
; This is enabled with a secret dev password. See data/passwords.asm
wEnableLevelSkip:: ; $dde8
	ds 1

	ds $fe

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

	ds 4

wCurScreen:: ; $deff
	ds 1

wOAMBuffer:: ; $df00
	ds $a0
wOAMBufferEnd:: ; $dfa0

SECTION "Stack", WRAMX[$dfa0], BANK[1]
	ds $60
wStack:: ; $e000 echo
