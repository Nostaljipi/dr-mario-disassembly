;Build config
include build_config.asm

;Defines and macros
include defines/drmario_ram_zp.asm
include defines/drmario_ram.asm
include defines/drmario_registers.asm
include defines/drmario_constants.asm
include defines/drmario_macros.asm

;iNes header
include header/drmario_header_ines.asm

;Set the starting address
org $8000

;PRG chunk 1
include prg/drmario_prg_game_init.asm
include prg/drmario_prg_level_init.asm
include prg/drmario_prg_visual_nametable.asm
include prg/drmario_prg_visual_sprites.asm
include prg/drmario_prg_game_logic.asm

;Data chunk 1
include data/drmario_data_game.asm
include data/drmario_data_metasprites.asm

;PRG chunk 2
include prg/drmario_prg_level_end.asm
include prg/drmario_prg_general.asm

;Data chunk 2
include data/drmario_data_nametables.asm
include unused/drmario_unused_data_ced5.asm
include data/drmario_data_demo_field_pills.asm
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D000)
include data/drmario_data_demo_inputs.asm

;Audio engine - general & sfx
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D200)
include prg/drmario_prg_audio_general_a.asm
include unused/drmario_unused_data_d2cc.asm
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D300)
include data/drmario_data_sfx.asm               
include prg/drmario_prg_audio_general_b.asm
include prg/drmario_prg_audio_sfx.asm

;Audio engine - music
include prg/drmario_prg_audio_music.asm
include data/drmario_data_music.asm
if ver_EU
    include unused/drmario_unused_data_eu_fc29.asm
    include prg/drmario_prg_reset.asm                  
endif 
include unused/drmario_unused_data_fafd.asm
if $<$C000
    org $C000                                   ;Samples cannot be located before $C000
endif
align 64                                        ;Must be aligned on a 64-byte boundary (vanilla rom = $FD00)
include samples/drmario_samples_dmc.asm

;End of rom
if !ver_EU
    include prg/drmario_prg_reset.asm
else 
    include prg/routines/drmario_prg_audio_update.asm                  
endif 
include unused/drmario_unused_data_ff32.asm
include prg/drmario_prg_audio_linker.asm
include unused/drmario_unused_data_ffd9.asm

;Nintendo header
org $FFE0                                       ;Is on a specific address (doesn't impact the game though)
include header/drmario_header_nintendo.asm

;Interrupt vectors
org $FFFA                                       ;Must be at this specific address             
word nmi, reset, irq              

;CHR
incbin bin/drmario_chr.bin