; Set to non-zero value to indicate the game is paused.
hPaused EQU $ff92

; Increments by one every frame. Does not increment when game is paused.
hFrameCounter EQU $ff94

; Holds a 2-byte little-endian BCD value.
hScore EQU $fff0

hNumCarrots  EQU $fff3
hCarrotMeter EQU $fff4

; Set to $11 if running on a Game Boy Color. $00 otherwise.
hGameBoyColorDetection EQU $FFFE
