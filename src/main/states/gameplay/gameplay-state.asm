; ANCHOR: title-screen-start
INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "GameplayState", ROM0

arenaTileData: INCBIN "src/generated/backgrounds/arena.2bpp"
arenaTileDataEnd:

arenaTileMap: INCBIN "src/generated/backgrounds/arena.tilemap"
arenaTileMapEnd:

arenaPalData:INCBIN "src/generated/backgrounds/arena.pal"
arenaPalDataEnd:

arenaAttrmap:
    INCBIN "src/generated/backgrounds/arena.attrmap"
arenaAttrmapEnd:

; ANCHOR_END: gameplay-start
; ANCHOR: gameplay-init
InitGamePlayState::

    ld a, 42      ; X offset = 42 pixels
	ld [rSCX], a

    ld a, 35      ; Y offset = 38 pixels
	ld [rSCY], a

	call DrawArena

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

    ret
; ANCHOR_END: gameplay-init

; ANCHOR: draw-arena
DrawArena::

    ; Load palette data from arena.pal
	ld hl, arenaPalData
    ld b, arenaPalDataEnd - arenaPalData  ; number of bytes
    ld a, %10000000                 ; rBCPS index 0, auto-increment
    ld [rBCPS], a

    arenaPalLoop:
        ld a, [hl]
        ld [rBCPD], a
        inc hl
        dec b
        jr nz, arenaPalLoop

	; Copy the tile data
	ld de, arenaTileData ; de contains the address where data will be copied from;
	ld hl, $9340 ; hl contains the address where data will be copied to;
	ld bc, arenaTileDataEnd - arenaTileData ; bc contains how many bytes we have to copy.
	call CopyDEintoMemoryAtHL
	
    ; --- VRAM Bank Switching for Attribute Map ---
    ; First, switch to VRAM Bank 1 to load the attribute map
    ld a, 1
    ld [rVBK], a

    ; Copy attribute map to VRAM Bank 1
    ld de, arenaAttrmap
    ld hl, $9800
    ld bc, arenaAttrmapEnd - arenaAttrmap
    arenaAttrmapLoop:
        ld a, [de]
        ld [hli], a
        inc de
        dec bc
        ld a, b
        or a, c
        jp nz, arenaAttrmapLoop

    ; Switch back to VRAM Bank 0 for regular operations
    ld a, 0
    ld [rVBK], a

	; Copy the tilemap
	ld de, arenaTileMap
	ld hl, $9800
	ld bc, arenaTileMapEnd - arenaTileMap
	jp CopyDEintoMemoryAtHL_With52Offset

; ANCHOR_END: draw-arena

; ANCHOR: update-gameplay
UpdateGamePlayState::
    ; Call Our function that draws text onto background/window tiles
    
    ; Wait for A
    ld a, PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction

    ; Clear the background
    call ClearBackgroundWithAttr

    ; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

    ld a, 1
    ld [wGameState], a
    jp NextGameState
    ret
; ANCHOR_END: update-gameplay
