dbw: MACRO
	db \1
	dw \2
	ENDM

dwb: MACRO
	dw \1
	db \2
	ENDM

dba: MACRO
	dbw BANK(\1), \1
	ENDM

dab: MACRO
	dwb \1, BANK(\1)
	ENDM

dn: MACRO
	rept _NARG / 2
	db (\1) << 4 + (\2)
	shift
	shift
	endr
	ENDM

dx: MACRO
x = 8 * ((\1) - 1)
	rept \1
	db ((\2) >> x) & $ff
x = x + -8
	endr
	ENDM

bigdw: MACRO ; big-endian word
	dx 2, \1
	ENDM

RGB: MACRO
	dw (\3 << 10 | \2 << 5 | \1)
	ENDM

; \1: source data
; \2: destination
compressed_data: MACRO
	db Bank(\1)
	dw \1
	dw \2
	ENDM

; \1: source data
; \2: destination
; \3: num bytes
uncompressed_data: MACRO
	db Bank(\1)
	dw \1
	dw \3
	dw \2
	ENDM
