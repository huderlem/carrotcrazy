MACRO dbw
	db \1
	dw \2
	ENDM

MACRO dwb
	dw \1
	db \2
	ENDM

MACRO dba
	dbw BANK(\1), \1
	ENDM

MACRO dab
	dwb \1, BANK(\1)
	ENDM

MACRO dn
	rept _NARG / 2
	db (\1) << 4 + (\2)
	shift
	shift
	endr
	ENDM

MACRO dx
DEF x = 8 * ((\1) - 1)
	rept \1
	db ((\2) >> x) & $ff
DEF x = x + -8
	endr
	ENDM

MACRO bigdw ; big-endian word
	dx 2, \1
	ENDM

MACRO RGB
	dw ((\3) << 10 | (\2) << 5 | (\1))
	ENDM

; \1: source data
; \2: destination
MACRO compressed_data
	db Bank(\1)
	dw \1
	dw \2
	ENDM

; \1: source data
; \2: destination
; \3: num bytes
MACRO uncompressed_data
	db Bank(\1)
	dw \1
	dw \3
	dw \2
	ENDM

; \1: tile id
; \2: oam attribute
; \3: x offset
; \4: y offset
MACRO sub_sprite
	db \4, \3, \1, \2
	ENDM

; \1; num sub sprites
; \2: gfx address base
; \3: gfx address
; \4: gbc palette id
; \5: gb palette id
MACRO dynamic_sprite_8
	db ((\5 & $1) << 4) | (\4 & $7)
; Bits 14-15 are the source address's high bits, which must be $4000 (ROMX)
; for banks > 11; the real bank is switched in separately at load time.
IF (Bank(\2) - $8) >= 4
	dw $4000 | ((\3) & $3ff0) | (\1)
ELSE
	dw ((Bank(\2) - $8) << 14) | ((\3) & $3ff0) | (\1)
ENDC
	ENDM

; \1; num sub sprites
; \2: gfx address
; \3: gbc palette id
; \4: gb palette id
MACRO dynamic_sprite
	db ((\4 & $1) << 4) | (\3 & $7)
	dw ((\2) & $fff0) | (\1)
	ENDM

; \1: x offset
; \2: y offset
; \3: x offset when horizontally flipped
MACRO dynamic_sprite_offsets
	db \2, \1, \3
	ENDM

; \1: minimum x coord
; \2: maximum x coord
; \3: entity num
; \4: level name
MACRO trigger
	dw \1, \2, wLevelEntities + (\4Entity\3 - \4Entities) + 2
	ENDM

; \1: type
; \2: x pixel coord
; \3: y pixel coord
MACRO entity_collectible
	dw HandleCollectibleEntity
	dw \3, \2
	db \1, $0
	IF \1 >= 7
	db 0
	ENDC
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_cannon
	dw HandleCannonEntity
	dw \2, \1
	db 0
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when paddling
; \4: maximum x coord when paddling
MACRO entity_barrel_boat
	dw HandleBarrelBoatEntity
	dw \2, \1
	db 0
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
MACRO entity_pushable_chest
	dw HandlePushableObjectEntity
	dw \2, \1
	db $80 | 2
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when pushing
; \4: maximum x coord when pushing
MACRO entity_pushable_crate
	dw HandlePushableObjectEntity
	dw \2, \1
	db 0
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_hint_umbrella
	dw HandleActionHintEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_hint_shovel
	dw HandleActionHintEntity
	dw \2, \1
	db $80
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: entrance type
MACRO entity_yosemite_sam
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
MACRO entity_seagull
	dw HandleSeagullEntity
	dw \2, \1
	db $80, $01, $00
	dw \3, \4
	db $00, $00, $00, $00, $00, $00
	dw \5
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_rock_thrower
	dw HandleRockThrowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_brick_thrower
	dw HandleBrickThrowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_fire_hydrant
	dw HandleFireHydrantEntity
	dw \2, \1
	db $00, $00, $2B, $75, ((\2) & $ff)
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when skateboarding
; \4: maximum x coord when skateboarding
MACRO entity_skateboard
	dw HandleSkateboardEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: bomb explosion y coord
MACRO entity_sylvester
	dw HandleSylvesterEntity
	dw \2, \1
	db $00, $00, $00, $00, $00
	dw \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
MACRO entity_daffy_duck
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
MACRO entity_ladder
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
MACRO entity_taz
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
MACRO entity_hippo
	dw HandleHippoEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_monkey
	dw HandleMonkeyEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_taz_female
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
MACRO entity_giraffe_feeder
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
MACRO entity_balloons
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
MACRO entity_marvin_martian
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
MACRO entity_pushable_computer
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
MACRO entity_hover_ship
	dw HandleHoverShipEntity
	dw \2, \1
	db $00
	dw \3, \4
	dw \5
	dw \2
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_instant_martian
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
MACRO entity_teleporter
	dw HandleTeleporterEntity
	dw \2, \1
	db $00
	dw \3, \4
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_k9
	dw HandleK9Entity
	dw \2, \1
	db $81, $00, $F4, $77, $00
	dw \1
	db $F4, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_bomb_hazard
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00, $DE, $77
	ENDM

; \1: spring x pixel coord
; \2: spring y pixel coord
; \3: lever x pixel coord
; \4: lever y pixel coord
MACRO entity_lever_spring
	dw HandleLeverSpringEntity
	dw \2, \1
	db $00
	dw \4, \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum y coord when flying
MACRO entity_helicopter_chair
	dw HandleHelicopterChairEntity
	dw \2, \1
	db $00
	dw \3, \2
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_disguised_hunter
	dw HandleDisguisedHunterEntity
	dw \2, \1
	db $00, $00, $97, $78, $03
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x coord when walking
; \4: maximum x coord when walking
; \5: entrance type
MACRO entity_elmer_fudd
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
MACRO entity_bear_trap
	dw HandleBearTrapEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_hunting_dog
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
MACRO entity_rock_teeter_totter
	dw HandleRockTeeterTotterEntity
	dw \2, \1
	db 10
	dw \3, \4
	dw \5
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_hook_line
	dw HandleHookLineEntity
	dw \2, \1
	db $00, $00
	dw $7846 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_tnt_barrel
	dw HandleTNTBarrelEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_log_destruction
	dw HandleLogDestructionEntity
	dw \2, \1
	db $00, $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
MACRO entity_raft
	dw HandleRaftEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
MACRO entity_shark
	dw HandleSharkEntity
	dw \2, \1
	db $00, $00
	dw $766D ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_cannonball
	dw HandleCannonballEntity
	dw \2, \1
	db $20
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
MACRO entity_yosemite_sam_boss
	dw HandleYosemiteSamBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_right_boss_vehicle_off_screen
	dw HandleMoveRightBossVehicleOffScreenEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_right_boss_vehicle_far_left
	dw HandleMoveRightBossVehicleFarLeftEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_right_boss_vehicle_far_right
	dw HandleMoveRightBossVehicleFarRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_yosemite_ship_middle
	dw HandleMoveYosemiteShipMiddleEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_bouncing_oil_drum
	dw HandleBouncingOilDrumEntity
	dw \2, \1
	db $00, $00
	dw $75D8 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when riding
MACRO entity_jackhammer
	dw HandleJackhammerEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_hanging_hook
	dw HandleHangingHookEntity
	dw \2, \1
	db $00, $00
	dw $75b8 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_wrecking_ball
	dw HandleWreckingBallEntity
	dw \2, \1
	db $00, $00
	dw $7547 ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_brick_wall
	dw HandleBreakableWallEntity
	dw \2, \1
	db $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
MACRO entity_daffy_duck_boss
	dw HandleDaffyDuckBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_taz_female_boss
	dw HandleTazFemaleBossEntity
	dw \2, \1
	db $20, $00, $01, $00, $00, $00, $00, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_balloon
	dw HandleBalloonEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: maximum x pixel coord when riding
MACRO entity_bicycle
	dw HandleBicycleEntity
	dw \2, \1
	db $00
	dw \3
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_cage_wall
	dw HandleBreakableWallEntity
	dw \2, \1
	db $86
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_cage_drop
	dw HandleCageDropEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_left_boss_vehicle_off_screen
	dw HandleMoveLeftBossVehicleOffScreenEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_left_boss_vehicle_far_left
	dw HandleMoveLeftBossVehicleFarLeftEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_move_left_boss_vehicle_far_right
	dw HandleMoveLeftBossVehicleFarRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_normal_scroll_right
	dw HandleNormalScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_fast_scroll_right
	dw HandleFastScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_fastest_scroll_right
	dw HandleFastestScrollRightEntity
	dw \2, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
MACRO entity_taz_boss
	dw HandleTazBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $22, $0F, $AA, $0F, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_space_scooter
	dw HandleSpaceScooterEntity
	dw \2, \1
	db $20
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_fuel_canister
	dw HandleFuelCanisterEntity
	dw \2, \1
	db $00, $00
	dw $781A ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_falling_asteroid
	dw HandleFallingAsteroidEntity
	dw \2, \1
	db $00, $00
	dw $780C ; TODO:
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_instant_martian_boss
	dw HandleInstantMartianEntity
	dw \2, \1
	db $00, $00, $02, $77, $00
	dw \2, \1
	db $02, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_bomb_hazard_boss
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00, $D2, $77
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
MACRO entity_marvin_martian_boss
	dw HandleMarvianMartianBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_dirt_path_destruction
	dw HandleDirtPathDestructionEntity
	dw \2, \1
	db $00, $06
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: minimum x pixel coord when surfing
MACRO entity_train_track_dolly
	dw HandleTrainTrackDollyEntity
	dw \2, \1
	db $00
	dw \3, \1
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_train_track_barricade
	dw HandleTrainTrackBarricadeEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_brick_thrower_tower
	dw HandleBrickThrowerTowerEntity
	dw \2, \1
	db $80, $01, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_boom_barrier
	dw HandleBoomBarrierEntity
	dw \2, \1
	db $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
; \3: health
MACRO entity_elmer_fudd_boss
	dw HandleElmerFuddBossEntity
	dw \2, \1
	db $20, $00
	db \3
	db $00, $00, $00, $00, $00, $88, $00, $04
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_studio_yosemite_sam
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $6B54
	dw $6B54
	db $AC, $01
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_credits_studio_yosemite_sam
	dw HandleCreditsStudioCharacterEntity
	dw \2, \1
	db $00
	dw $6B54
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_studio_daffy_duck
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $696E
	dw $696E
	db $2C, $01
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_credits_studio_daffy_duck
	dw HandleCreditsStudioCharacterEntity
	dw \2, \1
	db $00
	dw $696E
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_studio_taz
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7028
	dw $7028
	db $2C, $02
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_credits_studio_taz
	dw HandleCreditsStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7028
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_studio_marvin_martian
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7412
	dw $7412
	db $AC, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_credits_studio_marvin_martian
	dw HandleCreditsStudioCharacterEntity
	dw \2, \1
	db $00
	dw $7412
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_studio_elmer_fudd
	dw HandleStudioCharacterEntity
	dw \2, \1
	db $00
	dw $77AE
	dw $77AE
	db $2C, $00
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_credits_studio_elmer_fudd
	dw HandleCreditsStudioCharacterEntity
	dw \2, \1
	db $00
	dw $77AE
	ENDM
