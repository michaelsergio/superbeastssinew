; Displays green screen
;
; ca65 green.s
; ld65 -C lorom128.cfg -o green.smc green.o

.define ROM_NAME "TICTACXO"
.include "lorom128.inc"
.include "register_clear.inc"
.include "graphics.inc"


.macro rc_oam_write
.endmacro
.macro rc_vram_write
.endmacro
.macro rc_cgdata_write
.endmacro

.macro init_cpu
    clc
    xce
    rep #$10        ; X/Y 16-bit
    sep #$20        ; A 8-bit
.endmacro

; Follow set up in chapter 23 of manual
Reset:
    ; Not in manual but part of common cpu setup
    init_cpu
    
    ; Move to force blank and clear all the registers
    register_clear

    jsr setup_video

    ; Release VBlank
    lda #$0F   ; Full brightness
    sta $2100 
    ; Display Period begins now

    ; enable NMI Enable and Joycon
    lda #$81
    sta $4200

    game_loop:
        wai ; Wait for NMI

        ; TODO: Gen data of register to be renewed & mem to change BG & OBJ data
        ; aka Update
        ; react to input

        jmp game_loop

VBlank:
    ; Detect Beginning of VBlank (Appendix B-3)        
    lda $4210 ; Read NMI flag
    bpl endvblank ; loop if the MSB is 0 N=0  (positive number)

    ; TODO: set data changed registers and memory
    ; TODO: transfer renewed data via OAM
    ; TODO: change data settings for BG&OAM that renew picture

    jsr joycon_read

    endvblank: 
        rti 

joycon_read:
    lda $4212           ; auto-read joypad status
    ; TODO: read joycon data (registers 4218h ~ 421Fh)
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

    jsr load_tile

    ; TODO: Loop VRAM until OBJ, BG CHR, BG SC Data has been transfered

    ; Register initial screen settings
    jsr register_screen_settings

    rts

load_tile:
    ; The tile should already be in VRAM from the load_block_to_vram via DMA
    ; There are two tile (empty at 0000 and A at 0010).
    ; Now load data into the tile map 
    lda #$80   ; word single inc (HL Inc is set to 1)
    sta $2115  
    ; Write the tile name "1" to the Tile Map ($0400) to display at topleft (0,0)
    ldx #$0400 ; to vram address 0400 (1024 bc of tilemap addr increments)
    stx $2116
    lda #$01    
    sta $2118
    ; This is weird to me because we only write to the local block but
    ; we are supposed to increment when writing to the high block (2119)
    ; according to the 80 passed in to 2115s
    ; Update: Ahh but the DMA Transfer type (4300) is 2 regs 001, so DMA 
    ;         alternates between writing 2118 and 2119. This happened
    ;         in the load_block_to_vram (load_vram) macro.

    ; Expirement second tile
    ldx #$0401 ; to vram address 0400 (1024 bc of tilemap addr increments)
    stx $2116
    lda #$01    
    sta $2118

    ; Expirement more tiles
    ldx #$040F  ; (pos 16)
    stx $2116
    lda #$01    
    sta $2118
    ldx #$041F  ; (pos 32)
    stx $2116
    lda #$01    
    sta $2118
    ldx #$0420  ; (pos 33, aka (0,1))
    stx $2116
    lda #$01    
    sta $2118
    ldx #$0760  ; (bottom left?, aka (27,0)) $EC0 / 2
    stx $2116
    lda #$01    
    sta $2118

    rts

register_screen_settings:
    stz $2105 ; mode 0 8x8 4 color 4bgs

    lda #$04  ; Tile Map Location - set BG1 tile offset to $0400 (Word addr) (0800 in vram) with sc_size=00
    sta $2107 ; BG1SC 
    stz $210B ; BG1 name base address to $0000 (word addr)
    lda #$01  ; Enable BG1 as main screen.
    sta $212C ;

    lda #$FF  ; Scroll down 1023 (FF really 03FF 63) 
    sta $210E
    sta $210E ; Set V offset Low, High, to FFFF for BG1
    rts

.segment "RODATA"
; TODO I want to put this on a different bank
;.segment "BANK1"

test_font_a_obj:
.incbin "imggen/a.pic"

test_font_a_palette:
.incbin "imggen/a.clr"

ObjFontA:
    .byte  $00, $00, $00, $00
