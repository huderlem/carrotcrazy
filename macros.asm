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

; \1: minimum x coord
; \2: maximum x coord
; \3: entity num
; \4: level name
trigger: MACRO
	dw \1, \2, wLevelEntities + (\4Entity\3 - \4Entities) + 2
	ENDM

; \1: type
; \2: x pixel coord
; \3: y pixel coord
entity_collectible: MACRO
	dw HandleCollectibleEntity
	dw \3, \2
	db \1, $0
	IF \1 >= 7
	db 0
	ENDC
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_cannon: MACRO
	dw HandleCannonEntity
	dw \2, \1
	db 0
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when paddling
; \4: maximum x coord when paddling
entity_barrel_boat: MACRO
	dw HandleBarrelBoatEntity
	dw \2, \1
	db 0
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
entity_pushable_chest: MACRO
	dw HandlePushableObjectEntity
	dw \2, \1
	db $82
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
entity_pushable_crate: MACRO
	dw HandlePushableObjectEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_hint_umbrella: MACRO
	dw HandleActionHintEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_hint_shovel: MACRO
	dw HandleActionHintEntity
	dw \2, \1
	db $80
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: entrance type
entity_yosemite_sam: MACRO
	dw HandleYosemiteSamEntity
	dw \2, \1
	db $80, $01, $00
	dw \1
	db \5
	dw \3, \4
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: cannonball explosion y coord
entity_seagull: MACRO
	dw HandleSeagullEntity
	dw \2, \1
	db $80, $01, $00
	dw \3, \4
	db $00, $00, $00, $00, $00, $00
	dw \5
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_rock_thrower: MACRO
	dw HandleRockThrowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_fire_hydrant: MACRO
	dw HandleFireHydrantEntity
	dw \2, \1
	db $00, $00, $2B, $75, $4A
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when skateboarding
; \4: maximum x coord when skateboarding
entity_skateboard: MACRO
	dw HandleSkateboardEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: bomb explosion y coord
entity_sylvester: MACRO
	dw HandleSylvesterEntity
	dw \2, \1
	db $00, $00, $00, $00, $00
	dw \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
entity_daffy_duck: MACRO
	dw HandleDaffyDuckEntity
	dw \2, \1
	db $80, $01, $00
	dw \1
	db $00
	dw \3, \4
	db $00
	ENDM
