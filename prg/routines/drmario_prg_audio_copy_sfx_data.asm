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