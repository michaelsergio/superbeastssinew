.macro joycon_read wJoyVar
    joycon_read_in_progress:
    lda HVBJOY   ; auto-read joypad status
    and #$01    ; Check low bit to see if ready to be read.
    
    ; wait for 0 to ready to read data
    bne joycon_read_in_progress

    joycon_ready_to_read:

    rep #$30    ; A/X/Y - 16 bit

    ; read joycon data (registers 4218h ~ 421Fh)
    lda JOY1L    ; Controller 1 as 16 bit.
    sta wJoyVar

    sep #$20    ; Go back to A 8-bit

    end_joycon_read:
.endmacro
