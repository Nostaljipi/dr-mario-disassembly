;;
;; audioUpdate [$D3D0]
;;
;; Main routine to update all the audio (sfx and music)
;;       
    _gameWasJustPaused:      
        inc flag_pause_forAudio_internal
        jsr initAPU_channels                ;A is set to zero when we rts from this subroutine 
        sta sfxPause_soundProgress
        rts  
    _audioOnPause:            
        lda flag_pause_forAudio_internal
        beq _gameWasJustPaused   
        lda sfxPause_soundProgress
        cmp #sfx_pause_length                 
        beq @exit_audioOnPause              ;If so, pause sound has finished playing
    @continuePlaying_pauseSFX:
        and #sfx_pause_change_step          ;Changes sfx step at every $03 frames                 
        cmp #sfx_pause_change_step                 
        bne @increasePauseSFXcounter
        inc sfxPause_soundProgress_div
        ldy #<sfx_pause_SQ0_step2                 
        lda sfxPause_soundProgress_div
        and #$01                            ;Effectively alternates between both sfx steps                 
        bne @updateSQ0_pauseSFX  
        ldy #<sfx_pause_SQ0_step1                 
    @updateSQ0_pauseSFX:     
        jsr copy_sfxData_to_APU_SQ0          
    @increasePauseSFXcounter:
        inc sfxPause_soundProgress
    @exit_audioOnPause:      
        rts                        
audioUpdate:             
        lda #APUCOUNTER_mode_step5 + APUCOUNTER_irq_inhibit                
        sta APUCOUNTER                      ;Mode = 5-step (drives env, sweep, length for all channels except DMC), IRQ inhibit... manually synchronizes with PPU NMI
        jsr randomizeNoisePeriod 
        lda flag_pause_forAudio  
        cmp #pauseAudio                 
        beq _audioOnPause         
    @audioNotOnPause:        
        lda #$00                 
        sta flag_pause_forAudio_internal
        sta sfxPause_soundProgress_div
        lda sfx_toPlay_sq0_sq1   
        cmp #sq0_sq1_UFO_siren                 
        beq @prepVariousUFO_sfx             ;If this sfx is playing, than no music is playing
        jmp @sfx_triggeredByMusic
    @prepVariousUFO_sfx:     
        jsr initAPU_variablesAndChannels
        lda #sq0_sq1_UFO_siren              ;Starting the siren always comes with UFO appears & UFO motor sfx           
        sta sfx_toPlay_sq0_sq1   
        lda #noise_UFO_appears                 
        sta sfx_toPlay_noise     
        lda #trg_UFO_motor_regular                 
        sta sfx_toPlay_trg       
    @sfx_triggeredByMusic:   
        lda music_toPlay                    ;This portion checks if there are sfx triggered by music (which occurs on fail and once during the final cutscene)      
        cmp #mus_fail                 
        beq @musicIsFail         
        cmp #mus_cutscene_explosion                 
        beq @musicIsFinalCutscene_duringFireworks
        jmp @audioUpdate_all     
    @musicIsFinalCutscene_duringFireworks:
        jsr initAPU_variablesAndChannels    ;Gets here when the fireworks just started
    if !optimize
        lda #mus_cutscene_explosion         ;We can optimize, music_toPlay is already mus_cutscene_explosion                 
        sta music_toPlay         
    endif 
        lda #noise_explosion                ;Play the explosion sfx
        sta sfx_toPlay_noise     
        jmp @audioUpdate_all     
    @musicIsFail:            
        lda #noise_explosion
    if !optimize                 
        bne @nextStep                       ;Seems a bit useless since both lead to the next instruction
    @nextStep:
    endif            
        sta sfx_toPlay_noise                ;Plays the explosion sfx
    @audioUpdate_all:        
        jsr audioUpdate_initVariablesChannels
        jsr sfxUpdate_NOISE                 ;The order here is important, update that occur before others will "monopolize" the channel
        jsr sfxUpdate_SQ0_SQ1               ;For instance, if a sfx with SQ0 and SQ1 is playing, we won't play later SQ0 sfx, nor both SQ in the music
        jsr sfxUpdate_TRG      
        jsr sfxUpdate_SQ0      
        jsr music_toPlay_andUpdate
        lda #$00                 
        ldx #mixer_channels                 
    @emptyAll_audioToPlay:   
        sta sfx_toPlay_noise-1,X            ;Empty all "to play" (5 sfx channels + 1 music channel) before ending music update
        dex                      
        bne @emptyAll_audioToPlay
        rts    