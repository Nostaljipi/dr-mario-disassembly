;;
;; music_toPlay_andUpdate [$DAEA]
;;
;; Routine that manages which music is playing, and does some init/prep when a new music must play
;;
    _toInitAPU_variablesAndChannels:
        jmp initAPU_variablesAndChannels
    _titleMusicContinueCheck:
        pha                      
        lda music_playing        
        cmp #mus_title                 
        bne @justSwitchedToTitleMusic   ;If title music is not already playing, prep it
        pla                      
        rts                             
    @justSwitchedToTitleMusic:
        pla                      
        jmp _prepMusicToPlay     
music_toPlay_andUpdate:  
        lda music_toPlay            ;Routine actually starts here    
        tay                      
        cmp #$FF                    ;If music to play is $FF, then init APU variables and channels (never occurs in vanilla)
        beq _toInitAPU_variablesAndChannels
        cmp #$00                    ;If no new music must play, check if a music is playing
        beq _checkMusicPlaying   
        cmp #mus_title              ;If music is title, check if it was already playing      
        beq _titleMusicContinueCheck
    _prepMusicToPlay:        
        sta audioToPlay_copy        ;Make a copy of music to play
        sta music_toPlay_zeroBased
        dec music_toPlay_zeroBased  ;Then another copy, this time zero-based
        lda musicBeatDurationTable,Y
        sta musicBeatDuration       ;Then get music beat duration (to time animation to music)
        lda #$7F                 
        sta SQ0_SWEEP_RAM           ;Disable both sweeps
        sta SQ1_SWEEP_RAM        
        jsr prepNewMusic            ;Prep new music
    _toMusicUpdate:          
        jmp musicUpdate             ;Then update music 
    _checkMusicPlaying:      
        lda music_playing           ;If music is playing, update music      
        bne _toMusicUpdate       
        rts                      

;;
;; musicBeatDurationTable [$DB2D]
;;
;; The duration of a beat for each music, used for timing of animations to the beat (music nb is zero-based in this case)
;;
musicBeatDurationTable:
.db $00,$00,$0D,$0A,$0B,$04,$0B,$00
.db $00,$00,$00,$00,$00

;;
;; music_noiseData_percussion [$DB3A]
;;
;; Called by music_updateNoise. Each group is a noise-based percussion
;;
music_noiseData_percussion:
.db $00             ;First byte unused
.db $10,$01,$18     ;Then groups of 3 bytes (each is a noise-based percussion) : volume, period (pitch), length
.db $00,$01,$38
.db $00,$03,$40
.db $00,$06,$58
.db $00,$0A,$38
.db $02,$04,$40
.db $13,$05,$40
.db $14,$0A,$40
.db $14,$08,$40
.db $12,$0E,$08
.db $16,$0E,$28
.db $16,$0B,$18

;;
;; pitch_envelope_update [$DB5F]
;;
;; Called by musicUpdate. Checks if we need to update a note's pitch based on an envelope (and preps accordingly)
;;
;; Inputs:
;;  X: channel number (sq0, sq1, trg, percussion)
pitch_envelope_update:   
        txa                      
        cmp #mus_channel_perc           ;Not needed for percussion (noise/dmc)
        beq @exit_pitch_envelope_update
    @channelIsNotNoiseDMC:   
        lda music_sq0_envelope_index,X
        and #%11100000                  ;3 first bits used for pitch modulation
        beq @exit_pitch_envelope_update
    @thereIsPitchEnvelope:   
        sta pitchEnvelope_index         ;If not zero, store the pitch envelope index  
        lda music_sq0_pitchIndex,X      
        cmp #$02                        ;Index $02 is a silence with a given duration
        beq @noteIsASilence_incEnvStep
    @noteIsNotSilent:        
        ldy music_channel 
        lda SQ0_TIMER_RAM,Y      
        sta currentPitch                ;Store current pitch, and go to the lower-level pitch envelope routine
        jsr pitchEnvelope        
    @noteIsASilence_incEnvStep:
        inc music_sq0_envelope_step_pitch,X ;If note was a silence, we simply increase the pitch envelope step
    @exit_pitch_envelope_update:
        rts                      

;;
;; pitchEnvelope [$DB82]
;;
;; Updates the pitch which results from the pitch envelope and stores it in APU
;;
;; Inputs:
;;  pitchEnvelope_index: which envelope do we use
;; 
;; Local variables:
pitchEnvelope_step = tmpE2_audio

    _pitchEnvelopeIs_80_or_C0:
        lda pitchEnvelope_step          
        cmp #$31                 ;Pitch envelope $80/$C0 is $31-1 bytes long 
        bne @getPitchOffset_env80_or_C0
    @loopEnvelope80_or_C0:   
        lda #$27                 ;Loop from $27 if we have reached the end
    @getPitchOffset_env80_or_C0:
        tay                      
        lda pitch_envelope_80_or_C0,Y
        pha                      
        lda music_sq0_pitchIndex,X
        cmp #$46                ;Since this envelope bends the pitch (up or down?), we need to cap it at a certain pitch  
        bne @pitchIndexIsNot46   
    @pitchIndexIs46:         
        pla                      ;Seems it never gets there
        lda #$00                 ;But if it ever does, always stay on pitch 46, no more offset
        beq _storePitchEnvStep   
    @pitchIndexIsNot46:      
        pla                      
        jmp _storePitchEnvStep
    if !removeMoreUnused   
        _pitchEnvelopeIs_40_UNUSED:
            lda pitchEnvelope_step          
            tay                      
            cmp #$10                 ;Check if we have finished the envelope, if so, sustain on F6
            bcs @sustainOnF6         
        @pitchEnvelopeIs_40_getData:
            lda pitch_envelope_40_UNUSED,Y
            jmp _checkIfSomethingPlaying
        @sustainOnF6:            
            lda #$F6                 
            bne _checkIfSomethingPlaying
    endif 
    _pitchEnvelopeIs_60:
    if !optimize     
        lda music_sq0_pitchIndex,X  ;This one here behaves differently, we get the current pitch index, and depending if we exceed or not the pitch index, we branch differently
        cmp #$4C                    
        bcc @pitchIndex_under4C  
    @pitchIndex_notUnder4C:  
        lda #$FE                    ;Doesn't seem to change anything since both offset pitch by the exact same amount, we can optimize (maybe it was meant to have different values?)
        bne _checkIfSomethingPlaying
    @pitchIndex_under4C:
    endif      
        lda #$FE                    
        bne _checkIfSomethingPlaying
pitchEnvelope:                      ;Routine actually starts here
        lda music_sq0_envelope_step_pitch,X
        sta pitchEnvelope_step      ;Store the current envelope step
        lda pitchEnvelope_index     ;Check the pitch envelope index
        cmp #$20                 
        beq @pitchEnvelopeIs_20  
        cmp #$A0                 
        beq @pitchEnvelopeIs_A0  
        cmp #$60                 
        beq _pitchEnvelopeIs_60
    if !removeMoreUnused  
        cmp #$40                 
        beq _pitchEnvelopeIs_40_UNUSED
    endif 
        cmp #$80                 
        beq _pitchEnvelopeIs_80_or_C0
        cmp #$C0                 
        beq _pitchEnvelopeIs_80_or_C0   ;Defaults to the standard $20 if neither of the values match
    @pitchEnvelopeIs_20:     
        lda pitchEnvelope_step          
        cmp #$0A                    ;Pitch envelope $20 is $0A-1 bytes long 
        bne @getPitchOffset_env20
    @loopEnvelope20:         
        lda #$00                    ;Loop from beginning if we have reached the end
    @getPitchOffset_env20:   
        tay                      
        lda pitch_envelope_20,Y     ;Load pitch offset in A
        jmp _storePitchEnvStep   
    @pitchEnvelopeIs_A0:     
        lda pitchEnvelope_step          
        cmp #$2B                    ;Pitch envelope $A0 is $2B-1 bytes long
        bne @getPitchOffset_envA0
    @loopEnvelopeA0:         
        lda #$21                    ;Loop from $21 if we have reached the end
    @getPitchOffset_envA0:   
        tay                      
        lda pitch_envelope_A0,Y
    _storePitchEnvStep:      
        pha                         ;Perform some stack operations to store value of Y (pitch envelope step) in an absolute,x address        
        tya                      
        sta music_sq0_envelope_step_pitch,X
        pla                     
    _checkIfSomethingPlaying:
        pha                      
        lda sfxPlaying_forMusic_sq0,X
        bne @dontPlay_andExit       ;If a sfx is playing in that channel, don't update (maybe this could have been done earlier?)
    @updateChannelPitchRegister:
        pla                      
        clc                      
        adc currentPitch            ;Then add current pitch to pitch offset (from pitch envelope)  
        ldy music_channel 
        sta SQ0_TIMER,Y             ;And update APU accordingly  
        rts                               
    @dontPlay_andExit:       
        pla                      
        rts                      

;;
;; pitch_envelope_80_or_C0 & others [$DC11]
;;
;; Data for the pitch envelope used by routine pitchEnvelope
;; Each byte is a different step in the envelope and represents an offset to the pitch
;; 
pitch_envelope_80_or_C0:
.db $00,$00,$01,$01,$02,$02,$03,$03
.db $04,$04,$05,$05,$06,$06,$07,$07
.db $08,$08,$09,$09,$0A,$0A,$0B,$0B
.db $0C,$0C,$0D,$0D,$0E,$0E,$0F,$0F
.db $10,$10,$11,$11,$12,$12,$13,$13
.db $14,$14,$15,$15,$16,$16,$17,$17

pitch_envelope_A0:
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$01
.db $00,$00,$00,$00,$FF,$00,$00,$00
.db $00,$01,$01,$00,$00,$00,$FF,$FF
.db $00

pitch_envelope_20:
.db $00,$01,$01,$02,$01,$00,$FF,$FF
.db $FE,$FF

if !removeMoreUnused
    pitch_envelope_40_UNUSED:
    .db $00,$FF,$FE,$FD,$FC,$FB,$FA,$F9     ;Is also present in Tetris, probably safe to remove
    .db $F8,$F7,$F6,$F5,$F6,$F7,$F6,$F5
endif 

;;
;; prepNewMusic [$DC7C]
;;
;; Gets data pointers to where the music data actually starts for each channels of a given music
;; 
    _music_silenceChannel:   
        lda #mus_silence_chan                       
        sta music_4channels_currentPointer+0,X
        bne _storeHighByte       
prepNewMusic:                       ;Routine actually starts here
        jsr initAPU_channelsAndDMC  ;Start with initiating the APU channels
        lda audioToPlay_copy     
        sta music_playing           ;Store music to play into music playing
    if !optimize
        lda music_toPlay_zeroBased
        tay 
    else 
        ldy music_toPlay_zeroBased
    endif                       
        lda music_metadata_offset,Y ;Get the offset to the music metadata
        tay                      
        ldx #$00                 
    @storeMusicMetadata_loop:
        lda music_metadata_pointers,Y
        sta music_metadata_RAM,X    ;Copy music metadata to RAM
        iny                      
        inx 
    if !optimize                      
        txa                      
        cmp #$0A                    ;Metadata is 10 bytes long
    else                     
        cpx #$0A                    
    endif 
        bne @storeMusicMetadata_loop
    @initFramesLeft:         
        lda #$01                    ;Then init a couple variables (related to frames)
        sta music_noteLength_sq0_framesLeft
        sta music_noteLength_sq1_framesLeft
        sta music_noteLength_trg_framesLeft
        sta music_noteLength_perc_framesLeft
        lda #$00                 
        sta musicFramesSinceLastBeat
    if !optimize
        sta tmpEA_audio             ;Doesn't look like this value is ever used
    endif 
        ldy #mus_channels*2                 
    @init_4channelsPointer_loop:    ;Then init the 4 music channels pointers
        sta music_4channels_currentPointer+7,Y
        dey                         
        bne @init_4channelsPointer_loop
        tax                      
    _store4channelsStartPointers_loop:
        lda music_metadata_4chan_pointers+0,X
        sta music_currentChan_startDataPointer_lowByte
        lda music_metadata_4chan_pointers+1,X
        cmp #mus_silence_chan                       ;If music high byte address starts with $FFxx, this means we silence the channel
        beq _music_silenceChannel
        sta music_currentChan_startDataPointer_highByte
        ldy music_sq0_pointerOffset                 ;Will probably always be a $00 at this point (but we still need it for indirect adressing of next instruction)
        lda (music_currentChan_startDataPointer),Y  ;Get current pointer address from start data pointer (low, then high byte)
        sta music_4channels_currentPointer+0,X
        iny                      
        lda (music_currentChan_startDataPointer),Y
    _storeHighByte:          
        sta music_4channels_currentPointer+1,X
        inx                                         ;Increase 2 bytes to get to next 2-byte pointer
        inx                      
        txa                      
        cmp #mus_channels*2                         ;Once all 4 channels have their pointers copied (8 bytes), exit
        bne _store4channelsStartPointers_loop
        rts                      

;;
;; updateSquareCheck [$DCE4]
;;
;; Unmutes the music playing if a sfx using SQ0 and/or SQ1 has just finished
;; 
updateSquareCheck:       
        lda flag_sfxJustFinished 
        beq _exit_updateSquareCheck     ;If no sfx using SQ0 or SQ1 just finished, we bypass this completely
        cmp #$01                 
        beq @flagIs01_updateSQ0         ;If flag was increased just once, this means only SQ0 was used for the sfx (and now can resume)  
    @flagIs02_updateSQ1:     
        lda #$7F                        ;Unmute the music playing the SQ1 channel
        sta SQ1_SWEEP            
        lda SQ1_TIMER_RAM        
        sta SQ1_TIMER            
        lda SQ1_LENGTH_RAM       
        sta SQ1_LENGTH           
    @flagIs01_updateSQ0:     
        lda #$7F                        ;Unmute music playing in the SQ0 channel
        sta SQ0_SWEEP            
        lda SQ0_TIMER_RAM        
        sta SQ0_TIMER            
        lda SQ0_LENGTH_RAM       
        sta SQ0_LENGTH           
        lda #$00                        ;Then reset sfx finished flag
        sta flag_sfxJustFinished 
    _exit_updateSquareCheck: 
        rts                      

;;
;; vol_envelope_update [$DD15]
;;
;; Called by musicUpdate. Checks if we need to update a note's volume based on an envelope (and updates accordingly)
;;
;; Inputs:
;;  X: current channel
;; 
;; Local variables:
vol_4bit            = tmpE0_audio
volEnvelope_index   = tmpE1_audio
volEnvelope_addr    = tmpE2_audio
volEnvelope_addr_lo = tmpE2_audio
volEnvelope_addr_hi = tmpE3_audio

vol_envelope_update:     
        txa                      
        cmp #$02                        ;Checks the channel, and if not a Square chan, exit right away
        bcs _exit_updateSquareCheck
        lda music_sq0_envelope_index,X
        and #%00011111                  ;First 5 bits hold the volume envelope "code" 
        beq @exit_vol_envelope_update
        sta volEnvelope_index          
        lda music_sq0_pitchIndex,X      ;Check if channel is currently silenced
        cmp #$02                        ;Index $02 is a silence with a given duration
        beq @silenceChannel_increaseEnvStep
        ldy #$00                 
    @get_vol_envelope_index: 
        dec volEnvelope_index          
        beq @get_vol_envelope_value
        iny                             ;The idea is to double the value initially in volEnvelope_index (and store it in Y) so that we get a 2-byte address pointer
        iny                      
        bne @get_vol_envelope_index
    @get_vol_envelope_value: 
        lda jumpTable_vol_envelopes+0,Y
        sta volEnvelope_addr_lo          
        lda jumpTable_vol_envelopes+1,Y
        sta volEnvelope_addr_hi         ;Store volume envelope data address   
        lda music_sq0_envelope_step_vol,X
        lsr A                           ;Get current step, then divide in 2 (each envelope data is valid for 2 steps because data is actually held in 4-bits)
        tay                      
        lda (volEnvelope_addr),Y      
        sta audioData_envelope   
        cmp #vol_env_sustain            ;$FF means sustain current volume 
        beq @sustain_current_vol 
        cmp #vol_env_silence            ;$F0 means silence channel
        beq @silenceChannel      
        lda music_sq0_envelope_step_vol,X
        and #$01                        ;Odd steps = volume data is in first 4 bits
        bne @isolateVolBits      
    @move4LastBits_to4FirstBits:
        lsr audioData_envelope          ;Otherwise, it is in the last 4 bits, we move them to the first 4 bits
        lsr audioData_envelope   
        lsr audioData_envelope   
        lsr audioData_envelope   
    @isolateVolBits:         
        lda audioData_envelope          ;Isolate first 4 bits
        and #%00001111                 
        sta vol_4bit          
        lda SQ0_DUTY_RAM,X       
        and #%11110000                  ;Isolate last 4 bits
        ora vol_4bit                    ;Join first 4 bits
        tay                             ;Store result in y temporarily
    @increaseEnvStep:        
        inc music_sq0_envelope_step_vol,X
    @checkIfStingerSFXPlaying:
        lda sfxPlaying_forMusic_sq0,X
        bne @exit_vol_envelope_update   ;If a sfx is playing in the current channel, exit without writing to APU
        tya                             
        ldy music_channel               ;Otherwise restore the volume and store it in APU
        sta SQ0_DUTY,Y           
    @exit_vol_envelope_update:
        rts                              
    @sustain_current_vol:    
        ldy SQ0_DUTY_RAM,X              ;Get current volume to sustain it
        bne @checkIfStingerSFXPlaying
    @silenceChannel:         
        ldy #$10                        ;Set to value that silences the channel
        bne @checkIfStingerSFXPlaying
    @silenceChannel_increaseEnvStep:
        ldy #$10                        ;Set to value that silences the channel
        bne @increaseEnvStep     

;;
;; musicUpdate [$DD88]
;;
;; This routine is so long it hurts my eyes. Updates all 4 music channels according to music data (also takes into consideration if other sfx are playing that "mask" one or several channels)
;; 
;; Local variables:
note_volume         = tmpE0_audio
pitchIndex_offset   = tmpE3_audio

    _music_loopToSection:    
        iny                             ;Get next pointer low byte
        lda (music_currentChan_startDataPointer_lowByte),Y
        sta music_metadata_4chan_pointers+0,X
        iny                             ;Then high byte
        lda (music_currentChan_startDataPointer_lowByte),Y
        sta music_metadata_4chan_pointers+1,X
        lda music_metadata_4chan_pointers+0,X
        sta music_currentChan_startDataPointer_lowByte
        lda music_metadata_4chan_pointers+1,X
        sta music_currentChan_startDataPointer_highByte
        txa                             ;The next pointer after a loop marker ($FFFF) is the address to loop to (holds the next pointer)
        lsr A                    
        tax                             ;Channel back to single byte    
        lda #$00                 
        tay                      
        sta music_sq0_pointerOffset,X   ;Reset pointer offset (both in RAM and Y)
        jmp _getNewChannelPointers
    _songIsFinished:         
        jsr initAPU_variablesAndChannels    ;This mutes everything (including sfx)
    _exit_musicUpdate:       
        rts                             ;Finally found the exit
    _music_reachedEndOfSection:
        txa                             ;Double channel (to make it a 2-byte offset)            
        asl A                    
        tax                             ;Get copy of current pointer
        lda music_metadata_4chan_pointers+0,X
        sta music_currentChan_startDataPointer_lowByte
        lda music_metadata_4chan_pointers+1,X
        sta music_currentChan_startDataPointer_highByte
        txa                             ;Channel back to single byte 
        lsr A                    
        tax                      
        inc music_sq0_pointerOffset,X   ;Increase pointer offset by 2 bytes (one full word)
        inc music_sq0_pointerOffset,X
        ldy music_sq0_pointerOffset,X
    _getNewChannelPointers:  
        txa                             ;Pointer offset is now in Y
        asl A                    
        tax                             ;Double channel (to make it a 2-byte offset)
        lda (music_currentChan_startDataPointer_lowByte),Y
        sta music_4channels_currentPointer+0,X
        iny                             ;Use start data pointer as current pointer (bringing it back to the start of a pre-determined section)
        lda (music_currentChan_startDataPointer_lowByte),Y
        sta music_4channels_currentPointer+1,X
        cmp #$00                        ;If low-byte data from pointer is $00, the song is finished
        beq _songIsFinished      
        cmp #$FF                        ;If $FF then it loops
        beq _music_loopToSection 
        txa                             ;Otherwise, song continues to advance      
        lsr A                    
        tax                             ;Channel back to single byte    
        lda #$00                 
        sta music_sq0_dataOffset,X      ;Reset data offset and set frames left for this channel
        lda #$01                 
        sta music_noteLength_sq0_framesLeft,X
        bne _startTreatingChannel
    _noteData_00_reachedEndOfSection:
        jmp _music_reachedEndOfSection  ;Necessary because target address is too far to branch to directly 
musicUpdate:             
        inc musicFramesSinceLastBeat    ;Used for syncing music with animation
        jsr updateSquareCheck           ;Unmutes the music playing if a sfx using SQ0 and/or SQ1 has just finished    
        lda #$00                 
        tax                      
        sta music_channel               ;Start with first channel
        beq _startTreatingChannel
    _finishedWithThisChannel_CheckNext:
        txa                             ;Divide x by two to get back to initial channel number
        lsr A                    
        tax                      
    _finishedUpdatingThisChannelAPU:
        inx                             ;Increase channel
        txa                      
        cmp #mus_channels               ;Check if we have finished all 4 music channels
        beq _exit_musicUpdate    
        lda music_channel               ;If not, add $04 to get the proper RAM offset needed for each channel (each channel takes up 4 bytes in RAM)
        clc                      
        adc #$04                 
        sta music_channel 
    _startTreatingChannel:   
        txa                             ;Temporarily double x to get a 2-byte address index
        asl A                    
        tax                      
        lda music_4channels_currentPointer+0,X
        sta music_currentChan_startDataPointer_lowByte
        lda music_4channels_currentPointer+1,X
        sta music_currentChan_startDataPointer_highByte
    if !optimize
        lda music_4channels_currentPointer+1,X  ;This value was already in A
    endif 
        cmp #mus_silence_chan                   ;Checks if channel is silence, if so we ar finished with this channel, check next
        beq _finishedWithThisChannel_CheckNext
        txa                                     ;This part is repeated in _finishedWithThisChannel_CheckNext... probably a way to optimize          
        lsr A                    
        tax                                     ;Divide x by two to get back to initial channel number
        dec music_noteLength_sq0_framesLeft,X
        bne _noteIsNotFinished                  ;Decrease note length counter, and when in reaches zero, reset envelope values and get next data
        lda #$00                 
        sta music_sq0_envelope_step_vol,X
        sta music_sq0_envelope_step_pitch,X
    _getNextChannelData:     
        jsr music_getNextChannelData            ;Get next music data for the current channel
        beq _noteData_00_reachedEndOfSection    ;If is zero then skip to next
        cmp #note_data_section_start            ;Dispatch to part of routine according to note data                
        beq _noteData_9F_startOfSection
        cmp #note_data_tempo_change                 
        beq _noteData_9E_changeTempo
        cmp #note_data_transpose                 
        beq _noteData_9C_changeTranspose
        tay                      
        cmp #note_data_repeat_end                 
        beq @noteData_FF_repeatMarker
        and #note_data_repeat_start                 
        cmp #note_data_repeat_start                 
        beq @noteData_C0orHigher_repeatSectionYtimes
        jmp _noteDate_lowerThanC0
    @noteData_FF_repeatMarker:
        lda music_sectionRepeatCounter_sq0,X
        beq @toGetNextChannelData               ;If repeat counter is finished, move to next section
        dec music_sectionRepeatCounter_sq0,X
        lda music_sq0_repeatStart,X             ;Otherwise, update pointer to section start
        sta music_sq0_dataOffset,X
        bne @toGetNextChannelData
    @noteData_C0orHigher_repeatSectionYtimes:
        tya                      
        and #%00111111                          ;Isolate the number of repetitions
        sta music_sectionRepeatCounter_sq0,X    ;Store it
        dec music_sectionRepeatCounter_sq0,X    ;Decrease it
        lda music_sq0_dataOffset,X              
        sta music_sq0_repeatStart,X             ;Store current data offset as repeat start marker, then get next data for this channel
    @toGetNextChannelData:   
        jmp _getNextChannelData  
    _noteIsNotFinished:      
        jsr vol_envelope_update                 ;Update volume and pitch envelope, then move on to next channel
        jsr pitch_envelope_update
        jmp _finishedUpdatingThisChannelAPU
    _jmpTo_toPlayPerc:     
        jmp _toPlayPerc                         ;Necessary because target addresses are too far to branch to directly
    _jmpTo_TRG_setNoteLength:
        jmp _TRG_setNoteLength   
    _noteData_9F_startOfSection:
        jsr music_getNextChannelData            ;2 next bytes are used by this code: 1 = envelope index, 2 = duty, volume (and length counter halt)
        sta music_sq0_envelope_index,X
        jsr music_getNextChannelData
        sta SQ0_DUTY_RAM,X       
        jmp _getNextChannelData                 ;Then get next data for this channel
    if !removeMoreUnused  
        UNUSED_Sub_DE87:         
            jsr music_getNextChannelData        ;Gets 2 times data, first is then useless?
            jsr music_getNextChannelData        ;Probably safe to remove
            jmp _getNextChannelData
    endif 
    _noteData_9E_changeTempo:
        jsr music_getNextChannelData            ;New tempo is in next byte
        sta music_metadata_tempo_index    
        jmp _getNextChannelData                 ;Then get next data for this channel
    _noteData_9C_changeTranspose:
        jsr music_getNextChannelData            ;New transpose is in next byte
        sta music_metadata_transpose    
        jmp _getNextChannelData                 ;Then get next data for this channel
    _noteDate_lowerThanC0:   
        tya                      
        and #note_data_length_index             ;Checks if data is a note duration setting or an actual note       
        cmp #note_data_length_index                 
        bne _music_noteData_lessThanB0_playNote
    @noteData_isWithin_B0_setNoteLength:
        tya                      
        and #%00001111                          ;The first 4 bits are used as index for the note length
        clc                      
        adc music_metadata_tempo_index          ;Add the offset of the tempo to get to correct note lengths
        tay                      
        lda noteLengthTable,Y
        sta music_noteLength_sq0,X              ;Store note length
        tay                      
        txa                      
        cmp #mus_channel_trg                    ;Check if current channel is triangle (it has a special routine to setup length)
        beq _jmpTo_TRG_setNoteLength
    _getNextData_noteToPlay: 
        jsr music_getNextChannelData            ;A note absolutely needs to follow the setting of a new note length
        tay                      
    _music_noteData_lessThanB0_playNote:
        tya                      
        sta music_sq0_pitchIndex,X              ;Note data is actually the pitch index if it is under $B0
        txa                      
        cmp #mus_channel_perc                   ;Checks if channel is percussion (noise + dmc) (if so, it has a different routine for setting pitch)
        beq _jmpTo_toPlayPerc
    @noteIsNotPerc:      
        pha                                     ;Push channel to stack
        ldx music_channel                       ;Load 4-byte channel in X
        lda pitchTable+1,Y                      ;Pitch is 2-bytes, big endian... if lowest byte is $00, note is silent
        beq @afterPlayingPitch                   
        lda music_metadata_transpose            ;If transpose is higher than $80, we subtract to the pitch index (we modulate lower), if not we add to pitch ( modulate higer)
        bpl @addPitchIndex       
    @subtractPitchIndex:     
        and #%01111111                          ;Mask last bit                 
        sta pitchIndex_offset          
        tya                                     ;Recall pitch index         
        clc                      
        sbc pitchIndex_offset                   ;Change index according to transpose
        jmp @music_play_pitch    
    @addPitchIndex:          
        tya                      
        clc                      
        adc music_metadata_transpose
    @music_play_pitch:       
        tay                      
        lda pitchTable+1,Y                      ;Timer low
        sta SQ0_TIMER_RAM,X      
        lda pitchTable+0,Y                      ;Timer high
        ora #%00001000                          ;Adds lowest bit of length counter load
        sta SQ0_LENGTH_RAM,X     
    @afterPlayingPitch:      
        tay                                          
        pla                      
        tax                                     ;Put channel back in X
        tya                      
        bne @noteIsNotSilence    
    @noteIsSilence:          
        lda #$00                                ;Code for silence with triangle channel
        sta note_volume          
        txa                      
        cmp #mus_channel_trg                    ;Check if channel is triangle
        beq @checkIfSomethingPlaying_inChannel
    @notTriangle:            
        lda #$10                                ;Code for silence (constant volume 0) with pulse channels
        sta note_volume          
        bne @checkIfSomethingPlaying_inChannel
    @noteIsNotSilence:       
        lda SQ0_DUTY_RAM,X       
        sta note_volume                         ;At this point, we now know what volume to play   
    @checkIfSomethingPlaying_inChannel:
        txa                      
        dec sfxPlaying_forMusic_sq0,X
        cmp sfxPlaying_forMusic_sq0,X           ;Check if a stinger is playing (and should prevent music from playing)
        beq _stingerSFXPlaying_dontPlayMusic
        inc sfxPlaying_forMusic_sq0,X           ;Restore flag value
        ldy music_channel 
        txa                      
        cmp #mus_channel_trg                    ;If triangle, we skip next section
        beq @useDutyLinearAsIs   
    @isNotTriangle:          
        lda music_sq0_envelope_index,X
        and #%00011111                          ;Check if there was a volume envelope                 
        beq @useDutyLinearAsIs   
        lda note_volume                         ;Check if note is silent 
        cmp #$10                 
        beq @channelRAM_toAPU  
        and #$F0                                ;Another way to check if silent
    if !optimize                 
        ora #$00                                ;Seems a bit useless...
    endif 
        bne @channelRAM_toAPU  
    @useDutyLinearAsIs:      
        lda note_volume                         ;Finally, if we get there, we can use the note volume as is     
    @channelRAM_toAPU:     
        sta SQ0_DUTY,Y           
        lda SQ0_SWEEP_RAM,X                     ;Then store the rest of music ram for that channel
        sta SQ0_SWEEP,Y          
        lda SQ0_TIMER_RAM,Y      
        sta SQ0_TIMER,Y          
        lda SQ0_LENGTH_RAM,Y     
        sta SQ0_LENGTH,Y         
    _storeNoteLength:        
        lda music_noteLength_sq0,X              ;Store note length
        sta music_noteLength_sq0_framesLeft,X
        jmp _finishedUpdatingThisChannelAPU     ;And then we're done with this channel for this frame
    _stingerSFXPlaying_dontPlayMusic:
        inc sfxPlaying_forMusic_sq0,X           ;Restore sfx playing flag
        jmp _storeNoteLength
    _TRG_setNoteLength:      
        lda music_trg_envelope_index
        and #%00011111                  ;If envelope index is not empty, and that any of the 5 first bits is set, store the index as is
        bne @storeTRG_LINEAR_RAM 
        lda music_trg_envelope_index
        and #%11000000                 
        bne @cmpTo_C0                   ;If any of first 2 bits are set, check if it is $C0
    @useNoteLengthInstead:   
        tya                             ;Note length is in Y
        bne @decreaseNoteLength         ;If not zero, decrease note length
    @cmpTo_C0:               
        cmp #$C0                 
        beq @useNoteLengthInstead       ;If equal to $C0, use note length, if anything higher than this, then set to $FF
        lda #$FF                 
        bne @storeTRG_LINEAR_RAM 
    @decreaseNoteLength:     
        clc                      
        adc #$FF                        ;Has same effect as decreasing by one
        asl A                           ;Move two bits to the left (because we use the linear counter, it is clocked more often and therefore needs a higher value to be equivalent to square channels length)
        asl A                    
        cmp #$3C                 
        bcc @storeTRG_LINEAR_RAM 
        lda #$3C                        ;Maxout at $3C
    @storeTRG_LINEAR_RAM:    
        sta TRG_LINEAR_RAM              ;Store in RAM then get next data (which must be a note)
        jmp _getNextData_noteToPlay
    _toPlayPerc:      
        tya                             ;Y holds the note data
        pha                             ;Push note data to stack to save it for later
        jsr checkIf_playDMC      
        pla                      
        and #%00011111                  ;Noise data uses only the first 5 bits (and is actually the offset)
        tay                      
        jsr music_updateNoise    
        jmp _storeNoteLength     

;;
;; music_updateNoise [$DF9D]
;;
;; Checks if noise sfx playing, then if not, copy noise percussion data
;; 
;; Inputs:
;;  Y: the "noise instrument" address offset (should always be a multiple of 3 to which we then add 1)
;;
music_updateNoise:       
        lda sfx_playing_noise    
        bne @exit_music_updateNoise         ;If a noise sfx is playing, do not play noise music
        lda music_noiseData_percussion+0,Y
        sta NOISE_VOLUME                    ;Otherwise, update APU with noise music data
        lda music_noiseData_percussion+1,Y
        sta NOISE_PERIOD         
        lda music_noiseData_percussion+2,Y
        sta NOISE_LENGTH         
    @exit_music_updateNoise: 
        rts                      

;;
;; checkIf_playDMC [$DFB5]
;;
;; Get DMC instrument data based on note data. Checks if a DMC sfx is playing, and if note play the DMC instrument.
;; 
;; Inputs
;;  Y: note data
;; 
;; Local variables:
DMC_FREQ_RAM    = tmpE1_audio

checkIf_playDMC:         
        tya                      
        and #%11100000                          ;Isolate first 3 bits, as first 5 bits are for noise
        cmp #$40                 
        beq @playDMC_code40                     ;Dispatch according to code
        cmp #$80                 
        beq @playDMC_code80      
        cmp #$20                 
        beq @playDMC_code20      
        cmp #$60                 
        beq @playDMC_code60      
        rts                             
    @playDMC_code20:         
        lda #$0E                 
        sta DMC_FREQ_RAM                        ;This holds DMC freq
        lda #$07                                ;This holds DMC length (113-bytes in this case)
        ldy #(dmcSample_code20_and40-$C000)/64  ;This holds DMC address
        bne @updateDMC           
    @playDMC_code60:         
        lda #$0F                 
        sta DMC_FREQ_RAM          
        lda #$0F                                ;241-bytes long
        ldy #(dmcSample_code60_and80-$C000)/64                  
        bne @updateDMC           
    @playDMC_code40:         
        lda #$07                 
        sta DMC_FREQ_RAM          
        lda #$07                 
        ldy #(dmcSample_code20_and40-$C000)/64                 
        bne @updateDMC           
    @playDMC_code80:         
        lda #$0E                 
        sta DMC_FREQ_RAM          
        lda #$0F                 
        ldy #(dmcSample_code60_and80-$C000)/64                 
    @updateDMC:              
        sta DMC_LENGTH          ;Store length and address    
        sty DMC_ADDR             
        lda sfx_playing_dmc     ;If a DMC sfx is playing, stop there, do not play the DMC music
        bne @exit_updateDMC      
        lda DMC_FREQ_RAM          
        sta DMC_FREQ            ;Otherwise set frequency     
        lda #APUSTATUS_enable_all-APUSTATUS_dmc_on                 
        sta APUSTATUS           ;Disable DMC channel temporarily   
        lda #$00                 
        sta DMC_COUNTER         ;Reset DMC counter   
        lda #APUSTATUS_enable_all                 
        sta APUSTATUS           ;Then re-enable DMC channel  
    @exit_updateDMC:         
        rts                      

;;
;; music_getNextChannelData [$E00F]
;;
;; Simple routine that gets the next music data for a given channel
;; 
;; Inputs:
;;  X: current music channel
;;
music_getNextChannelData:
        ldy music_sq0_dataOffset,X
        inc music_sq0_dataOffset,X
        lda (music_currentChan_startDataPointer_lowByte),Y
        rts 

;;
;; jumpTable_vol_envelopes [$E018]
;;
;; Jumptable to the volume envelopes. Is not zero-based (value used to acces it is transformed in zero-based index)
;; 
jumpTable_vol_envelopes:
.word vol_env_01, vol_env_02, vol_env_03, vol_env_04
.word vol_env_05, vol_env_06, vol_env_07, vol_env_08
.word vol_env_09, vol_env_0A, vol_env_0B, vol_env_0C
.word vol_env_0D, vol_env_0E, vol_env_0F, vol_env_10
.word vol_env_11, vol_env_12, vol_env_13, vol_env_14
.word vol_env_15, vol_env_16, vol_env_17, vol_env_18
.word vol_env_19, vol_env_1A, vol_env_1B, vol_env_1C
.word vol_env_1D, vol_env_1E, vol_env_1F

;;
;; vol_env_01 to vol_env_1F [$E056]
;;
;; Actual data for the volume envelopes (a byte is two values of 4 bits). Ends with either a silence or sustain.
;; 
vol_env_01:
.hex 00B9999888887777777711
.db vol_env_silence

vol_env_02:
.hex 0000000BBA98888889
.db vol_env_silence

vol_env_04:
.hex 00988888888888888888888888
.db vol_env_silence

vol_env_05:
.hex 0FFEBBBBAAAA
.db vol_env_silence

vol_env_06:
.hex 843110
.db vol_env_silence

vol_env_07:
.hex A99222
.db vol_env_silence

vol_env_08:
.hex 976543332111
.db vol_env_silence

vol_env_09:
.hex A8811111
.db vol_env_silence

vol_env_0A:
.hex AAA111111111112222333444455566677776665554444433333322222211111111
.db vol_env_silence

vol_env_0B:
.hex 0774111111111111
.db vol_env_silence

vol_env_0C:
.hex 772133111111
.db vol_env_silence

vol_env_0D:
.hex 223344556677778866
.db vol_env_sustain

vol_env_0E:
.hex 0877111111
.db vol_env_silence

vol_env_0F:
.hex FEA998777766665555444433332222221111111111111111
.db vol_env_silence

vol_env_10:
.hex B91110741110321111
.db vol_env_sustain

vol_env_11:
.hex 76543221
.db vol_env_silence

vol_env_12:
.hex 0043222222222221
.db vol_env_silence

vol_env_13:
.hex EB975321
.db vol_env_sustain

vol_env_14:
.hex 76666555
.db vol_env_sustain

vol_env_15:
.hex 0003544444
.db vol_env_sustain

vol_env_16:
.hex 698777765555555555
.db vol_env_sustain

vol_env_17:
.hex 233344333333333333
.db vol_env_sustain

vol_env_18:
.hex 005432211111
.db vol_env_silence

vol_env_19:
.hex 6332211111
.db vol_env_silence

vol_env_1A:
.hex 2322222222
.db vol_env_sustain

vol_env_1B:
.hex 766331111111110000005422211000
.db vol_env_sustain

vol_env_1C:
.hex 5432211111
.db vol_env_silence

vol_env_1D:
.hex 4332221111
.db vol_env_silence

vol_env_1E:
.hex 32222111
.db vol_env_silence

vol_env_1F:
.hex 21111110
.db vol_env_silence

vol_env_03:
.hex 11111111
.db vol_env_silence

;;
;; pitchTable [$E16A]
;;
;; Each pitch is 2 bytes (high then low timer value for APU), starting from lower pitch to higher pitch
;;
;; Couple notes:
;;  -index is zero-based and must be even (odd numbers will yield weird values)
;;  -if $00 is in the low byte, note will be silent
;;  -lowest pitch is index $00 ($07F0) = 55hz (note A, octave 1)
;;  -highest pitch is index $94 ($000A) = 10169hz (note D# + 37 cents, octave 9)
;;
pitchTable:
.db $07,$F0,$00,$00,$06,$AE,$06,$4E     ;Index $02 yields a silent note
.db $05,$F3,$05,$9E,$05,$4D,$05,$01
.db $04,$B9,$04,$75,$04,$35,$03,$F8
.db $03,$BF,$03,$89,$03,$57,$03,$27
.db $02,$F9,$02,$CF,$02,$A6,$02,$80
.db $02,$5C,$02,$3A,$02,$1A,$01,$FC
.db $01,$DF,$01,$C4,$01,$AB,$01,$93
.db $01,$7C,$01,$67,$01,$52,$01,$3F
.db $01,$2D,$01,$1C,$01,$0C,$00,$FD
.db $00,$EE,$00,$E1,$00,$D4,$00,$C8
.db $00,$BD,$00,$B2,$00,$A8,$00,$9F
.db $00,$96,$00,$8D,$00,$85,$00,$7E
.db $00,$76,$00,$70,$00,$69,$00,$63
.db $00,$5E,$00,$58,$00,$53,$00,$4F
.db $00,$4A,$00,$46,$00,$42,$00,$3E
.db $00,$3A,$00,$37,$00,$34,$00,$31
.db $00,$2E,$00,$2B,$00,$29,$00,$27
.db $00,$24,$00,$22,$00,$20,$00,$1E
.db $00,$1C,$00,$1A,$00,$0A
.db $00,$10,$00,$19                     ;Last 2 pitches here seems out of place, since they not the highest (4302hz)

;;
;; noteLengthTable [$E204]
;;
;; Duration of note in frames, according to song bpm
;; 
;; Index is as follows:
;;  0: sixteenth note
;;  1: eight note
;;  2: quarter note
;;  3: half note
;;  4: whole note

;;  5: dotted quarter note
;;  6: dotted half note
;;  7: dotted eight note
;; 
;;  8: quarter note triplet     (these 2 not always accurate)
;;  9: sixteenth note triplet
;;
;; 10: thirty-secondth note     (these 2 not always accurate)
;; 11: sixty-fourth note
;;
;; 12 to 15: extra custom durations
noteLengthTable:
noteLenght_225bpm:          ;$00                 
.db $04,$08,$10,$20,$40     ;4,8,16,32,64
.db $18,$30,$0C             ;24,48,12
.db $0A,$05,$02,$01         ;10,5,2,1

noteLenght_180bpm:          ;$0C
.db $05,$0A,$14,$28,$50     ;5,10,20,40,80
.db $1E,$3C,$0F             ;30,60,15
.db $0D,$06,$02,$01         ;13,6,2,1

noteLenght_150bpm:          ;$18
.db $06,$0C,$18,$30,$60     ;6,12,24,48,96
.db $24,$48,$12             ;36,72,18
.db $10,$08,$03,$01         ;16,8,3,1
.db $04,$02,$00,$90

noteLenght_128bpm:          ;$28    ...is actually 128,57 bpm
.db $07,$0E,$1C,$38,$70     ;7,14,28,56,112
.db $2A,$54,$15             ;42,84,21
.db $12,$09,$03,$01         ;18,9,3,1
.db $02

noteLenght_112bpm           ;$35    ...is actually 112,5 bpm
.db $08,$10,$20,$40,$80     ;8,16,32,64,128
.db $30,$60,$18             ;48,96,24
.db $15,$0A,$04,$01         ;21,10,4,1
.db $02,$C0

noteLenght_100bpm           ;UNUSED ($43)
.db $09,$12,$24,$48,$90     ;9,18,36,72,144
.db $36,$6C,$1B             ;54,108,27
.db $18,$0C,$04,$01         ;24,12,4,1

noteLenght_90bpm            ;$4F
.db $0A,$14,$28,$50,$A0     ;10,20,40,80,160
.db $3C,$78,$1E             ;60,120,30
.db $1A,$0D,$05,$01         ;26,13,5,1
.db $02,$17                      