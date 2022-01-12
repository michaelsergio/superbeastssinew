; Simplfies loading vram to copy data
; src_addr: 24 bit addr of src data
; dest: VRAM addr to write to (WORD address!)
; size: number of Bytes to copy
; modifies a, x, y
.macro load_block_to_vram src_addr, dest, size
    lda #$80
    sta $2115 ; VRAM mode word access, inc 1.
    lda #$ca
    ldx #dest
    stx $2116 ; destination of vram

    ; Make call to load_vram
    lda #^src_addr  ; Gets the bank of the src_addr
    ldx #src_addr   ; get the src addr
    ldy #size       ; size 
    jsr load_vram
.endmacro


; Load Palette with DMA
; In A:X - points to the data (bank and address)
; Y - size of data
load_vram:
    phb  ; store bank
    php  ; store processor status registers

    stx $4302 ; DMA data offset
    sta $4304 ; DMA data bank
    sty $4305 ; DMA size

    lda #$01  ; DNA mode WORD (for VRAM 2-addr L,H)
    sta $4300
    lda #$18  ; DMA destination register 2118 (VRAM data write)
    sta $4301

    lda $01   ; DMA channel 0
    sta $420B ; Initiate transfer

    plp
    plb
    rts

; src_addr: 24 bit addr of src data
; start: color to start on in CG Ram
; size: # of colors to copy
; modifies a, x, y
.macro load_palette src_addr, start, size
    lda #start
    sta $2121       ; start address for CG RAM

    lda #^src_addr  ; Gets the bank of the src_addr
    ldx #src_addr   ; get the src addr
    ldy #(size * 2) ; bytes for each color (16 bit value)
    jsr dma_palette
.endmacro

; Load Palette with DMA
; In A:X - points to the data (bank and address)
; Y - size of data
dma_palette:
    phb  ; store bank
    php  ; store processor status registers

    stx $4302 ; DMA data offset
    sta $4304 ; DMA data bank
    sty $4305 ; DMA size

    stz $4300 ; DMA mode: byte, normal inc

    lda #$22  ; DMA dest register - $2122
    sta $4301 

    lda #$01  ; DMA Channel 0
    sta $420B ; Initiate!

    plp
    plb
    rts


