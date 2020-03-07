hDMARoutine EQU $ff80

; Set to non-zero value to indicate the game is paused.
hPaused EQU $ff92

; Holds the number of active sprites * 4
hActiveSprites EQU $ff93

; Increments by one every frame. Does not increment when game is paused.
hFrameCounter EQU $ff94

hForcedSideScrollSpeed EQU $ff95

hCameraXOffset EQU $ffa0
hCameraYOffset EQU $ffa2

; $ffaf = player state (crouching, etc.)

hLevelPixelWidth  EQU $ffa6
hLevelPixelHeight EQU $ffa8

hDiggingMetatileReplacements EQU $ffaa

hLevelCleared EQU $ffb5

; The current pixel coordinates of the player
hPlayerXPos EQU $ffc8
hPlayerYPos EQU $ffca

hCameraXOffsetScreenRight EQU $ffdb

hCurHealth EQU $ffed
hMaxHealth EQU $ffee
hNumLives  EQU $ffef

; Holds a 2-byte little-endian BCD value.
hScore EQU $fff0

hNumClapboards EQU $fff2
hNumCarrots    EQU $fff3
hCarrotMeter   EQU $fff4

hEXTRALetterHUD EQU $fff5

hClapboardPieceHUD EQU $fff9

; Holds the count of obtained letters for EXTRA.
; If all letters were obtained, the player gets to go to the bonus stage.
hEXTRALetters EQU $fffd

; Set to $11 if running on a Game Boy Color. $00 otherwise.
hGameBoyColorDetection EQU $FFFE
