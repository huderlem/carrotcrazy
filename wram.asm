SECTION "WRAM Bank 0", WRAM0

wRAMStart::

UNION
	; Every 4-byte group is a metatile.
	wMetatiles:: ; $c000
		ds $400
NEXTU
	; While the EXTRA bonus minigame runs (see RunLevelBonusScreen), the level
	; metatile buffer is unused and reused as scratch. 
	; 16 entries, 3 bytes each. First byte is an attribute, second two are the pointer.
	wBonusSpritePtrTable:: ; $c000
		ds 16 * 3

	; One slot per target the player throws carrots at, indexed by the active
	; LevelBonusSequence.
	; Each entry is 4 bytes: state flags, move timer, x, y
	wBonusTargets:: ; $c030
		ds 12 * 4

	; Pointer to each target character's sprite.
	wBonusTargetSprites:: ; $c060
		ds 6 * 2
	; Same, for the "hit" sprite shown after a target is struck.
	wBonusTargetHitSprites:: ; $c06c
		ds 6 * 2

		ds $10c ; sprite OAM data referenced by the target sprite tables above

	; Thrown-carrot animation frames, indexed by the toss timer ($ddcf).
	wBonusThrownCarrotSprites:: ; $c184
		ds $64

	; Player sprite at the bottom of the screen.
	wBonusPlayerSprite:: ; $c1e8
		ds $3a
	; Player sprite while throwing (drawn when $ddcd bit 7 is set).
	wBonusPlayerThrowSprite:: ; $c222
		ds $3a
	; Prompt that blinks until the player presses B to start.
	wBonusReadyPrompt:: ; $c25c
		ds $16
	; Prompt shown when the bonus round is completed.
	wBonusClearPrompt:: ; $c272
		ds $16

	; Frames for the scripted carrot animation (path script at $ddd2).
	wBonusCarrotScriptSprites:: ; $c288
		ds $40

	; Pointers to the carrot-meter fill graphics.
	wBonusCarrotMeterGfx:: ; $c2c8
		ds 3 * 2
ENDU

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

	ds $42 ; $db00: sound channel 1 state struct (see constants/audio_constants.asm)

wMusicPaused:: ; $db42
	ds 1

; Nonzero would enable per-channel NR51 stereo panning, but nothing ever sets it,
; so panning stays off (NR51 = $ff: every channel to both speakers).
wMusicStereoEnabled:: ; $db43
	ds 1

; Last value written to NR32 (wave channel volume); cached to skip redundant writes.
wMusicLastWaveVolume:: ; $db44
	ds 1

; Nonzero while a command stream is reading from a macro sub-stream (command $85).
wMusicInMacro:: ; $db45
	ds 1

; NR51 stereo-panning bits for the noise channel (channel 4 / sound effects).
wMusicNoisePanning:: ; $db46
	ds 1

; While nonzero, a sound effect owns the noise channel and music noise is muted;
; counts down once per frame.
wSfxNoiseLock:: ; $db47
	ds 1

; Pointer to the active song's macro table (command $85 indexes into it).
wMusicMacroTable:: ; $db48
	ds 2

; Pointer to the active song's arpeggio table (commands $94-$AF index into it).
wMusicArpeggioTable:: ; $db4a
	ds 2

; Pointer to the wave pattern that channel 3 loads into wave RAM.
wMusicWavePtr:: ; $db4c
	ds 2

; === Noise/drum (percussion) sequence state ($db4e-$db5f) ===
; The percussion track is a separate "noise sequence": a byte stream (started by
; MusicCommand_StartNoiseSequence) processed by AdvanceNoiseSequence to drive the
; hardware noise channel. Some of its command bytes trigger a "noise instrument",
; which is a short pre-baked pair of NR43 (frequency) and NR42 (volume) sweeps that
; synthesise one drum hit, played out by UpdateNoiseChannel.

; Stereo ping-pong interval: every this-many drum hits, UpdateNoiseChannel rotates
; the noise channel's panning (set by noise-sequence command $35). 0 = disabled.
wNoiseSeqPanInterval:: ; $db4e
	ds 1
; Pointer to the active noise sequence (stored high byte first), and the read
; cursor (byte offset) into it.
wNoiseSeqPtrHi:: ; $db4f
	ds 1
wNoiseSeqPtrLo:: ; $db50
	ds 1
wNoiseSeqIndex:: ; $db51
	ds 1
; Nonzero while a noise sequence is playing.
wNoiseSeqActive:: ; $db52
	ds 1
; Frames per noise-sequence step (reload) and the running countdown.
wNoiseSeqStepLength:: ; $db53
	ds 1
wNoiseSeqStepTimer:: ; $db54
	ds 1
; Noise-sequence repeat loop (commands $5b-$bf / $36): remaining iterations and
; the cursor to jump back to.
wNoiseSeqLoopCount:: ; $db55
	ds 1
wNoiseSeqLoopStart:: ; $db56
	ds 1
; Pointers (stored high byte first) into the active noise instrument's two
; parallel byte lists: the NR43 frequency sweep and the NR42 volume/envelope sweep.
wNoiseInstrumentFreqPtrHi:: ; $db57
	ds 1
wNoiseInstrumentFreqPtrLo:: ; $db58
	ds 1
wNoiseInstrumentVolPtrHi:: ; $db59
	ds 1
wNoiseInstrumentVolPtrLo:: ; $db5a
	ds 1
; Read cursor into the instrument's sweep lists, and a nonzero "playing" flag.
wNoiseInstrumentIndex:: ; $db5b
	ds 1
wNoiseInstrumentActive:: ; $db5c
	ds 1
; Volume attenuation applied to the instrument's NR42 values (noise-sequence
; command $37-$46): 0 = full volume, $f = quietest.
wNoiseSeqVolumeAttenuation:: ; $db5d
	ds 1
; Frames per noise-instrument step: running countdown and reload (set by
; noise-sequence command $47-$5a).
wNoiseInstrumentStepTimer:: ; $db5e
	ds 1
wNoiseInstrumentStepLength:: ; $db5f
	ds 1

; Master-volume (NR50) envelope sequence: data pointer, current index, frame
; countdown, countdown reload (speed), and active flag.
wMusicMasterVolSeq:: ; $db60
	ds 2
wMusicMasterVolSeqIndex:: ; $db62
	ds 1
wMusicMasterVolSeqDelay:: ; $db63
	ds 1
wMusicMasterVolSeqSpeed:: ; $db64
	ds 1
wMusicMasterVolSeqActive:: ; $db65
	ds 1

	ds $23d ; $db66: channel 2 ($dc00) and channel 3 ($dd00) structs, plus more state

wAnimatedTilesPointer:: ; $dda3
	ds 2

	ds $3d

; $ff if in credits scene, $00 otherwise.
wInCreditsScene:: ; $dde2
	ds 1

	ds 2

wCurCreditsText:: ; $dde5
	ds 2

	ds 1

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

	ds $1

wSoundEffectFrequency:: ; $de05
	ds 2

	ds $3

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
