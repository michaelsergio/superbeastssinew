; Displays green screen
;
; ca65 green.s
; ld65 -C lorom128.cfg -o green.smc green.o

.define ROM_NAME "TICTACXO"
.include "lorom128.inc"

.define CGDATA 2122h
.define INIDISP 2100h
.define NMITIMEN 4200h

reset:
    init_cpu

    ; 3.3 Background Example

    ; Clear PPU registers pg 115
    ldx #$33
@loop:  stz INIDISP,x
    stz NMITIMEN,x ; Disable NMI, Disable V/H TIME EN pg 140
    dex
    bpl @loop


    ; set register 2105h
    ; bg mode and bg size

    ; set register 2107h - 210Ah
    ; sc size and sc base addr

    ; set register 210bh and 210ch
    ; set name base addr

    ; set d0~d3 of register 212Ch set through main BG

    ; Forced Blank
    ; set register 2115h
    ; vram address seq mode and h/l inc


    ; set register 2116h ~ 2119h
    ; vraam addr and vram data
    ; transfer bg-data & bg character data to vram by DMA

    ;set register 2121h and 2122h 
    ; cg ram addr and cg ram data
    ; transfer color data to cg (color generator) by DMA

    ; VBLANK
    ; set register 210Dh ~ 2114h 
    ; Set BG H/V Offset
    ; display
    ; goto vblank

    ; Set background color to $03E0
    ; Page 212 for colors (A-17)
    ; Write to CG Ram low/high
    ; only can be done during h/v blank or forced blank period
    ; 03E0 is %0000 0011 1110 0000
    ; Format is %xbbb bbgg gggr rrrr
    
    ; Red 001F
    lda #1Fh
    sta CGDATA
    lda #00h
    sta CGDATA

    ; Maximum screen brightness
    lda #$0F
    sta INIDISP

forever:
    jmp forever

