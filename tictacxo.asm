.define ROM_NAME "TICTACXO"

.include "snes_registers.asm"
.include "lorom128.inc"
.include "register_clear.inc"
.include "graphics.asm"
.include "chars.asm"
.include "tileswitch.asm"


.zeropage
dpTmp0: .res 1, $00
dpTmp1: .res 1, $00
dpTmp2: .res 1, $00
dpTmp3: .res 1, $00
dpTmp4: .res 1, $00
dpTmp5: .res 1, $00
wJoyInput: .res 2, $0000
bScrollBg1: .res 1, $00

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
        wai ; Wait for NMI

        ; TODO: Gen data of register to be renewed & mem to change BG & OBJ data
        ; aka Update
        ; react to input

        jmp game_loop

VBlank:
    ; Detect Beginning of VBlank (Appendix B-3)        
    lda RDNMI; Read NMI flag
    bpl endvblank ; loop if the MSB is 0 N=0  (positive number)

    ; TODO: set data changed registers and memory
    ; TODO: transfer renewed data via OAM
    ; TODO: change data settings for BG&OAM that renew picture

    ; Constant Screen Scrolling
    ;jsr scroll_the_screen_left

    jsr joycon_read

    lda wJoyInput + 1               ; Check for keys in the high byte
    check_left:
        bit #>KEY_LEFT              ; check for key
        beq check_right             ; if not set (is zero) we skip 
        jsr scroll_the_screen_left
        bra endvblank
    check_right:
        bit #>KEY_RIGHT
        beq endvblank
        jsr scroll_the_screen_right
        bra endvblank
    endvblank: 
        rti 


joycon_read:
    lda HVBJOY   ; auto-read joypad status
    and #$01    ; Check low bit to see if ready to be read.
    bne end_joycon_read

    rep #$30    ; A/X/Y - 16 bit

    ; read joycon data (registers 4218h ~ 421Fh)
    lda JOY1L    ; Controller 1 as 16 bit.
    sta wJoyInput

    sep #$20    ; Go back to A 8-bit

    end_joycon_read:
    rts


load_custom_palette:
    ; force a palette here
    lda #$80        ; according to A-15 in OBJ palettes in mode 0
    sta CGADD

    lda #%00000000 ; Blue
    sta CGDATA
    lda #%01111100
    sta CGDATA

    lda #%11100000
    sta CGDATA
    lda #%00000011 ; Green
    sta CGDATA

    lda #%00011111
    sta CGDATA
    lda #%00000000 ; Red
    sta CGDATA

    stz CGDATA
    stz CGDATA


    stz CGDATA
    stz CGDATA
    stz CGDATA
    stz CGDATA
    stz CGDATA
    stz CGDATA
    stz CGDATA
    stz CGDATA



    rts

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
    load_block_to_vram test_font_a_obj, $0000, $0020 ; 2 tiles, 2bpp * 8x8 / 8bits = 32 bytes
    load_block_to_vram font_charset, $0100, 640 ; 40 tiles, 2bpp * 8x8 / 8 bits= 
    load_block_to_vram tiles_basic_set, $0280, 128 ; 8 tiles, 2bpp * 8x8 / 8 bits = 128
    load_block_to_vram tiles_hangman, $0700, 256 ; 2 tiles, 4bpp * 16x16 / 8 bits = 256 bytes

    jsr load_tile

    ; TODO: Loop VRAM until OBJ, BG CHR, BG SC Data has been transfered

    ; TODO: Transfer OAM, CGRAM Data via DMA (2 channels)
    jsr oam_load


    ; Register initial screen settings
    jsr register_screen_settings

    rts

oam_load:
    lda #%00000000  ;sssnnbbb b=base_sel_bits n=name_selection s=size_from_table
    sta OBSEL

    ; Sprite Table 1 at OAM $00
    lda #$00
    sta OAMADDL     ; write to oam slot 0
    lda #$00
    sta OAMADDH     ; write to oam slot 0

    lda #$0F         ; OBJ H pos
    sta OAMDATA
    lda #$0F         ; OBJ V pos
    sta OAMDATA
    lda #$70         ; Name - Face at location $E0 or $0E00
    sta OAMDATA
    lda #%00110010  ; Load palette 1
    sta OAMDATA     ; HBFlip/Pri/ColorPalette/9name

    ; Sprite Table 2 at OAM $0100
    lda #$00
    sta OAMADDL     
    lda #$01
    sta OAMADDH     ; write to oam slot 256 ($100)
    ; We want Obj 0 to be small and not use H MSB
    stz OAMDATA
    stz OAMDATA


    rts

scroll_the_screen_left:
    lda bScrollBg1
    ina
    sta bScrollBg1   ; increment and update the Scroll position
    sta BG1HOFS
    stz BG1HOFS     ; Write the position to the BG
    rts

scroll_the_screen_right:
    lda bScrollBg1
    dea
    sta bScrollBg1   ; increment and update the Scroll position
    sta BG1HOFS
    stz BG1HOFS     ; Write the position to the BG
    rts


load_tile:
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
    ;lda #$01    
    lda #$01    
    sta VMDATAL
    lda #$C0 ; Flip V & H for fun (Turn A)
    sta VMDATAH


    load_chars_to_screen
    ; Expirement more tiles
    load_chars_in_corner
    write_charset_with_autoinc
    print_hello_world

    rts

register_screen_settings:
    stz BGMODE  ; mode 0 8x8 4 color 4bgs

    lda #$04    ; Tile Map Location - set BG1 tile offset to $0400 (Word addr) (0800 in vram) with sc_size=00
    sta BG1SC   ; BG1SC 
    stz BG12NBA ; BG1 name base address to $0000 (word addr)
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
