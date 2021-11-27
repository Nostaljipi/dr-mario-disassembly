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