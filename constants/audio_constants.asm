; Constants for the music/sound engine (see "ROM Bank $02" in main.asm).
;
; The engine drives the Game Boy's 4 sound channels once per frame via
; TickMusicEngine. Each channel has a state struct in WRAM aligned to a $100
; boundary, so its high address byte is constant: the engine selects a channel
; by loading that byte into `h` once, then reaches each field with `l`.
;
;   $db00  Channel 1  (Pulse A,  NR10-NR14)
;   $dc00  Channel 2  (Pulse B,  NR21-NR24)
;   $dd00  Channel 3  (Wave,     NR30-NR34)
;   $de00  Channel 4  (Noise,    NR41-NR44) -- also the sound effect channel
;
; Only the low ~$41 bytes of each struct are used. The rest of channel 1's range
; ($db44-$db65) holds the engine's global state (see wram.asm).
DEF MUSIC_CHAN_1 EQU $db00
DEF MUSIC_CHAN_2 EQU $dc00
DEF MUSIC_CHAN_3 EQU $dd00
DEF MUSIC_CHAN_4 EQU $de00


; === Per-channel state struct field offsets ===
; Used as `ld l, MUSIC_CH_*` with `h` holding the channel's high address byte.

; Pointer to the current position in this channel's "chain": a tracker-style list
; of pointers to phrases. When the current phrase ends, the engine advances the
; chain to the next phrase (see MusicCommand_EndPhrase).
DEF MUSIC_CH_CHAIN_PTR  EQU $00 ; 2 bytes

; Pointer to the current position within the channel's current phrase (a stream of
; the command bytes documented at the bottom of this file).
DEF MUSIC_CH_CMD_PTR    EQU $02 ; 2 bytes

; Bitfield of per-channel state flags:
;   bit 0 = arpeggio table active        (set by commands $94-$AF)
;   bit 1 = timed mid-note effect enabled (params at MUSIC_CH_NOTE_FX)
;   bit 2 = timed mid-note effect applied
;   bit 3 = vibrato enabled              (params at MUSIC_CH_VIBRATO)
;   bit 4 = vibrato direction (1=up)
;   bit 5 = per-note callback enabled    (callback pointer at MUSIC_CH_NOTE_CB)
DEF MUSIC_CH_FLAGS      EQU $04

; The 11-bit frequency value sent to NRx3/NRx4, looked up from NoteFrequencies
; for the current note and combined with the pitch offset at MUSIC_CH_PITCH_BEND.
DEF MUSIC_CH_FREQ       EQU $05 ; 2 bytes

; Cached high byte of the frequency last written to NRx4, used to skip
; redundant register writes (and reused as the NR30 DAC-enable byte on channel 3).
DEF MUSIC_CH_FREQ_HI    EQU $07

; Current volume/envelope level (0-$F).
DEF MUSIC_CH_VOLUME     EQU $08

; Default note duration applied to following notes (set by commands $C0-$EF).
DEF MUSIC_CH_NOTE_LEN   EQU $09

; Countdown of frames left in the current note. Reaching 0 reads the next command.
DEF MUSIC_CH_NOTE_TIMER EQU $0a

; Note pitch components. The played pitch is the sum of these, used to index
; NoteFrequencies: transpose + note + octave base + arpeggio offset.
DEF MUSIC_CH_TRANSPOSE  EQU $0b ; one-shot transpose, folded into the note
DEF MUSIC_CH_NOTE       EQU $0c ; the current note value
DEF MUSIC_CH_OCTAVE     EQU $0d ; octave base offset
DEF MUSIC_CH_ARP_OFFSET EQU $0e ; current arpeggio table entry
DEF MUSIC_CH_DETUNE     EQU $0f ; global detune applied to all melodic channels

; Software volume envelope (set by command $B0-$BF). Used by channels 3 and 4,
; which lack a usable hardware envelope. $10 = attack, $13 = decay (each packed
; as count/step nibbles), $16 = peak level; $17-$1b hold the runtime timers.
DEF MUSIC_CH_VOL_ENV    EQU $10 ; params at $10-$16
DEF MUSIC_CH_VOL_ENV_T  EQU $17 ; runtime timers at $17-$1b

; Arpeggio table pointer + index (command $94-$AF).
DEF MUSIC_CH_ARP_PTR    EQU $1d ; 2 bytes
DEF MUSIC_CH_ARP_IDX    EQU $1f

; Vibrato oscillator. $20 = onset delay (reload), $21 = delay countdown,
; $22 = depth step, $23 = steps until reversing, $24 = step count (reload).
DEF MUSIC_CH_VIBRATO    EQU $20 ; params at $20-$24

; Signed pitch offset (vibrato output) added to MUSIC_CH_FREQ each frame.
DEF MUSIC_CH_PITCH_BEND EQU $25 ; 2 bytes

; Nonzero = channel enabled. On channel 4 this holds the active sound effect ID.
DEF MUSIC_CH_ENABLED    EQU $27

; Hardware-envelope (NRx2) state for channels 1/2, set by command $74
; (MusicCommand_SetEnvelope). MUSIC_CH_NRX2_RELOAD is copied back into
; MUSIC_CH_NRX2 at every note start. The optional one-shot sweep at $29-$2b
; ($29 = delay reload (0 = sweep disabled, else N+1 frames before the sweep
; fires), $2a = countdown timer reloaded from $29 on note start, $2b = target
; NRx2 value) is ticked by UpdateVolumeEnvelope: when the countdown reaches 0
; the target is installed into MUSIC_CH_NRX2 and a retrigger is requested.
DEF MUSIC_CH_NRX2_RELOAD EQU $28
DEF MUSIC_CH_NRX2_SWEEP  EQU $29 ; $29-$2b

; Stereo-panning sequence: pointer + countdown, advanced into MUSIC_CH_PAN.
DEF MUSIC_CH_PAN_SEQ    EQU $2c ; $2c-$2e

; Duty-cycle sequence: pointer + countdown, advanced into NR11/NR21 duty bits.
DEF MUSIC_CH_DUTY_SEQ   EQU $2f ; $2f-$31

; Shadow of the channel's NRx2 volume/envelope register, written on note retrigger.
DEF MUSIC_CH_NRX2       EQU $32
; Nonzero requests a note retrigger (sets the trigger bit in NRx4).
DEF MUSIC_CH_RETRIGGER  EQU $33

; Parameters for a timed mid-note effect (command $7B): after the note has played
; for a set time it is retriggered with the new volume in $35. The high nibble of
; $34 gates it by note length; the low nibble is the trigger time. Exact musical
; purpose is unclear (see Func_8447).
DEF MUSIC_CH_NOTE_FX    EQU $34 ; $34-$35

; Saved return pointer for the call/return commands ($7E / $6A).
DEF MUSIC_CH_RETURN_PTR EQU $36 ; 2 bytes

; NR51 stereo panning bits for this channel.
DEF MUSIC_CH_NR51       EQU $38

; Subroutine call state (commands $F0-$FF): repeat count + return pointer.
DEF MUSIC_CH_CALL       EQU $39 ; $39-$3b

; Saved-note window for the per-note callback system (channel flag bit 5). On each new
; note these rotate -- the prior MUSIC_CH_NOTE_CUR becomes MUSIC_CH_NOTE_PREV
; and the new note is stored in MUSIC_CH_NOTE_CUR -- before MUSIC_CH_NOTE_CB
; is invoked, letting the callback inspect both values. The note-end command
; ($62/$65; Func_8502) then calls MUSIC_CH_NOTE_END_CB and replays
; MUSIC_CH_NOTE_PREV via StartNote.
DEF MUSIC_CH_NOTE_PREV  EQU $3c
DEF MUSIC_CH_NOTE_CUR   EQU $3d

; Pointer to a per-note callback routine (invoked when channel flag bit 5 is set).
DEF MUSIC_CH_NOTE_CB    EQU $3e ; 2 bytes

; Pointer to a per-note-end callback routine (invoked by Func_8502 / command
; $62/$65 when channel flag bit 5 is set).
DEF MUSIC_CH_NOTE_END_CB EQU $40 ; 2 bytes


; === Phrase command opcodes ===
; A phrase is a byte sequence. Bytes below FIRST_MUSIC_COMMAND are note values;
; bytes >= FIRST_MUSIC_COMMAND are commands, dispatched by range:
;   $60-$84  table-dispatched commands (MusicCommandTable)
;   $85-$93  macro / sub-phrase calls
;   $94-$AF  select arpeggio table
;   $B0-$BF  set software volume envelope
;   $C0-$EF  set note duration (length = opcode - $BF)
;   $F0-$FF  call phrase, repeating (opcode - $EE) times
DEF FIRST_MUSIC_COMMAND EQU $60


; === Note value constants ===
; A note byte in a phrase indexes NoteFrequencies (one semitone per step).
; Index 0 plays ~65.4 Hz (C natural, octave 2); the table covers 80 semitones
; up through G natural, octave 8. The played pitch sums these channel fields,
; mod 256, before the lookup:
;   transpose + note + octave + arpeggio_offset + detune
; so the byte you write here is the absolute pitch only when the other fields
; are zero. The engine's MUSIC_CH_OCTAVE field is stored as a signed semitone
; shift (mus_octave_shift bakes in the engine's +12 input bias).
;
; Constant naming: `<L><a><N>`. L = note letter (C..G,A,B), a = `n` (natural)
; or `s` (sharp), N = octave number.
DEF Cn2 EQU 0
DEF Cs2 EQU 1
DEF Dn2 EQU 2
DEF Ds2 EQU 3
DEF En2 EQU 4
DEF Fn2 EQU 5
DEF Fs2 EQU 6
DEF Gn2 EQU 7
DEF Gs2 EQU 8
DEF An2 EQU 9
DEF As2 EQU 10
DEF Bn2 EQU 11
DEF Cn3 EQU 12
DEF Cs3 EQU 13
DEF Dn3 EQU 14
DEF Ds3 EQU 15
DEF En3 EQU 16
DEF Fn3 EQU 17
DEF Fs3 EQU 18
DEF Gn3 EQU 19
DEF Gs3 EQU 20
DEF An3 EQU 21
DEF As3 EQU 22
DEF Bn3 EQU 23
DEF Cn4 EQU 24 ; (middle C, ~262 Hz)
DEF Cs4 EQU 25
DEF Dn4 EQU 26
DEF Ds4 EQU 27
DEF En4 EQU 28
DEF Fn4 EQU 29
DEF Fs4 EQU 30
DEF Gn4 EQU 31
DEF Gs4 EQU 32
DEF An4 EQU 33
DEF As4 EQU 34
DEF Bn4 EQU 35
DEF Cn5 EQU 36
DEF Cs5 EQU 37
DEF Dn5 EQU 38
DEF Ds5 EQU 39
DEF En5 EQU 40
DEF Fn5 EQU 41
DEF Fs5 EQU 42
DEF Gn5 EQU 43
DEF Gs5 EQU 44
DEF An5 EQU 45
DEF As5 EQU 46
DEF Bn5 EQU 47
DEF Cn6 EQU 48
DEF Cs6 EQU 49
DEF Dn6 EQU 50
DEF Ds6 EQU 51
DEF En6 EQU 52
DEF Fn6 EQU 53
DEF Fs6 EQU 54
DEF Gn6 EQU 55
DEF Gs6 EQU 56
DEF An6 EQU 57
DEF As6 EQU 58
DEF Bn6 EQU 59
DEF Cn7 EQU 60
DEF Cs7 EQU 61
DEF Dn7 EQU 62
DEF Ds7 EQU 63
DEF En7 EQU 64
DEF Fn7 EQU 65
DEF Fs7 EQU 66
DEF Gn7 EQU 67
DEF Gs7 EQU 68
DEF An7 EQU 69
DEF As7 EQU 70
DEF Bn7 EQU 71
DEF Cn8 EQU 72
DEF Cs8 EQU 73
DEF Dn8 EQU 74
DEF Ds8 EQU 75
DEF En8 EQU 76
DEF Fn8 EQU 77
DEF Fs8 EQU 78
DEF Gn8 EQU 79
