;Constants
gameName_length         =   $0A
rngSeed                 =   $89
rngSize                 =   $02     ;Bytes for rng

player1                 =   $04
player2                 =   $05

playerRAMsize           =   $30

selectableLvCap         =   $14     ;(or indicate as decimal number?)
finalCutsceneLv         =   $14     
lvCap                   =   $18
speedUps_max            =   $31     ;Prevents speed increase after $31 (49) increases
match_length            =   $04     ;Length of color chain required for a match

attackSize_min          =   $02
attackSize_max          =   $04
attackSize_2_pos        =   $03     ;Attack sizes 2 and 3 can start in 4 different positions starting from left
attackSize_3_pos        =   $03
attackSize_4_pos        =   $01     ;Attack sizes 4 can start in 2 different positions starting from left
attackSize_2_gap        =   $03     ;3 empty spaces between half pills
attackSize_3_gap        =   $01
attackSize_4_gap        =   $01

demo_virus              =   $44     ;Is in decimal (44 virus)
demo_level              =   $0A     ;Is NOT in decimal (level 10)
demo_startPos           =   $7F     ;Virus are only placed in lower half

rowSize                 =   $08     ;Bottle width in half pill units, NOT zero based
lastColumn              =   rowSize - 1     ;$07 (is the zero-based equivalent of rowSize)
lastColumn_forMatch     =   rowSize - match_length  ;$05
heightSize              =   $10     
lastRow                 =   heightSize - 1  ;$0F (is the zero-based equivalent of heightSize)
fieldSize               =   $80
lastFieldPos            =   fieldSize - 1
lastRow_forMatch        =   fieldSize - (rowSize * (match_length-1))
lowerFieldPos           =   $40     ;Where virus are removed to display end game animation
mask_fieldPos_row       =   $78
mask_fieldPos_row_alt   =   $F8     ;Almost the same as mask_fieldPos_row, but does not mask the highest bit
mask_column             =   $07

pillsReserveSize        =   $80     ;(or indicate as decimal number?)
defaultPillSize         =   $02
maxPillSize             =   $04     ;This is not actually fully supported
pillStartingX           =   $03
pillStartingY           =   $0F

rndColorQty             =   $01     ;How many random colors after forcing one of each virus color (possible values: $01, $05, $0D, $1D, $3D, $7D, $FD)
virusRndMask            =   $02 + rndColorQty
virusRndColor           =   $03     ;When adding a virus, if this value or higher, we choose a random color
virusSameColorCheck     =   $02     ;The offset at which another virus with the same color is prohibited
virusVerCheck           =   rowSize * virusSameColorCheck
virusHorCheck           =   virusSameColorCheck

true                    =   $00
false                   =   $FF

checksumAddr_start      = $B900     ;Must end in $00
checksumAddr_end        = $BE00

if ver_revA
    checksumValue       =   $98
elseif ver_EU
    checksumValue       =   $6B
else
    checksumValue       =   $C1
endif
    


persistentRAM           = $0700     ;RAM starting from this address is not wiped at reset
persistentRAM_end       = $07FF

flag_demo_playing       =   $FE
flag_demo_record        =   $FF

;Timings
txtScrollSpeed_cutscene =   $07     ;Zero-based, so every 8 frames, a letter is added
fast_drop_speed         =   $01     ;Zero-based, so every 2 frames, down button is checked for fast drop
if !ver_EU
    hor_accel_speed     =   $10     ;The amount of frames left/right must be held for first lateral movement to occur
    hor_max_speed       =   $06     ;The amount of frames left/right must be held for any subsequent lateral movement to occur (cannot be higher than hor_accel_speed)
else 
    hor_accel_speed     =   $0D
    hor_max_speed       =   $05 
endif 
options_change_speed    =   $08

endScreen_delay         =   $40     ;Amount of frames to wait before displaying end screen
endLevel_delay          =   $80
demoStart_delay         =   $08     ;This is times 256 (every complete frame counter cycle)
if !ver_EU
    levelIntro_delay    =   $80     ;After virus appears, before throwing pill 
else 
    levelIntro_delay    =   $69
endif 
noVirusLeft_delay       =   $40     ;After at least one player has no virus left, before stage clear
statusUpdate_delay      =   $10     ;Delay that is long enough to insure complete status update of field (16 frames, 1 for each row) 
lightning_delay         =   $C0     ;Delay before starting lightning in final cutscene

;Registers
ppuctrl_nt_2000         = %00000000                    
ppuctrl_nt_2400         = %00000001                    
ppuctrl_nt_2800         = %00000010                    
ppuctrl_nt_2C00         = %00000011                    
ppuctrl_vram_dir_right  = %00000000
ppuctrl_vram_dir_down   = %00000100
ppuctrl_spr_tbl_0       = %00000000
ppuctrl_spr_tbl_1       = %00001000
ppuctrl_bkg_tbl_0       = %00000000
ppuctrl_bkg_tbl_1       = %00010000
ppuctrl_spr_8x8         = %00000000
ppuctrl_spr_8x16        = %00100000
ppuctrl_master          = %00000000
ppuctrl_slave           = %01000000     ;Recommended not to use
ppuctrl_nmi_off         = %00000000
ppuctrl_nmi_on          = %10000000
ppuctrl_nmi_off_mask    = %01111111

ppumask_greyscale           = %00000001
ppumask_bkg_col1_enable     = %00000010
ppumask_spr_col1_enable     = %00000100
ppumask_bkg_show            = %00001000
ppumask_spr_show            = %00010000
ppumask_emphasis_red        = %00100000
ppumask_emphasis_green      = %01000000
ppumask_emphasis_blue       = %10000000
ppumask_enable_all          = ppumask_bkg_col1_enable + ppumask_spr_col1_enable + ppumask_bkg_show + ppumask_spr_show

ppuoam_attr_pal0        = %00000000
ppuoam_attr_pal1        = %00000001
ppuoam_attr_pal2        = %00000010
ppuoam_attr_pal3        = %00000011
ppuoam_attr_front       = %00000000
ppuoam_attr_behind      = %00100000
ppuoam_attr_flip_hor    = %01000000
ppuoam_attr_flip_ver    = %10000000

ppustatus_vblank_in     = %10000000
ppustatus_vblank_not    = %00000000


;Controllers
btn_right               = %00000001                    
btn_left                = %00000010
btn_down                = %00000100
btn_up                  = %00001000
btn_start               = %00010000
btn_select              = %00100000
btn_b                   = %01000000
btn_a                   = %10000000

btns_dpad               = %00001111
btns_left_right         = %00000011
btns_reset              = %11110000


;Modes
mode_toTitle                =   $00 
mode_toOptions              =   $01 
mode_toDemo                 =   $01     ;Shared
mode_toLevel                =   $02 
mode_initData_level         =   $03 
mode_mainLoop_level         =   $04 
mode_anyPlayerLoses         =   $05
if !removeMoreUnused 
    mode_6                      =   $06     ;This mode ($06) is unused, just changes to mode $04
    mode_playerLoses_endScreen  =   $07 
    mode_levelIntro             =   $08
else 
    mode_playerLoses_endScreen  =   $06 
    mode_levelIntro             =   $07
endif

;Next actions
nextAction_pillFalling      =   $00
nextAction_pillPlaced       =   $01
nextAction_checkAttack      =   $02
nextAction_sendPillFinished =   $03
if !removeMoreUnused
    nextAction_doNothing        =   $04     ;Seems this is used when a player failed
    nextAction_incNextAction    =   $05
    nextAction_sendPill         =   $06
else 
    nextAction_incNextAction    =   $04
    nextAction_sendPill         =   $05
endif 

;Pill placed step
pillPlaced_resetCombo       =   $00
if !optimize
    pillPlaced_nextStep1        =   $01
    pillPlaced_nextStep2        =   $02
    pillPlaced_checkDrop        =   $03
    pillPlaced_resetMatchFlag   =   $04
    pillPlaced_checkHorMatch    =   $05
    pillPlaced_checkVerMatch    =   $06
    pillPlaced_updateField      =   $07
    pillPlaced_resetPillPlaced  =   $08
else 
    pillPlaced_checkDrop        =   $01
    pillPlaced_resetMatchFlag   =   $02
    pillPlaced_checkHorMatch    =   $03
    pillPlaced_checkVerMatch    =   $04
    pillPlaced_updateField      =   $05
    pillPlaced_resetPillPlaced  =   $06
endif 

;Field objects (aka sprites/tiles)
topHalfPill             =   $40
bottomHalfPill          =   $50
leftHalfPill            =   $60
rightHalfPill           =   $70
singleHalfPill          =   $80
middleVerHalfPill       =   $90
middleHorHalfPill       =   $A0
clearedPillOrVirus      =   $B0
virus                   =   $D0
fieldPosJustEmptied     =   $F0     ;Still holds the color that was previously there, once fully empty, this becomes $FF
fieldPosEmpty           =   $FF
mask_fieldobject_color  =   $0F
mask_fieldobject_type   =   $F0

;Field objects positions
txtBox_draw_fieldPos    =   $28
txtBox_gameOver_fieldPos=   $10

;Colors
yellow                  =   $00
red                     =   $01
blue                    =   $02
mask_color              =   $03

;Speed
speed_low               =   $00
speed_med               =   $01
speed_hi                =   $02

;Options
options_section_lvl     =   $00
options_section_speed   =   $01
options_section_music   =   $02

;Data
virusColor_random_size  =   $0F
fireworksData_size      =   $25

;MMC
mmc_mirroring_one_lower = %00000000
mmc_mirroring_one_upper = %00000001
mmc_mirroring_ver       = %00000010
mmc_mirroring_hor       = %00000011
mmc_prg_switch          = %00000000 ;Or %00000001, both work
mmc_prg_fix_8000        = %00001000
mmc_prg_fix_C000        = %00001100
mmc_chr_8kb             = %00000000
mmc_chr_4kb             = %00010000

;Constants - Graphics
nametable0              = $2000
nametable1              = $2400
nametable2              = $2800
nametable3              = $2C00
nametable_size          =  $400
nametable_attr_addr     =  $3C0     ;The relative address from each nametable's starting adress where the attribute table is
nametable_attr_size     =   $40     

;CHR banks
CHR_levelTiles_frame0   =   $00
CHR_levelTiles_frame1   =   $01
CHR_levelSprites        =   $02
CHR_titleSprites        =   $02     ;Shared
CHR_titleTiles_frame0   =   $03
CHR_titleTiles_frame1   =   $04
CHR_optionsTiles        =   $05
CHR_optionsSprites      =   $05     ;Shared
CHR_cutsceneTiles       =   $06
CHR_cutsceneSprites     =   $07


;2 player level vram
speedText_P1_VRAMaddr   = $20EC
speedText_P2_VRAMaddr   = $20F1

;1 player level vram
highScore_VRAMaddr      = $2102
score_VRAMaddr          = $2162
levelNb_VRAMaddr        = $227B    
speedText_1P_VRAMaddr   = $22DA
virusLeft_VRAMaddr      = $233B

;options vram
lvlNbP1_VRAMaddr        = $2157
lvlNbP2_VRAMaddr        = $21B7
optionsNbP_VRAMaddr     = $20AA  

;cutscene text vram
cutsceneText_VRAMaddr   = $2128

;cutscene text letters
_A_ = $0A 
_B_ = $0B
_C_ = $0C
_D_ = $0D
_E_ = $0E
_F_ = $0F
_G_ = $10
_H_ = $11
_I_ = $12
_J_ = $13
_K_ = $14
_L_ = $15
_M_ = $16
_N_ = $17
_O_ = $18
_P_ = $19
_Q_ = $1A
_R_ = $1B
_S_ = $1C
_T_ = $1D
_U_ = $1E
_V_ = $1F
_W_ = $20
_X_ = $21
_Y_ = $22
_Z_ = $23
_excl_ = $24    ;Exclamation mark

;PPU palette address
PPUPAL              = $3F00
PPUPAL_BKG0         = $3F00
PPUPAL_BKG1         = $3F04
PPUPAL_BKG2         = $3F08
PPUPAL_BKG3         = $3F0C
PPUPAL_SPR0         = $3F10
PPUPAL_SPR1         = $3F14
PPUPAL_SPR2         = $3F18
PPUPAL_SPR3         = $3F1C

;Palette numbers
palNb_level_1P               =   $80
palNb_title                  =   $81
palNb_options                =   $82
palNb_level_2p               =   $83
palNb_cutscene               =   $84
palNb_cutscene_night         =   $85
palNb_lvl20Low_ending        =   $86
palNb_cutscene_UFO_fireworks =   $87
palNb_cutscene_dusk1         =   $88
palNb_cutscene_dusk2         =   $89
palNb_cutscene_lightning     =   $8A
palNb_cutscene_fireworks     =   $8B

;Tile numbers
tileNb_crown_topLeft        =   $5C
tileNb_crown_topRight       =   $5D
tileNb_crown_bottomLeft     =   $6C
tileNb_crown_bottomRight    =   $6D
tileNB_fireworks            =   $40

;Graphics - various
vram_row                =   $20     ;32 tiles
textLevelSpeedSize      =   $03     ;NOT zero based
spr_txt_width           =   $08     ;For rare occasions where text is actually sprites and not tiles
cutsceneFrame_removeTxt =   $81

flyingObjectStatus_appears      =   $02
flyingObjectStatus_removeTxt    =   $04
flyingObjectStatus_moving       =   $06

bkgData_changePtr       =   $4C
bkgData_restorePtr      =   $60


;Metasprites - TO DO: seperate between CHR pages? (also, rename for metaspr_... ?)
spr_txt_pause                       =   $00
spr_cursor_big_top                  =   $02       ;Also $01
spr_cursor_big_bottom               =   $03
spr_musicTypeBox_large              =   $04
spr_musicTypeBox_small              =   $05
spr_bigVirus_red_holdSign_frame0    =   $06
spr_loseXsign                       =   $07
spr_mario_win_frame0                =   $08
spr_mario_win_frame1                =   $09
spr_mario_throw_frame0              =   $0A
spr_mario_throw_frame1              =   $0B
spr_mario_throw_frame2              =   $0C
spr_txt_low                         =   $0D
spr_txt_med                         =   $0E 
spr_txt_hi                          =   $0F 
spr_txt_start                       =   $10
spr_bigVirus_red_holdSign_frame1    =   $11        
spr_bigVirus_red_laughing           =   $13       ;Also $12
spr_bigVirus_yellow_laughing        =   $14
spr_bigVirus_blue_laughing          =   $15
spr_cloud_big                       =   $16
spr_cloud_middle                    =   $17
spr_cloud_small                     =   $18
spr_cursor_small_top                =   $19       ;All up to $1D use this too
spr_cursor_small_bottom             =   $1E
spr_virusGroupCutscene              =   $1F         ;Is the same as the next one
spr_virusGroupCutscene_frame0       =   $20       ;Same as previous
spr_cursor_heart                    =   $21
spr_virusGroupCutscene_frame1       =   $22
spr_bigVirus_red_dancing_frame0     =   $23
spr_bigVirus_red_dancing_frame1     =   $24    
spr_bigVirus_red_dancing_frame1_flipped     =   $25
spr_bigVirus_blue_dancing_frame0            =   $26
spr_bigVirus_blue_dancing_frame1            =   $27
spr_bigVirus_blue_dancing_frame1_flipped    =   $28
spr_bigVirus_yellow_dancing_frame0          =   $29
spr_bigVirus_yellow_dancing_frame1          =   $2A 
spr_bigVirus_yellow_dancing_frame1_flipped  =   $2B
spr_bigVirus_red_hurt_frame0                =   $2C
spr_bigVirus_red_hurt_frame0_flipped        =   $2D
spr_bigVirus_blue_hurt_frame0               =   $2E
spr_bigVirus_blue_hurt_frame0_flipped       =   $2F
spr_bigVirus_yellow_hurt_frame0             =   $30
spr_bigVirus_yellow_hurt_frame0_flipped     =   $31
spr_mario_fail                      =   $32
spr_bigVirus_eradicated             =   $33
spr_UFO_top                         =   $34
spr_UFO_bottom_frame0               =   $35
spr_UFO_bottom_frame1               =   $36
spr_UFO_beam                        =   $37
spr_cutscene_pig_frame0             =   $38
spr_cutscene_pig_frame1             =   $39
spr_cutscene_turtle_frame0          =   $3A
spr_cutscene_turtle_frame1          =   $3B
if !optimize
    spr_cutscene_snowman            =   $3C       ;UNUSED, also $3D
    spr_cutscene_witch_frame0       =   $3E
else 
    spr_cutscene_snowman            =   $3C
    spr_cutscene_witch_frame0       =   $3C
endif
spr_cutscene_witch_frame1           =   spr_cutscene_witch_frame0           + 1
spr_cutscene_rooster_frame0         =   spr_cutscene_witch_frame1           + 1
spr_cutscene_rooster_frame1         =   spr_cutscene_rooster_frame0         + 1
spr_cutscene_spraycan_frame0        =   spr_cutscene_rooster_frame1         + 1
spr_cutscene_spraycan_frame1        =   spr_cutscene_spraycan_frame0        + 1
spr_cutscene_book_frame0            =   spr_cutscene_spraycan_frame1        + 1
spr_cutscene_book_frame1            =   spr_cutscene_book_frame0            + 1
spr_cutscene_dinosaur_frame0        =   spr_cutscene_book_frame1            + 1
spr_cutscene_dinosaur_frame1        =   spr_cutscene_dinosaur_frame0        + 1
spr_mario_title                     =   spr_cutscene_dinosaur_frame1        + 1
spr_mario_title_rightFoot_frame0    =   spr_mario_title                     + 1
spr_mario_title_rightFoot_frame1    =   spr_mario_title_rightFoot_frame0    + 1

;Sprite coordinates
spr_mario_lvl_1p_x                  =   $C0
spr_mario_lvl_1p_y                  =   $4B
spr_nextPill_2p_p1_x                =   $38
spr_nextPill_2p_p1_y                =   $33
spr_nextPill_2p_p2_x                =   $B8
spr_nextPill_2p_p2_y                =   $33
spr_lvlNb_2p_p1_x                   =   $6D
spr_lvlNb_2p_p2_x                   =   $84
spr_lvlNb_2p_y                      =   $2B     ;Shared by both players
spr_virusLeft_2p_p1_x               =   $6E
spr_virusLeft_2p_p2_x               =   $83
spr_virusLeft_2p_y                  =   $BF
spr_mario_win_y                     =   $A7
spr_bigVirus_red_holdSign_y         =   $B7
spr_bigVirus_blue_title_x           =   $C0
spr_bigVirus_blue_title_y           =   $B0
spr_mario_title_x                   =   $2C
spr_mario_title_y                   =   $A7
spr_txt_start_x                     =   $6D     ;y is variable
spr_txt_pause_x                     =   $70
spr_txt_pause_y                     =   $77
spr_cursor_heart_x                  =   $45
spr_musicTypeBox_y                  =   $B7
spr_virusGroupCutscene_x            =   $70     ;starting positions, will bu updated during cutscene (same goes for the following until spr_cloud_small_y)
spr_virusGroupCutscene_y            =   $82
spr_virusGroup_minDist_UFO          =   $24     ;The minimum distance at which the virus group is from the UFO before disappearing
spr_UFO_x                           =   $5E     ;Initial at start of cutscene
spr_UFO_x_final                     =   $E0
spr_UFO_y_low                       =   $44     ;The lowest the UFO gets before absorbing the virus group
spr_UFO_y_high                      =   $30     ;The highest after absorbing virus, before bolting off
spr_cutscene_flyingObject_y         =   $50

spr_offscreen_y                     =   $F8
spr_cutscene_right_boundary_x       =   $F0
spr_cutscene_offscreen_x            =   $F8

;Sprite attributes
spr_txt_2p_attr                     =   $01     ;Palette 1
spr_endGame_2p_attr                 =   $00     ;Palette 0

;Animations speed
spr_mario_win_speed                 =   $08     ;Every 8 frames, mario updates its win animation
spr_bigVirus_red_holdSign_speed     =   $04
spr_bigVirus_circling_speed         =   $01     ;This one is not based on the frame counter, but on the virus dance frames
spr_bigVirus_hurt_speed             =   $04
spr_bigVirus_yellow_laughing_speed  =   $04
spr_bigVirus_red_laughing_speed     =   $08
spr_bigVirus_blue_laughing_speed    =   $04
spr_txt_start_speed                 =   $08
spr_virusGroupCutscene_speed        =   $08
spr_virusGroupCutscene_ver_speed    =   $03
spr_mario_throw_speed_low           =   $01     ;On low setting, the animation updates every other frame, while at med/hi it updates every frame
spr_UFO_ver_speed_slow              =   $03
spr_UFO_ver_speed_fast              =   $01
spr_UFO_hor_speed_fast              =   $02     ;Moves in x twice every frame
spr_UFO_bottom_speed                =   $04     ;Bottom rotation speed
spr_UFO_beam_speed                  =   $01

smallVirusLvlAnim_speed             =   $08
titleAnim_speed                     =   $10     ;Used for the glowing Dr. Mario effet on the title
pillThrown_rotation_speed           =   $01     ;Rotates every other frame
fireworks_fall_speed                =   $03
fireworks_color_change_speed        =   $01

;Animation frames
spr_bigVirus_dance_frames           =   $03     
spr_bigVirus_circling_frames        =   $40     ;Could also be calculated as bigVirus_YPos - bigVirus_XPos, which gives use the size of the table
spr_mario_dance_frames              =   $01
spr_mario_throw_frames_mask         =   $03     ;Animation has 3 frames, all bits but the first 2 must be masked
spr_cutscene_flyingObject_frames    =   $01

;Sprite - various
spr_bigVirus_state_alive            =   $00
spr_bigVirus_state_hurt_in          =   $01
spr_bigVirus_state_hurt_loop        =   $02
spr_bigVirus_state_disappearing     =   $03

spr_bigVirus_hurt_loop_duration     =   $A0     ;160 frames
spr_bigVirus_disappear_duration     =   $05

;Visual update flags
vu_pill         = %00000001     ;Or general update?                    
vu_lvlNb        = %00000010
vu_pScore       = %00000100
vu_hScore       = %00001000
vu_virusLeft    = %00010000
vu_bit5         = %00100000     ;Seems unused
vu_bit6         = %01000000     ;Seems unused
vu_endLvl       = %10000000     ;Only used for victories it seems, though it is also set when in 1-player mode
vu_endLvl_mask  = %01111111     
vu_all          = vu_pill + vu_lvlNb + vu_pScore + vu_hScore + vu_virusLeft + vu_endLvl    ;We assume that bit 5 and 6 are not used

vu_options_ver_lvl      = %00000001
vu_options_ver_speed    = %00000010
vu_options_ver_music    = %00000011
vu_options_lvl_nb       = %00000100
vu_options_ver_mask     = %11111100


;Constants - Audio

;SFX - Noise
if !removeMoreUnused
    noise_UNUSED_01                 =   $01     ;Sounds like an alternate UFO leaves/appears
    noise_explosion                 =   $02
else 
    noise_explosion                 =   $01
endif 
noise_bigVirus_hurt                 =   noise_explosion     +1
noise_UFO_leaves                    =   noise_bigVirus_hurt +1
noise_UFO_appears                   =   noise_UFO_leaves    +1
noise_beam_start                    =   noise_UFO_appears   +1
noise_beam_stop                     =   noise_beam_start    +1

;SFX - SQ0
sq0_cursor_vertical                 =   $01     ;Shared
sq0_letter_cutscene                 =   $01     ;Shared
sq0_pills_cleared                   =   $02
sq0_cursor_horizontal               =   $03     ;Shared
sq0_pill_moveX                      =   $03     ;Shared
sq0_virus_cleared                   =   $04
sq0_pill_rotate                     =   $05
sq0_speed_up                        =   $06
sq0_pill_land                       =   $07     ;Shared
sq0_pill_remains_drop               =   $07     ;Shared
if !removeMoreUnused
    sq0_UNUSED_08                   =   $08     ;High-pitched, glass-like
    sq0_bigVirus_eradicated         =   $09
    sq0_UNUSED_0A                   =   $0A     ;Sounds like an alert (maybe alternate attack sfx)
    sq0_UNUSED_0B                   =   $0B     ;Sounds like a slower alert (maybe alternate attack sfx)
else
    sq0_bigVirus_eradicated         =   $08
endif 

;SFX - Trg
trg_UFO_beam                        =   $01           
if !removeMoreUnused
    trg_UNUSED_02                   =   $02     ;Sounds like a low cursor
    trg_UFO_motor_fast              =   $03
else 
    trg_UFO_motor_fast              =   $02
endif 
trg_UFO_motor_regular               =   trg_UFO_motor_fast  +1

;SFX - SQ0 & SQ1
sq0_sq1_attack_p1                   =   $01
sq0_sq1_attack_p2                   =   $02
sq0_sq1_UFO_siren                   =   $03

;Music
mus_cutscene                        =   $01
mus_chill                           =   $02
mus_silence                         =   $03
mus_fever                           =   $04
mus_fail                            =   $05
mus_title                           =   $06
mus_options                         =   $07
mus_ending                          =   $08
mus_victory_fever                   =   $09
mus_victory_chill                   =   $0A
mus_victory_final                   =   $0B
mus_cutscene_explosion              =   $0C
if !removeMoreUnused
    mus_ending_alt                      =   $0D ;UNUSED I believe
endif 

musicType_fever                     =   $00
musicType_chill                     =   $01
musicType_silence                   =   $02
musicType_demo                      =   $03     ;This value here makes the current music continue 


;Audio registers constants
APU_channel_register_size   =   $04

APUSTATUS_sq0_on        = %00000001
APUSTATUS_sq1_on        = %00000010
APUSTATUS_trg_on        = %00000100
APUSTATUS_noise_on      = %00001000
APUSTATUS_dmc_on        = %00010000

APUSTATUS_enable_all    = %00011111


SQ_DUTY_NOISE_mute      = %00010000

APUCOUNTER_mode_step5   = %10000000
APUCOUNTER_irq_inhibit  = %01000000

;Other various audio constants
pauseAudio              =   $05     ;Rather arbitrary value for a flag

sfx_channel_noise       =   $00
sfx_channel_sq0         =   $01
sfx_channel_sq1         =   $02
sfx_channel_init        =   $02     ;Seems to replace sq1 in this special case
sfx_channel_trg         =   $03
sfx_channel_sq0_sq1     =   $04     ;sq0 + sq1

mixer_channels          =   $06     ;The above channels + 1 channel for music 

rngSeed_noise           =   $55

sfx_pause_length        =   $12
sfx_pause_change_step   =   $03     ;Changes sfx step at every $03 frames

mus_channel_sq0         =   $00
mus_channel_sq1         =   $01
mus_channel_trg         =   $02
mus_channel_perc        =   $03     ;Noise and DMC percussions

mus_channels            =   $04

vol_env_sustain         =   $FF
vol_env_silence         =   $F0 

mus_silence_chan        =   $FF

note_data_section_end   =   $00
note_data_section_start =   $9F
note_data_tempo_change  =   $9E     ;Tempo
note_data_transpose     =   $9C 
note_data_repeat_end    =   $FF     ;Repeat marker
note_data_repeat_start  =   $C0     ;Anything between $C0 and $FE is a repeat, with the first 6 bits serving as qty of repeats (minus 1) (ex: $C0 = $FF times, $C1 = $00 times, $C2 = $01 times, ... $FE = $3D times)
note_data_length_index  =   $B0     ;Index for note length (uses tempo table that was set in metadata of song, or manually set with $9E) (values are between $B0 and $BF)

if !ver_EU
    tempo_225bpm            = noteLength_225bpm - noteLengthTable   ;$00
    tempo_180bpm            = noteLength_180bpm - noteLengthTable   ;$0C
    tempo_150bpm            = noteLength_150bpm - noteLengthTable   ;$18
    tempo_128bpm            = noteLength_128bpm - noteLengthTable   ;$28
    tempo_112bpm            = noteLength_112bpm - noteLengthTable   ;$35
    tempo_100bpm            = noteLength_100bpm - noteLengthTable   ;$43
    tempo_90bpm             = noteLength_90bpm - noteLengthTable    ;$4F
else
    tempo_250bpm            = noteLength_250bpm - noteLengthTable   ;$00
    tempo_187bpm            = noteLength_187bpm - noteLengthTable   ;$0C
    tempo_166bpm            = noteLength_166bpm - noteLengthTable   ;$18             
    tempo_150bpm            = noteLength_150bpm - noteLengthTable   ;$28              
    tempo_136bpm            = noteLength_136bpm - noteLengthTable   ;$38              
    tempo_125bpm            = noteLength_125bpm - noteLengthTable   ;$48
    tempo_115bpm            = noteLength_115bpm - noteLengthTable   ;$58              
    tempo_107bpm            = noteLength_107bpm - noteLengthTable   ;$68             
    tempo_93bpm             = noteLength_93bpm - noteLengthTable    ;$76              
    tempo_83bpm             = noteLength_83bpm - noteLengthTable    ;$84
endif        

transpose_lower         =   $80     ;If transpose is higher than $80, we subtract to the pitch index (we modulate lower), if not we add to pitch ( modulate higer)
transpose_higher        =   $00 