INCLUDE "src/main/utils/hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0

EntryPoint:
    
WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ld a, 0
    ld [rLCDC], a

; Load palette data from logo.pal
ld hl, LogoPalData
ld b, LogoPalEnd - LogoPalData  ; number of bytes
ld a, %10000000                 ; rBCPS index 0, auto-increment
ld [rBCPS], a

LoadPaletteLoop:
    ld a, [hl]
    ld [rBCPD], a
    inc hl
    dec b
    jr nz, LoadPaletteLoop

; Copy tile data
ld de, Tiles
ld hl, $9000
ld bc, TilesEnd - Tiles
CopyTiles:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTiles

; --- VRAM Bank Switching for Attribute Map ---
; First, switch to VRAM Bank 1 to load the attribute map
ld a, 1
ld [rVBK], a

; Copy attribute map to VRAM Bank 1
ld de, Attrmap
ld hl, $9800
ld bc, AttrmapEnd - Attrmap
CopyAttrmap:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyAttrmap

; Switch back to VRAM Bank 0 for regular operations
ld a, 0
ld [rVBK], a
   
; Copy tilemap
ld de, Tilemap
ld hl, $9800
ld bc, TilemapEnd - Tilemap
CopyTilemap:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTilemap

; Set horizontal scroll (SCX)
ld a, 48      ; X offset = 32 pixels
ld [rSCX], a

; Set vertical scroll (SCY)
ld a, 55      ; Y offset = 42 pixels
ld [rSCY], a

; Turn on LCD
ld a, LCDCF_ON | LCDCF_BGON
ld [rLCDC], a

Done:
    jp Done

; --- Data ---
Tiles:
    INCBIN "src/generated/backgrounds/logo.2bpp"
TilesEnd:

Tilemap:
    INCBIN "src/generated/backgrounds/logo.tilemap"
TilemapEnd:

Attrmap:
    INCBIN "src/generated/backgrounds/logo.attrmap"
AttrmapEnd:

LogoPalData:
    INCBIN "src/generated/backgrounds/logo.pal"
LogoPalEnd:
