;;
;; gameName_ROM [$A008]
;;
;; Game name in the rom, used to see if this is a cold boot or reset (name already loaded = reset)  
;;
gameName_ROM:
.db '!','D','R','.','M','A','R','I'         
.db 'O','!'

;;
;; cutscene_objectFlying_basedOnSpeedAndLvl [$A012]
;; 
;; Defines what object is flying in the cutscene, according to speed, and at which level
;; Note that the following is zero-based, and that the cutscene actually plays BEFORE the NEXT level, and not AFTER the CURRENT level, meaning custcenes are indicated at levels 6/11/16/21
;; 3 chunks x 32 bytes, 1 chunk for each speed setting (up to level 21 is supported, beyond that is skipped by code)
;; Technically, this means that the 10 last bytes of each chunk are actually unused (though code requires that we stay 32-bytes bound)
;; 
cutscene_objectFlying_basedOnSpeedAndLvl:
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00

.db $00,$00,$00,$00,$00,$00,$07,$00
.db $00,$00,$00,$05,$00,$00,$00,$00
.db $06,$00,$00,$00,$00,$08,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00

.db $00,$00,$00,$00,$00,$00,$02,$00
.db $00,$00,$00,$01,$00,$00,$00,$00
.db $04,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00

;;
;; cutscene_objectFlying [$A072]
;;
;; Various properties of a given flying object. Index 0 means no object.
;; 
;; flipFrame:   This tells us at what frame interval we update the anim
;; sprIndex:    Which metasprite is used
;; leftOrRight: Gives the starting position (x coordinate), either left or right of screen ($F0 = right)
;; moveFrame:   Metasprite is moved every x frames
;; XOffset:     Every time the object is moving, it moves in x-coordinate by what is in this table ($FF = 1 to the left)
;;
cutscene_objectFlying_flipFrame:
.db $00,$01,$0F,$03,$07,$07,$03,$07
.db $07
cutscene_objectFlying_sprIndex:
.db $00
.db spr_cutscene_pig_frame0
.db spr_cutscene_turtle_frame0
.db spr_cutscene_snowman            ;This one is never used
.db spr_cutscene_witch_frame0
.db spr_cutscene_rooster_frame0
.db spr_cutscene_spraycan_frame0
.db spr_cutscene_book_frame0
.db spr_cutscene_dinosaur_frame0
cutscene_objectFlying_leftOrRight:
.db $00,$F0,$00,$F0,$00,$F0,$F0,$00
.db $00
cutscene_objectFlying_moveFrame:
.db $00,$00,$0F,$00,$01,$03,$00,$00
.db $03
cutscene_objectFlying_XOffset:
.db $00,$FF,$01,$FF,$01,$FF,$FE,$01
.db $01

;;
;; finalCutscene_lightningPAL_change [$A09F]
;;
;; Palette to change to everytime the lightning anim is updated
;; 
finalCutscene_lightningPAL_change:
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_lightning
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_lightning
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night
.db palNb_cutscene_night

;;
;; cutscene_musicToPlay_basedOnSpeed [$A0AF]
;;
;; Which music plays during cutscenes on low, med and hi speed settings
;; 
cutscene_musicToPlay_basedOnSpeed:
.db mus_ending
.db mus_cutscene
.db mus_cutscene

;;
;; cutsceneText [$A0B2]
;;
;; Position and letters for cutscene text
;; 
cutsceneText_PPUaddr:
.db $00,$28,$29,$2A,$2B,$2C,$2D,$2E     ;CONGRATULATIONS!
.db $2F,$30,$31,$32,$33,$34,$35,$36
.db $37
.db $88,$89,$8A,$8B,$8C                 ;VIRUS 
.db $8E,$8F,$90,$91,$92                 ;LEVEL
.db $95                                 ;Current virus level nb
.db $C8,$C9,$CA,$CB,$CC                 ;SPEED
.db $D4                                 ;Current speed setting
.db $D3                                 ;End of data

cutsceneText:
.db $00,_C_,_O_,_N_,_G_,_R_,_A_,_T_     
.db _U_,_L_,_A_,_T_,_I_,_O_,_N_,_S_
.db _excl_
.db _V_,_I_,_R_,_U_,_S_                  
.db _L_,_E_,_V_,_E_,_L_                 
.db $01                                 ;Current virus level nb
.db _S_,_P_,_E_,_E_,_D_                 
.db $00                                 ;Current speed setting   
.db $FF                                 ;End of data

;;
;; cutscenePal_basedOnSpeed [$A0F8]
;;
;; The palette used for the cutscene depending on the speed setting
;; 
cutscenePal_basedOnSpeed:
.db palNb_lvl20Low_ending
.db palNb_cutscene
.db palNb_cutscene

;;
;; cutscene_cloudSprites [$A0FB]
;;
;; Data for properties of clouds in cutscenes
;; 
cutscene_cloudSprites_index:
.db $00
.db spr_cloud_big
.db spr_cloud_middle
.db spr_cloud_small
cutscene_cloudSpritesData:
.db $01,$D0,$36                         ;Cloud 1 data (id, x, y)
.db $02,$30,$74                         ;Cloud 2 data
.db $03,$D8,$AB                         ;Cloud 3 data
.db $00                                 ;Ends the data (necessary)
cutscene_cloudSprites_speed:
.db $00,$03,$07,$0F                     ;In the order: unused, big, middle, small

if !removeUnused
    UNUSED_A10D:
    .db $01,$16,$01,$17,$18,$19,$18,$1A                 ;Not present in virus 1989, appears in april prototype, but is unused
    .db $1B,$1C,$1B,$20
endif

;;
;; bigVirus_failLvl_spriteIndex [$A119]
;;
;; The two meta-sprites that constitute the "fail level" animation for the big virus
;; 
bigVirusYellow_failLvl_spriteIndex:
.db spr_bigVirus_yellow_dancing_frame0
.db spr_bigVirus_yellow_laughing
bigVirusRed_failLvl_spriteIndex:
.db spr_bigVirus_red_dancing_frame0
.db spr_bigVirus_red_laughing
bigVirusBlue_failLvl_spriteIndex:
.db spr_bigVirus_blue_dancing_frame0
.db spr_bigVirus_blue_laughing

;;
;; startTxt_YPos_basedOnNbPlayers & others [$A11F]
;;
;; Positionning of visual elements at end game according to nb players and who's winner/loser
;; 
startTxt_YPos_basedOnNbPlayers:
.db $00,$C3,$D3
redLoseVirus_XPos_basedOnLoser:
.db $00,$34,$B4
marioWin_XPos_basedOnWinner:
.db $00,$34,$B4
redLoseVirus_spriteIndex_basedOnFrame:
.db spr_bigVirus_red_holdSign_frame0
.db spr_bigVirus_red_holdSign_frame1

if !removeUnused
    UNUSED_A12A:
    .db $00,$40,$C0                                     ;Not present in virus 1989, appears in april prototype, but is unused
endif

;;
;; musicTypeBox [$A12D]
;;
;; Sprite index and x position of music type box
;; 
musicTypeBox_sprIndex:
.db spr_musicTypeBox_large  ;LOW
.db spr_musicTypeBox_large  ;MED
.db spr_musicTypeBox_small  ;HI
if !removeUnused
    UNUSED_A130:
    .db $00
endif
musicTypeBox_XPos:
.db $38,$70,$A7

;;
;; bigVirus [$A134]
;;
;; Manages the movement of the big virus in the magnifier
;; 
bigVirusState_haltTable:                            ;Based on the virus current state: 0 = alive and well, 1 = hurt in, 2 = hurt loop, 3 = dying, 4 = dead
.db $00,$01,$01,$01,$00                             ;If 1, it halts the circular movement of the virus, if zero, they move according to the following tables
bigVirus_XPos:
.db $20,$22,$24,$25,$27,$28,$2A,$2B                 ;A total of 64 positions. Yellow starts at index 0 ($20)
.db $2C,$2D,$2E,$2F,$2F,$2F,$30,$30
.db $30,$30,$30,$2F,$2F,$2F,$2E,$2D                 ;Red starts at index 21 ($2F)
.db $2C,$2B,$2A,$28,$27,$25,$24,$22
.db $20,$1E,$1C,$1B,$19,$18,$16,$15
.db $14,$13,$12,$11,$11,$11,$10,$10                 ;Blue starts at index 42 ($12)
.db $10,$10,$10,$11,$11,$11,$12,$13
.db $14,$15,$16,$18,$19,$1B,$1C,$1E
.db $20,$22,$24,$25,$27,$28,$2A,$2B                 ;Repeat of the 64 positions to support red & blue virus offset
.db $2C,$2D,$2E,$2F,$2F,$2F,$30,$30
.db $30,$30,$30,$2F,$2F,$2F,$2E,$2D
.db $2C,$2B,$2A,$28,$27,$25,$24,$22
.db $20,$1E,$1C,$1B,$19,$18,$16,$15
.db $14,$13
if !optimize
    .db         $12,$11,$11,$11,$10,$10             ;Everything from $12 onward here is never used
    .db $10,$10,$10,$11,$11,$11,$12,$13
    .db $14,$15,$16,$18,$19,$1B,$1C,$1E
endif 
bigVirus_YPos:
.db $AF,$AF,$AE,$AE,$AD,$AC,$AB,$AA                 ;Same principle
.db $A8,$A7,$A5,$A3,$A2,$A0,$9E,$9D
.db $9B,$99,$98,$96,$94,$93,$91,$8F
.db $8E,$8C,$8B,$8A,$89,$88,$88,$87
.db $87,$87,$88,$88,$89,$8A,$8B,$8C
.db $8E,$8F,$91,$93,$94,$96,$98,$99
.db $9B,$9D,$9E,$A0,$A2,$A3,$A5,$A7
.db $A8,$AA,$AB,$AC,$AD,$AE,$AE,$AF
.db $AF,$AF,$AE,$AE,$AD,$AC,$AB,$AA
.db $A8,$A7,$A5,$A3,$A2,$A0,$9E,$9D
.db $9B,$99,$98,$96,$94,$93,$91,$8F
.db $8E,$8C,$8B,$8A,$89,$88,$88,$87
.db $87,$87,$88,$88,$89,$8A,$8B,$8C
.db $8E,$8F
if !optimize
    .db         $91,$93,$94,$96,$98,$99
    .db $9B,$9D,$9E,$A0,$A2,$A3,$A5,$A7
    .db $A8,$AA,$AB,$AC,$AD,$AE,$AE,$AF
endif

;;
;; scoreMultiplier_table [$A239]
;;
;; Score multiplier based on the number of matches in a combo
;; 
scoreMultiplier_table:
.db $01,$02,$04,$08,$10,$20,$20,$20
.db $20,$20,$20

;;
;; bkgColor_basedOnSpeed [$A244]
;;
;; Level bkg color (direct value from nes palette) according to speed
;; 
bkgColor_basedOnSpeed:
.db $0A,$03,$00             ;Green, purple, gray

;;
;; virusPlacement_colorBits [$A247]
;;
;; Used by the routine that adds virus to the level
;; 
virusPlacement_colorBits:
.db %00000001,%00000010,%00000100,%00000000

;;
;; bigVirusHurt_YOffset [$A24B]
;;
;; The virus hurt "jump" animation in y coordinates
;; 
bigVirusHurt_YOffset:
.db $FC,$F8,$F4,$F2,$F1,$F0,$F1,$F2
.db $F4,$F8,$FC,$00

;;
;; text_speed [$A257]
;;
;; The letters for the speed text used in level and cutscenes
;; 
textLevelSpeed:
.db _L_,_O_,_W_,$00     
.db _M_,_E_,_D_,$00
.db $FE,_H_,_I_,$00
cutsceneText_speed:
.db _L_,_O_,_W_,$00     
.db _M_,_E_,_D_,$00     
.db $FF,_H_,_I_,$00

;;
;; bigVirus_spriteIndex [$A26F]
;;
;; The metasprites used in the big virus dancing animation
;; 
bigVirus_spriteIndex:
.db spr_bigVirus_red_dancing_frame0
.db spr_bigVirus_red_dancing_frame1
.db spr_bigVirus_red_dancing_frame0
.db spr_bigVirus_red_dancing_frame1_flipped
.db spr_bigVirus_blue_dancing_frame0
.db spr_bigVirus_blue_dancing_frame1
.db spr_bigVirus_blue_dancing_frame0
.db spr_bigVirus_blue_dancing_frame1_flipped
.db spr_bigVirus_yellow_dancing_frame0
.db spr_bigVirus_yellow_dancing_frame1
.db spr_bigVirus_yellow_dancing_frame0
.db spr_bigVirus_yellow_dancing_frame1_flipped

;;
;; music_index [$A27B]
;;
;; Music playing depending on which is selected in the options
;; 
winMusic_basedOnMusicType:
.db mus_victory_fever   ;Fever
.db mus_victory_chill   ;Chill
.db mus_victory_fever   ;Silence
selectableMusicIndex:
.db mus_fever
.db mus_chill
.db mus_silence

;;
;; titleCursorYPos [$A281]
;;
;; The title's cursor position when on 1 or 2 players
;; 
titleCursorYPos:
.db $00,$A7,$B7

;;
;; bkgOptions_eraseP2 & others [$A284]
;;
;; Several data sets for the options
;; 
bkgOptions_eraseP2:                     ;"Erases" (or rather covers) tiles from 2p background options when playing in 1-player mode. Format is: PPUADDR high byte, PPUADDR low byte, qty of tiles, actual tiles (times qty) 
.db $21,$88,$02,$FF,$FF                 ;"P2" in VIRUS LEVEL           
.db $21,$96,$04,$FF,$FF,$FF,$FF         ;3 lines of the box that shows player 2's selected level
.db $21,$B6,$04,$FF,$FF,$FF,$FF         
.db $21,$D6,$04,$FF,$FF,$FF,$FF         
.db $22,$28,$02,$F3,$F4                 ;3 lines to replace 1P/2P for speed into 1P only 
.db $22,$48,$02,$F5,$F6                 
.db $22,$68,$02,$FF,$FF
.db $FF                                 ;End of data             
lvlCursor_XPos:
.db $57,$5B,$5F,$63,$67,$6B,$6F,$73     ;x-coordinates for the 21 selectable levels  
.db $77,$7B,$7F,$83,$87,$8B,$8F,$93
.db $97,$9B,$9F,$A3,$A7
lvlCursor_YPos:
.db $00,$00,$00,$00,$53,$62             ;Uses p1=4 and p2=5 values which explains why we have four zeroes before having actual values
speedCursor_XPos:
.db $58,$80,$A4                         ;x-coordinates for the 3 selectable speed settings
speedCursor_YPos:
.db $00,$00,$00,$00,$87,$96             ;Same as for level cursor
bkgOptions_cursorOnLvl:
_dw $23C0                               ;Changes attributes for top half of screen for cursor on level
.db $20                         
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$88,$22,$00
.db $00,$50,$50,$50,$10,$88,$22,$00
_dw $23E0                               ;Changes attributes for bottom half of screen
.db $20                         
.db $00,$05,$05,$05,$01,$00,$00,$00
.db $00,$55,$55,$55,$11,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $FF                                 ;End of data
bkgOptions_cursorOnSpeed:
_dw $23C0                               ;Same principle for cursor on speed
.db $20
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$50,$50,$50,$10,$00,$00,$00
.db $00,$05,$05,$05,$01,$88,$22,$00
.db $00,$00,$00,$00,$00,$88,$22,$00
_dw $23E0                               
.db $20
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$55,$55,$55,$11,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $FF
bkgOptions_cursorOnMusic:
_dw $23C0                               ;Same principle for cursor on music
.db $20
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$50,$50,$50,$10,$00,$00,$00
.db $00,$05,$05,$05,$01,$88,$22,$00
.db $00,$50,$50,$50,$10,$88,$22,$00
_dw $23E0                               
.db $20
.db $00,$05,$05,$05,$01,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $00,$00,$00,$00,$00,$00,$00,$00
.db $FF

;;
;; baseSpeedSettingValue [$A3A7]
;;
;; Base speed index manually set by players, related to speedCounterTable
;; 
baseSpeedSettingValue:
.db $0F,$19,$1F         ;Low ($0F = $27), Med ($19 = $13), Hi ($1F = $0D)

;;
;; virusPlacement_offset [$A3AA]
;;
;; When adding virus, at which distance in field pos should we make sure there is not another virus of the same color, based on speed
;; 
if !optimize
    virusPlacement_verOffset:
    .db $10,$10,$10             ;We can safely replace by constants instead
    virusPlacement_horOffset:
    .db $02,$02,$02
endif 

;;
;; crowns_PPUADDR [$A3B0]
;;
;; The PPUADDR for the crowns graphics when a player wins in 2-player match
;; 
crownsP1_PPUADDR:
_dw $220E
_dw $21CE
_dw $218E
crownsP2_PPUADDR:
_dw $2210
_dw $21D0
_dw $2190

if !removeUnused
    UNUSED_A3BC:                                    ;Seems to be virus per level, present and unused since earliest virus prototype
    .db $00,$04,$08,$12,$16,$20,$24,$28
    .db $32,$36,$40,$44,$48,$52,$56,$60
    .db $64,$68,$72,$76,$80,$84,$88,$92
    .db $96
    addVirus_minPos_basedOnLvl_UNUSED:              ;Was used in the virus prototype as another way to set virus max height
    .db $30,$30,$30,$30,$30,$30,$30,$30
    .db $30,$30,$30,$30,$30,$30,$30,$28
    .db $28,$20,$20,$18,$18,$18,$18,$18
    .db $18,$18,$18,$18,$18,$18,$18,$18
    .db $18,$18,$18
endif

;;
;; addVirus_maxHeight_basedOnLvl [$A3F8]
;;
;; The max height at which to add virus according to the level
;; 
addVirus_maxHeight_basedOnLvl:
.db $09,$09,$09,$09,$09,$09,$09,$09
.db $09,$09,$09,$09,$09,$09,$09,$0A                 ;First change on lvl 15
.db $0A,$0B,$0B,$0C,$0C,$0C,$0C,$0C                 ;Then lvl 17 and finally lvl 19
.db $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
.db $0C,$0C,$0C

;;
;; pillThrownAnim [$A41B]
;;
;; The x and y coordinates of the pill thrown anim ($F1, $F2 and $F0 change Mario's throw frame, $FF ends the data)
;; 
pillThrownAnim_XPos:
.db $BE,$F1,$BE,$BC,$B8,$B4,$F2,$B0
.db $AC,$A8,$A4,$A0,$9E,$98,$94,$90
.db $8C,$88,$84,$80,$7C,$7A,$78,$F0
.db $78
.db $FF                                 ;End of data
pillThrownAnim_YPos:                            
.db $45,$00,$40,$36,$2E,$27,$00,$21
.db $1E,$1B,$19,$18,$18,$1A,$1C,$1F
.db $23,$28,$2D,$34,$3C,$43,$4A,$00
.db $4F
if !optimize
    .db $F8                             ;Last byte ($F8) is actually never used
endif 

if !removeUnused
    UNUSED_A44F:                                    ;Present and unused since earliest prototype
    .db $01,$08,$FF,$00,$00,$07,$0F,$17
    .db $02,$02,$02,$02,$02,$02,$02,$02
    .db $03,$03,$03,$03,$03,$03,$03,$03
    .db $04,$04,$04,$04,$04,$04,$04,$04
endif

;;
;; pillBoundaries [$A46F]
;;
;; Used when validating movement of pills. The pill size is used as an offset to check the pill boundaries
;; 
if !optimize
    horPillBoundaries_leftHalf:     ;Can actually be completely safely bypassed
    .db $00,$FF,$FF
    horPillBoundaries_rightHalf:
    .db $F9,$F9,$FA
    verPillBoundaries:
    .db $00,$FF,$FF
endif 

if !removeUnused
    UNUSED_A478:                                    ;Present and unused since earliest prototype, seems to be somewhat sprite related
    .db $60,$68,$70,$78,$80,$88,$90,$98
    .db $C0,$C1,$C2,$B0,$B1,$B2,$08,$F8
    .db $01,$FF,$50,$40,$70,$60
endif

;;
;; pill_fieldPos_relativeToPillY [$A48E]
;;
;; Performes a "row nb" to "field pos" transformation (ex: top row 0 = field pos $78) 
;; 
pill_fieldPos_relativeToPillY:
.db $78,$70,$68,$60,$58,$50,$48,$40
.db $38,$30,$28,$20,$18,$10,$08,$00

;;
;; fallingPill_YPos [$A49E]
;;
;; Performes a "row nb" to "sprite y-pos" transformation (ex: top row 0 = sprite y-pos $C8)
;; 
fallingPill_YPos:
.db $C8,$C0,$B8,$B0,$A8,$A0,$98,$90
.db $88,$80,$78,$70,$68,$60,$58,$50

;;
;; pillSpriteData [$A4AE]
;;
;; Data for what constitutes a pill sprite, based on rotation
;; 
pillSpriteData_index:
if !optimize
    .db $00,$00,$00,$00,$00,$00,$00,$00     ;These 8 bytes here are unreachable, they can be optimized
endif
.db $00,$09,$12,$1B                         ;Get an offset for pillSpriteData based on pill rotation
pillSpriteData:
.db $00,$60,$02,$00,$00,$70,$02,$08         ;4 bytes x 2 for sprite properties of both halves of a pill
.db $FF
.db $00,$50,$02,$00,$F8,$40,$02,$00
.db $FF
.db $00,$70,$02,$08,$00,$60,$02,$00
.db $FF
.db $F8,$40,$02,$00,$00,$50,$02,$00
.db $FF

;;
;; relativeFieldPos_halfPills_rotationAndSizeBased & others [$A4DE]
;;
;; Data regarding half pills based on the pill size and rotation
;; 
relativeFieldPos_halfPills_rotationAndSizeBased:
.db $00,$01,$00,$00                         ;Relative field pos of second half pill (horizontal) (used in pillMoveValidation)
.db $F8,$00,$00,$00                         ;For vertical
if !optimize
    .db $FF,$00,$01,$00,$F8,$00,$08,$00     ;Again, always size 2 pills means we don't need this 
    .db $FF,$00,$01,$02,$F0,$F8,$00,$08
endif
halfPill_posOffset_rotationAndSizeBased:
.db $00,$01,$63,$63                         ;Similar to previous, but used in confirmPlacement
.db $00,$F8,$63,$63                         ;1 rotation
.db $01,$00,$63,$63                         ;2 rotations
.db $F8,$00,$63,$63                         ;3 rotations
if !optimize
    .db $FF,$00,$01,$63,$08,$00,$F8,$63     ;Again, always size 2 pills means we don't need this
    .db $01,$00,$FF,$63,$F8,$00,$08,$63
    .db $FF,$00,$01,$02,$08,$00,$F8,$F0
    .db $02,$01,$00,$FF,$F0,$F8,$00,$08
endif 
halfPill_shape_rotationAndSizeBased:
.db $60,$70,$00,$00                         ;Same as previous, but for sprite instead of position
.db $50,$40,$00,$00
.db $70,$60,$00,$00
.db $40,$50,$00,$00
if !optimize
    .db $60,$A0,$70,$00,$50,$90,$40,$00     ;Again, always size 2 pills means we don't need this    
    .db $70,$A0,$60,$00,$40,$90,$50,$00
    .db $60,$A0,$A0,$70,$50,$90,$90,$40
    .db $70,$A0,$A0,$60,$40,$90,$90,$50
endif

if !removeUnused
    optionCursor_YPos_UNUSED:                   ;Used in early virus prototype
    .db $47,$57,$67,$77,$87,$97,$A7
    optionPillsStayMidAir_sprIndex_UNUSED:      ;ON or OFF for fall down in Virus prototype
    .db $01,$02
endif

;;
;; otherPlayerRAM_addrOffset [$A55F]
;;
;; Offset between p1 and p2's RAM. Used in checkReleaseAttack
;; 
otherPlayerRAM_addrOffset:
.db $00,$00,$00,$00,$80,$00                     ;Uses p1 = $04 and p2 = $05 which explains all te empty data

if !removeUnused
    attackRelease_fieldPos_UNUSED:              ;Part of unused attack routine in prototype
    .db $11,$13,$15,$17,$10,$12,$14,$16
    .db $09,$0B,$0D,$0F,$08,$0A,$0C,$0E
    .db $10,$12,$14,$16,$11,$13,$15,$17
    .db $08,$0A,$0C,$0E,$09,$0B,$0D,$0F
endif

;;
;; palData [$A585]
;;
;; The palette data for all backgrounds + sprites in the game
;; 
palData:
    palLevel_1P:
    _dw PPUPAL_BKG0                         ;PPUADDR
    .db $20                                 ;Bytes to copy
    .db $0F,$31,$2C,$0C,$0F,$32,$28,$0C     ;Actual data
    .db $0F,$28,$15,$21,$0F,$00,$22,$0C
    .db $0F,$37,$30,$18,$0F,$28,$15,$0F
    .db $0F,$28,$15,$21,$0F,$28,$21,$0F
    .db $FF                                 ;End of data
    palTitle:
    _dw PPUPAL_BKG0
    .db $20
    .db $0F,$0A,$1A,$11,$0F,$30,$28,$11
    .db $0F,$0A,$1A,$15,$0F,$30,$28,$15
    .db $0F,$37,$30,$18,$0F,$30,$15,$0C
    .db $0F,$30,$2C,$0C,$0F,$38,$21,$0F
    .db $FF
    palOptions:
    _dw PPUPAL_BKG0
    .db $20
    .db $0F,$30,$27,$15,$0F,$30,$17,$0F
    .db $0F,$30,$29,$1A,$0F,$30,$0A,$0F
    .db $0F,$30,$27,$15,$0F,$30,$17,$0F
    .db $0F,$30,$29,$1A,$0F,$29,$27,$21
    .db $FF
    palLevel_2P:
    _dw PPUPAL_BKG0
    .db $20
    .db $0F,$31,$2C,$0C,$0F,$32,$28,$0C
    .db $0F,$28,$15,$21,$0F,$00,$22,$0C
    .db $0F,$37,$30,$18,$0F,$28,$15,$0F
    .db $0F,$28,$15,$21,$0F,$28,$21,$0F
    .db $FF
    palCutscene:
    _dw PPUPAL_BKG0
    .db $20
    .db $22,$1A,$0A,$28,$22,$30,$0F,$0F
    .db $22,$28,$15,$21,$22,$08,$18,$0F
    .db $22,$27,$15,$3C,$22,$30,$10,$0F
    .db $22,$28,$15,$0F,$22,$35,$29,$0F
    .db $FF
    palCutscene_night:
    _dw PPUPAL_BKG0
    .db $20
    .db $02,$0F,$0F,$0F,$02,$02,$0F,$0F
    .db $02,$28,$15,$21,$02,$08,$18,$0F
    .db $02,$0F,$0F,$0F,$02,$30,$10,$0F
    .db $02,$28,$15,$0F,$02,$10,$00,$0F
    .db $FF
    palLvl20Low_ending:
    _dw PPUPAL_BKG0
    .db $20
    .db $0F,$0F,$0F,$0F,$0F,$30,$0F,$0F
    .db $0F,$0F,$0F,$0F,$0F,$08,$18,$0F
    .db $0F,$0F,$0F,$0F,$0F,$30,$0F,$0F
    .db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
    .db $FF
    palCutscene_UFO_fireworks_spritesOnly:
    _dw PPUPAL_SPR0
    .db $10
    .db $02,$28,$15,$21,$02,$02,$10,$0F
    .db $02,$28,$15,$0F,$02,$10,$00,$0F
    .db $FF
    palCutscene_dusk1:
    _dw PPUPAL_BKG0
    .db $20
    .db $23,$19,$09,$18,$23,$30,$0F,$0F
    .db $23,$28,$15,$21,$23,$08,$18,$0F
    .db $23,$28,$16,$2C,$23,$10,$00,$0F
    .db $23,$28,$15,$21,$23,$0F,$0F,$0F
    .db $FF
    palCutscene_dusk2:
    _dw PPUPAL_BKG0
    .db $20
    .db $13,$0A,$0F,$08,$13,$30,$0F,$0F
    .db $13,$28,$15,$21,$13,$08,$18,$0F
    .db $13,$08,$06,$1C,$13,$00,$21,$02
    .db $13,$28,$15,$21,$13,$0F,$0F,$0F
    .db $FF
    palCutscene_lightning:
    _dw PPUPAL_BKG0
    .db $20
    .db $23,$19,$09,$18,$23,$30,$0F,$0F
    .db $23,$28,$15,$21,$23,$08,$18,$0F
    .db $23,$28,$16,$2C,$23,$10,$00,$0F
    .db $23,$28,$15,$21,$23,$0F,$0F,$0F
    .db $FF
    palCutscene_fireworks_bkgOnly:
    _dw PPUPAL_BKG0
    .db $10
    .db $02,$0F,$0F,$0F,$02,$30,$0F,$0F
    .db $02,$28,$15,$21,$02,$08,$18,$0F
    .db $FF

;;
;; fallingPill_startXPos [$A715]
;;
;; The starting x position of falling pills depending if 1 or 2-player game (and which player)
;; 
fallingPill_startXPos:                      ;60 is for 1 player game, 20 is for p1, A0 is for p2
.db $60,$60,$20,$A0

if !removeUnused
    UNUSED_A719:                                ;Present and unused in earliest prototype
    .db $C0,$F8,$6E,$82
    score_basedOnChainLength_UNUSED:            ;Related to score in prototype, by groups of 4 bytes, so chain of 4 = 30, 5= 100, 6 = 800, 7 =1200, 8 = 3000
    .db $00,$00,$30,$00,$00,$01,$00,$00
    .db $00,$08,$00,$00,$00,$12,$00,$00
    .db $00,$30,$00,$00
endif

;;
;; fieldRow_PPUADDR [$A731]
;;
;; PPUADDR of field leftmost column for each row, depending on 1 or 2-player mode (anc which player)
;; 
fieldRow_PPUADDR_1P:
.db $21,$4C,$21,$6C,$21,$8C,$21,$AC
.db $21,$CC,$21,$EC,$22,$0C,$22,$2C
.db $22,$4C,$22,$6C,$22,$8C,$22,$AC
.db $22,$CC,$22,$EC,$23,$0C,$23,$2C
fieldRow_PPUADDR_2P_P1:
.db $21,$44,$21,$64,$21,$84,$21,$A4
.db $21,$C4,$21,$E4,$22,$04,$22,$24
.db $22,$44,$22,$64,$22,$84,$22,$A4
.db $22,$C4,$22,$E4,$23,$04,$23,$24
fieldRow_PPUADDR_2P_P2:
.db $21,$54,$21,$74,$21,$94,$21,$B4
.db $21,$D4,$21,$F4,$22,$14,$22,$34
.db $22,$54,$22,$74,$22,$94,$22,$B4
.db $22,$D4,$22,$F4,$23,$14,$23,$34

;;
;; levelForDisplay [$A791]
;;
;; TBD
;; 
levelForDisplay:
.db $00,$01,$02,$03,$04,$05,$06,$07
.db $08,$09,$10,$11,$12,$13,$14,$15
.db $16,$17,$18,$19,$20,$21,$22,$23
.db $24
if !optimize
    .db $25,$26,$27,$28,$29             ;These levels can never be reached
endif

;;
;; speedCounterTable [$A7AF]
;;
;; The number of frames to wait before dropping 1 vertical for a falling pill. Aka, the gravity.
;; 
speedCounterTable:
if !ver_EU
    .db $45,$43,$41,$3F,$3D,$3B,$39,$37
    .db $35,$33,$31,$2F,$2D,$2B,$29,$27     ;Slowest actually starts at $27 (index $0F)
    .db $25,$23,$21,$1F,$1D,$1B,$19,$17
    .db $15,$13,$12,$11,$10,$0F,$0E,$0D
    .db $0C,$0B,$0A,$09,$09,$08,$08,$07
    .db $07,$06,$06,$05,$05,$05,$05,$05
    .db $05,$05,$05,$05,$05,$05,$05,$04
    .db $04,$04,$04,$04,$03,$03,$03,$03
    .db $03,$02,$02,$02,$02,$02,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01,$01
    .db $00
else 
    .db $38,$36,$35,$33,$31,$30,$2E,$2C
    .db $2B,$29,$27,$26,$24,$22,$21,$1F
    .db $1D,$1C,$1A,$18,$17,$15,$13,$12
    .db $10,$0F,$0E,$0D,$0C,$0B,$0A,$09
    .db $09,$08,$07,$06,$06,$05,$05,$05
    .db $04,$04,$04,$04,$03,$03,$03,$03
    .db $03,$03,$02,$02,$02,$02,$02,$02
    .db $02,$02,$02,$02,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01,$01
    .db $01,$01,$01,$01,$01,$01,$01,$01
    .db $00
endif

if !removeUnused
    UNUSED_A800:                                ;Present and unused in earliest prototype
    .db $01,$02,$03,$04,$05,$06,$03
endif

;;
;; virusColor_random [$A807]
;;
;; Table used for random selection of virus color when adding virus
;; 
virusColor_random:
.db $00,$01,$02,$02,$01,$00,$00,$01
.db $02,$02,$01,$00,$00,$01,$02,$01

;;
;; colorCombination [$A817]
;;
;; Tables used for random selection of halfpills color when generating a new pill
;; 
colorCombination_left:
.db $00,$00,$00,$01,$01,$01,$02,$02
.db $02
colorCombination_right:
.db $00,$01,$02,$00,$01,$02,$00,$01
.db $02

;;
;; txtBox [$A829]
;;
;; Visual data for text box displayed over level when the level ends (for several reasons). $00 ends the data
;; 
txtBox_draw:
.db $8B,$8C,$8C,$8C,$8C,$8C,$8C,$8D
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $8E,$FE,_D_,_R_,_A_,_W_,$FE,$8F
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $ED,$EE,$EE,$EE,$EE,$EE,$EE,$EF
.db $00
txtBox_gameOver:
.db $8B,$8C,$8C,$8C,$8C,$8C,$8C,$8D
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $8E,$FE,_G_,_A_,_M_,_E_,$FE,$8F
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $8E,$FE,_O_,_V_,_E_,_R_,$FE,$8F
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $ED,$EE,$EE,$EE,$EE,$EE,$EE,$EF
.db $00
txtBox_stageClear:
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $8B,$8C,$8C,$8C,$8C,$8C,$8C,$8D
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $8E,_S_,_T_,_A_,_G_,_E_,$FE,$8F
.db $8E,$FE,_C_,_L_,_E_,_A_,_R_,$8F
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $8E,_T_,_R_,_Y_,$FE,$FE,$FE,$8F
.db $8E,$FE,$FE,_N_,_E_,_X_,_T_,$8F
.db $8E,$FE,$FE,$FE,$FE,$FE,$FE,$8F
.db $ED,$EE,$EE,$EE,$EE,$EE,$EE,$EF
.db $00