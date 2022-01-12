.define ROM_NAME "TICTACXO"

.include "snes_registers.asm"
.include "lorom128.inc"
.include "register_clear.inc"
.include "graphics.asm"
.include "chars.asm"
.include "tileswitch.asm"


.segment "ZEROPAGE"
JoyInput: .res 2, $0000
ScrollBg1: .res 1, $00

.segment "CODE"

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

    lda JoyInput + 1       ; Check for keys in the high byte
    check_left:
        bit #>KEY_LEFT    ; check for key
        beq check_right   ; if not set (is zero) we skip 
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
    sta JoyInput

    sep #$20    ; Go back to A 8-bit

    end_joycon_read:
    rts


setup_video:
    ; Main register settings
    ; Mode 0 is OK for now

    ; Set OAM, CGRAM Settings
    ; We're going to DMA the graphics instead of using 2121/2122
    load_palette test_font_a_palette, 0, 4


    ; TODO: Transfer OAM, CGRAM Data via DMA (2 channels)

    ; Set VRAM Settings
    ; Transfer VRAM Data via DMA

    ; Load tile data to VRAM
    load_block_to_vram test_font_a_obj, $0000, $0020 ; 2 tiles, 2bpp = 32 bytes
    load_block_to_vram font_charset, $0100, $0280 ; 40 tiles, 2bpp = 32 bytes

    jsr load_tile

    ; TODO: Loop VRAM until OBJ, BG CHR, BG SC Data has been transfered

    ; Register initial screen settings
    jsr register_screen_settings

    rts

scroll_the_screen_left:
    lda ScrollBg1
    ina
    sta ScrollBg1   ; increment and update the Scroll position
    sta BG1HOFS
    stz BG1HOFS     ; Write the position to the BG
    rts

scroll_the_screen_right:
    lda ScrollBg1
    dea
    sta ScrollBg1   ; increment and update the Scroll position
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
    lda #BG1_ON ; Enable BG1 as main screen.
    sta TM 

    lda #$FF    ; Scroll down 1 pixel (FF really 03FF 63) (add -1 in 2s complement)
    sta BG1VOFS
    sta BG1VOFS ; Set V offset Low, High, to FFFF for BG1
    rts

.segment "RODATA"

test_font_a_obj:
.incbin "imggen/a.pic"

font_charset:
.incbin "imggen/chars.pic"

test_font_a_palette:
.incbin "imggen/a.clr"

ObjFontA:
    .byte  $00, $00, $00, $00
