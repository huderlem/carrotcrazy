; Load uncompressed or compressed data according to the
; given data table located at register hl.
;
; Uncompressed Data Item Format:
;     db source bank
;     dw source address
;     dw number of bytes to load (low 15 bits are the value, highest bit must be set)
;     dw destination address
;
; Compressed Data Item Format:
;     db source bank
;     dw source address
;     dw destination address (highest bit must be reset)
LoadData:
	ld a, $06
	ld [MBC5RomBank], a
	ld a, [hli]
	cp $ff
	ret z
	ld [$ff8a], a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	bit 7, d
	jr nz, .decompress
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [$ff8a]
	ld [MBC5RomBank], a
.copy:
	ld a, [bc]
	inc bc
	ld [hli], a
	dec de
	ld a, e
	or d
	jr nz, .copy
	pop hl
	inc hl
	inc hl
	jr LoadData
.decompress:
	ld a, [$ff8a]
	ld [MBC5RomBank], a
	push hl
	call Decompress
	pop hl
	jr LoadData

; Decompress data to a destination.
; The data is decompressed using Rob Northen Compression.
; https://segaretro.org/Rob_Northen_compression
; The original compression was performed using the RNC ProPack tool.
; Note that this decompression is for "mode 2" of RNC compression.
;
; Input: bc = compressed data
;        de = destination address
Decompress:
	ld hl, $12 ; skip over the 18-byte RNC header
	add hl, bc
	scf
	ld a, [hli]
	adc a
	add a
	jp Decompress_NextCommand

Decompress_NextControlByte5:
	ld a, [hli]
	adc a
	jp asm_3f4b

Decompress_NextControlByte3:
	ld a, [hli]
	adc a
	jp asm_3f50

Decompress_NextControlByte6:
	ld a, [hli]
	adc a
	jp asm_3f55

Decompress_NextControlByte7:
	ld a, [hli]
	adc a
	jp asm_3f64

Decompress_NextControlByte4:
	ld a, [hli]
	adc a
	jp asm_3f2c

Decompress_CopyRows:
	ld c, $04
Decompress_CopyRows_CountLoop:
	add a
	jr z, Decompress_NextControlByte4
asm_3f2c:
	rl b
	dec c
	jr nz, Decompress_CopyRows_CountLoop
	; number of bytes copied is (b + 3) * 2
	push af
	ld a, $03
	add b
	add a
	ld c, a
Decompress_CopyRows_Loop:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, Decompress_CopyRows_Loop
	pop af
	jp Decompress_NextCommand

Decompress_NextControlByte2:
	ld a, [hli]
	adc a
	jr c, asm_3fb2
asm_3f48:
	add a
	jr z, Decompress_NextControlByte5
asm_3f4b:
	rl c
	add a
	jr z, Decompress_NextControlByte3
asm_3f50:
	jr nc, Decompress_CheckCopyBytes
	add a
	jr z, Decompress_NextControlByte6
asm_3f55:
	dec c
	push hl
	ld h, a
	ld a, c
	adc a
	ld c, a
	cp $09
	ld a, h
	pop hl
	jr z, Decompress_CopyRows
Decompress_CheckCopyBytes:
	add a
	jr z, Decompress_NextControlByte7
asm_3f64:
	jr nc, Decompress_CopyBytes
	add a
	jr nz, asm_3f6b
	ld a, [hli]
	adc a
asm_3f6b:
	rl b
	add a
	jr nz, asm_3f72
	ld a, [hli]
	adc a
asm_3f72:
	jr c, asm_3fcc
	inc b
	dec b
	jr nz, Decompress_CopyBytes
	inc b
asm_3f79:
	add a
	jr nz, asm_3f7e
	ld a, [hli]
	adc a
asm_3f7e:
	rl b
Decompress_CopyBytes:
	push af
	ld a, e
	sub [hl]
	push hl
	ld l, a
	ld a, d
	sbc b
	ld h, a
	dec hl
Decompress_CopyBytesLoop:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, Decompress_CopyBytesLoop
	pop hl
	inc hl
	pop af
	jr Decompress_NextCommand
Decompress_NextControlByte:
	ld a, [hli]
	adc a
	jr c, Decompress_Backref
Decompress_CopyOneByte:
	push af
	ld a, [hli]
	
	ld [de], a
	inc de
	pop af
Decompress_NextCommand:
	add a
	jr c, Decompress_CheckLastControlBit
	push af
	ld a, [hli]
	ld [de], a
	inc de
	pop af
	add a
	jr nc, Decompress_CopyOneByte
Decompress_CheckLastControlBit:
	jr z, Decompress_NextControlByte
Decompress_Backref:
	ld bc, $2
	add a
	jr z, Decompress_NextControlByte2
	jr nc, asm_3f48
asm_3fb2:
	add a
	jr z, asm_3fdf
asm_3fb5:
	jr nc, Decompress_CopyBytes
	inc c
	add a
	jr z, asm_3fe4
asm_3fbb:
	jr nc, Decompress_CheckCopyBytes
	ld c, [hl]
	inc hl
	inc c
	dec c
	jr z, asm_3fe9
	push af
	ld a, c
	add $08
	ld c, a
	pop af
	jp Decompress_CheckCopyBytes
asm_3fcc:
	add a
	jr nz, asm_3fd1
	ld a, [hli]
	adc a
asm_3fd1:
	rl b
	set 2, b
	add a
	jr nz, asm_3fda
	ld a, [hli]
	adc a
asm_3fda:
	jr c, Decompress_CopyBytes
	jp asm_3f79
asm_3fdf:
	ld a, [hli]
	adc a
	jp asm_3fb5
asm_3fe4:
	ld a, [hli]
	adc a
	jp asm_3fbb
asm_3fe9:
	add a
	jr nz, Decompress_TryEnd
	ld a, [hli]
	adc a
Decompress_TryEnd:
	jr c, Decompress_NextCommand
	ret
