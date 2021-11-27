;;
;; sfx_increaseSectionCounter [$D2AC]
;;
;; Increases the current channel's sfx counter, and if we reach the length pre-determined for that section, reset the counter to 0
;; 
;; Returns:
;;  Zero flag: clear if section finished, set if not
;;
sfx_increaseSectionCounter:
        ldx sfx_channel           
        inc sfx_sectionCounter_noise,X
        lda sfx_sectionCounter_noise,X
        cmp sfx_sectionLength_noise,X
        bne @exit_sfx_increaseSectionCounter
        lda #$00                 
        sta sfx_sectionCounter_noise,X
    @exit_sfx_increaseSectionCounter:
        rts   