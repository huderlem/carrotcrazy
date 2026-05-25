SECTION "WRAM Bank 0", WRAM0

wRAMStart::

; Every 4-byte group is a metatile.
wMetatiles:: ; $c000
	ds $400

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

	ds $12 ; $db4e: noise/drum sequence state (undocumented)

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
