BG2_PALETTE_1 = $24
BG2_TILEMAP_VRAM_ADDR = $1800

; Nifty color picker tool
; https://orangeglo.github.io/BGR555/
load_textbox_palette:
    ; force a palette here
    lda #BG2_PALETTE_1        ; Set 2nd palette for bg2
    sta CGADD

    stz CGDATA      
    stz CGDATA      ; Black for transparency

    ; Text Color
    lda #$FF       ; White
    sta CGDATA
    sta CGDATA

    ; Solid BG Color
    lda #%00000000 ; Blue
    sta CGDATA
    lda #$30
    sta CGDATA

    ; another color for palette
    lda #$FF    ; yellow
    sta CGDATA
    lda #$03
    sta CGDATA
rts

.macro write_single_line msg
    ; Set the pri=1 and pal=2
    ldy #$2400
    sty z:dpTmp0
    ldx #msg
    jsr write_line
.endmacro

write_line:
    @loop_until_null:
        lda 0, x
        beq @done
        sta z:dpTmp0
        ldy z:dpTmp0
        sty VMDATAL
        inx
    bra @loop_until_null
    @done:
rts

load_bg2_tilemap:
    lda #V_INC_1
    sta VMAIN        ; Single Inc
 
    ldx #BG2_TILEMAP_VRAM_ADDR + ($20 * 3) + $9 ; Jump 4 lines + space
    stx VMADDL
    write_single_line msg_blank_line
    ldx #BG2_TILEMAP_VRAM_ADDR + ($20 * 4) + $9 ; Jump 4 lines + space
    stx VMADDL
    write_single_line msg_blank_line

    ldx #BG2_TILEMAP_VRAM_ADDR + ($20 * 5) + $9 ; Jump 4 lines + space
    stx VMADDL
    write_single_line msg_its_yellow

    ldx #BG2_TILEMAP_VRAM_ADDR + ($20 * 6) + $9 ; Jump 4 lines + space
    stx VMADDL
    write_single_line msg_blank_line
    ldx #BG2_TILEMAP_VRAM_ADDR + ($20 * 7) + $9 ; Jump 4 lines + space
    stx VMADDL
    write_single_line msg_blank_line
rts


line_feed:
    ldx #$20
    @line_feed_loop:
        ldy #($2000 | $0000) ; 10 for color palette 0, tile 1 for solid
        sty VMDATAL
        dex
    bne @line_feed_loop
rts

.segment "RODATA"
msg_blank_line: .asciiz "                 "
msg_its_yellow: .asciiz " IT'S YELLOW...? "