; ANCHOR: title-screen-start
INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "TitleScreenState", ROM0

PressPlayText::  db "press a to play", 255
 
titleScreenTileData: INCBIN "src/generated/backgrounds/title-screen.2bpp"
titleScreenTileDataEnd:
 
titleScreenTileMap: INCBIN "src/generated/backgrounds/title-screen.tilemap"
titleScreenTileMapEnd:

titleScreenPalData:INCBIN "src/generated/backgrounds/title-screen.pal"
titleScreenPalDataEnd:

tileScreenAttrmap:
    INCBIN "src/generated/backgrounds/title-screen.attrmap"
tileScreenAttrmapEnd:

; ANCHOR_END: title-screen-start
; ANCHOR: title-screen-init
InitTitleScreenState::

	call DrawTitleScreen

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

    ret
; ANCHOR_END: title-screen-init
	
; ANCHOR: draw-title-screen
DrawTitleScreen::
	
    ; Load palette data from logo.pal
    ld hl, titleScreenPalData
    ld b, titleScreenPalDataEnd - titleScreenPalData  ; number of bytes
    ld a, %10000000                 ; rBCPS index 0, auto-increment
    ld [rBCPS], a

    titleScreenPalLoop:
        ld a, [hl]
        ld [rBCPD], a
        inc hl
        dec b
        jr nz, titleScreenPalLoop

	; Copy the tile data
	ld de, titleScreenTileData ; de contains the address where data will be copied from;
	ld hl, $9340 ; hl contains the address where data will be copied to;
	ld bc, titleScreenTileDataEnd - titleScreenTileData ; bc contains how many bytes we have to copy.
	call CopyDEintoMemoryAtHL
	
    ; --- VRAM Bank Switching for Attribute Map ---
    ; First, switch to VRAM Bank 1 to load the attribute map
    ld a, 1
    ld [rVBK], a

    ; Copy attribute map to VRAM Bank 1
    ld de, tileScreenAttrmap
    ld hl, $9800
    ld bc, tileScreenAttrmapEnd - tileScreenAttrmap
    tileScreenAttrmapLoop:
        ld a, [de]
        ld [hli], a
        inc de
        dec bc
        ld a, b
        or a, c
        jp nz, tileScreenAttrmapLoop

    ; Switch back to VRAM Bank 0 for regular operations
    ld a, 0
    ld [rVBK], a

	; Copy the tilemap
	ld de, titleScreenTileMap
	ld hl, $9800
	ld bc, titleScreenTileMapEnd - titleScreenTileMap
	jp CopyDEintoMemoryAtHL_With52Offset

; ANCHOR_END: draw-title-screen

; ANCHOR: update-title-screen
UpdateTitleScreenState::


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Continue to next game state
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Call Our function that draws text onto background/window tiles
    ld de, $99C3
    ld hl, PressPlayText
    call DrawTextTilesLoop

    	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

    ret
; ANCHOR_END: update-title-screen
