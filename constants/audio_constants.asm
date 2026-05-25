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

; Pointer to this channel's song "order list" (a list of pointers to command
; streams). When a stream ends, the engine advances through this list.
DEF MUSIC_CH_ORDER_PTR  EQU $00 ; 2 bytes

; Pointer to the current position in the channel's command stream.
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

; Pointer to a per-note callback routine (invoked when flag bit 5 is set).
DEF MUSIC_CH_NOTE_CB    EQU $3e ; 2 bytes


; === Command stream opcodes ===
; A command stream is a byte sequence. Bytes below FIRST_MUSIC_COMMAND are note
; values; bytes >= FIRST_MUSIC_COMMAND are commands, dispatched by range:
;   $60-$84  table-dispatched commands (MusicCommandTable)
;   $85-$93  macro / sub-stream calls
;   $94-$AF  select arpeggio table
;   $B0-$BF  set software volume envelope
;   $C0-$EF  set note duration (length = opcode - $BF)
;   $F0-$FF  call command stream, repeating (opcode - $EE) times
DEF FIRST_MUSIC_COMMAND EQU $60
