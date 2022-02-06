MERCILAK_TILES = 6
OAM_SIZE_BYTES = 4
SIZE_OF_MERCILAK = MERCILAK_TILES * OAM_SIZE_BYTES

MERCILAK_TILE_0 = $E2
MERCILAK_INIT_X = $05
MERCILAK_INIT_Y = $05

.zeropage
zpbMercilakPosX: .res 1, $00
zpbMercilakPosY: .res 1, $00
zpmOAMSpriteMercilak: .res SIZE_OF_MERCILAK, $00

.code 

; DMA the OAM data for mercilak
dma_sprite_mercilak: 
    ; Set the OAM Address first
    lda #$10
    sta OAMADDL
    lda #$00
    sta OAMADDH

    ; Following procedure in (2-17-3) using ch0

    lda #$00        ; DMA 1addr LH, CPU -> PPU autoinc
    ;lda #$04        ; DMA 4addr LH, CPU -> PPU autoinc
    ;lda #$01        ; DMA 2addr LH, CPU -> PPU autoinc
    sta DMAPx + CH0

    lda #$04        ; B address for OAM 2104 
    sta BBADx + CH0

    lda #^zpmOAMSpriteMercilak
    ldx #zpmOAMSpriteMercilak
    sta A1Bx + CH0
    stx A1TxL + CH0

    ldy #SIZE_OF_MERCILAK
    sty DASxL + CH0

    lda #$01 
    sta MDMAEN

    @merclilak_high_table:
    ; Set high table spots of obj 8-13, 14&15 dont change
    lda #$01
    sta OAMADDL
    lda #$01
    sta OAMADDH

    stz OAMDATA     ; small nonnegative for Obj 8-11
    lda #50         ; Low High order
    sta OAMDATA     ; small nonnegnative for 12,13. 0 for 14,15
rts 

moam_load_mercilak:
    ; Set bytes 2 and 3 of each 6 tiles
    ; Set high pri and palette byte and name to same everything
    ldx #(%00110100 << 8 | MERCILAK_TILE_0)
    stx zpmOAMSpriteMercilak + 0 * OAM_SIZE_BYTES + 2
    inx
    stx zpmOAMSpriteMercilak + 1 * OAM_SIZE_BYTES + 2
    inx
    stx zpmOAMSpriteMercilak + 2 * OAM_SIZE_BYTES + 2
    inx
    stx zpmOAMSpriteMercilak + 3 * OAM_SIZE_BYTES + 2
    inx
    stx zpmOAMSpriteMercilak + 4 * OAM_SIZE_BYTES + 2
    inx
    stx zpmOAMSpriteMercilak + 5 * OAM_SIZE_BYTES + 2


    ; Set bytes 0 of each 6 tile VPOS
    lda #(MERCILAK_INIT_Y + 0)
    sta zpmOAMSpriteMercilak + 0 * OAM_SIZE_BYTES + 1
    sta zpmOAMSpriteMercilak + 1 * OAM_SIZE_BYTES + 1
    lda #(MERCILAK_INIT_Y + 8)
    sta zpmOAMSpriteMercilak + 2 * OAM_SIZE_BYTES + 1
    sta zpmOAMSpriteMercilak + 3 * OAM_SIZE_BYTES + 1
    lda #(MERCILAK_INIT_Y + 16)
    sta zpmOAMSpriteMercilak + 4 * OAM_SIZE_BYTES + 1
    sta zpmOAMSpriteMercilak + 5 * OAM_SIZE_BYTES + 1

    ; Set bytes 1 of each 6 tile HPOS
    lda #(MERCILAK_INIT_X + 0)
    sta zpmOAMSpriteMercilak + 0 * OAM_SIZE_BYTES + 0
    sta zpmOAMSpriteMercilak + 2 * OAM_SIZE_BYTES + 0
    sta zpmOAMSpriteMercilak + 4 * OAM_SIZE_BYTES + 0
    lda #(MERCILAK_INIT_X + 8)
    sta zpmOAMSpriteMercilak + 1 * OAM_SIZE_BYTES + 0
    sta zpmOAMSpriteMercilak + 3 * OAM_SIZE_BYTES + 0
    sta zpmOAMSpriteMercilak + 5 * OAM_SIZE_BYTES + 0
rts

