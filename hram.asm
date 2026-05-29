DEF hDMARoutine EQU $ff80

; General-purpose scratch bytes
DEF hTemp  EQU $ff8a
DEF hTemp2 EQU $ff8b

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

DEF hSlopeClampOverride EQU $ffac

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

DEF hPlayerTransformTimer EQU $ffb1

DEF hPlayerBounceTimer EQU $ffb2
DEF hPlayerHoverTimer  EQU $ffb3
DEF hPlayerHammerTimer EQU $ffb4

DEF hLevelCleared EQU $ffb5

DEF hHabaneroTimer EQU $ffb6

DEF hPlayerStateTimer EQU $ffb7
DEF hPlayerDeathTimer EQU $ffb8
DEF hPlayerHurtTimer EQU $ffb9

; Three 16-bit position clamp bounds applied while riding vehicles.
; Which axis (X or Y) each bounds depends on the active vehicle handler.
DEF hPlayerClampBoundA EQU $ffba
DEF hPlayerClampBoundB EQU $ffbc
DEF hPlayerClampBoundC EQU $ffbe

DEF hPlayerDigEnterTimer  EQU $ffc0
DEF hPlayerDigEmergeTimer EQU $ffc1
; signed; sign selects launch direction
DEF hPlayerLaunchXTimer   EQU $ffc2
DEF hPlayerLaunchYTimer   EQU $ffc3

DEF hPlayerXAcceleration EQU $ffc4
DEF hPlayerXVelocity     EQU $ffc5
DEF hPlayerYVelocity     EQU $ffc6

; The current pixel coordinates of the player
DEF hPlayerXSubpixel     EQU $ffc7
DEF hPlayerXPos EQU $ffc8
DEF hPlayerYPos EQU $ffca
DEF hPlayerYSubpixel EQU $ffcc
DEF hPlayerPrevXPos EQU $ffcd
DEF hPlayerPrevYPos EQU $ffcf

; 16-bit; accumulated fall distance, raises terminal fall velocity past a threshold
DEF hPlayerFallDistance EQU $ffd1

; $00 = left hitbox edge, $ff = right.
DEF hCollisionProbeEdge EQU $ffd3
DEF hCollisionProbeCount EQU $ffd4

DEF hPlayerAnimationTimer EQU $ffd5
; 16-bit pointer to the current player animation data
DEF hPlayerAnimationPtr EQU $ffd6

DEF hPlayerSpriteFrameBank EQU $ffd8
DEF hPlayerSpriteFramePtr  EQU $ffd9

DEF hCameraXOffsetScreenRight EQU $ffdb

; 16-bit value; Player center X in world coords (hPlayerXPos + 8); entities read it for proximity/collision checks.
DEF hPlayerCollisionXPos EQU $ffdd
; 16-bit value; player top-edge Y in world coords (hPlayerYPos - height)
DEF hPlayerCollisionYPos EQU $ffdf

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
