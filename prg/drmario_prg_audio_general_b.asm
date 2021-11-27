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

if !ver_EU
    include prg/routines/drmario_prg_audio_update.asm                  
endif 

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