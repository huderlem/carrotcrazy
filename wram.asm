SECTION "WRAM Bank 0", WRAM0

	ds $1000

SECTION "WRAM Bank 1", WRAMX

	ds $ee7

wPasswordEntryCursor:: ; $dee7
	ds 1
wPasswordCharacters:: ; $dee8
	ds 3

	ds $14

wCurScreen:: ; $deff
	ds 1
