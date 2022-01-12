; Simplfies loading vram to copy data
; src_addr: 24 bit addr of src data
; dest: VRAM addr to write to (WORD address!)
; size: number of Bytes to copy
; modifies a, x, y
.macro load_block_to_vram src_addr, dest, size
    lda #V_INC_1
    sta VMAIN ; VRAM mode word access, inc 1.
    ldx #dest
    stx VMADDL ; destination of vram

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

    stx (CH0 + A1TxL)   ; DMA data offset
    sta (CH0 + A1Bx)    ; DMA data bank
    sty (CH0 + DASxL)   ; DMA size

    lda #$01            ; DMA mode WORD (for VRAM 2-addr L,H)
    sta (CH0 + DMAPx)
    lda #$18            ; DMA destination register 2118 (VRAM data write)
    sta (CH0 + BBADx)

    lda $01     ; DMA channel 0
    sta MDMAEN  ; Initiate transfer

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

    stx (CH0 + A1TxL)   ; DMA data offset
    sta (CH0 + A1Bx)    ; DMA data bank
    sty (CH0 + DASxL)   ; DMA size

    stz (CH0 + DMAPx)

    lda #$22            ; DMA dest register - $2122
    sta (CH0 + BBADx)

    lda #$01            ; DMA Channel 0
    sta MDMAEN          ; Initiate!

    plp
    plb
    rts


