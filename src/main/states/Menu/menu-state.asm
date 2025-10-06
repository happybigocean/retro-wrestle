INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "MenuStateASM", ROM0

InitMenuState::
    ; Turn on LCD so the player can see menu right away
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
    ld [rLCDC], a

    ; Initialize the current option to 0 (first line)
    xor a
    ld [wCurOption], a
    ret

; =======================
; TEXT DATA
; =======================
StartText::     db "start game", 255
FlagText::      db 1, 255
ClearFlagText:: db 0, 255
TrainText::     db "train", 255
OptionsText::   db "options", 255

; -----------------------
; Wait for Input
; -----------------------
WaitForInput::
    call Input               ; read current keys
    ld a, [wNewKeys]         ; check for newly pressed keys
    or a                     ; set zero flag if zero
    jr z, WaitForInput        ; loop until a key is pressed
    ret
    
; =======================
; MAIN MENU UPDATE LOOP
; =======================
UpdateMenuState::

.loop
    ; Wait for VBlank to avoid tearing
    call WaitForOneVBlank

    ; Clear previous flag positions
    ld de, $9968
    ld hl, ClearFlagText
    call DrawTextTilesLoop
    ld de, $99c8
    ld hl, ClearFlagText
    call DrawTextTilesLoop
    ld de, $9A28
    ld hl, ClearFlagText
    call DrawTextTilesLoop

    ; Draw menu text
    ld de, $996A
    ld hl, StartText
    call DrawTextTilesLoop
    ld de, $99cA
    ld hl, TrainText
    call DrawTextTilesLoop
    ld de, $9A2A
    ld hl, OptionsText
    call DrawTextTilesLoop

    ; Draw flag for current option
    ld a, [wCurOption]
    cp 0
    jp nz, .flag_check_1
    ld de, $9968
    jp .flag_draw
.flag_check_1
    cp 1
    jp nz, .flag_check_2
    ld de, $99c8
    jp .flag_draw
.flag_check_2
    ld de, $9A28
.flag_draw
    ld hl, FlagText
    call DrawTextTilesLoop

    ; Read controller input
    call Input       ; updates wCurKeys and wNewKeys

    ; ---- Handle UP ----
    ld a, [wNewKeys]
    and PADF_UP
    jp z, .check_down     ; if UP not pressed, check DOWN
    ld a, [wCurOption]
    cp 0
    jp z, .check_down     ; already at top, skip
    dec a
    ld [wCurOption], a
    jp .loop              ; redraw immediately

.check_down
    ld a, [wNewKeys]
    and PADF_DOWN
    jp z, .check_a        ; if DOWN not pressed, check A
    ld a, [wCurOption]
    cp 2
    jp z, .check_a        ; already at bottom, skip
    inc a
    ld [wCurOption], a
    jp .loop              ; redraw immediately

.check_a
    ld a, [wNewKeys]
    and PADF_A
    jp z, .loop           ; if A not pressed, continue loop

    ; If A pressed, start game
    ld a, 2
    ld [wGameState], a
    jp NextGameState
