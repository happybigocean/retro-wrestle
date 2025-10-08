; ANCHOR: background-utils
include "src/main/utils/hardware.inc"

SECTION "Background", ROM0

ClearBackground::

	; Turn the LCD off
	xor a
	ld [rLCDC], a

	ld bc, 1024
	ld hl, $9800

	ClearBackgroundLoop:

		xor a
		ld [hli], a

		
		dec bc
		ld a, b
		or c

		jp nz, ClearBackgroundLoop

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

	ret

ClearBackgroundWithAttr::

	; Turn the LCD off
	xor a
	ld [rLCDC], a

	ld bc, 1024
	ld hl, $9800

	ClearBackLoop:

		xor a
		ld [hli], a

		dec bc
		ld a, b
		or c

		jp nz, ClearBackLoop

	ld a, 1           ; use palette #1 instead of 0
	ld [rVBK], a
	ld bc, 1024
	ld hl, $9800

	ClearBackgroundWithAttrLoop:
		xor a
		ld [hli], a       ; set all tiles to palette #1
		dec bc
		ld a, b
		or c
		jp nz, ClearBackgroundWithAttrLoop

	ld a, 0           ; use palette #0 instead of 1
	ld [rVBK], a

	ld bc, 1024
	ld hl, $9340

	ClearBackgroundWithAttrTileDataLoop:
		xor a
		ld [hli], a       ; set all tiles to palette #1
		dec bc
		ld a, b
		or c
		jp nz, ClearBackgroundWithAttrTileDataLoop

	; Turn the LCD on
	ld a, LCDCF_ON  | LCDCF_BGON|LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a

	ret
; ANCHOR_END: background-utils
