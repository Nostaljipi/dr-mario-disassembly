;Build config
completeCleanup     = 0         ;Set to 1 to set all build config options

bypassChecksum      = 0         ;Set to 1 to bypass the anti-piracy checksum
removeUnused        = 0         ;Set to 1 to remove most unused data/code (relatively safe)
removeMoreUnused    = 0         ;Set to 1 to remove the assumed remaining unused data/code (could be risky)
optimize            = 0         ;Set to 1 to optimize code (frees-up space, but might impact cycle accuracy)
bugfix              = 0         ;Set to 1 to fix some bugs (minor bugs not affecting gameplay)


if completeCleanup
    bypassChecksum      = 1         
    removeUnused        = 1         
    removeMoreUnused    = 1         
    optimize            = 1         
    bugfix              = 1         
endif


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
if !removeUnused
    include unused/drmario_unused_data_ced5.asm
endif
include data/drmario_data_demo_field_pills.asm
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D000)
include data/drmario_data_demo_inputs.asm

;Audio engine
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D200)
include prg/drmario_prg_audio_general_a.asm
if !removeUnused
    include unused/drmario_unused_data_d2cc.asm
endif
align 256                                       ;Must be aligned on a 256-byte boundary (vanilla rom = $D300)
include data/drmario_data_sfx.asm               
include prg/drmario_prg_audio_general_b.asm
include prg/drmario_prg_audio_sfx.asm
include prg/drmario_prg_audio_music.asm
include data/drmario_data_music.asm
if !removeUnused
    include unused/drmario_unused_data_fafd.asm
endif
if $<$C000
    org $C000                                   ;Samples cannot be located before $C000
endif
align 64                                        ;Must be aligned on a 64-byte boundary (vanilla rom = $FD00)
include samples/drmario_samples_dmc.asm

;End of rom
include prg/drmario_prg_reset.asm
if !removeUnused
    include unused/drmario_unused_data_ff32.asm
endif
include prg/drmario_prg_audio_linker.asm
if !removeUnused
    include unused/drmario_unused_data_ffd9.asm
endif   

;Nintendo header
org $FFE0                                       ;Is on a specific address (doesn't impact the game though)
include header/drmario_header_nintendo.asm

;Interrupt vectors
org $FFFA                                       ;Must be at this specific address             
word nmi, reset, irq              

;CHR
incbin bin/drmario_chr.bin