.zeropage
bSpritePosX: .res 1, $00
bSpritePosY: .res 1, $00

.code 
oam_load_man_with_pants: 
    jsr oam_load_man
    jsr oam_load_man_pants
rts

oam_load_man:
    ; Set an initial position for sprite
    lda #$0F 
    sta z:bSpritePosX
    sta z:bSpritePosY

    lda #%00000000  ;sssnnbbb b=base_sel_bits n=name_selection s=size_from_table
    sta OBSEL

    ; Sprite Table 1 at OAM $00
    lda #$00
    sta OAMADDL     
    lda #$00
    sta OAMADDH     ; write to oam slot 0000

    lda z:bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda z:bSpritePosY ; OBJ V pos
    sta OAMDATA

    lda #$00        ; Name - Face at location $100
    sta OAMDATA
    lda #%00110011  ; Highest priority / palette 1 
    sta OAMDATA     ; HVFlip/Pri/ColorPalette/9n

    ; Sprite Table 2 at OAM $0100
    lda #$00
    sta OAMADDL     
    lda #$01
    sta OAMADDH     ; write to oam slot 256 ($100)
    ; We want Obj 0 to be small and not use H MSB
    stz OAMDATA
    stz OAMDATA
rts

oam_load_man_pants:
    lda #%00000000  ;sssnnbbb b=base_sel_bits n=name_selection s=size_from_table
    sta OBSEL

    ; Sprite Table 1 at OAM $02
    lda #$02
    sta OAMADDL     
    lda #$00
    sta OAMADDH     ; write to oam slot 0000

    lda z:bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda z:bSpritePosY ; OBJ V pos
    inc
    sta OAMDATA

    lda #$01        ; Name - Pants at location $102
    sta OAMDATA
    lda #%00110011  ; Highest priority / palette 1 
    sta OAMDATA     ; HVFlip/Pri/ColorPalette/9n

    ; Sprite Table 2 at OAM $0100 (OAM 256) has sprites data for OBJ 0-7
    lda #$00
    sta OAMADDL     
    lda #$0A
    sta OAMADDH     ; write to oam slot 256 ($100)
    ; We want Obj 0 to be small and not use H MSB
    stz OAMDATA
    stz OAMDATA
rts
