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

; \1: x velocity (signed 8.8 fixed-point), added to the x position each frame
; \2: y base offset added to each sub-sprite of the frame
; \3: sprite frame
MACRO titlescreen_scroll_sprite
	dw \1
	db \2
	dw \3
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

; \1: gravity
; \2: initial y velocity
; \3: x velocity
; \4: x spawn offset when facing left
; \5: x spawn offset when facing right
; \6: y spawn offset
; \7: sprite anim mask
; \8: sprite table
MACRO projectile_spawn
	db \1, \2, \3, \4, \5, \6, \7
	dw \8
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw FireHydrantScript
	db ((\2) & $ff)
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw BalloonsScript
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
	db $81, $00 ; entity flags, initial movement-script timer
	dw InstantMartianScript
	db $00
	dw \2, \1
	dw InstantMartianScript
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
	db $81, $00 ; entity flags, initial movement-script timer
	dw K9Script
	db $00
	dw \1
	dw K9Script
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_bomb_hazard
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00 ; entity flags, initial movement-script timer
	dw BombHazardScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw DisguisedHunterScript
	db $03
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
	db $81, $00 ; entity flags, initial movement-script timer
	dw HuntingDogScript
	db $00
	dw \1
	dw HuntingDogScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw HookLineScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw SharkScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw BouncingOilDrumScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw HangingHookScript
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_wrecking_ball
	dw HandleWreckingBallEntity
	dw \2, \1
	db $00, $00 ; entity flags, initial movement-script timer
	dw WreckingBallScript
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
	db $00, $00 ; entity flags, initial movement-script timer
	dw FuelCanisterScript
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_falling_asteroid
	dw HandleFallingAsteroidEntity
	dw \2, \1
	db $00, $00 ; entity flags, initial movement-script timer
	dw FallingAsteroidScript
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_instant_martian_boss
	dw HandleInstantMartianEntity
	dw \2, \1
	db $00, $00 ; entity flags, initial movement-script timer
	dw InstantMartianBossScript
	db $00
	dw \2, \1
	dw InstantMartianBossScript
	ENDM

; \1: x pixel coord
; \2: y pixel coord
MACRO entity_bomb_hazard_boss
	dw HandleBombHazardEntity
	dw \2, \1
	db $00, $00 ; entity flags, initial movement-script timer
	dw BombHazardBossScript
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

; Music phrase command macros
; A "phrase" is a byte stream consumed by the bank sound engine. Bytes below
; FIRST_MUSIC_COMMAND ($60) are note values; bytes >= $60 are commands by range
; (see constants/audio_constants.asm).

; Notes: one or more note-value bytes (each < $60). Naming a sequence of
; notes is common in phrase data, so the macro accepts a variable number of args.
; Each value is an index into NoteFrequencies (one semitone per step, starting at
; C2 = 0); prefer the `<letter><n|s><octave>` constants in audio_constants.asm
; (e.g. Cn2, Ds3, Gs7).
MACRO mus_note
	rept _NARG
	db \1
	shift
	endr
	ENDM

; $60: set the one-shot transpose folded into the next note's pitch.
MACRO mus_transpose ; value
	db $60, \1
	ENDM

; $61: clear the transpose.
MACRO mus_transpose_off
	db $61
	ENDM

; $62: end the current note (and invoke MUSIC_CH_NOTE_END_CB if armed).
MACRO mus_end_note
	db $62
	ENDM

; $63: enable vibrato
MACRO mus_vibrato ; delay, depth, rate
	db $63, \1, \2, \3
	ENDM

; $64: disable vibrato.
MACRO mus_vibrato_off
	db $64
	ENDM

; $65: identical to mus_end_note
MACRO mus_end_note_alt
	db $65
	ENDM

; $66: note-off (volume = 0; on channels 1/2, NRx2 also zeroed).
MACRO mus_note_off
	db $66
	ENDM

; $67: reset all music channels
MACRO mus_reset_channels
	db $67
	ENDM

; $68: stop the channel; also terminates a macro sub-phrase.
MACRO mus_stop_channel
	db $68
	ENDM

; $69: set the global detune applied to all melodic channels.
MACRO mus_detune ; value
	db $69, \1
	ENDM

; $6A: end the current phrase (return-from-call or advance the chain).
MACRO mus_end_phrase
	db $6A
	ENDM

; $6B: set the default note length (in frames).
MACRO mus_note_length ; length
	db $6B, \1
	ENDM

; $6C: start the percussion (noise) track, with the given step length and
; pointer to a noise-sequence label.
MACRO mus_noise_seq ; step_length, seq_label
	db $6C, \1
	dw \2
	ENDM

; $6D: stop the percussion track.
MACRO mus_noise_seq_off
	db $6D
	ENDM

; $6E: pan to both speakers.
MACRO mus_pan_center
	db $6E
	ENDM

; $6F: pan right only.
MACRO mus_pan_right
	db $6F
	ENDM

; $70: pan left only.
MACRO mus_pan_left
	db $70
	ENDM

; $71: 50% duty cycle.
MACRO mus_duty_50
	db $71
	ENDM

; $72: 75% duty cycle.
MACRO mus_duty_75
	db $72
	ENDM

; $73: 12.5% duty cycle.
MACRO mus_duty_12
	db $73
	ENDM

; $74: set the NRx2 hardware envelope (channels 1/2). The optional volume sweep
; is N+1 frames of delay followed by a target NRx2 value.
;   mus_envelope nrx2                  -> $74 nrx2 $00         (no sweep)
;   mus_envelope nrx2, delay, target   -> $74 nrx2 delay target (sweep enabled)
MACRO mus_envelope
	IF _NARG == 1
	db $74, \1, $00
	ELSE
	db $74, \1, \2, \3
	ENDC
	ENDM

; $75: start a stereo pan sequence (the parameter is the step speed).
MACRO mus_pan_seq ; speed
	db $75, \1
	ENDM

; $76: start a duty-cycle sequence (the parameter is the step speed).
MACRO mus_duty_seq ; speed
	db $76, \1
	ENDM

; $77: start a master-volume (NR50) sequence (step speed + sequence pointer).
MACRO mus_master_vol_seq ; speed, seq_label
	db $77, \1
	dw \2
	ENDM

; $78: stop the master-volume sequence.
MACRO mus_master_vol_seq_off
	db $78
	ENDM

; $79: load a 16-byte wave pattern into wave RAM.
MACRO mus_load_wave ; wave_label
	db $79
	dw \1
	ENDM

; $7A: set the octave base offset. The handler stores `param - 12` into
; MUSIC_CH_OCTAVE, so the stored shift in semitones is signed. Use the
; mus_octave_shift wrapper below for readable signed-semitone values.
MACRO mus_octave ; raw byte (stored shift = byte - 12)
	db $7A, \1
	ENDM

; Signed-semitone wrapper around $7A: `mus_octave_shift -14` is equivalent to
; `mus_octave $fe`, and means "shift the played pitch down 14 semitones".
;   mus_octave_shift 0    -> neutral
;   mus_octave_shift 12   -> up an octave
;   mus_octave_shift -12  -> down an octave
MACRO mus_octave_shift ; signed semitone shift
	db $7A, (\1) + 12
	ENDM

; $7B: arm/disable the timed mid-note effect.
;   mus_note_fx $00          -> $7B $00         (disable)
;   mus_note_fx step, timing -> $7B step timing (arm: see Func_84ac)
MACRO mus_note_fx
	IF _NARG == 1
	db $7B, \1
	ELSE
	db $7B, \1, \2
	ENDC
	ENDM

; $7C: disable arpeggio.
MACRO mus_arp_off
	db $7C
	ENDM

; $7D: jump to an absolute position in the current phrase.
MACRO mus_goto ; target_label
	db $7D
	dw \1
	ENDM

; $7E: call a sub-phrase (saves the current position; returns at $6A).
MACRO mus_call ; sub_label
	db $7E
	dw \1
	ENDM

; $7F: jump into native code at the given address.
MACRO mus_call_code ; code_label
	db $7F
	dw \1
	ENDM

; $80: loop-back marker that pairs with mus_loop_start; counts down the
; repeat counter and rewinds the stream until it reaches zero.
MACRO mus_loop_back
	db $80
	ENDM

; $81: set the software volume envelope's peak level.
MACRO mus_envelope_peak ; value
	db $81, \1
	ENDM

; $82: pitch slide up (sets vibrato to a fast continuous-slide configuration).
MACRO mus_pitch_slide_up ; depth
	db $82, \1
	ENDM

; $83: pitch slide down (same as $82 but clears the direction bit).
MACRO mus_pitch_slide_down ; depth
	db $83, \1
	ENDM

; $84: arm or disable the per-note callback system.
;   mus_note_cb_off                  -> $84 $00
;   mus_note_cb per_note, note_end   -> $84 cb1 cb2  (each as a 16-bit pointer)
MACRO mus_note_cb_off
	db $84, $00
	ENDM
MACRO mus_note_cb ; per_note_cb, note_end_cb
	db $84
	dw \1
	dw \2
	ENDM

; $85-$93: invoke a macro sub-phrase. The opcode encodes the table index; the
; macro emits one byte. Argument matches the engine opcode (e.g. mus_macro $85).
MACRO mus_macro ; opcode ($85-$93)
	db \1
	ENDM

; $94-$AF: select an arpeggio table entry.
MACRO mus_arp ; opcode ($94-$AF)
	db \1
	ENDM

; $B0-$BF: load the software volume envelope (peak baked into the opcode, plus
; three parameter bytes for attack/decay/timer-pair).
MACRO mus_vol_env ; peak (0-15), attack, decay, timers
	db $B0 + (\1), \2, \3, \4
	ENDM

; $C0-$EF: set the default note length to (opcode - $BF), range 1-48.
MACRO mus_default_length ; length (1-48)
	db $BF + (\1)
	ENDM

; $F0-$FF: begin a loop block that runs (opcode - $EE) total passes (2-17).
; Pair with mus_loop_back at the end of the block.
MACRO mus_loop_start ; num_passes (2-17)
	db $EE + (\1)
	ENDM
