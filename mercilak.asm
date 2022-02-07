
MERCILAK_TILE_0 = $E2
MERCILAK_INIT_X = $15
MERCILAK_INIT_Y = $15

; Must store things in little endian. Just like memory
.struct OAMSprite
    posX .byte
    posY .byte
    name .byte
    status .byte
.endstruct

.struct SpriteMercilak
    sub0 .tag OAMSprite
    sub1 .tag OAMSprite
    sub2 .tag OAMSprite
    sub3 .tag OAMSprite
    sub4 .tag OAMSprite
    sub5 .tag OAMSprite
.endstruct

OAM_SIZE_BYTES = .sizeof(OAMSprite)

.zeropage
zpbMercilakPosX: .res 1, $00
zpbMercilakPosY: .res 1, $00
zpmOAMSpriteMercilak: .tag SpriteMercilak

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
    sta DMAPx + CH0

    lda #$04        ; B address for OAM 2104 
    sta BBADx + CH0

    lda #^zpmOAMSpriteMercilak  ; Bank address. Should I force 7E for this over ZP?
    ldx #zpmOAMSpriteMercilak
    sta A1Bx + CH0
    stx A1TxL + CH0

    ldy #.sizeof(SpriteMercilak)
    sty DASxL + CH0

    lda #$01 
    sta MDMAEN
rts 

; This is used just for the offscreen and the SM/LG select.
dma_sprite_mercilak_high_table: 
    ; Set high table spots of obj 8-13, 14&15 dont change
    lda #$01
    sta OAMADDL
    lda #$01
    sta OAMADDH

    stz OAMDATA     ; small nonnegative for Obj 8-11
    lda #$50         ; Low High order
    sta OAMDATA     ; small nonnegnative for 12,13. 0 for 14,15
rts

.macro mercilak_flip_subchar index
    lda zpmOAMSpriteMercilak + index * OAM_SIZE_BYTES + OAMSprite::status
    eor #$40
    sta zpmOAMSpriteMercilak + index * OAM_SIZE_BYTES + OAMSprite::status
.endmacro

; Swaps tiles pos with next adjacent tile
.macro mercilak_swap_subchar index_a, index_b
    ; We need to swap the whole status, name
    ; Move sprite A -> tmp
    ldx zpmOAMSpriteMercilak + index_a * OAM_SIZE_BYTES + OAMSprite::name
    stx z:dpTmp0

    ; Move sprite B -> sprite A
    ldx zpmOAMSpriteMercilak + index_b * OAM_SIZE_BYTES + OAMSprite::name
    stx zpmOAMSpriteMercilak + index_a * OAM_SIZE_BYTES + OAMSprite::name

    ; Move tmp -> sprite B
    ldx z:dpTmp0
    stx zpmOAMSpriteMercilak + index_b * OAM_SIZE_BYTES + OAMSprite::name
.endmacro

mercilak_flip_head:
    mercilak_flip_subchar 0
    mercilak_flip_subchar 1
    mercilak_swap_subchar 0, 1
rts

mercilak_flip_v:
    ; Need to flip all the vtiles in oam and then check the vflip flag
    ; First flip all H's
    mercilak_flip_subchar 0
    mercilak_flip_subchar 1
    mercilak_flip_subchar 2
    mercilak_flip_subchar 3
    mercilak_flip_subchar 4
    mercilak_flip_subchar 5
    mercilak_flip_subchar 6

    ; Then swap the position
    mercilak_swap_subchar 0, 1
    mercilak_swap_subchar 2, 3
    mercilak_swap_subchar 4, 5
rts

moam_load_mercilak:
    ; Set bytes 2 and 3 of each 6 tiles
    ; Set flip, high pri and palette byte and name to same everything
    ; Sets the status and the name bit in one shot
    ldx #(%00110100 << 8 | MERCILAK_TILE_0)
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub0 + OAMSprite::name
    inx
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub1 + OAMSprite::name
    inx
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub2 + OAMSprite::name
    inx
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub3 + OAMSprite::name
    inx
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub4 + OAMSprite::name
    inx
    stx zpmOAMSpriteMercilak + SpriteMercilak::sub5 + OAMSprite::name

    ; Set initial pos
    lda #MERCILAK_INIT_X
    sta zpbMercilakPosX
    lda #MERCILAK_INIT_Y
    sta zpbMercilakPosY

    jsr update_mercilak_pos
rts

update_mercilak_pos:
    ; Set bytes 0 of each 6 tile VPOS
    lda #(zpbMercilakPosY + 0)
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub0 + OAMSprite::posY
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub1 + OAMSprite::posY
    lda #(zpbMercilakPosY + 8)
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub2 + OAMSprite::posY
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub3 + OAMSprite::posY
    lda #(zpbMercilakPosY + 16)
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub4 + OAMSprite::posY
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub5 + OAMSprite::posY

    ; Set bytes 1 of each 6 tile HPOS
    lda #(zpbMercilakPosX + 0)
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub0 + OAMSprite::posX
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub2 + OAMSprite::posX
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub4 + OAMSprite::posX
    lda #(zpbMercilakPosX + 8)
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub1 + OAMSprite::posX
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub3 + OAMSprite::posX
    sta zpmOAMSpriteMercilak + SpriteMercilak::sub5 + OAMSprite::posX

rts


