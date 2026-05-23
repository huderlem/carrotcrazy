DEF hDMARoutine EQU $ff80

; Set to non-zero value to indicate the game is paused.
DEF hPaused EQU $ff92

; Holds the number of active sprites * 4
DEF hActiveSprites EQU $ff93

; Increments by one every frame. Does not increment when game is paused.
DEF hFrameCounter EQU $ff94

DEF hForcedSideScrollSpeed EQU $ff95

DEF hCameraXOffset EQU $ffa0
DEF hCameraYOffset EQU $ffa2

; $ffaf = player state (crouching, etc.)

DEF hLevelPixelWidth  EQU $ffa6
DEF hLevelPixelHeight EQU $ffa8

DEF hDiggingMetatileReplacements EQU $ffaa

DEF hLevelCleared EQU $ffb5

; The current pixel coordinates of the player
DEF hPlayerXPos EQU $ffc8
DEF hPlayerYPos EQU $ffca

DEF hCameraXOffsetScreenRight EQU $ffdb

DEF hCurHealth EQU $ffed
DEF hMaxHealth EQU $ffee
DEF hNumLives  EQU $ffef

; Holds a 2-byte little-endian BCD value.
DEF hScore EQU $fff0

DEF hNumClapboards EQU $fff2
DEF hNumCarrots    EQU $fff3
DEF hCarrotMeter   EQU $fff4

DEF hEXTRALetterHUD EQU $fff5

DEF hClapboardPieceHUD EQU $fff9

; Holds the count of obtained letters for EXTRA.
; If all letters were obtained, the player gets to go to the bonus stage.
DEF hEXTRALetters EQU $fffd

; Set to $11 if running on a Game Boy Color. $00 otherwise.
DEF hGameBoyColorDetection EQU $FFFE
