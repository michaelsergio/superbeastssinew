.segment "CODE"
; In order to do things with the char set 
;load_block_to_vram font_charset, $0100, $0280 ; 40 tiles, 2bpp = $280 bytes

; Needs loaded tileset in VRAM at $0200 (40 chars in length)
.macro putchar position, char_index
    ldx #($0400 + position)  ; pos x+y*32 (x, y) in words from offset 0400
    stx $2116
    lda #char_index    ; char B
    sta $2118
.endmacro

.macro put_alpha letter, posx, posy
    putchar (posx + posy * 32), ((letter - 65 + 1) + $20) 
.endmacro

.macro putB position
    putchar position, $22 
.endmacro

.macro load_chars_to_screen
    ; Load B from the second charset
    ; ldx #$0402  ; pos 3 (0, 3) in words from offset 0400
    ; stx $2116
    ; lda #$22    ; char B
    ; sta $2118
    putB 2
    put_alpha 'C', 3, 0
    put_alpha 'Q', 4, 1
.endmacro


.macro write_charset_with_autoinc
    ; Try and write the whole charset using auto increment
    lda #$00   ; 1 word increment
    sta $2115  
    ldx #($0400 + (5 + 2 * 32))  ; pos x+y*32 (x, y) in words from offset 0400
    stx $2116
    ; Charset base moved forward $8 to go into middle
    ldy #$5                     ; write 5 chars from charset
    lda #($20 + ('G' - 65 + 1))    ; start at G and ignore space
    write_charset: 
        sta $2118
        ina
        dey
        bne write_charset
.endmacro

.macro print_hello_world
    lda #$00   ; 1 word increment
    sta $2115  
    ldx #($0400 + (5 + 12 * 32))    ; pos x+y*32 (x, y) in words from offset 0400
    stx $2116                       ; Write to middle of screen
    ldy #$00                        ; Index for word
    @write: 
        lda message_hello_world, y
        beq @end_of_str             ; Check for null byte at end
        clc
        adc #$0C        ; This is a hack to get things working. I'm not sure why my offset is $0C in the tilemap
        sta $2118
        iny
        bra @write
    @end_of_str:
.endmacro

.macro load_chars_in_corner
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
.endmacro

.segment "RODATA"

; This is converted from ascii - 44
message_hello_world:
;       H    E    L    L    O    sp   W    O    R    L    D   NULL
.byte $1C, $19, $20, $20, $23, $14, $2B,  $23, $26, $20, $18, $00

; This should also be defined
; font_charset:
;.incbin "imggen/chars.pic"