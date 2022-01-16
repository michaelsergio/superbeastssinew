.segment "CODE"
; In order to do things with the char set 
;load_block_to_vram font_charset, $0100, $0280 ; 40 tiles, 2bpp = $280 bytes

; Needs loaded tileset in VRAM at $0200 (40 chars in length)
.macro putchar position, char_index
    ldx #($0400 + position)  ; pos x+y*32 (x, y) in words from offset 0400
    stx VMADDL
    lda #char_index    ; Index from start of tilemap
    sta VMDATAL
    stz VMDATAH
.endmacro

.macro put_alpha letter, posx, posy, tile_start
    putchar (posx + posy * 32), ((letter - 65 + 1) + tile_start) ; +1 bc space char in my set
.endmacro

; Load B from the second charset
; Assumes alpha set is loaded at $20 (0200 in VRAM)
.macro putB position
    putchar position, $22
.endmacro

; Assumes alpha set is loaded at $20 (0200 in VRAM)
.macro load_chars_to_screen
    putB 2
    put_alpha 'C', 3, 0, $20
    put_alpha 'Q', 4, 1, $20
.endmacro


.macro write_charset_with_autoinc_2
    ; starts at $20 goes for 40 chars
    lda #V_INC_1
    sta VMAIN       ; autoinc 1

    ; Start writing from word 0200

    ; TODO FINISH this

.endmacro

.macro write_charset_with_autoinc
    ; Try and write the whole charset using auto increment
    lda #$00   ; 1 word increment
    sta VMAIN
    ldx #($0400 + (5 + 2 * 32))  ; pos x+y*32 (x, y) in words from offset 0400
    stx VMADDL
    ; Charset base moved forward $8 to go into middle
    ldy #$5                     ; write 5 chars from charset
    lda #($20 + ('G' - 65 + 1))    ; start at G and ignore space
    write_charset: 
        sta VMDATAL
        ina
        dey
        bne write_charset
.endmacro

.macro print_hello_world
    lda #$00   ; 1 word autoincrement
    sta VMAIN
    ldx #($0400 + (5 + 12 * 32))    ; pos x+y*32 (x, y) in words from offset 0400
    stx VMADDL                      ; Write to middle of screen
    ldy #$00                        ; Index for word
    @write: 
        lda message_hello_world, y
        beq @end_of_str             ; Check for null byte at end
        clc
        adc #$0C        ; This is a hack to get things working. I'm not sure why my offset is $0C in the tilemap
        sta VMDATAL
        iny
        bra @write
    @end_of_str:
.endmacro

.macro load_chars_in_corner
    ldx #$040F  ; (pos 16)
    stx VMADDL
    lda #$01    
    sta VMDATAL
    ldx #$041F  ; (pos 32)
    stx VMADDL
    lda #$01    
    sta VMDATAL
    ldx #$0420  ; (pos 33, aka (0,1))
    stx VMADDL
    lda #$01    
    sta VMDATAL
    ldx #$0760  ; (bottom left?, aka (27,0)) $EC0 / 2
    stx VMADDL
    lda #$01    
    sta VMDATAL
.endmacro

.segment "RODATA"

; This is converted from ascii - 44
message_hello_world:
;       H    E    L    L    O    sp   W    O    R    L    D   NULL
.byte $1C, $19, $20, $20, $23, $14, $2B,  $23, $26, $20, $18, $00

; This should also be defined
; font_charset:
;.incbin "imggen/chars.pic"