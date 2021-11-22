;;
;; sfx_data [$D300]
;;
;; The 4 bytes of sfx data to copy in a channel's register (each byte represents something slightly different depending on the channel)
;; 
sfx_data:

if !removeUnused
    __sfx_UNK_D300_noCode:  ;These unknown/unused must be left there because their index order must be preserved
    .db $03,$7F,$0F,$C0     ;Was also present in Tetris
endif

sfx_UFO_beam_NOISE:      
.db $33,$7F,$80,$C0

if !removeUnused
    __sfx_UNK_D308_NOISE_noIndex:
    .db $3F,$7F,$82,$C0 
endif

if !removeMoreUnused
    sfx_highToLowPitch_NOISE_UNUSED:
    .db $39,$7F,$00,$C0 
endif

sfx_UFO_leaves_NOISE:    
.db $39,$7F,$0E,$C0   

sfx_UFO_any_NOISE_finished:
.db $32,$7F,$0E,$C0   

sfx_explosion_NOISE:     
.db $1F,$7F,$0F,$C0    

sfx_bigVirusHurt_NOISE:  
.db $14,$7F,$02,$C0    

if !removeUnused
    __sfx_UNK_D320_noCode:
    .db $B0,$7F,$1C,$40   

    __sfx_UNK_D324_noCode:
    .db $B0,$7F,$32,$40
endif

sfx_UFO_siren_SQ0:       
.db $B0,$7F,$30,$40 

sfx_UFO_siren_SQ1:       
.db $B0,$7F,$10,$40

sfx_pause_SQ0_step1:     
.db $9D,$7F,$7A,$28

sfx_pause_SQ0_step2:     
.db $9D,$7F,$40,$28

sfx_flipPill_SQ0_step1:  
.db $96,$7F,$A3,$28

sfx_flipPill_SQ0_step2:  
.db $B2,$7F,$A3,$08

sfx_speedUp_SQ0:         
.db $96,$7F,$D4,$28

sfx_pillLand_SQ0:        
.db $9B,$84,$FF,$0B

sfx_cursorVertical_SQ0_step1:
.db $D7,$7F,$40,$30

sfx_cursorVertical_SQ0_step2:
.db $D2,$7F,$40,$30

if !removeMoreUnused
    sfx_alert_SQ0_UNUSED:    
    .db $00,$7F,$78,$08

    sfx_alertSlow_SQ0_UNUSED:
    .db $01,$7F,$B2,$08
endif 

sfx_bigVirus_eradicated_SQ0:
.db $9E,$99,$F0,$08

sfx_pillCleared_SQ0:     
.db $9C,$BB,$80,$09

sfx_virusEliminated_SQ0: 
.db $9F,$87,$FF,$08      

if !removeMoreUnused
    sfx_highPitchedGlassLike_SQ0_step1_UNUSED:
    .db $96,$7F,$5E,$20             ;Similar sfx in Tetris, but 3rd byte is different 

    sfx_highPitchedGlassLike_SQ0_step2_UNUSED:
    .db $82,$7F,$53,$F8             ;Similar sfx in Tetris, but 3rd byte is different  
endif 

sfx_cursorHorizontal_SQ0:
.db $80,$7F,$62,$18     

sfx_p1_attack_SQ0:       
.db $01,$7F,$58,$08    

sfx_p1_attack_SQ1:       
.db $01,$7F,$59,$08     

sfx_p2_attack_SQ0:       
.db $FA,$7F,$8D,$08     

sfx_p2_attack_SQ1:       
.db $F7,$7F,$8E,$08     

sfx_UFO_motor_TRG:       
.db $FF,$7F,$20,$0A     

sfx_UFO_beam_TRG:        
.db $FF,$7F,$52,$0A

if !removeMoreUnused
    sfx_lowPitchedCursor_TRG_UNUSED:
    .db $03,$7F,$3D,$18             ;Also present in Tetris 

    sfx_highPitchedGlassLike_SQ0_dutyVolEnv_UNUSED:
    .db $14,$93,$94,$D3             ;Also present in Tetris
endif 

;;
;; sfx_fail_NOISE_env [$D390]
;;
;; Envelope data for the fail noise (explosion), 32-bytes long, for both the period and volume
;; 
sfx_fail_NOISE_periodEnv:
.db $FE,$FE,$FF,$EF,$FE,$EF,$FE,$EF
.db $EF,$FE,$EF,$FE,$EF,$FF,$EE,$EE
.db $FF,$EF,$FF,$FF,$FF,$EF,$EF,$FF
.db $FD,$EF,$EF,$EF,$FE,$EF,$EF,$FF

sfx_fail_NOISE_volEnv:
.db $F1,$FF,$E1,$EF,$EF,$EF,$DF,$FB
.db $FB,$AE,$AA,$99,$98,$87,$76,$66
.db $55,$44,$44,$44,$44,$43,$33,$33
.db $22,$22,$22,$22,$21,$11,$11,$11