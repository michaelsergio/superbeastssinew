.code 
switch_tile:
    ldx #$0400          ; Base address of VRAM
    lda TileSelector
    tax
    stx VMADDL    ; Old tile
    stz VMDATAL   ; Clear it

    inc         ; store next tile
    sta TileSelector
    tax
    stx VMADDL   ; Next tile addr
    lda #$01    ; set to tile name 1
    sta VMDATAL
    lda #$C0 ; Flip V & H for fun
    sta VMDATAH

    rts