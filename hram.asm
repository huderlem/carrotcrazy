hDMARoutine EQU $ff80

; Set to non-zero value to indicate the game is paused.
hPaused EQU $ff92

; Increments by one every frame. Does not increment when game is paused.
hFrameCounter EQU $ff94

hCameraXOffset EQU $ffa0
hCameraYOffset EQU $ffa2

hLevelPixelWidth  EQU $ffa6
hLevelPixelHeight EQU $ffa8

hCurHealth EQU $ffed
hMaxHealth EQU $ffee
hNumLives  EQU $ffef

; Holds a 2-byte little-endian BCD value.
hScore EQU $fff0

hNumCarrots  EQU $fff3
hCarrotMeter EQU $fff4

; Set to $11 if running on a Game Boy Color. $00 otherwise.
hGameBoyColorDetection EQU $FFFE
