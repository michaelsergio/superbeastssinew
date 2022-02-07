
LEVEL_SIZE = 32*28*2 ; Assume a level is 32x28 x2 bytes

.macro tiled_load_level_as_bg level_addr, vram_tiles_addr, palette_num
    ; Setup Screen
    lda #V_INC_1
    sta VMAIN        ; Single Inc
    ldx #$0400      ;#($0400 + $0 + $0 * $20) ; screen position 0 
    stx VMADDL

    ; read the data byte by byte
    ldx #$0000
    load_tile:
        ; This is the status byte
        lda level_addr, x
        ora #(palette_num << 2)
        ora #>vram_tiles_addr
        sta dpTmp1                  ; store as high byte
        inx
        lda level_addr, x
        clc
        adc #<vram_tiles_addr
        sta dpTmp0                  ; store as low byte
        ldy dpTmp0                  ; Y writes L then H
        sty VMDATAL     
        inx
        cpx #LEVEL_SIZE
    bne load_tile
.endmacro

level_load:
    ; Start at some address
    ; Need a tile offset number
    ; Need a palette number
rts