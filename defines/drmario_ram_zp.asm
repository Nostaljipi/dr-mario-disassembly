;Zero page RAM ($00 to $FF)
tmp0                            =   $00
ptr                             =   $00     ;Shared
ptr_lo                          =   $00     ;Shared
rng0_offset                     =   $00     ;Shared
CTRL_exp1                       =   $00     ;Shared

tmp1                            =   $01
ptr_hi                          =   $01     ;Shared
rng1_offset                     =   $01     ;Shared
CTRL_exp2                       =   $01     ;Shared

PPUDATA_init_attr               =   $02

ptrTemp_low                     =   $05
ptrTemp_high                    =   $06

rng0                            =   $17
rng1                            =   $18

nmiFlag                         =   $33     ;Set to 1 during NMI
flag_initDone                   =   $34

ptr_demoInstruction_low         =   $36
ptr_demoInstruction_high        =   $37
bigVirusYellow_XPos             =   $38
virusGroup_XPos                 =   $38     ;Shared
bigVirusYellow_YPos             =   $39
virusGroup_YPos                 =   $39     ;Shared
bigVirusRed_XPos                =   $3A
flyingObjectNb                  =   $3A     ;Shared 
bigVirusRed_YPos                =   $3B
flyingObject_XPos               =   $3B     ;Shared
bigVirusBlue_XPos               =   $3C
flyingObject_YPos               =   $3C     ;Shared
bigVirusBlue_YPos               =   $3D
flyingObjectStatus              =   $3D     ;Shared
bigVirus_circularPos            =   $3E
flyingObject_IndexOffset        =   $3E     ;Shared

spritePointer                   =   $42
frameCounter                    =   $43
spriteXPos                      =   $44
spriteYPos                      =   $45
mode                            =   $46     ;See constants below for valid values
tmp47                           =   $47
tmp48                           =   $48
tmp49                           =   $49
tmp4A                           =   $4A
tmp4B                           =   $4B
tmp4C                           =   $4C

spriteXPos_UFO                  =   $4F
spriteYPos_UFO                  =   $50
waitFrames                      =   $51
visualUpdateFlags               =   $52
spriteIndex                     =   $53     
metaspriteIndex                 =   $53     ;Shared
enablePause                     =   $54
whoWon                          =   $55

currentP_fieldPointer           =   $57
currentP                        =   $58     ;4 for player, 5 for player 2
fieldPos                        =   $59
fieldPos_tmp                    =   $5A
currentP_btnsPressed            =   $5B
currentP_btnsHeld               =   $5C
flag_inLevel_NMI                =   $5D
finalCutsceneStep               =   $5E
spriteAttribute                 =   $60
whoFailed                       =   $61     ;Is used to set the position of the red lose virus (Draw sets this value to zero, otherwise p1=1 & p2=2)

optionSectionHighlight          =   $65     ;0 = Level, 1 = Speed, 2 = Music
palToChangeTo                   =   $66

visualUpdateFlags_options       =   $68
counterDemoInstruction          =   $69
demo_inputs                     =   $70

bigVirusYellow_health           =   $72
bigVirusRed_health              =   $73
bigVirusBlue_health             =   $74
bigVirusYellow_state            =   $75
bigVirusRed_state               =   $76
bigVirusBlue_state              =   $77
bigVirusYellow_frame            =   $78
bigVirusRed_frame               =   $79
bigVirusBlue_frame              =   $7A
danceFrame                      =   $7B     ;Shared by all 3 viruses and Mario on title

pillThrownFrame                 =   $7D
marioThrowFrame                 =   $7E
cutsceneFrame                   =   $7F

;Current player zero-page RAM ($80 to $AF)
currentP_RAM                    =   $80     ;$30 bytes long
currentP_status                 =   $80     ;Is most of the time analoguous to the row at which the game is currently treating the player's field.
currentP_fallingPill1stColor    =   $81
currentP_fallingPill2ndColor    =   $82
currentP_fallingPill3rdColor    =   $83
currentP_fallingPill4thColor    =   $84
currentP_fallingPillX           =   $85
currentP_fallingPillY           =   $86
currentP_pillPlacedStep         =   $87
currentP_UNK_88                 =   $88
currentP_levelFailFlag          =   $89
currentP_speedUps               =   $8A
currentP_speedSetting           =   $8B
currentP_UNUSED_8C              =   $8C
currentP_UNUSED_8D              =   $8D
currentP_chainLength_0based     =   $8E
currentP_comboCounter           =   $8F
currentP_pillsCounter_decimal   =   $90
currentP_pillsCounter_hundreds  =   $91
currentP_speedCounter           =   $92
currentP_horVelocity            =   $93
currentP_matchFlag              =   $94
currentP_chainStartRow          =   $95
currentP_level                  =   $96
currentP_nextAction             =   $97
currentP_attackSize             =   $98
currentP_UNUSED_99              =   $99
currentP_nextPill1stColor       =   $9A
currentP_nextPill2ndColor       =   $9B
currentP_nextPill3rdColor       =   $9C
currentP_nextPill4thColor       =   $9D
currentP_victories              =   $9E
currentP_UNUSED_9F              =   $9F
currentP_speedIndex             =   $A0
currentP_chainLength            =   $A1
currentP_nextPillRotation       =   $A2
currentP_nextPillSize           =   $A3
currentP_virusLeft              =   $A4
currentP_fallingPillRotation    =   $A5
currentP_fallingPillSize        =   $A6
currentP_pillsCounter           =   $A7
currentP_virusToAdd             =   $A8
currentP_attackColors           =   $A9     ;4 bytes long
currentP_scoreMultiplier        =   $AD
currentP_UNUSED_AE              =   $AE
currentP_UNUSED_AF              =   $AF

;Audio zero-page RAM ($E0 to $EF)
tmpE0_audio                     =   $E0
pitchEnvelope_index             =   $E0     ;Shared
tmpE1_audio                     =   $E1
currentPitch                    =   $E1     ;Shared
tmpE2_audio                     =   $E2
tmpE3_audio                     =   $E3
audioData_envelope              =   $E4     ;Either volume or pitch

music_currentChan_startDataPointer          =   $E6
music_currentChan_startDataPointer_lowByte  =   $E6
music_currentChan_startDataPointer_highByte =   $E7

tmpEA_audio                     =   $EA     ;Seems unused (part of music routine, but only ever stored, never read)
sfx_rndNoisePeriod              =   $EB
sfx_rndNoisePeriod_tmp1         =   $EC
sfx_channel                     =   $ED     ;0 = Noise, 1 = Square 0, 2 = Square 1, 3 = Triangle, 4 = DMC
music_channel                   =   $EE     ;0 = Square 0, 4 = Square 1, 8 = Triangle, 12 = Noise
audioToPlay_copy                =   $EF

;Controllers zero-page RAM
p1_btns_held_UNUSED             =   $F1
p2_btns_held_UNUSED             =   $F2
exp1_btns_held_UNUSED           =   $F3
exp2_btns_held_UNUSED           =   $F4
p1_btns_pressed                 =   $F5 
p2_btns_pressed                 =   $F6
p1_btns_held                    =   $F7
exp1_btns_pressed_UNUSED        =   $F7     ;Shared 
p2_btns_held                    =   $F8
exp2_btns_pressed_UNUSED        =   $F8     ;Shared 

ctrlPort                        =   $FB     ;Should be left to zero, having a value of 2 of 4 would mean using the expansion ports

;PPU zero-page RAM
PPUSCROLL_y                     =   $FC
PPUSCROLL_x                     =   $FD
PPUMASK_RAM                     =   $FE
PPUCTRL_RAM                     =   $FF