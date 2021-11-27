;Build config
completeCleanup     = 1         ;Set to 1 to set all build config options

bypassChecksum      = 0         ;Set to 1 to bypass the anti-piracy checksum
removeUnused        = 0         ;Set to 1 to remove most unused data/code (relatively safe)
removeMoreUnused    = 0         ;Set to 1 to remove the assumed remaining unused data/code (could be risky)
optimize            = 0         ;Set to 1 to optimize code (frees-up space, but might impact cycle accuracy)
bugfix              = 0         ;Set to 1 to fix some bugs (minor bugs not affecting gameplay)

if bugfix
    bypassChecksum      = 1     ;The bugfix setting adds bytes, therefore we need to remove something to prevent getting out of range
endif 

if completeCleanup
    bypassChecksum      = 1         
    removeUnused        = 1         
    removeMoreUnused    = 1         
    optimize            = 1         
    bugfix              = 1         
endif


;Build version
ver_revA            = 1         ;Set only one of these to 1
ver_EU              = 0         ;Based on ver_JU
ver_JU              = 0         ;If none selected, this will default to this one

;Changes in ver_revA are:
; - wipe all persistentRAM on init
; - more extended usage of PPUMASK_RAM
; - some bugfix related to music in demo
; - different unused data
; - different checksum values

;Changes in ver_EU are:
; - wipe all persistentRAM on init
; - different checksum values               
; - different unused data  
; - reset handler in different location                           
; - audioUpdate in different location
; - different demo inputs (but same field/pills)
; - different timings (hor_accel_speed/hor_max_speed, levelIntro_delay, speedCounterTable)
; - different order audio code (drmario_prg_audio_general_a)   
; - different musicBeatDurationTable            
; - different noteLengthTable
; - different volume envelopes (vol_envelope_01, etc.)                     
; - some music data slightly different (mostly timing wise I guess)
; - different timing for sfx (stingers)
; - slight change to reset routine