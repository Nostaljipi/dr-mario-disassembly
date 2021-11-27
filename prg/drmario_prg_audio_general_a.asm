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

if !ver_EU
    include prg/routines/drmario_prg_audio_copy_sfx_data.asm                   
    include prg/routines/drmario_prg_audio_rnd_noise.asm                   
    include prg/routines/drmario_prg_audio_sfx_counter.asm
    include prg/routines/drmario_prg_audio_init_status.asm
else 
    include prg/routines/drmario_prg_audio_sfx_counter.asm
    include prg/routines/drmario_prg_audio_init_status.asm
    include prg/routines/drmario_prg_audio_copy_sfx_data.asm                   
    include prg/routines/drmario_prg_audio_rnd_noise.asm 
endif 
                   

               