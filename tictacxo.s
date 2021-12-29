; Displays green screen
;
; ca65 green.s
; ld65 -C lorom128.cfg -o green.smc green.o

.define ROM_NAME "TICTACXO"
.include "lorom128.inc"
.include "register_clear.inc"

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
reset:
    ; Not in manual but part of common cpu setup
    init_cpu
    
    ; Move to force blank and clear all the registers
    register_clear

    jsr setup_video
    
    ; Release VBlank
    lda #0Fh
    sta 2100h
    ; Display Period begins now

    ; enable NMI Enable and Joycon
    lda #81h
    sta 4200h

    game_loop:
        wai ; Wait for NMI

        ; TODO: Gen data of register to be renewed & mem to change BG & OBJ data
        ; aka Update
        ; react to input

        jmp game_loop

VBlank:
    ; Detect Beginning of VBlank (Appendix B-3)        
    lda 4210h ; Read NMI flag
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
    ; TODO: Main register settings
    ; TODO: Set OAM, CGRAM Settings
    ; TODO: Transfer OAM, CGRAM Data via DMA (2 channels)
    ; TODO: Set VRAM Settings
    ; TODO: Transfer VRAM Data via DMA
    ; TODO: Loop VRAM until OBJ, BG CHR, BG SC Data has been transfered
    ; TODO: Register initial screen settings
    rts

