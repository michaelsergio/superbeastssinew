.code

; Assumes Tile Data is loaded at $280 or $28 in VRAM
; Loads 4 tiles per row
load_simple_tilemap_level_1:

    lda #V_INC_1
    sta VMAIN        ; Single Inc
 
    ldx #$0400
    ;ldx #($0400 + $0 + $0 * $20) ; screen position 0 TODO: change later
    stx VMADDL

    ; Set an index for the x
    ldx #$08
    ldy #$0450      ; 04 for color palette 1, number 50 for basic tile set
    @do_row:
        jsr fill_row_with_tiles
        jsr fill_row_with_tiles
        jsr fill_row_with_tiles
        jsr fill_row_with_tiles
        iny
        dex 
    bne @do_row
rts

; Assume VMADDL is currently set to proper position autoinc-1
; Need Y to be the tile data - attr+name
; Modifies A
fill_row_with_tiles:
    ; Write Y 32 times.
    lda #$4
    @loop_row:
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        sty VMDATAL
        dea
    bne @loop_row
rts