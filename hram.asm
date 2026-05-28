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

DEF hLevelPixelWidth  EQU $ffa6
DEF hLevelPixelHeight EQU $ffa8

DEF hDiggingMetatileReplacements EQU $ffaa

; Player flags bitfield.
;   bit 1 = collided with an object this frame;
;   bit 2 = dead/dying;
;   bit 4 = digging enabled;
;   bit 6 = state changed (re-init anim).
DEF hPlayerFlags          EQU $ffad
DEF hPlayerTerrainContact EQU $ffae
; Player posture flags.
;    bit 0 = crouching (shorter hitbox);
;    bit 4 = dig pose.
DEF hPlayerPose  EQU $ffaf
DEF hPlayerState EQU $ffb0

DEF hLevelCleared EQU $ffb5

DEF hPlayerXVelocity EQU $ffc4
DEF hPlayerYVelocity EQU $ffc6

; The current pixel coordinates of the player
DEF hPlayerXPos EQU $ffc8
DEF hPlayerYPos EQU $ffca

DEF hCameraXOffsetScreenRight EQU $ffdb

DEF hMovementScriptTimer EQU $ffe4
DEF hMovementScriptState EQU $ffe5

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
