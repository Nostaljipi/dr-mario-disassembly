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