; ANCHOR: title-screen-start
INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "TitleScreenState", ROM0

StartText::  db "start game", 255
FlagText:: db 1, 255

ClearFlagText:: db 0, 255
TrainText::  db "train", 255
OptionsText::  db "options", 255

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
    ; Call Our function that draws text onto background/window tiles
    ; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

	call WaitForOneVBlank

    xor a
    ld de, $9862

    ld hl, FlagText
    call DrawTextTilesLoop
     ;;;;;first line;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld de, $9864

    ld hl, StartText
    call DrawTextTilesLoop

    ;;;;;second line;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld de, $98c4

    ld hl, TrainText
    call DrawTextTilesLoop
    
    ;;;;;third line;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld de, $9924

    ld hl, OptionsText
    call DrawTextTilesLoop

    ; Wait for A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld a, PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction

    ld de, $9862

    ld hl, ClearFlagText
    call DrawTextTilesLoop

    ld de, $98c2

    ld hl, FlagText
    call DrawTextTilesLoop

    
    ; Wait for A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld a, PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction

    ld de, $98c2

    ld hl, ClearFlagText
    call DrawTextTilesLoop

    ld de, $9922

    ld hl, FlagText
    call DrawTextTilesLoop

    ret
; ANCHOR_END: update-title-screen
