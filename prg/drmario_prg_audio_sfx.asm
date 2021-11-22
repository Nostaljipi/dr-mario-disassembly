;;
;; playSFX_lengthA_dataD3YY [$D52B]
;;
;; Copies the data for a sfx into the appropriate APU registers
;; 
;; Inputs:
;;  A: the length of the sfx
;;  Y: low byte of sfx data address (if 0, then no update)
;;
playSFX_lengthA_dataD3YY:
        ldx sfx_channel           
        sta sfx_sectionLength_noise,X
        txa                      
        sta sfxPlaying_forMusic_noise,X     ;Stores which channel is playing
        tya                      
        beq @sfxUpdateForThisChannel_done   ;If y is 0, no update
        txa                      
        beq @sfxUses_NOISE                  ;Then branch to sfx channel
        cmp #sfx_channel_sq0                 
        beq @sfxUses_SQ0      
        cmp #sfx_channel_sq1                 
        beq @sfxUses_SQ1      
        cmp #sfx_channel_trg                 
        beq @sfxUses_TRG      
        rts                                 ;Don't think it can ever get there, would need to be a DMC sfx     
    @sfxUses_SQ0:         
        jsr copy_sfxData_to_APU_SQ0         ;This subroutine always returns zero    
        beq @sfxUpdateForThisChannel_done
    @sfxUses_SQ1:         
        jsr copy_sfxData_to_APU_SQ1          
        beq @sfxUpdateForThisChannel_done   ;Code never gets there I think (since there are no SQ1-only sfx)
    @sfxUses_TRG:         
        jsr copy_sfxData_to_APU_TRG          
        beq @sfxUpdateForThisChannel_done
    @sfxUses_NOISE:       
        jsr copy_sfxData_to_APU_NOISE        
    @sfxUpdateForThisChannel_done:
        lda audioToPlay_copy     
        sta sfx_playing_noise,X             ;Store the "to play" into "playing"
        lda #$00                            ;Reset a bunch of variables
        sta sfx_sectionCounter_noise,X
    _resetChannelVariables:                 ;This label is also used by sfx_bothAttacks_andUFOsiren_SQ1
        sta sfx_noise_pitch,X     
        sta sfx_noise_vol,X
        sta sfx_noise_data,X                ;Can be used for several different applications, kind of like tmp RAM
        sta flag_sfxJustFinished 
    _exit_playSFX_lengthA_dataD3YY:         ;This label is also used by sfxPlaying_UFO_beam_NOISE   and   sfxPlaying_UFO_leave_NOISE
        rts                      


;;
;; playSFX_UFO_beam_NOISE [$D570]
;;
;; Routines for starting and updating the UFO beam sfx (noise channel, the sort of electric sound)
;;
playSFX_UFO_beam_NOISE:  
        lda #$02                                ;Loads the sfx length and address                                 
        ldy #sfx_UFO_beam_NOISE-sfx_data                 
        jsr playSFX_lengthA_dataD3YY            ;Then copy it

sfxPlaying_UFO_beam_NOISE:
        jsr sfx_increaseSectionCounter          ;Wait till we have reached the end of the section length
        bne _exit_playSFX_lengthA_dataD3YY
        lda sfx_noise_step                      ;Then increase the period and volume envelope (which constitutes the sound)
        and #$0F                                ;Wraparound (loop) after $0F steps                         
        tay                      
        inc sfx_noise_step       
        lda sfx_UFO_beam_NOISE_period,Y
        sta NOISE_PERIOD         
        lda sfx_UFO_beam_NOISE_volume,Y
        sta NOISE_VOLUME         
        rts                      

sfx_UFO_beam_NOISE_period:
.db $81,$81,$82,$82,$83,$83,$84,$84             ;Bit 7 ($80) gives the buzzing electric sound, the first 4 bits give us the pitch
.db $83,$83,$82,$82,$81,$81,$82,$82

sfx_UFO_beam_NOISE_volume:
.db $33,$34,$35,$36,$37,$38,$39,$38             ;Bit 5 & 6 ($30) halt the length counter & gives us constant volume, the first 4 bits give us the volume
.db $39,$38,$37,$36,$35,$34,$33,$32

if !removeUnused
        playSFX_UNK_D5B2_noise_probably:
                lda #$07                 
                ldy #sfx_UFO_any_NOISE_finished-sfx_data                 
                jsr playSFX_lengthA_dataD3YY
                rts                      
endif

;;
;; playSFX_UFO_leave_NOISE [$D5BA]
;;
;; Routines for starting and updating the UFO leaving noise
;;
playSFX_UFO_leave_NOISE: 
        lda #$B3                                ;Gives the signal to the UFO siren noise to start lowering its volume (this value will be stored in SQ0_DUTY & SQ1_DUTY)        
        sta sfx_sq0_data       
        lda #$07                                ;Step lenght       
        ldy #sfx_UFO_leaves_NOISE-sfx_data                 
        jsr playSFX_lengthA_dataD3YY
        lda #$3E                                ;The starting volume                
        sta sfx_noise_vol
        lda #$0F                                ;The starting pitch
        sta sfx_noise_pitch       
        rts                      
            
sfxPlaying_UFO_leave_NOISE:
        jsr sfx_increaseSectionCounter
        bne _exit_playSFX_lengthA_dataD3YY      ;Not sure why we don't aim for a closer rts here...
        dec sfx_noise_pitch                     ;Decrease pitch at given interval
    if !removeMoreUnused       
        jmp sfxPlaying_UFO_leave_fadeNoise      ;Not needed if we remove the following unused routine
    endif 

if !removeMoreUnused
        playSFX_highToLowPitch_NOISE_UNUSED:
                lda #$0B                        ;Index 0 of sfx table in vanilla, alternative to UFO leaving (pretty much the same except with reversed pitch)
                ldy #sfx_highToLowPitch_NOISE_UNUSED-sfx_data                 
                jsr playSFX_lengthA_dataD3YY
                lda #$3E                 
                sta sfx_noise_vol
                lda #$00                 
                sta sfx_noise_pitch       
                rts                          
        sfxPlaying_highToLowPitch_NOISE_UNUSED:
                jsr sfx_increaseSectionCounter  ;Index 0 (8)
                bne _exit_sfxPlaying_UFO_leave_fadeNoise
                inc sfx_noise_pitch 
endif  

sfxPlaying_UFO_leave_fadeNoise:
        lda sfx_noise_pitch       
        sta NOISE_PERIOD         
        dec sfx_noise_vol                       ;Also decrease volume
        lda sfx_noise_vol
        sta NOISE_VOLUME         
        cmp #$36                 
        beq @volumeDecreasedTo6                 ;Once volume is decreased enough, stop the UFO motor sfx
        cmp #$2F                                ;If volume is lowered completely...
        bne _exit_sfxPlaying_UFO_leave_fadeNoise
        lda #$B1                                ;...give the signal to the UFO siren noise to further lower its volume (this value will be stored in SQ0_DUTY & SQ1_DUTY)
        sta sfx_sq0_data       
        jmp resetNoise                          ;Then reset the noise channel
    @volumeDecreasedTo6:     
        jsr sfxFinished_TRG                     ;Stop the UFO motor TRG sfx
    _exit_sfxPlaying_UFO_leave_fadeNoise:
        rts                      

;;
;; playSFX_bigVirus_hurt_NOISE [$D619]
;;
;; Routines for starting and updating the big virus hurt noise
;; Exceptionally here, the "playSFX" is played every frame, and only when reaching the end of the hurt anim that we play the "sfxPlaying" 
;;
playSFX_bigVirus_hurt_NOISE:   
        lda #$04                                ;Surprisingly, this plays for a short duration on level load... probably a bug
        ldy #sfx_bigVirusHurt_NOISE-sfx_data                 
        jsr playSFX_lengthA_dataD3YY
        lda sfx_rndNoisePeriod                  ;Uses random number for noise period
        and #$07                 
        sta NOISE_PERIOD         
        rts                      

if !optimize
            _storeNoisePeriod_thenRTS:           ;Only used as part of the sfxPlaying_explosion_NOISE routine... why this is placed here is beyond me
                sta NOISE_PERIOD         
                rts 
        manageEnvelope_explosionSfx_period:      ;Routine actually starts here
                jsr manageEnvelope_explosionSfx
                jmp _storeNoisePeriod_thenRTS
endif

if !removeUnused
        playSFX_UNK_D632_NOISE:  
                lda #$07                 ;no index...
                ldy #__sfx_UNK_D308_NOISE_noIndex-sfx_data                 
                jmp playSFX_lengthA_dataD3YY

        sfxPlaying_UNK_D639_NOISE:
                jsr sfx_increaseSectionCounter
                bne @exit_sfxPlaying_UNK_D639_NOISE
                lda sfx_noise_vol
                beq @increaseStep        
                dec sfx_noise_pitch       
                beq resetNoise          
        @increaseStep:           
                inc sfx_noise_pitch       ;looks like some electric random sfx
                lda sfx_rndNoisePeriod   
                and #$07                 
                ora #$80                 
                sta NOISE_PERIOD         
                lda sfx_noise_pitch       
                cmp #$0B                 
                beq @increasePitchModulator
                ora #$10                 
                sta NOISE_VOLUME         
                lda #$08                 
                sta NOISE_LENGTH         
        @exit_sfxPlaying_UNK_D639_NOISE:
                rts                       
        @increasePitchModulator: 
                inc sfx_noise_vol
                rts                      
endif

sfxPlaying_bigVirus_hurt_NOISE:
        jsr sfx_increaseSectionCounter          ;Simply loop the current section until length is finished
        bne _exit_resetNoise                    ;Continues into the next routine if it does not branch

;;
;; resetNoise [$D66F]
;;
;; Reset noise sfx playing and mute channel
;;
resetNoise:             
        lda #$00                                
        sta sfx_playing_noise    
        lda #$10                 
        sta NOISE_VOLUME         
    _exit_resetNoise:
        rts                      

;;
;; playSFX_UFO_boom_NOISE [$D67A]
;;
;; Routines for starting and updating the UFO boom noise (when it appears)
;;
playSFX_UFO_boom_NOISE:  
        lda #$40                 
        ldy #sfx_explosion_NOISE-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

sfxPlaying_UFO_boom_NOISE:
        lda sfx_noise_end_flag                       
        bne _exit_resetNoise                            ;Exits the routine if the noise end flag is set
        jsr sfx_increaseSectionCounter          
        bne _manageEnvelope_explosionSfx_pitch_vol      ;Otherwise, while the section counter has not reached the end, update the noise envelope
        inc sfx_noise_end_flag                          ;When section counter is finished, raise the flag
        ldy #sfx_UFO_any_NOISE_finished-sfx_data                  
        jmp copy_sfxData_to_APU_NOISE 

;;
;; playSFX_UFO_postBeam_NOISE [$D693]
;;
;; Routine for updating the noise channel after the beam has finished
;;
playSFX_UFO_postBeam_NOISE:
        ldy #sfx_UFO_any_NOISE_finished-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

;;
;; playSFX_explosion_NOISE [$D698]
;;
;; Routines for starting and updating the explosion noise (ex: on fail)
;;
playSFX_explosion_NOISE: 
        lda #$40                 
        ldy #sfx_explosion_NOISE-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

sfxPlaying_explosion_NOISE:
        jsr sfx_increaseSectionCounter
        bne _manageEnvelope_explosionSfx_pitch_vol
        jmp resetNoise          
    _manageEnvelope_explosionSfx_pitch_vol:
        ldx #sfx_fail_NOISE_periodEnv-sfx_data  ;Updates the pitch & volume envelope for the noise channel
    if !optimize                 
        jsr manageEnvelope_explosionSfx_period  ;This routine basically only does manageEnvelope_explosionSfx and stores its result
    else 
        jsr manageEnvelope_explosionSfx          
        sta NOISE_PERIOD 
    endif 
        ldx #sfx_fail_NOISE_volEnv-sfx_data                 
        jsr manageEnvelope_explosionSfx
        ora #$10                 
        sta NOISE_VOLUME         
        inc sfx_noise_step       
        rts 
                      
;;
;; manageEnvelope_explosionSfx [$D6BA]
;;
;; This routine updates the explosion sfx with corresponding pitch envelope or volume envelope value 
;;
;; Inputs:
;;  X: low byte to envelope data
;;
;; Returns:
;;  A: envelope value (for either NOISE_PERIOD or NOISE_VOLUME)
;;
;; Local variables:
envAddr         = tmpE0_audio
envAddr_lo      = tmpE0_audio
envAddr_hi      = tmpE1_audio

manageEnvelope_explosionSfx:        
        stx envAddr_lo          ;Store envelope data address  
        ldy #>sfx_data                 
        sty envAddr_hi          
        ldx sfx_noise_step      ;Get at which envelope step we are   
        txa                      
        lsr A                    
        tay                      
        lda (envAddr),Y      
        sta audioData_envelope   
        txa                      
        and #$01                ;Data is only 4bits long, so we read each twice, but only grab half a byte each time
        beq @isolateFirst4Bits   
        lda audioData_envelope   
        and #$0F                 
        rts                      
    @isolateFirst4Bits:      
        lda audioData_envelope   
        lsr A                    
        lsr A                    
        lsr A                    
        lsr A                    
        rts                      



;;
;; playSFX_p2_attack [$D6DB]
;;
;; Routines for starting and updating the attack jingle from player 2
;;
playSFX_p2_attack:       
        ldy #sfx_p2_attack_SQ0-sfx_data         ;First start by copying the SQ0 data to APU                 
        jsr copy_sfxData_to_APU_SQ0          
        lda #$05                 
        ldy #sfx_p2_attack_SQ1-sfx_data                 
        jmp sfx_bothAttacks_andUFOsiren_SQ1     ;The data for SQ 1 + lenght (shared by both SQ0 and SQ1)
    _toFinishedPlayingMalusStinger:
        jmp _finishedPlayingAttackStinger       ;Needed because the BEQ branch that leads here would get out of range if trying to branch directly to the address

sfxPlaying_p2_attack:    
        jsr sfx_increaseSectionCounter          
        bne _exit_sfxPlaying_p1_attack
        ldy sfx_sq0_step                        ;Every time we finish a section lenght, store sfx_sq0_step in y before increasing it
        inc sfx_sq0_step         
        lda sfx_p2_sendMalus_SQ0_pitch,Y        ;Get pitch to play for both sq channels and update APU accordingly
        beq _toFinishedPlayingMalusStinger      
        sta SQ0_TIMER            
        lda sfx_p2_sendMalus_SQ1_pitch,Y
        sta SQ1_TIMER            
        lda #$08                                ;Set note duration for both channels       
        sta SQ0_LENGTH           
        sta SQ1_LENGTH           
        rts                      

sfx_p2_sendMalus_SQ0_pitch:
.db $8D,$01,$7E,$8D,$01,$9F,$01,$A8
.db $01,$01,$01,$D4,$01,$00

sfx_p2_sendMalus_SQ1_pitch:
.db $8E,$01,$7F,$8E,$01,$A0,$01,$A9
.db $01,$01,$01,$D5,$01

;;
;; playSFX_p1_attack [$D727]
;;
;; Routines for starting and updating the attack jingle from player 1. Same principle as for player 2 (previous routines)
;;
playSFX_p1_attack:       
        ldy #sfx_p1_attack_SQ0-sfx_data                 
        jsr copy_sfxData_to_APU_SQ0          
        lda #$06                 
        ldy #sfx_p1_attack_SQ1-sfx_data                 
        jmp sfx_bothAttacks_andUFOsiren_SQ1
    _exit_sfxPlaying_p1_attack:
        rts                      
       
sfxPlaying_p1_attack:    
        jsr sfx_increaseSectionCounter
        bne _exit_sfxPlaying_p1_attack
        ldy sfx_sq0_step         
        inc sfx_sq0_step         
        lda sfx_p1_sendMalus_SQ0_pitch,Y
        beq _finishedPlayingAttackStinger
        sta SQ0_TIMER            
        lda sfx_p1_sendMalus_SQ1_pitch,Y
        sta SQ1_TIMER            
        lda #$08                 
        sta SQ0_LENGTH           
        sta SQ1_LENGTH           
        rts                      

if !removeUnused
        to_finishedPlayingAttackStinger_UNUSED:      
                jmp _finishedPlayingAttackStinger ;This here seems unused
endif

sfx_p1_sendMalus_SQ0_pitch:
.db $63,$96,$01,$4A,$01,$4A,$01,$00

sfx_p1_sendMalus_SQ1_pitch:
.db $64,$97,$01,$76,$00,$76,$01,$00

;;
;; sfx_bothAttacks_andUFOsiren_SQ1 [$D769]
;;
;; Routine shared by all sq0 + sq1 sfx
;;
;; Inputs:
;;  A: sfx section counter value
;;  Y: low byte of sfx data address
;;
sfx_bothAttacks_andUFOsiren_SQ1:
        sta sfx_sectionLength_sq0_sq1   ;Copy SQ1 data to APU
        jsr copy_sfxData_to_APU_SQ1          
        lda audioToPlay_copy            ;Then init/set a couple variables
        sta sfx_playing_sq0_sq1  
        ldx #$01                 
        stx sfxPlaying_forMusic_sq0
        inx                      
        stx sfxPlaying_forMusic_sq1
        lda #$00                 
        sta sfx_sectionCounter_sq0_sq1
        sta sfx_playing_sq0      
        ldx #$01                 
        jmp _resetChannelVariables

;;
;; _finishedPlayingAttackStinger [$D78A]
;;
;; As its name suggests, branched to when the attack stinger is finished playing. Basically inits/sets a couple variables
;;  
_finishedPlayingAttackStinger:
        jsr sfxFinished_SQ0      
        jsr sfxFinished_SQ1      
        inc flag_sfxJustFinished 
        lda #$00                 
        sta sfx_playing_sq0_sq1
    if !optimize 
        ldx #$01                ;Can be optimized, see below    
        lda #$7F                 
        sta SQ0_DUTY,X           
        sta SQ1_DUTY,X           
    else 
        lda #$7F                ;Disables the sweep unit        
        sta SQ0_SWEEP          
        sta SQ1_SWEEP 
    endif 
        rts                      



;;
;; playSFX_UFO_siren_squares [$D7A3]
;;
;; Routines for starting and updating/modulating the UFO siren sfx 
;;        
playSFX_UFO_siren_squares:
        ldy #sfx_UFO_siren_SQ0-sfx_data         ;First routine here copies the data to APU SQ0 and SQ1              
        jsr copy_sfxData_to_APU_SQ0          
        lda #$08                 
        ldy #sfx_UFO_siren_SQ1-sfx_data                 
        jmp sfx_bothAttacks_andUFOsiren_SQ1

sfxPlaying_UFO_siren_squares:
        jsr sfx_UFO_modulatePitch               ;Modulate pitch
        jsr sfx_increaseSectionCounter
        bne sfx_UFO_modulatePitch               ;Modulate again unless end of section counter reached
        ldx #$00                 
        inc sfx_sq0_step               
        lda sfx_sq0_step                        
        cmp #$12                                ;Increase step, if over $12, reset step counter
        beq @UFO_siren_backToStart
        cmp #$09                 
        bcc @UFO_siren_underStep9               
        lda #$B7                 
        jmp @checkIfWeFade       
    @checkIfWeFade:          
        pha                      
        lda sfx_sq0_data                        ;If set, this means we need to start fading the sound    
        bne @UFO_fadeSiren       
        pla                      
    @storeBothSQ_DUTY:       
        sta SQ0_DUTY,X           
        sta SQ1_DUTY,X           
        rts                               
    @UFO_fadeSiren:          
        pla                      
        lda sfx_sq0_data                        ;The data here actually is the value we need to store in SQ0_DUTY and SQ1_DUTY 
        bne @storeBothSQ_DUTY    
    @UFO_siren_backToStart:  
        lda #$00                 
        sta sfx_sq0_step         
        rts                              
    @UFO_siren_underStep9:   
        ora #$B0                                ;Duty at 50%, constant volume, no lenght   
        jmp @checkIfWeFade       

sfx_UFO_modulatePitch:   
        inc sfx_sq0_pitchModulator      ;Next step in pitch modulation
        lda sfx_sq0_pitchModulator
        and #$0F                        ;Wraparound/loop at the end of data
        tay                      
        lda sfx_UFO_pitchModulation_SQ0_SQ1,Y
        clc                      
        adc sfx_UFO_siren_SQ0+2         ;Pitch modulation is relative to the sfx initial pitch
        sta SQ0_TIMER            
        lda sfx_UFO_pitchModulation_SQ0_SQ1,Y
        clc                      
        adc sfx_UFO_siren_SQ1+2         ;Do the same for SQ1
        sta SQ1_TIMER            
        rts                      

sfx_UFO_pitchModulation_SQ0_SQ1:
.db $00,$00,$01,$02,$01,$01,$00,$00
.db $00,$FF,$FE,$FF,$FF,$00,$00,$00

;;
;; checkIf_SFXplaying [$D819]
;;
;; Checks if specified sfx (SQ0 only) are playing
;;
;; Returns
;;  Zero flag: clear if specified sfx is/are playing, set if none of the specified sfx is playing
;;
checkIf_SFXplaying_0A_0B:
if !removeMoreUnused
        lda sfx_playing_sq0             ;Since these sfx are unused, we don't need to check for them   
        cmp #sq0_UNUSED_0A                 
        beq _exit_sfxPlayingCheck
        cmp #sq0_UNUSED_0B                 
        beq _exit_sfxPlayingCheck
        rts 
endif                       
checkIf_SFXplaying_bigVirus_eradicated: 
        lda sfx_playing_sq0      
        cmp #sq0_bigVirus_eradicated                 
        beq _exit_sfxPlayingCheck
        rts                      
checkIf_SFXplaying_cleared_speedup:
        lda sfx_playing_sq0      
        cmp #sq0_pills_cleared                 
        beq _exit_sfxPlayingCheck
        cmp #sq0_virus_cleared                 
        beq _exit_sfxPlayingCheck
        cmp #sq0_speed_up                 
        beq _exit_sfxPlayingCheck
    _exit_sfxPlayingCheck:   
        rts                      

if !removeMoreUnused
        sfxPlaying_highPitchedGlassLike_SQ0_UNUSED:
                lda sfx_sq0_pitchModulator  ;index 23 (34)
                beq @pitchModulatorEmpty 
                inc sfx_sq0_step         
                lda sfx_sq0_step         
                cmp #$16                 
                bne _exit_sfxFinished    
                jmp sfxFinished_SQ0      
        @pitchModulatorEmpty:    
                lda sfx_sq0_step         
                and #$03                 
                tay                      
                lda sfx_highPitchedGlassLike_SQ0_dutyVolEnv_UNUSED,Y
                sta SQ0_DUTY             
                inc sfx_sq0_step         
                lda sfx_sq0_step         
                cmp #$08                 
                bne _exit_sfxFinished    
                inc sfx_sq0_pitchModulator
                ldy #sfx_highPitchedGlassLike_SQ0_step2_UNUSED-sfx_data                 
                jmp copy_sfxData_to_APU_SQ0          
        playSFX_highPitchedGlassLike_SQ0_UNUSED:
                jsr checkIf_SFXplaying_bigVirus_eradicated   ;index 23
                beq _exit_sfxFinished    
                ldy #sfx_highPitchedGlassLike_SQ0_step1_UNUSED-sfx_data                 
                jmp playSFX_lengthA_dataD3YY
endif 

;;
;; playSFX_pillLand [$D877]
;;
;; Checks if we're already playing a more important sfx (cleared pill/virus, or virus eradicated), then if not, play the pill land sfx
;;
playSFX_pillLand:        
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_sfxFinished
    endif     
        jsr checkIf_SFXplaying_cleared_speedup
        beq _exit_sfxFinished    
        jsr checkIf_SFXplaying_bigVirus_eradicated
        beq _exit_sfxFinished    
        lda #$0F                 
        ldy #sfx_pillLand_SQ0-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

;;
;; playSFX_cursor_horizontal [$D88D]
;;
;; Checks if we're already playing a more important sfx (cleared pill/virus, or virus eradicated), then if not, play the cursor horizontal sfx
;;
playSFX_cursor_horizontal:
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_sfxFinished
    endif       
        jsr checkIf_SFXplaying_cleared_speedup
        beq _exit_sfxFinished    
        jsr checkIf_SFXplaying_bigVirus_eradicated
        beq _exit_sfxFinished    
        lda #$02                 
        ldy #sfx_cursorHorizontal_SQ0-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

;;
;; sfxPlaying_increaseDataPointer [$D8A3]
;;
;; Used as update routine for playSFX_pillLand & playSFX_cursor_horizontal
;;
sfxPlaying_increaseDataPointer:
        jsr sfx_increaseSectionCounter
        bne _exit_sfxFinished    

;;
;; sfxFinished_SQ0 [$D8A8]
;;
;; Mutes the SQ0 channel and inits some variables
;;
sfxFinished_SQ0:         
        lda #$10                 
        sta SQ0_DUTY             
        lda #$00                 
        sta sfxPlaying_forMusic_sq0
        sta sfx_playing_sq0      
        inc flag_sfxJustFinished 
    _exit_sfxFinished:       
        rts 

;;
;; playSFX_cursor_vertical [$D8B9]
;;
;; Routines for starting and updating the cursor vertical sfx 
;;
    _exit_updateSFX_cursor_vertical:
        rts                      
sfxPlaying_cursor_vertical:
        jsr sfx_increaseSectionCounter                  ;Pretty standard: when reaching end of section coutner, increase step
        bne _exit_updateSFX_cursor_vertical
    @cursorVertical_sectionFinished:
        inc sfx_sq0_step         
        lda sfx_sq0_step         
        cmp #$02                                        ;And then when step reaches $02, change APU data to step 2
        bne @cursorVertical_changeSection
        jmp sfxFinished_SQ0      
    @cursorVertical_changeSection:
        ldy #sfx_cursorVertical_SQ0_step2-sfx_data                 
        jmp copy_sfxData_to_APU_SQ0          

playSFX_cursor_vertical: 
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_playSFX_cursor_vertical
    endif    
        jsr checkIf_SFXplaying_cleared_speedup          ;Make sure we're not playing more important sfx (pill/virus cleared or big virus eradicated)
        beq _exit_playSFX_cursor_vertical               ;There's no way this can happen in the vanilla game, so we could safely optimize if we wanted
        jsr checkIf_SFXplaying_bigVirus_eradicated
        beq _exit_playSFX_cursor_vertical
        lda #$02                 
        ldy #sfx_cursorVertical_SQ0_step1-sfx_data                 
        bne jmpTo_playSFX_lengthA_dataD3YY
    _exit_playSFX_cursor_vertical:
        rts                      

;;
;; playSFX_flipPill [$D8E7]
;;
;; Routines for starting and updating the pill flip sfx
;;
playSFX_flipPill:        
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_playSFX_cursor_vertical
    endif 
        jsr checkIf_SFXplaying_cleared_speedup          ;Pretty standard: check if more important sfx are playing, if not, copy appropriate APU data
        beq _exit_playSFX_cursor_vertical
        jsr checkIf_SFXplaying_bigVirus_eradicated
        beq _exit_playSFX_cursor_vertical
        lda #$03                 
        ldy #sfx_flipPill_SQ0_step1-sfx_data
    if !optimize                            
        jsr jmpTo_playSFX_lengthA_dataD3YY
    else 
        jsr playSFX_lengthA_dataD3YY
    endif 


sfxPlaying_flipPill:     
        jsr sfx_increaseSectionCounter                  ;Increase section counter               
        bne _exit_playSFX_cursor_vertical
        lda sfx_sq0_step                                ;Each end of section, increase step
        inc sfx_sq0_step         
        beq @sfxPlaying_flipPill_step2                  ;Depending on which step, cycle between sfx step 1 & 2
        cmp #$01                 
        beq @sfxPlaying_flipPill_step1   
        cmp #$02                 
        beq @sfxPlaying_flipPill_step2   
        cmp #$03                 
        bne _exit_playSFX_cursor_vertical
        jmp sfxFinished_SQ0                             ;On step 3, we go to the sfx end
    @sfxPlaying_flipPill_step1:      
        ldy #sfx_flipPill_SQ0_step1-sfx_data                 
        jmp copy_sfxData_to_APU_SQ0          
    @sfxPlaying_flipPill_step2:      
        ldy #sfx_flipPill_SQ0_step2-sfx_data                 
        jmp copy_sfxData_to_APU_SQ0 

;;
;; playSFX_bigVirus_eradicated [$D923]
;;
;; Routines for starting and updating the big virus eradicated sfx
;;
playSFX_bigVirus_eradicated:
        lda #$03                 
        ldy #sfx_bigVirus_eradicated_SQ0-sfx_data
    if !optimize                 
        jsr jmpTo_playSFX_lengthA_dataD3YY
    else 
        jsr playSFX_lengthA_dataD3YY                    ;Update APU data
    endif 
        lda #sfx_bigVirusEradicated_SQ0_TIMER-sfx_modulatePitch_data_SQ0                  
        bne _storePitchModulator                        ;Then store pitch modulator data

sfxPlaying_bigVirus_eradicated:
        jsr sfx_increaseSectionCounter                  ;Increase counter
        bne _exit_playSFX_virusEliminated
        ldy #sfx_bigVirus_eradicated_SQ0-sfx_data       ;When reaching end of counter, modulate pitch/duty              
        bne _modulate_pitch_duty     

;;
;; jmpTo_playSFX_lengthA_dataD3YY [$D937]
;;
;; This routine seems unnecessary, but it is needed for branching instructions that would need to branch to playSFX_lengthA_dataD3YY
;;
jmpTo_playSFX_lengthA_dataD3YY:
        jmp playSFX_lengthA_dataD3YY
                  

;;
;; playSFX_pillMatch_noVirus [$D93B]
;;
;; Routines for starting and updating the pill match (without virus) sfx
;;
    _exit_playSFX_pillMatch_noVirus:
        rts    
playSFX_pillMatch_noVirus:
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_playSFX_pillMatch_noVirus
    endif 
        jsr checkIf_SFXplaying_bigVirus_eradicated      ;Same principle as playSFX_bigVirus_eradicated, only with different values
        beq _exit_playSFX_pillMatch_noVirus
        lda #$02                 
        ldy #sfx_pillCleared_SQ0-sfx_data
    if !optimize                 
        jsr jmpTo_playSFX_lengthA_dataD3YY
    else 
        jsr playSFX_lengthA_dataD3YY
    endif 
        lda #sfx_pillMatch_SQ0_TIMER-sfx_modulatePitch_data_SQ0                 
        bne _storePitchModulator 

sfxPlaying_pillMatch_noVirus:
        jsr sfx_increaseSectionCounter
        bne _exit_playSFX_virusEliminated
        ldy #sfx_pillCleared_SQ0-sfx_data                 
        bne _modulate_pitch_duty 

;;
;; playSFX_virusEliminated [$D959]
;;
;; Routines for starting and updating the virus eliminated sfx
;;
playSFX_virusEliminated: 
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_playSFX_virusEliminated
    endif         
        jsr checkIf_SFXplaying_bigVirus_eradicated      ;Same principle as playSFX_bigVirus_eradicated, only with different values
        beq _exit_playSFX_virusEliminated
        lda #$02                 
        ldy #sfx_virusEliminated_SQ0-sfx_data
    if !optimize                 
        jsr jmpTo_playSFX_lengthA_dataD3YY
    else 
        jsr playSFX_lengthA_dataD3YY
    endif 
        lda #sfx_virusEliminated_SQ0_TIMER-sfx_modulatePitch_data_SQ0                 
    _storePitchModulator:    
        sta sfx_sq0_pitchModulator
    _exit_playSFX_virusEliminated:
        rts                      

sfxPlaying_virusEliminated:
        jsr sfx_increaseSectionCounter
        bne _exit_playSFX_virusEliminated
        ldy #sfx_virusEliminated_SQ0-sfx_data                 
    _modulate_pitch_duty:        
        jsr copy_sfxData_to_APU_SQ0                     ;This part here is shared by several SQ0 sfx playing routines
        clc                      
        lda sfx_sq0_pitchModulator                      ;Actually, an offset to the pitch modulation data
        adc sfx_sq0_step         
        tay                      
        lda sfx_virusEliminated_SQ0_TIMER,Y             ;Modulate pitch
        sta SQ0_TIMER            
        ldy sfx_sq0_step         
        lda sfx_virusEliminated_pillMatch_SQ0_DUTY,Y    ;Then modulate duty. Also shared by big virus eradicated 
        sta SQ0_DUTY                                    ;If the value of duty is $00, we have reached the end of the data (and thus the end of the sfx), otherwise, increase step
        bne @sfx_virusEliminated_notFinished
        jmp sfxFinished_SQ0      
    @sfx_virusEliminated_notFinished:
        inc sfx_sq0_step         
    _exit_sfxPlaying_virusEliminated:
        rts                      

if !removeMoreUnused        
        playSFX_slowAlert_SQ0_UNUSED:
                lda #$12                            ;index 26
                ldy #sfx_alertSlow_SQ0_UNUSED-sfx_data                 
                jmp playSFX_lengthA_dataD3YY
        sfxPlaying_slowAlert_SQ0_UNUSED:
                jsr sfx_increaseSectionCounter      ;index 26 (37)
                bne _exit_sfxPlaying_virusEliminated
                inc sfx_sq0_step         
                lda sfx_sq0_step         
                cmp #$03                 
                bne @sfxNotFinished      
                jmp sfxFinished_SQ0      
        @sfxNotFinished:         
                ldy #sfx_alertSlow_SQ0_UNUSED-sfx_data                 
                jmp copy_sfxData_to_APU_SQ0

        playSFX_alert_SQ0_UNUSED:
                lda #$07                            ;index 25
                ldy #sfx_alert_SQ0_UNUSED-sfx_data                 
                jmp playSFX_lengthA_dataD3YY
        sfxPlaying_alert_SQ0_UNUSED:
                jsr sfx_increaseSectionCounter      ;index 25 (36)
                bne _exit_sfxPlaying_virusEliminated
                inc sfx_sq0_step         
                lda sfx_sq0_step         
                cmp #$05                 
                bne @sfxNotYetFinished   
                jmp sfxFinished_SQ0      
        @sfxNotYetFinished:      
                ldy #sfx_alert_SQ0_UNUSED-sfx_data                 
                jmp copy_sfxData_to_APU_SQ0                             
endif 
    _exit_SFX_speedUp:          ;This part is used by other routines       
        rts   

;;
;; sfx_virusEliminated_pillMatch_SQ0_DUTY & other data [$D9D7]
;;
;; Data used to modulate duty, volume and pitch of SQ0 sfx
;;
sfx_virusEliminated_pillMatch_SQ0_DUTY:
.db $BD,$BB,$BA,$B9,$B8,$B7,$B6,$B4     ;Modulates duty and volume, shared by 3 SQ0 sfx
.db $B3,$B2,$B2,$B1
.db $00                                 ;End of data 

sfx_modulatePitch_data_SQ0:
sfx_virusEliminated_SQ0_TIMER:
.db $F0,$60,$E0,$70,$D0,$80,$C0,$90     ;Modulates pitch, one data set per sfx
.db $F0,$60,$E0,$70                     ;Must be of same size than sfx_virusEliminated_pillMatch_SQ0_DUTY (minus the end of data)

sfx_pillMatch_SQ0_TIMER:
.db $60,$80,$60,$80,$60,$80,$60,$80
.db $60,$80,$60,$80

sfx_bigVirusEradicated_SQ0_TIMER:
.db $E0,$D0,$C0,$B0,$A0,$90,$80,$70
.db $60,$50,$50,$40

;;
;; playSFX_speedUp [$DA08]
;;
;; Routines for starting and updating the speed up sfx
;;
sfxPlaying_speedUp:      
        jsr sfx_increaseSectionCounter
        bne _exit_SFX_speedUp    
        ldy sfx_sq0_step                ;Each step, change pitch according to data
        inc sfx_sq0_step         
        lda sfx_speedUp_SQ0_TIMER,Y     ;The timer is each note
        beq @playSFX_speedUp_finished   ;If data is zero, we have reached the end of the sfx
        sta SQ0_TIMER            
        lda #$28                        ;All notes have equal length 
        sta SQ0_LENGTH           
        rts                            
    @playSFX_speedUp_finished:
        jmp sfxFinished_SQ0

playSFX_speedUp:         
    if !optimize
        jsr checkIf_SFXplaying_0A_0B
        beq _exit_SFX_speedUp    
    endif 
        jsr checkIf_SFXplaying_bigVirus_eradicated      ;Pretty standard: check if more important sfx playing, if not, copy relevant data to APU
        beq _exit_SFX_speedUp    
        lda #$05                 
        ldy #sfx_speedUp_SQ0-sfx_data                 
        jmp playSFX_lengthA_dataD3YY

sfx_speedUp_SQ0_TIMER:   
.db $A8,$8D,$A8,$D4
.db $00                 ;End of data

;;
;; sfxFinished_SQ1 [$DA3A]
;;
;; Mutes the SQ1 channel and inits some variables (called only by _finishedPlayingAttackStinger)
;;
sfxFinished_SQ1:         
        lda #$10                 
        sta SQ1_DUTY             
        lda #$00                 
        sta sfxPlaying_forMusic_sq1
        sta sfx_playing_sq1      
        rts                      

;Here starts the (unused) routines for DMC sfx
if !removeMoreUnused
        playSFX_UNK_DA48_DMC:    
                lda #$3F                 ;index 54
                ldy #$60                 ;Quite probaly garbage as code is at the specified address (D800)
                ldx #$0F                 
                bne _storeDmc_SFX
        playSFX_UNK_DA50_DMC:    
                lda #$3F                 ;index 53
                ldy #$60                 ;Quite probaly garbage as code is at the specified address (D800)
                ldx #$0E                 
                bne _storeDmc_SFX        
        _storeDmc_SFX:           
                sta DMC_LENGTH           
                sty DMC_ADDR             
                stx DMC_FREQ             
                lda #$0F                 
                sta APUSTATUS            
                lda #$00                 
                sta DMC_COUNTER          
                lda #$1F                 
                sta APUSTATUS            
                rts 
endif                      

;Here starts the routines for triangle channel sfx
if !removeMoreUnused
        playSFX_lowPitchedCursor_TRG_UNUSED:
                lda #$03                            ;index 39
                ldy #sfx_lowPitchedCursor_TRG_UNUSED-sfx_data                 
                jmp playSFX_lengthA_dataD3YY
        sfxPlaying_lowPitchedCursor_TRG_UNUSED:
                jsr sfx_increaseSectionCounter      ;index 39 (43)
                bne _exit_sfxFinished_TRG 
endif 

;;
;; sfxFinished_TRG [$DA7D]
;;
;; Mutes the TRG channel and inits some variables
;;
sfxFinished_TRG:   
        lda #$00                            
        sta TRG_LINEAR           
        sta sfxPlaying_forMusic_trg
        sta sfx_playing_trg      
        lda #$18                 
        sta TRG_LENGTH           
    _exit_sfxFinished_TRG:
        rts                      

;;
;; sfxPlaying_UFO_motor_TRG [$DA8E]
;;
;; Routine for updating the UFO motor sfx (the playSfx routine for this is lower)
;;        
sfxPlaying_UFO_motor_TRG:
        jsr sfx_increaseSectionCounter
        beq @UFO_motor_TRG_finishedSection
    if !optimize
        sta TRG_TIMER                   ;No need, we will change this value 4 instructions from now                 
    endif 
        lda sfx_trg_pitchModulator
        adc sfx_trg_pitch_offset     
        sta sfx_trg_pitchModulator      ;Calculate pitch using offset and modulator (aka previous value)
        sta TRG_TIMER            
        rts                           
    @UFO_motor_TRG_finishedSection:
        lda sfx_trg_pitch         
        sta sfx_trg_pitchModulator      ;Store actual pitch to use as pitch modulator later     
        ldy sfx_trg_data                ;SFX data is stored in this variable
        jsr copy_sfxData_to_APU_TRG     ;Update APU data (bypassing the usual playSFX_lengthA_dataD3YY)         
        rts                      

;;
;; playSFX_UFO_beam_TRG [$DAB0]
;;
;; Routine for starting the UFO beam trg sfx
;;
playSFX_UFO_beam_TRG:    
        lda #$1B                        ;Copy basic APU data for sfx
        ldy #sfx_UFO_beam_TRG-sfx_data                 
        jsr playSFX_lengthA_dataD3YY
        lda sfx_UFO_beam_TRG+2          ;Store pitch in pitch modulator (and current pitch)
        sta sfx_trg_pitchModulator
        sta sfx_trg_pitch         
        lda #sfx_UFO_beam_TRG-sfx_data                 
        sta sfx_trg_data                ;Store address offset to sfx data
        lda #$FC                 
        sta sfx_trg_pitch_offset        ;Store pitch offset for beam (different for each trg sfx)
        rts                      
      
;;
;; playSFX_UFO_motor_TRG [$DACB]
;;
;; Routines for starting the UFO motor sfx (update routine is higher up)
;;
playSFX_UFO_motor_fast_TRG:
        lda #$1B                        ;Different length (and thus speed) of sfx depending on motor speed
        bne _storeUFO_motorDataAddr
playSFX_UFO_motor_TRG:   
        lda #$23                 
    _storeUFO_motorDataAddr: 
        ldy #sfx_UFO_motor_TRG-sfx_data                 
        jsr playSFX_lengthA_dataD3YY
        lda sfx_UFO_motor_TRG+2         ;The rest is same as playSFX_UFO_beam_TRG (but with different values)
        sta sfx_trg_pitchModulator
        sta sfx_trg_pitch         
        lda #sfx_UFO_motor_TRG-sfx_data                 
        sta sfx_trg_data     
        lda #$05                 
        sta sfx_trg_pitch_offset
        rts                      