Func_84:
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
; 0x100