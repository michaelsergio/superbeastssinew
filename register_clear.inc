; Initial Settings as described in Chapter 26 of SNES Manual
; Results in forced blank state with all registers cleared
;
; must define the following macros:
; rc_oam_write: OAM Data: Write to 2104h
; rc_vram_write: VRAM Data: Write to low/high 2118h/2119h
; rc_cgdata_write: CGRam Data: Write to 2122h
.macro register_clear

; PPU Registers

lda #8Fh  ; Forced Blank - max brightness
sta 2100h

stz 2101h
stz 2102h
stz 2103h

; 2104h gets OAM Data
; refer to page A-3 and 2-26-2
rc_oam_write

stz 2105h
stz 2106h
stz 2107h
stz 2108h
stz 2109h
stz 210Ah
stz 210Bh
stz 210Ch

; Must write in low high order
stz 210Dh
stz 210Dh
stz 210Eh
stz 210Eh
stz 210Fh
stz 210Fh
stz 2110h
stz 2110h
stz 2111h
stz 2111h
stz 2112h
stz 2112h
stz 2113h
stz 2113h
stz 2114h
stz 2114h

; Single writes

lda #80h  ; inc addr after w/r from 2119h/213Ah (the second VRAM byte)-1x1 inc
sta 2115h
stz 2116h
stz 2117h

; 2118h VRAM Data
; 2119h VRAM Data
rc_vram_write

stz 211Ah

; Double writes again in low high order
stz 211Bh
lda #01h  ; mode7 param A: identity matrix 1 
sta 211Bh

stz 211Ch
stz 211Ch

stz 211Dh
stz 211Dh

stz 211Eh
lda #01h  ; mode7 param D: identity matrix 1 
stz 211Eh

stz 211Fh
stz 211Fh

stz 2120h
stz 2120h

; single write 
stz 2121h

; 2122 IS for CG Data.
rc_cgdata_write

stz 2123h
stz 2124h
stz 2125h
stz 2126h
stz 2127h
stz 2128h
stz 2129h
stz 212Ah
stz 212Bh
stz 212Ch
stz 212Dh
stz 212Eh
; No F in the documentation?

lda #30h  ; Color window off 
sta 2130h

stz 2131h

lda #E0h ; BLACK for fixed color addition
sta 2132h
stz 2133h

; CPU registers 

stz 4200h ; NMI-VBlank-flag / V/H Blank / Controller - all disabled

lda #FFh  ; Write IO set to output all FFs
sta 4201h

stz 4202h
stz 4203h
stz 4204h
stz 4205h
stz 4206h
stz 4207h
stz 4208h
stz 4209h
stz 420Ah
stz 420Bh
stz 420Ch
stz 420Dh

.endmacro

