; Collectible Entities
DEF CARROT          EQU 0
DEF HABANERO_CARROT EQU 1
DEF SUPER_CARROT    EQU 2
DEF CLAPBOARD_0     EQU 3
DEF CLAPBOARD_1     EQU 4
DEF CLAPBOARD_2     EQU 5
DEF CLAPBOARD_3     EQU 6
DEF TWEETY_E        EQU 7
DEF TWEETY_X        EQU 8
DEF TWEETY_T        EQU 9
DEF TWEETY_R        EQU 10
DEF TWEETY_A        EQU 11
DEF TWEETY_HEART    EQU 12
DEF TWEETY_1UP      EQU 13

; A boss-capable character's *Sprites table (see HandleCharacterEntity) is preceded
; by two of these project records: the boss variant first, then the enemy variant.
rsreset
DEF CHARPROJ_MASK  rb   ; $00  walk-pace mask, ANDed with the frame counter
DEF CHARPROJ_SPAWN rb 9 ; $01  9-byte projectile_spawn struct (see macros.asm)
DEF CHARPROJ_SIZE EQU _RS ; $0a
; Distances back from the *Sprites label to each field the handler reads:
DEF CHARPROJ_ENEMY_MASK   EQU CHARPROJ_SIZE - CHARPROJ_MASK      ; $0a
DEF CHARPROJ_ENEMY_SPAWN  EQU CHARPROJ_SIZE - CHARPROJ_SPAWN     ; $09
DEF CHARPROJ_BOSS_SPAWN   EQU 2 * CHARPROJ_SIZE - CHARPROJ_SPAWN ; $13
