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
	dw ((\3) << 10 | (\2) << 5 | (\1))
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

; \1: tile id
; \2: oam attribute
; \3: x offset
; \4: y offset
sub_sprite: MACRO
	db \4, \3, \1, \2
	ENDM

; \1; num sub sprites
; \2: gfx address
; \3: gfx bank
; \4: palette id
dynamic_sprite: MACRO
	db \4
	dw (((\3) - 8) << 14) | ((\2) & $fff) | (\1)
	ENDM

; \1: x offset
; \2: y offset
; \3: x offset when horizontally flipped
dynamic_sprite_offsets: MACRO
	db \2, \1, \3
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
	db $80 | 2
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
entity_pushable_crate: MACRO
	dw HandlePushableObjectEntity
	dw \2, \1
	db 0
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
; \3: minimum x coord when flying
; \4: maximum x coord when flying
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
entity_brick_thrower: MACRO
	dw HandleBrickThrowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_fire_hydrant: MACRO
	dw HandleFireHydrantEntity
	dw \2, \1
	db $00, $00, $2B, $75, ((\2) & $ff)
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

; \1: x pixel coord
; \2: y pixel coord
entity_ladder: MACRO
	dw HandleLadderEntity
	dw \2, \1
	db $00, $00
	dw \1
	dw \2 - $10
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: ???
entity_taz: MACRO
	dw HandleTazEntity
	dw \2, \1
	db $80, $01, $00
	dw \1
	db \5
	dw \3, \4
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when riding
; \4: maximum x coord when riding
entity_hippo: MACRO
	dw HandleHippoEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_monkey: MACRO
	dw HandleMonkeyEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_taz_female: MACRO
	dw HandleTazFemaleEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord of feeder
; \2: y pixel coord of feeder
; \3: minimum x coord when pushing feeder
; \4: maximum x coord when pushing feeder
; \5: x pixel coord of giraffe
; \6: y pixel coord of giraffe - only lo byte is actually used
entity_giraffe_feeder: MACRO
	dw HandleGiraffeFeederEntity
	dw \2, \1
	db 6
	dw \3, \4
	db \6, $00
	dw \5
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_balloons: MACRO
	dw HandleBalloonsEntity
	dw \2, \1
	db $00, $00
	dw $76A2 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: entrance type
entity_marvin_martian: MACRO
	dw HandleMarvianMartianEntity
	dw \2, \1
	db $80, $01, $00
	dw \1
	db \5
	dw \3, \4
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
entity_pushable_computer: MACRO
	dw HandlePushableObjectEntity
	dw \2, \1
	db 8
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when hovering
; \4: maximum x coord when pushing
; \5: minimum y coord when pushing
entity_hover_ship: MACRO
	dw HandleHoverShipEntity
	dw \2, \1
	db $00
	dw \3, \4
	dw \5
	dw \2
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_instant_martian: MACRO
	dw HandleInstantMartianEntity
	dw \2, \1
	db $81, $00, $C2, $76, $00
	dw \2, \1
	db $C2, $76
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: destination x pixel coord
; \4: destination y pixel coord
entity_teleporter: MACRO
	dw HandleTeleporterEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_k9: MACRO
	dw HandleK9Entity
	dw \2, \1
	db $81, $00, $F4, $77, $00
	dw \1
	db $F4, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_bomb_hazard: MACRO
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00, $DE, $77
	ENDM

; \1: spring x pixel coord
; \2: spring y pixel coord
; \3: lever x pixel coord
; \4: lever y pixel coord
entity_lever_spring: MACRO
	dw HandleLeverSpringEntity
	dw \2, \1
	db $00
	dw \4, \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum y coord when flying
entity_helicopter_chair: MACRO
	dw HandleHelicopterChairEntity
	dw \2, \1
	db $00
	dw \3, \2
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_disguised_hunter: MACRO
	dw HandleDisguisedHunterEntity
	dw \2, \1
	db $00, $00, $97, $78, $03
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: entrance type
entity_elmer_fudd: MACRO
	dw HandleElmerFuddEntity
	dw \2, \1
	db $80, $01, $00
	dw \1
	db \5
	dw \3, \4
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_bear_trap: MACRO
	dw HandleBearTrapEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_hunting_dog: MACRO
	dw HandleHuntingDogEntity
	dw \2, \1
	db $81, $00, $60, $78, $00
	dw \1
	db $60, $78
	ENDM

; \1: rock x pixel coord
; \2: rock y pixel coord
; \3: rock minimum x coord when pushing
; \4: rock maximum x coord when pushing
; \5: rock maximum y coord when falling
entity_rock_teeter_totter: MACRO
	dw HandleRockTeeterTotterEntity
	dw \2, \1
	db 10
	dw \3, \4
	dw \5
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_hook_line: MACRO
	dw HandleHookLineEntity
	dw \2, \1
	db $00, $00
	dw $7846 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_tnt_barrel: MACRO
	dw HandleTNTBarrelEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_log_destruction: MACRO
	dw HandleLogDestructionEntity
	dw \2, \1
	db $00, $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
entity_raft: MACRO
	dw HandleRaftEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
entity_dolphin: MACRO
	dw HandleDolphinEntity
	dw \2, \1
	db $00, $00
	dw $766D ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_cannonball: MACRO
	dw HandleCannonballEntity
	dw \2, \1
	db $20
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
entity_yosemite_sam_boss: MACRO
	dw HandleYosemiteSamBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_right_boss_vehicle_off_screen: MACRO
	dw HandleMoveRightBossVehicleOffScreenEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_right_boss_vehicle_far_left: MACRO
	dw HandleMoveRightBossVehicleFarLeftEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_right_boss_vehicle_far_right: MACRO
	dw HandleMoveRightBossVehicleFarRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_yosemite_ship_middle: MACRO
	dw HandleMoveYosemiteShipMiddleEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_bouncing_oil_drum: MACRO
	dw HandleBouncingOilDrumEntity
	dw \2, \1
	db $00, $00
	dw $75D8 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when riding
entity_jackhammer: MACRO
	dw HandleJackhammerEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_hanging_hook: MACRO
	dw HandleHangingHookEntity
	dw \2, \1
	db $00, $00
	dw $75b8 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_wrecking_ball: MACRO
	dw HandleWreckingBallEntity
	dw \2, \1
	db $00, $00
	dw $7547 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_brick_wall: MACRO
	dw HandleBreakableWallEntity
	dw \2, \1
	db $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
entity_daffy_duck_boss: MACRO
	dw HandleDaffyDuckBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_taz_female_boss: MACRO
	dw HandleTazFemaleBossEntity
	dw \2, \1
	db $20, $00, $01, $00, $00, $00, $00, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_balloon: MACRO
	dw HandleBalloonEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: maximum x pixel coord when riding
entity_bicycle: MACRO
	dw HandleBicycleEntity
	dw \2, \1
	db $00
	dw \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_cage_wall: MACRO
	dw HandleBreakableWallEntity
	dw \2, \1
	db $86
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_cage_drop: MACRO
	dw HandleCageDropEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_left_boss_vehicle_off_screen: MACRO
	dw HandleMoveLeftBossVehicleOffScreenEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_left_boss_vehicle_far_left: MACRO
	dw HandleMoveLeftBossVehicleFarLeftEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_move_left_boss_vehicle_far_right: MACRO
	dw HandleMoveLeftBossVehicleFarRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_normal_scroll_right: MACRO
	dw HandleNormalScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_fast_scroll_right: MACRO
	dw HandleFastScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_fastest_scroll_right: MACRO
	dw HandleFastestScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
entity_taz_boss: MACRO
	dw HandleTazBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $22, $0F, $AA, $0F, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_space_scooter: MACRO
	dw HandleSpaceScooterEntity
	dw \2, \1
	db $20
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_fuel_canister: MACRO
	dw HandleFuelCanisterEntity
	dw \2, \1
	db $00, $00
	dw $781A ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_falling_asteroid: MACRO
	dw HandleFallingAsteroidEntity
	dw \2, \1
	db $00, $00
	dw $780C ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_instant_martian_boss: MACRO
	dw HandleInstantMartianEntity
	dw \2, \1
	db $00, $00, $02, $77, $00
	dw \2, \1
	db $02, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_bomb_hazard_boss: MACRO
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00, $D2, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
entity_marvin_martian_boss: MACRO
	dw HandleMarvianMartianBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_dirt_path_destruction: MACRO
	dw HandleDirtPathDestructionEntity
	dw \2, \1
	db $00, $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
entity_train_track_dolly: MACRO
	dw HandleTrainTrackDollyEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_train_track_barricade: MACRO
	dw HandleTrainTrackBarricadeEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_brick_thrower_tower: MACRO
	dw HandleBrickThrowerTowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_boom_barrier: MACRO
	dw HandleBoomBarrierEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
entity_elmer_fudd_boss: MACRO
	dw HandleElmerFuddBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_studio_yosemite_sam: MACRO
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $6B54
	dw $6B54
	db $AC, $01
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_studio_daffy_duck: MACRO
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $696E
	dw $696E
	db $2C, $01
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_studio_taz: MACRO
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7028
	dw $7028
	db $2C, $02
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_studio_marvin_martian: MACRO
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7412
	dw $7412
	db $AC, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
entity_studio_elmer_fudd: MACRO
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $77AE
	dw $77AE
	db $2C, $00
	ENDM
