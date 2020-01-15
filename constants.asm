INCLUDE "hram.asm"
INCLUDE "constants/screens.asm"
INCLUDE "constants/password.asm"

; MBC5
MBC5RomBank EQU  $2000

; Register A has a value of $11 during hardware startup, if a Game Boy Color is running.
GBC_MODE EQU $11
