.define ROM_NAME "TICTACXO"

.include "snes_registers.asm"
.include "lorom128.inc"
.include "register_clear.inc"
.include "graphics.asm"
.include "joycon.asm"
.include "chars.asm"
.include "tileswitch.asm"
.include "basic_tile_level.asm"


.zeropage
dpTmp0: .res 1, $00
dpTmp1: .res 1, $00
dpTmp2: .res 1, $00
dpTmp3: .res 1, $00
dpTmp4: .res 1, $00
dpTmp5: .res 1, $00
wJoyInput: .res 2, $0000
bSpritePosX: .res 1, $00
bSpritePosY: .res 1, $00
mBG1HOFS: .res 1, $00

.code
; Follow set up in chapter 23 of manual
Reset:
    ; Not in manual but part of common cpu setup
    init_cpu
    
    ; Move to force blank and clear all the registers
    register_clear

    jsr setup_video

    ; Release VBlank
    lda #FULL_BRIGHT  ; Full brightness
    sta INIDISP

    ; Display Period begins now
    lda #(NMI_ON | AUTO_JOY_ON) ; enable NMI Enable and Joycon
    sta NMITIMEN

    game_loop:
        ; TODO: Gen data of register to be renewed & mem to change BG & OBJ data
        ; aka Update
        ; react to input
        jsr joy_update
        wai ; Wait for NMI
jmp game_loop

joy_update:
    ; This has L and R
    check_L:
        lda wJoyInput
        bit #<KEY_L
        beq check_R                 ; if not set (is zero) we skip 
        jsr scroll_the_screen_left
    check_R:
        lda wJoyInput
        bit #<KEY_R
        beq check_left              ; if not set (is zero) we skip 
        jsr scroll_the_screen_right

    ; Check for keys in the high byte
    check_left:
        lda wJoyInput + 1               
        bit #>KEY_LEFT              ; check for key
        beq check_up                ; if not set (is zero) we skip 
        jsr move_sprite_left
    check_up:
        lda wJoyInput + 1               
        bit #>KEY_UP
        beq check_down
        jsr move_sprite_up
    check_down:
        lda wJoyInput + 1               
        bit #>KEY_DOWN
        beq check_right
        jsr move_sprite_down
    check_right:
        lda wJoyInput + 1               
        bit #>KEY_RIGHT
        beq endjoycheck
        jsr move_sprite_right
    endjoycheck:
rts

move_sprite_left:
    lda bSpritePosX
    dea
    sta bSpritePosX
rts
move_sprite_right:
    lda bSpritePosX
    ina
    sta bSpritePosX
rts
move_sprite_up:
    lda bSpritePosY
    dea
    sta bSpritePosY
rts
move_sprite_down:
    lda bSpritePosY
    ina
    sta bSpritePosY
rts


VBlank:
    ; Detect Beginning of VBlank (Appendix B-3)        
    lda RDNMI; Read NMI flag
    bpl endvblank ; loop if the MSB is 0 N=0  (positive number)

    ; TODO: set data changed registers and memory
    ; TODO: transfer renewed data via OAM
    ; TODO: change data settings for BG&OAM that renew picture

    ; Constant Screen Scrolling
    jsr scroll_the_screen_left

    ; Update the screen scroll register
    lda mBG1HOFS
    sta BG1HOFS
    stz BG1HOFS     ; Write the position to the BG

    joycon_read wJoyInput

    ; update the sprite (0000) position
    lda #$00
    sta OAMADDL     
    lda #$00
    sta OAMADDH     ; write to oam slot 0000
    lda bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda bSpritePosY ; OBJ V pos
    sta OAMDATA
    ; Update the pants
    lda #$02
    sta OAMADDL     
    lda #$00
    sta OAMADDH     ; write to oam slot 0000
    lda bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda bSpritePosY ; OBJ V pos
    inc
    sta OAMDATA

    endvblank: 
rti 

setup_video:
    ; Main register settings
    ; Mode 0 is OK for now

    ; Set OAM, CGRAM Settings
    ; We're going to DMA the graphics instead of using 2121/2122
    load_palette test_font_a_palette, 0, 4
    load_palette palette_basic_set, $10, 4
    load_palette palette_hangman, $90, $10

    ;custom_palette
    jsr load_custom_palette

    ; force Black BG by setting first color in first palette to black
    ; force_black_bg:
    ;     stz CGADD
    ;     stz CGDATA
    ;     stz CGDATA
    force_white_bg:
        stz CGADD
        lda #$FF
        sta CGDATA
        sta CGDATA

    ; Set VRAM Settings
    ; Transfer VRAM Data via DMA

    ; Load tile data to VRAM
    ;jsr reset_tiles
    ;load_block_to_vram test_font_a_obj, $0000, $0020 ; 2 tiles, 2bpp * 8x8 / 8bits = 32 bytes
    ;load_block_to_vram font_charset, $0100, 640 ; 40 tiles, 2bpp * 8x8 / 8 bits= 
    load_block_to_vram tiles_basic_set, $0280, 128 ; 8 tiles, 2bpp * 8x8 / 8 bits = 128
    load_block_to_vram tiles_hangman, $1000, 256 ; 2 tiles, 4bpp * 16x16 / 8 bits = 256 bytes
    ; Unsafe zone is 0800-0ff0


    ; TODO: Loop VRAM until OBJ, BG CHR, BG SC Data has been transfered

    ;jsr load_bg_tiles
    jsr load_simple_tilemap_level_1

    ; TODO: Transfer OAM, CGRAM Data via DMA (2 channels)
    jsr reset_sprite_table
    jsr oam_load_man
    jsr oam_load_man_pants

    ; Register initial screen settings
    jsr register_screen_settings
rts

oam_load_man:
    ; Set an initial position for sprite
    lda #$0F 
    sta bSpritePosX
    sta bSpritePosY

    lda #%00000000  ;sssnnbbb b=base_sel_bits n=name_selection s=size_from_table
    sta OBSEL

    ; Sprite Table 1 at OAM $00
    lda #$00
    sta OAMADDL     
    lda #$00
    sta OAMADDH     ; write to oam slot 0000

    lda bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda bSpritePosY ; OBJ V pos
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

    lda bSpritePosX ; OBJ H pos
    sta OAMDATA
    lda bSpritePosY ; OBJ V pos
    inc
    sta OAMDATA

    lda #$01        ; Name - Pants at location $102
    sta OAMDATA
    lda #%00110011  ; Highest priority / palette 1 
    sta OAMDATA     ; HVFlip/Pri/ColorPalette/9n

    ; Sprite Table 2 at OAM $0100
    lda #$00
    sta OAMADDL     
    lda #$0A
    sta OAMADDH     ; write to oam slot 256 ($100)
    ; We want Obj 0 to be small and not use H MSB
    stz OAMDATA
    stz OAMDATA
rts

scroll_the_screen_left:
    lda mBG1HOFS
    ina
    sta mBG1HOFS   ; increment and update the Scroll position
rts
scroll_the_screen_right:
    lda mBG1HOFS
    dea
    sta mBG1HOFS   ; increment and update the Scroll position
rts

load_bg_tiles:
    ;jsr load_simple_tiles
    ; Expirement with more tiles

    ;load_chars_to_screen
    ;load_chars_in_corner
    ;write_charset_with_autoinc
    ;print_hello_world
rts

load_simple_tiles:
    ; Write 'A' to the top left corner
    ; The tile should already be in VRAM from the load_block_to_vram via DMA
    ; There are two tile (empty at 0000 and A at 0010).
    ; Now load data into the tile map 
    lda #$80   ; word single inc (HL Inc is set to 1)
    sta VMAIN  
    ; Write the tile name "1" to the Tile Map ($0400) to display at topleft (0,0)
    ldx #$0400 ; to vram address 0400 (1024 bc of tilemap addr increments)
    stx VMADDL
    lda #$01    
    sta VMDATAL
    ; This is weird to me because we only write to the local block but
    ; we are supposed to increment when writing to the high block (2119)
    ; according to the 80 passed in to 2115s
    ; Update: Ahh but the DMA Transfer type (4300) is 2 regs 001, so DMA 
    ;         alternates between writing 2118 and 2119. This happened
    ;         in the load_block_to_vram (load_vram) macro.

    ; Expirement second tile
    ldx #$0401 ; to vram address 0401
    stx VMAIN
    lda #$01    
    sta VMDATAL
    lda #$C0 ; Flip V & H for fun (Turn A)
    sta VMDATAH
rts

register_screen_settings:
    stz BGMODE  ; mode 0 8x8 4-color 4-bgs

    lda #$04    ; Tile Map Location - set BG1 tile offset to $0400 (Word addr) (0800 in vram) with sc_size=00
    sta BG1SC   ; BG1SC 

    lda #$00
    sta BG12NBA ; BG1 name base address to $0000 (word addr) (Tiles offset)

    lda #(BG1_ON | SPR_ON) ; Enable BG1 and Sprites as main screen.
    ;lda #BG1_ON ; Enable BG1 on The Main screen
    ;lda #SPR_ON ; Enable Sprites on The Main screen.
    sta TM

    lda #$FF    ; Scroll down 1 pixel (FF really 03FF 63) (add -1 in 2s complement)
    sta BG1VOFS
    sta BG1VOFS ; Set V offset Low, High, to FFFF for BG1
rts


.segment "RODATA"

; Turns out sprite MUST be 4bpp
; 2bpp will make a mess of everything as it does now
test_font_a_obj:
.incbin "imggen/a.pic"

font_charset:
.incbin "imggen/chars.pic"

test_font_a_palette:
.incbin "imggen/a.clr"

tiles_hangman:
.incbin "spritesgen/hangman.pic"
palette_hangman:
.incbin "spritesgen/hangman.clr"

tiles_basic_set:
.incbin "imggen/basic_tileset.pic"
palette_basic_set:
.incbin "imggen/basic_tileset.clr"

ObjFontA:
    .byte  $00, $00, $00, $00
