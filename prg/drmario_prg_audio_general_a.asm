;;
;; jumptable_sfx [$D200]
;;
;; Jumptables for various sfx, seperated by channel use (and also if starting to play or already playing)
;; 
jumptable_sfx:
jumpTable_sfx_noise_play:
    if !removeMoreUnused
        .word playSFX_highToLowPitch_NOISE_UNUSED
    endif 
        .word playSFX_explosion_NOISE
        .word playSFX_bigVirus_hurt_NOISE
        .word playSFX_UFO_leave_NOISE
        .word playSFX_UFO_boom_NOISE
        .word playSFX_UFO_beam_NOISE
        .word playSFX_UFO_postBeam_NOISE
        .word _exit_sfxUses

jumpTable_sfx_noise_playing:
    if !removeMoreUnused
        .word sfxPlaying_highToLowPitch_NOISE_UNUSED
    endif 
        .word sfxPlaying_explosion_NOISE
        .word sfxPlaying_bigVirus_hurt_NOISE
        .word sfxPlaying_UFO_leave_NOISE
        .word sfxPlaying_UFO_boom_NOISE
        .word sfxPlaying_UFO_beam_NOISE
        .word _exit_sfxUses
        .word _exit_sfxUses 

jumpTable_sfx_sq0_play:
        .word playSFX_cursor_vertical
        .word playSFX_pillMatch_noVirus
        .word playSFX_cursor_horizontal
        .word playSFX_virusEliminated
        .word playSFX_flipPill
        .word playSFX_speedUp
        .word playSFX_pillLand
    if !removeMoreUnused
        .word playSFX_highPitchedGlassLike_SQ0_UNUSED
    endif 
        .word playSFX_bigVirus_eradicated
    if !removeMoreUnused
        .word playSFX_alert_SQ0_UNUSED
        .word playSFX_slowAlert_SQ0_UNUSED
    endif 
        
jumpTable_sfx_sq0_playing:        
        .word sfxPlaying_cursor_vertical
        .word sfxPlaying_pillMatch_noVirus
        .word sfxPlaying_increaseDataPointer
        .word sfxPlaying_virusEliminated 
        .word sfxPlaying_flipPill
        .word sfxPlaying_speedUp
        .word sfxPlaying_increaseDataPointer
    if !removeMoreUnused
        .word sfxPlaying_highPitchedGlassLike_SQ0_UNUSED
    endif  
        .word sfxPlaying_bigVirus_eradicated
    if !removeMoreUnused
        .word sfxPlaying_alert_SQ0_UNUSED
        .word sfxPlaying_slowAlert_SQ0_UNUSED
    endif 
 
jumpTable_sfx_trg_play:
        .word playSFX_UFO_beam_TRG
    if !removeMoreUnused
        .word playSFX_lowPitchedCursor_TRG_UNUSED
    endif 
        .word playSFX_UFO_motor_fast_TRG
        .word playSFX_UFO_motor_TRG

jumpTable_sfx_trg_playing:
        .word sfxPlaying_UFO_motor_TRG
    if !removeMoreUnused
        .word sfxPlaying_lowPitchedCursor_TRG_UNUSED
    endif 
        .word sfxPlaying_UFO_motor_TRG
        .word sfxPlaying_UFO_motor_TRG
        
jumpTable_sfx_sq0_sq1_play:
        .word playSFX_p1_attack
        .word playSFX_p2_attack
        .word playSFX_UFO_siren_squares

jumpTable_sfx_sq0_sq1_playing:
        .word sfxPlaying_p1_attack
        .word sfxPlaying_p2_attack
        .word sfxPlaying_UFO_siren_squares

jumpTable_sfx_initApu:
        .word initAPU_variablesAndChannels

jumpTable_sfx_dmc_UNUSED:
    if !removeMoreUnused
        .word playSFX_UNK_DA50_DMC
        .word playSFX_UNK_DA48_DMC
    endif 

;;
;; copy_sfxData_to_APU [$D26E]
;;
;; Fills up a given channel 4 APU registers with data from ROM
;; 
;; Inputs:
;;  Y: Low byte of sfx data
;;
;; Local variables:
APUADDR         = tmpE0_audio
APUADDR_lo      = tmpE0_audio
APUADDR_hi      = tmpE1_audio
sfxData         = tmpE2_audio
sfxData_lo      = tmpE2_audio
sfxData_hi      = tmpE3_audio
copy_sfxData_to_APU_SQ0:             
        lda #<APU_SQ0                 
        beq _sfxData_to_APUchannel
copy_sfxData_to_APU_TRG:             
        lda #<APU_TRG                 
        bne _sfxData_to_APUchannel
copy_sfxData_to_APU_NOISE:           
        lda #<APU_NOISE                 
        bne _sfxData_to_APUchannel
copy_sfxData_to_APU_SQ1:             
        lda #<APU_SQ1
    _sfxData_to_APUchannel:   
        sta APUADDR_lo          
        lda #>APU                       ;High byte of APU register, starts at $4000
        sta APUADDR_hi                        
        sty sfxData_lo                  ;Low byte of sfx data (was held in y)
        lda #>sfx_data                  ;High byte of sfx data: starts at $D300 in vanilla
        sta sfxData_hi          
        ldy #$00                 
    @fillChannelRegisters_loop:
        lda (sfxData),Y      
        sta (APUADDR),Y      
        iny                      
    if !optimize
        tya                             ;Why not compare directly to Y here?       
        cmp #APU_channel_register_size  ;4 times                 
    else 
        cpy #APU_channel_register_size
    endif 
        bne @fillChannelRegisters_loop
    _exit_sfxUses:           
        rts                      

;;
;; randomizeNoisePeriod [$D295]
;;
;; Generates two random numbers for use as noise period
;; An almost direct copy paste of randomNumberGenerator
;; 
randomizeNoisePeriod:
    if !optimize    
        lda sfx_rndNoisePeriod   
        and #$02                 
        sta sfx_rndNoisePeriod_tmp2
        lda sfx_rndNoisePeriod_tmp1
        and #$02                 
        eor sfx_rndNoisePeriod_tmp2
        clc                      
        beq @randomizeNoisePeriod_rotateRight
        sec                      
    @randomizeNoisePeriod_rotateRight:
        ror sfx_rndNoisePeriod   
        ror sfx_rndNoisePeriod_tmp1
        rts 
    else 
        ldx #sfx_rndNoisePeriod                 
        ldy #rngSize                 
        jmp randomNumberGenerator
    endif                      

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

;;
;; initAPU_status [$D2B7]
;;
;; Is only called during game init, enables all channels (except DMC), sets the random noise seed and then inits APU variables and channels
;;        
initAPU_status:          
        lda #APUSTATUS_sq0_on + APUSTATUS_sq1_on + APUSTATUS_trg_on + APUSTATUS_noise_on                 
        sta APUSTATUS            
        lda #rngSeed_noise                 
        sta sfx_rndNoisePeriod   
        jsr initAPU_variablesAndChannels
        rts                      