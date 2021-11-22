;;
;; audioUpdate_initVariablesChannels & sfxUpdate [$D3D0]
;;
;; Each "entry point" to this routine updates a different sfx channel (or inits the APU)
;; 
;; Local variables:
jumptable_sfx_chan      = tmpE0_audio
jumptable_sfx_chan_lo   = tmpE0_audio
jumptable_sfx_chan_hi   = tmpE1_audio
sfxRoutine              = tmpE2_audio
sfxRoutine_lo           = tmpE2_audio
sfxRoutine_hi           = tmpE3_audio
sfxToPlay_offset        = tmpE2_audio

audioUpdate_initVariablesChannels:
        ldx #sfx_channel_init                               ;Would normally be for SQ1, but seems to init APU variables and channels instead (INCLUDING music)
        lda #jumpTable_sfx_initApu-jumptable_sfx            
        ldy #jumpTable_sfx_initApu-jumptable_sfx                  
        bne _SFX_Mixer           
sfxUpdate_TRG:         
        ldx #sfx_channel_trg                                ;x is "sfx channel" number
        lda #jumpTable_sfx_trg_play-jumptable_sfx           ;This holds the offset for the index table when "sfx to play"
        ldy #jumpTable_sfx_trg_playing-jumptable_sfx        ;This holds the offset for the index table when "sfx is playing"
        bne _SFX_Mixer           
sfxUpdate_SQ0_SQ1:
        ldx #sfx_channel_sq0_sq1                            ;Always both squares
        lda #jumpTable_sfx_sq0_sq1_play-jumptable_sfx                  
        ldy #jumpTable_sfx_sq0_sq1_playing-jumptable_sfx                  
        bne _SFX_Mixer           
sfxUpdate_SQ0:         
        lda sfx_playing_sq0_sq1  
        bne _exit_channelAudioUpdate
        ldx #sfx_channel_sq0                 
        lda #jumpTable_sfx_sq0_play-jumptable_sfx                  
        ldy #jumpTable_sfx_sq0_playing-jumptable_sfx                  
        bne _SFX_Mixer           
sfxUpdate_NOISE:       
        ldx #sfx_channel_noise                 
        lda #jumpTable_sfx_noise_play-jumptable_sfx                 
        ldy #jumpTable_sfx_noise_playing-jumptable_sfx                 
    _SFX_Mixer:              
        sta jumptable_sfx_chan_lo                           ;In this case this var is the offset (or basis) for the sfx jump table
        stx sfx_channel           
        lda sfx_toPlay_noise,X   
        beq _noSFXToPlay_checkSFXPlaying
    _sfxToPlay_orIsPlaying:  
        sta audioToPlay_copy     
        sta sfxToPlay_offset          
        ldy #>jumptable_sfx                                 ;High byte of sfx jump table address
        sty jumptable_sfx_chan_hi          
    if !optimize
        and #%00000111                                      ;We then start from the index nb of the sfx to play, and transform into an offset for the sfx jump table
        tay                                                 ;It looks to me like a very complicated way of simply doing minus 1 (-1), then multiply by 2 (x2)
        lda sfx_jumpTable_offset,Y  
        tay                      
        dec sfxToPlay_offset          
        lda sfxToPlay_offset          
        and #%11111000                 
        sta sfxToPlay_offset          
        asl sfxToPlay_offset          
        tya                      
        ora sfxToPlay_offset          
        tay                                                 
    else 
        dec sfxToPlay_offset
        asl sfxToPlay_offset
        ldy sfxToPlay_offset
    endif 
        lda (jumptable_sfx_chan),Y                          ;We now have the offset for the current channel's sfx jump table address in Y
        sta sfxRoutine_lo          
        iny                      
        lda (jumptable_sfx_chan),Y      
        sta sfxRoutine_hi          
        jmp (sfxRoutine)                                    ;Here we jump to the routine that plays/updates the SFX
    if !optimize
    sfx_jumpTable_offset:    
        .db $0E,$00,$02,$04,$06,$08,$0A,$0C                 ;Part of the rather complicated code to reduce by 1 and mult by 2
    endif  
    _noSFXToPlay_checkSFXPlaying:
        lda sfx_playing_noise,X  
        beq _exit_channelAudioUpdate
        sty jumptable_sfx_chan_lo                           ;Y holds the address of the sfx_playing data     
        bne _sfxToPlay_orIsPlaying
    _exit_channelAudioUpdate:
        rts                      
                    

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
   
;;
;; initAPU_variablesAndChannels [$D4E5]
;;
;; Inits several APU variables & channels (muting everything including music)
;; 
initAPU_variablesAndChannels:
        jsr initAPU_variables    
initAPU_channelsAndDMC:  
        jsr initAPU_channels     
        lda #$00                              
    if !optimize
        sta DMC_COUNTER                 ;This was litteraly done just a couple cycles ago in initAPU_channels 
    endif 
        sta music_trg_envelope_index
        rts                      

;;
;; initAPU_variables [$D4F4]
;;
;; Inits plenty of variables related to sfx + music playing
;; 
initAPU_variables:       
        lda #$00                 ;Also when playing ending music
        sta sfxPlaying_forMusic_sq0
        sta sfxPlaying_forMusic_sq1
        sta sfxPlaying_forMusic_trg
    if !optimize
        sta flag_audio_68C_UNK  ;Is never used  
    endif 
        sta sfx_sq0_data        ;Not sure why specifically we init this variable       
        sta flag_sfxJustFinished 
        tay                      
    if !optimize
    @resetAudioPlaying:      
        lda #$00                ;Could be optimized   
        sta sfx_playing_noise,Y  
        iny                      
        tya                      
        cmp #mixer_channels     ;We have 6 "mixer channels" (5 for sfx and the last one for music)                 
    else                     
        lda #$00 
    @resetAudioPlaying:      
        sta sfx_playing_noise,Y  
        iny                                           
        cpy #mixer_channels     
    endif 
        bne @resetAudioPlaying   
        rts                      

;;
;; initAPU_channels [$D515]
;;
;; Mutes all channels
;; 
initAPU_channels:        
    if !optimize
        lda #$00                  
        sta DMC_COUNTER         ;This can be done later with the TRG_LINEAR
    endif         
        lda #SQ_DUTY_NOISE_mute                 
        sta SQ0_DUTY             
        sta SQ1_DUTY             
        sta NOISE_VOLUME         
        lda #$00                   
        sta TRG_LINEAR          
    if optimize
        sta DMC_COUNTER
    endif 
        rts                      