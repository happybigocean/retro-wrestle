INCLUDE "src/main/utils/hardware.inc"

SECTION "GameVariables", WRAM0

wLastKeys:: db
wCurKeys:: db
wNewKeys:: db
wGameState::db
wCurOption::db 

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header

EntryPoint:
; ANCHOR_END: entry-point
	
; ANCHOR: entry-point-end
	; Shut down audio circuitry
	xor a
	ld [rNR52], a
	ld [wGameState], a

	; Wait for the vertical blank phase before initiating the library
    call WaitForOneVBlank

	; Turn the LCD off
	xor a
	ld [rLCDC], a

	; Load our common text font into VRAM
	call LoadTextFontIntoVRAM

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_WINON | LCDCF_WIN9C00
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a    

; ANCHOR_END: entry-point-end
; ANCHOR: next-game-state

NextGameState::

	; Do not turn the LCD off outside of VBlank
	call WaitForOneVBlank
	call ClearBackground

	; Turn the LCD off
	xor a
	ld [rLCDC], a

	ld a, 48      ; X offset = 32 pixels
	ld [rSCX], a

	ld a, 55      ; Y offset = 42 pixels
	ld [rSCY], a

	xor a
	ld [rWX], a
	ld [rWY], a

	; disable interrupts
	call DisableInterrupts

	; Initiate the next state
	ld a, [wGameState]
	cp 2 ; 2 = Gameplay
	call z, InitGamePlayState
	ld a, [wGameState]
	cp 1 ; 1 = Menu
	call z, InitMenuState
	ld a, [wGameState]
	and a ; 0 = Title
	call z, InitTitleScreenState

	; Update the next state
	ld a, [wGameState]
	cp 2 ; 2 = Gameplay
	jp z, UpdateGamePlayState
	cp 1 ; 1 = Menu
	jp z, UpdateMenuState
	jp UpdateTitleScreenState

; ANCHOR_END: next-game-state