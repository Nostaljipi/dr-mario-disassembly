;Non-zero page RAM ($0100 to $07FF)

;Stack RAM ($0100 to $01FF)
stack                           = $0100     ;256 bytes

;Sprites RAM ($0200 to $02FF)
sprites                         = $0200

;Player 1 RAM ($0300 to $032F)
p1_RAM                          = $0300     ;$30 bytes long
p1_status                       = $0300
p1_fallingPill1stColor          = $0301
p1_fallingPill2ndColor          = $0302
p1_fallingPill3rdColor          = $0303
p1_fallingPill4thColor          = $0304
p1_fallingPillX                 = $0305
p1_fallingPillY                 = $0306
p1_pillPlacedStep               = $0307
p1_UNK_308                      = $0308
p1_levelFailFlag                = $0309
p1_speedUps                     = $030A
p1_speedSetting                 = $030B
p1_UNUSED_30C                   = $030C
p1_UNUSED_30D                   = $030D
p1_chainLength_0based           = $030E
p1_comboCounter                 = $030F
p1_pillsCounter_decimal         = $0310
p1_pillsCounter_hundreds        = $0311
p1_speedCounter                 = $0312
p1_horVelocity                  = $0313
p1_matchFlag                    = $0314
p1_chainStartRow                = $0315
p1_level                        = $0316
p1_nextAction                   = $0317
p1_attackSize                   = $0318
p1_UNUSED_319                   = $0319
p1_nextPill1stColor             = $031A
p1_nextPill2ndColor             = $031B
p1_nextPill3rdColor             = $031C
p1_nextPill4thColor             = $031D
p1_victories                    = $031E
p1_UNUSED_31F                   = $031F
p1_speedIndex                   = $0320
p1_chainLength                  = $0321
p1_nextPillRotation             = $0322
p1_nextPillSize                 = $0323
p1_virusLeft                    = $0324
p1_fallingPillRotation          = $0325
p1_fallingPillSize              = $0326
p1_pillsCounter                 = $0327
p1_virusToAdd                   = $0328
p1_attackColors                 = $0329     ;4 bytes long
p1_scoreMultiplier              = $032D
p1_UNUSED_32E                   = $032E
p1_UNUSED_32F                   = $032F  

;Player 2 RAM ($0380 to $03AF)
p2_RAM                          = $0380     ;$30 bytes long
p2_status                       = $0380
p2_fallingPill1stColor          = $0381
p2_fallingPill2ndColor          = $0382
p2_fallingPill3rdColor          = $0383
p2_fallingPill4thColor          = $0384
p2_fallingPillX                 = $0385
p2_fallingPillY                 = $0386
p2_pillPlacedStep               = $0387
p2_UNK_388                      = $0388
p2_levelFailFlag                = $0389
p2_speedUps                     = $038A
p2_speedSetting                 = $038B
p2_UNUSED_38C                   = $038C
p2_UNUSED_38D                   = $038D
p2_chainLength_0based           = $038E
p2_comboCounter                 = $038F
p2_pillsCounter_decimal         = $0390
p2_pillsCounter_hundreds        = $0391
p2_speedCounter                 = $0392
p2_horVelocity                  = $0393
p2_matchFlag                    = $0394
p2_chainStartRow                = $0395
p2_level                        = $0396
p2_nextAction                   = $0397
p2_attackSize                   = $0398
p2_UNUSED_399                   = $0399
p2_nextPill1stColor             = $039A
p2_nextPill2ndColor             = $039B
p2_nextPill3rdColor             = $039C
p2_nextPill4thColor             = $039D
p2_victories                    = $039E
p2_UNUSED_39F                   = $039F
p2_speedIndex                   = $03A0
p2_chainLength                  = $03A1
p2_nextPillRotation             = $03A2
p2_nextPillSize                 = $03A3
p2_virusLeft                    = $03A4
p2_fallingPillRotation          = $03A5
p2_fallingPillSize              = $03A6
p2_pillsCounter                 = $03A7
p2_virusToAdd                   = $03A8
p2_attackColors                 = $03A9     ;4 bytes long
p2_scoreMultiplier              = $03AD
p2_UNUSED_3AE                   = $03AE
p2_UNUSED_3AF                   = $03AF  

;Player 1 field RAM ($0400 to $047F)
p1_field                        = $0400     ;128 bytes long (or $80)

;Player 2 field RAM ($0500 to $057F)
p2_field                        = $0500     ;128 bytes long (or $80)

;Cutscene fireworks RAM ($0580 to $05FF)
fireworksData_RAM               = $0580     ;128 bytes long (or $80)

;Special Audio RAM ($067E & $067F) - For syncing music with animation
musicBeatDuration               = $067E     ;In frames
musicFramesSinceLastBeat        = $067F

;Audio RAM ($0680 to $06FF) - For audio engine
SQ0_TIMER_RAM                   = $0680
SQ0_LENGTH_RAM                  = $0681
flag_pause_forAudio_internal    = $0682
sfxPause_soundProgress          = $0683
SQ1_TIMER_RAM                   = $0684
SQ1_LENGTH_RAM                  = $0685

TRG_TIMER_RAM                   = $0688
TRG_LENGTH_RAM                  = $0689
flag_sfxJustFinished            = $068A
sfxPause_soundProgress_div      = $068B     ;Divided by four in relation to actual sound progress, used to swap channel data every 4 steps
flag_audio_68C_UNK              = $068C     ;Is never used (only initialized)
flag_pause_forAudio             = $068D     ;5 = pause

music_metadata_RAM              = $0690     ;10 bytes, first 2 not sure, then 2-byte pointers for each channels
music_metadata_transpose        = $0690     
music_metadata_tempo_index      = $0691
music_metadata_4chan_pointers   = $0692     ;8 bytes (4 chan x 2 bytes)
music_sq0_envelope_index        = $069A     ;Last 3-bits are pitch envelope index, and first 5-bits are volume envelope
music_sq1_envelope_index        = $069B
music_trg_envelope_index        = $069C
SQ0_DUTY_RAM                    = $069D
SQ1_DUTY_RAM                    = $069E
TRG_LINEAR_RAM                  = $069F
music_4channels_currentPointer  = $06A0     ;4 x 2-byte addresses
music_sq0_pointerOffset         = $06A8
music_sq1_pointerOffset         = $06A9
music_trg_pointerOffset         = $06AA
music_perc_pointerOffset        = $06AB
music_sq0_dataOffset            = $06AC     
music_sq1_dataOffset            = $06AD
music_trg_dataOffset            = $06AE
music_perc_dataOffset           = $06AF
music_sq0_repeatStart           = $06B0     ;Stored data offset, when not looping back to begining of section
music_sq1_repeatStart           = $06B1
music_trg_repeatStart           = $06B2
music_perc_repeatStart          = $06B3
music_noteLength_sq0_framesLeft     = $06B4     
music_noteLength_sq1_framesLeft     = $06B5
music_noteLength_trg_framesLeft     = $06B6
music_noteLength_perc_framesLeft    = $06B7
music_noteLength_sq0            = $06B8
music_noteLength_sq1            = $06B9
music_noteLength_trg            = $06BA
music_noteLength_perc           = $06BB
music_sectionRepeatCounter_sq0  = $06BC     ;When data is C0 or higher, this is decreased
music_sectionRepeatCounter_sq1  = $06BD
music_sectionRepeatCounter_trg  = $06BE
music_sectionRepeatCounter_perc = $06BF
SQ0_SWEEP_RAM                   = $06C0
SQ1_SWEEP_RAM                   = $06C1
TRG_UNUSED_RAM                  = $06C2     ;Would be for an unused register 4009
music_sq0_pitchIndex            = $06C3
music_sq1_pitchIndex            = $06C4
music_trg_pitchIndex            = $06C5
music_perc_noteIndex            = $06C6
sfxPlaying_forMusic_noise       = $06C7
sfxPlaying_forMusic_sq0         = $06C8
sfxPlaying_forMusic_sq1         = $06C9
sfxPlaying_forMusic_trg         = $06CA
sfxPlaying_forMusic_dmc_MAYBE   = $06CB
music_toPlay_zeroBased          = $06CC
music_sq0_envelope_step_vol     = $06CD     ;Just for volume?
music_sq1_envelope_step_vol     = $06CE
music_trg_envelope_step_vol_UNUSED  = $06CF     ;Triangle has no volume
music_perc_envelope_step_vol_UNUSED = $06D0     ;Unused I think
music_sq0_envelope_step_pitch   = $06D1
music_sq1_envelope_step_pitch   = $06D2
music_trg_envelope_step_pitch   = $06D3
music_perc_envelope_step_pitch_UNUSED   = $06D4     ;Pitch envelopes not used with DMC/noise in this audio driver
sfx_sectionLength_noise         = $06D5
sfx_sectionLength_sq0           = $06D6
sfx_sectionLength_sq1           = $06D7
sfx_sectionLength_trg           = $06D8
sfx_sectionLength_sq0_sq1       = $06D9
sfx_sectionCounter_noise        = $06DA
sfx_sectionCounter_sq0          = $06DB
sfx_sectionCounter_sq1          = $06DC
sfx_sectionCounter_trg          = $06DD
sfx_sectionCounter_sq0_sq1      = $06DE
sfx_noise_pitch                 = $06DF     ;Sometimes used as sfx_noise_volume as well
sfx_noise_step                  = $06DF     ;Shared
sfx_sq0_step                    = $06E0
sfx_trg_pitch_offset            = $06E1
sfx_trg_pitch                   = $06E2
sfx_noise_vol                   = $06E3
sfx_noise_end_flag              = $06E3     ;Shared, set when reaching the end section of a sfx playing
sfx_sq0_pitchModulator          = $06E4     
sfx_sq1_pitchModulator          = $06E5
sfx_trg_pitchModulator          = $06E6
sfx_noise_data                  = $06E7     ;Assumed, never actually used I think
sfx_sq0_data                    = $06E8     ;Used for UFO
sfx_sq1_data                    = $06E9     ;Assumed
sfx_trg_data                    = $06EA     ;Holds value $80 when starting UFO trg sfx, holds value $84 for UFO beam
sfx_toPlay_noise                = $06F0     ;See Constants section to know what sfx is what number, for each of the 5 channels
sfx_toPlay_sq0                  = $06F1
sfx_toPlay_sq1                  = $06F2
sfx_toPlay_trg                  = $06F3     
sfx_toPlay_sq0_sq1              = $06F4
music_toPlay                    = $06F5

sfx_playing_dmc                 = $06F7     ;UNUSED, because there are no DMC sfx (only read, never written) Also present in Tetris...
sfx_playing_noise               = $06F8
sfx_playing_sq0                 = $06F9
sfx_playing_sq1                 = $06FA
sfx_playing_trg                 = $06FB
sfx_playing_sq0_sq1             = $06FC
music_playing                   = $06FD

sfx_rndNoisePeriod_tmp2         = $06FF

;Highscore RAM
highScore                       = $0700     ;6 bytes

;Game Name RAM
gameName_RAM                    = $0710     ;10 bytes

;Config RAM
config_unknown720               = $0720     ;Seems unused
UNUSED_721                      = $0721
config_unknown722               = $0722     ;Seems unused
config_bypassSpeedUp            = $0723     ;Setting this to 1 bypasses the speeding up process
config_pillsStayMidAir          = $0724     ;Setting this to 1 leaves pills hanging mid-air once stacked
config_victoriesRequired        = $0725     ;Sets the required victories in 2 player match (was an option in the prototype)
UNUSED_726                      = $0726     ;Was used in prototype (for what I don't know)
nbPlayers                       = $0727

;Progress/score RAM
lvlsOver20                      = $0728
score                           = $0729     ;6 bytes

;Options RAM
musicType                       = $0731
p1_level_tmp                    = $0732
p1_victories_tmp                = $0732     ;Shared
p2_level_tmp                    = $0733
p2_victories_tmp                = $0733     ;Shared
p1_speedSetting_tmp             = $0734
p1_level_tmp2                   = $0734     ;Shared
p2_speedSetting_tmp             = $0735
p2_level_tmp2                   = $0735     ;Shared
p1_speedSetting_tmp2            = $0736
p2_speedSetting_tmp2            = $0737

p1_level_cache                  = $073C     ;Stored here when attract mode starts
p1_speedSetting_cache           = $073D     ;Stored here when attract mode starts
nbPlayers_cache                 = $073E     ;Stored here when attract mode starts
musicType_cache                 = $073F     ;Stored here when attract mode starts

;Misc flags RAM
flag_antiPiracy                 = $0740
flag_demo                       = $0741     ;0 = not in attract mode, FE = in attract mode, FF = attract record mode

;Cloud sprites RAM
cutscene_cloudSpritesData_RAM   = $0760     ;3 x 3 bytes:   Index, x, y    +1 byte for the last 0

;Pills reserve RAM
pillsReserve                    = $0780     ;$80 in size (128 pills)