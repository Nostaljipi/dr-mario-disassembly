;;
;; checkVirusLeft [$B269]
;;
;; Checks if any player has no virus left, if so, check for draw, then perform end level actions accordingly
;;
checkVirusLeft:          
        lda p1_virusLeft         
        beq @noVirusLeft_atLeast1p
        lda p2_virusLeft         
        beq @noVirusLeft_atLeast1p
        jmp @exit_checkVirusLeft 
    @noVirusLeft_atLeast1p:  
        lda #$0F                    ;Init both players statys         
        sta p1_status            
        sta p2_status            
        lda #noVirusLeft_delay      ;Slight delay                         
        jsr waitFor_A_frames     
        lda p1_virusLeft            ;Check if it is p1 who has no virus left
        bne @p1_hasVirusLeft     
        lda nbPlayers               ;If it is, check if there is a second player, and if this player also has finished (for a draw)     
        cmp #$01                 
        beq @p1_win              
        lda p2_virusLeft         
        bne @p1_win              
    @bothPlayersWon_draw:    
        jsr renderDraw_bothPlayers
        jmp @winLevel            
    @p1_win:                 
        jsr p1RAM_toCurrentP        ;Make p1 the active player, then display stage clear
        jsr displayStageClear    
        jsr currentP_toP1        
        lda #$01                    ;Mark player 1 as the winner  
        sta whoWon               
        jmp @winLevel            
    @p1_hasVirusLeft:        
        if !optimize	
            lda p2_virusLeft        ;Seems like a redundancy check since if we get there, we assuredly know that p2 has 0 virus       
            bne @winLevel
        endif             
    @p2_win:                 
        jsr p2RAM_toCurrentP        ;Same principle as for player 1
        jsr displayStageClear    
        jsr currentP_toP2        
        lda #$02                 
        sta whoWon               
    @winLevel:               
    if !optimize
        lda #$0F                    ;Is essentially the same as the routine fullStatusUpdate        
        sta p1_status            
        sta p2_status            
        lda #statusUpdate_delay              
        jsr waitFor_A_frames
    else 
        jsr fullStatusUpdate
    endif      
        ldx musicType            
        lda winMusic_basedOnMusicType,X
        sta music_toPlay            ;Start win music based on selected music
        lda nbPlayers            
        cmp #$01                    ;If 1-player game, we check if we increase the level
        bne @visualUpdate_andStatus
    @increaseLvl_check:      
        lda p1_level             
        cmp #lvCap                              
        beq @visualUpdate_andStatus
        inc p1_level             
    @visualUpdate_andStatus: 
        lda #vu_endLvl              ;Perform visual then status update                       
        ora visualUpdateFlags    
        sta visualUpdateFlags
    if !optimize    
        lda #$0F                 
        sta p1_status            
        sta p2_status            
        lda #statusUpdate_delay                 
        jsr waitFor_A_frames
    else 
        jsr fullStatusUpdate
    endif      
        lda #$0F                    ;Not sure why we need to do it twice here   
        sta p1_status            
        sta p2_status 
    if !optimize           
    @wait_p1Input:           
        lda frameCounter            ;This here is redundant from playerLoses_endScreen     
        and #spr_txt_start_speed                 
        beq @frameUpdate_checkBtns
    @startTxt_blink:         
        lda #spr_txt_start_x                 
        sta spriteXPos           
        ldx nbPlayers            
        lda startTxt_YPos_basedOnNbPlayers,X
        sta spriteYPos           
        lda #spr_txt_start                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @frameUpdate_checkBtns:  
        jsr visualAudioUpdate_NMI
        lda p1_btns_pressed      
        ora p1_btns_held         
        and #btn_start                 
        beq @wait_p1Input
    else 
        jsr startBlink_waitForInput
    endif        
    @p1_startPressed:        
        lda nbPlayers            
        cmp #$02                 
        beq @initField_2P        
        jsr toNextLevel
    if !optimize      
        lda #mode_initData_level    ;We can jump to different label that includes both those instructions before exiting               
        sta mode                 
        jmp @exit_checkVirusLeft
    else 
        jmp @switchMode_thenExit
    endif 
    @initField_2P:           
    if !optimize
        lda #fieldPosEmpty          ;We have a routine that does just this, probably safe to spend a few cycles to save space               
        ldx #>p1_field                             
        ldy #>p2_field                 
        jsr copy_valueA_fromX00_toY00_plusFF 
        lda #$0F                    ;We also have a routine that does just this              
        sta p1_status            
        sta p2_status            
        lda #statusUpdate_delay                 
        jsr waitFor_A_frames
    else 
        jsr initField_bothPlayers
        jsr fullStatusUpdate
    endif 
    @switchMode_thenExit:     
        lda #mode_initData_level                 
        sta mode
    if !optimize                 
        jmp @exit_checkVirusLeft    ;Definitely not needed
    endif  
    @exit_checkVirusLeft:    
        rts                      

;;
;; displayStageClear [$B351]
;;
;; Simply displays the "Stage Clear" box over the level
;;
displayStageClear:       
        lda currentP             
        tax                      
        tay                      
        lda #fieldPosEmpty                 
        jsr copy_valueA_fromX00_toY00_plusFF    ;Clears this single player's playfield
        lda #$00                 
        sta currentP_fieldPointer
        ldy #$00                 
    @displayStageClear_loop: 
        lda txtBox_stageClear,Y  
        beq @exit_displayStageClear             ;When data is zero, this means we are finished
        sta (currentP_fieldPointer),Y
        iny                      
        jmp @displayStageClear_loop
    @exit_displayStageClear: 
        rts                      

;;
;; fireworksData_toRAM [$B36C]
;;
;; Simple routine that copies the fireworks data to RAM
;;
fireworksData_toRAM:     
        ldx #$00                 
        ldy #$00                 
    @fireworksData_toRAM_loop:
        lda fireworksData_yPos,X
        sta fireworksData_RAM,Y
        iny                      
        lda fireworksData_sprIndex,X            ;Holds the color
        sta fireworksData_RAM,Y
        iny                      
        lda fireworksData_xPos,X
        sta fireworksData_RAM,Y
        iny                      
        inx 
    if !bugfix                     
        cpx #fireworksData_size + 1             ;Data is incomplete for the 26th firework
    else 
        cpx #fireworksData_size
    endif                            
        bne @fireworksData_toRAM_loop
        rts                      

;;
;; fireworksAnim [$B38B]
;;
;; Continually loops the falling fireworks (also manages their change of color)
;;
;; Local variables:
fireworks_yPos  = tmp47
fireworks_color = tmp47                         ;Re-used
fireworksAnim: 
    if !optimize          
        lda currentP_speedSetting               ;Don't think this is necessary here since we only play the final cutscene on hi speed setting
        cmp #speed_hi                 
        bne @exit_fireworksAnim
    endif   
        ldx #$00                 
        ldy spritePointer        
    @fireworksAnim_loop:     
        lda fireworksData_RAM,X
        sta fireworks_yPos                
        lda frameCounter         
        and #fireworks_fall_speed               ;Every $03 frames, increase Y pos
        bne @fireworksAnim_updateYpos
        inc fireworks_yPos                
    @fireworksAnim_updateYpos:
        lda fireworks_yPos                
        sta fireworksData_RAM,X
        sta sprites,Y          
        inx                      
        iny                                     ;Then update sprite index (color)
        lda fireworksData_RAM,X
        sta fireworks_color                
        lda frameCounter         
        and #fireworks_color_change_speed       ;Cycles through all 4 colors. Updated every other frame.
        clc                      
        adc fireworks_color                
        and #mask_color                         ;Isolate color bits         
        ora #tileNB_fireworks                   ;Is the sprite index for the firework dot
        sta fireworksData_RAM,X
        sta sprites,Y          
        inx                                     ;Then store attributes
        iny                      
        lda #ppuoam_attr_behind                 ;Fireworks are behind the bkg                 
        sta sprites,Y               
        iny                                     ;Then finally store x pos
        lda fireworksData_RAM,X
        sta sprites,Y          
        inx                      
        iny 
    if !bugfix                      
        cpx #(fireworksData_size + 1) * 3       ;Data is incomplete for the 26th firework
    else 
        cpx #fireworksData_size * 3
    endif 
        bne @fireworksAnim_loop  
        sty spritePointer        
    @exit_fireworksAnim:     
        rts                      

;;
;; fireworksData [$B3D9]
;;
;; Starting y-pos, x-pos and sprite index (color) for each firework
;;
fireworksData_yPos:
.db $00,$07,$0E,$15,$1C,$23,$2A,$31             ;Each is $25 bytes (fireworksData_size) long
.db $38,$3F,$46,$4D,$54,$5B,$62,$69
.db $70,$77,$7E,$85,$8C,$93,$9A,$A1
.db $A8,$AF,$B6,$BD,$C4,$CB,$D2,$D9
.db $E0,$E7,$EE,$F5,$FC
if !bugfix
    .db $FF                                     ;For some reasons, this one has a 26th byte
endif 
fireworksData_xPos:
.db $58,$C0,$40,$E0,$90,$10,$60,$A8
.db $70,$C0,$30,$D8,$50,$E8,$90,$B0
.db $10,$68,$C8,$38,$78,$20,$A8,$50
.db $D8,$C0,$88,$E8,$48,$98,$30,$C8
.db $60,$D8,$10,$A0,$80
fireworksData_sprIndex:
.db $F1,$F0,$F2,$F1,$F2,$F1,$F0,$F0             ;Strangely here $Fx is used when the actual sprites for fireworks are $4x
.db $F1,$F2,$F2,$F0,$F0,$F1,$F1,$F2
.db $F0,$F2,$F0,$F1,$F0,$F2,$F2,$F0
.db $F1,$F0,$F2,$F2,$F1,$F1,$F0,$F2
.db $F2,$F1,$F2,$F0,$F1

;;
;; checkFinalCutscene [$B449]
;;
;; Checks if we need to start the final cutscene (according to level and speed setting)
;;
checkFinalCutscene:      
        lda currentP_speedSetting
        cmp #speed_hi                 
        bne @exit_checkFinalCutscene
        lda currentP_level       
        cmp #finalCutsceneLv + 1                ;+1 is beacause the cutscene actually plays before the beginning of the next level
        bne @exit_checkFinalCutscene
        jsr finalCutscene_stepDispatch
    @exit_checkFinalCutscene:
        rts                      

;;
;; finalCutscene_stepDispatch [$B459]
;;
;; Jumps to the current final cutscene step
;;
finalCutscene_stepDispatch:
        lda finalCutsceneStep    
        jsr toAddressAtStackPointer_indexA
    @jumpTable_finalCutscene_steps
        .word spriteUpdate_clouds
        .word spriteUpdate_clouds
        .word spriteUpdate_clouds
        .word changeBKGTo_dusk1
        .word spriteUpdate_clouds
        .word spriteUpdate_clouds
        .word changeBKGTo_dusk2
        .word spriteUpdate_clouds
        .word spriteUpdate_clouds
        .word changeBKGTo_night
        .word finalCutscene_incStep
        .word waitFrame0
        .word playSirenSFX
        .word updateLightning
        .word UFOArrives
        .word spriteUpdate_UFO
        .word changeBKGTo_UFOBeam_fireworks
        .word playBeamSFX
        .word beamBlink
        .word blinkBeam_absorbVirusGroup
        .word stopBeamSFX
        .word spriteUpdate_UFO
        .word UFOLeaves_slow
        .word playUFO_flyAwaySFX
        .word UFOLeaves_fast
        .word waitFrame0
        .word updateLightning
        .word changeBKGTo_fireworks
        .word changeBKGTo_UFOBeam_fireworks
        .word playEndingMusic
        if !optimize
            .word jsrTo_fireworksAnim   ;This step is basically just a jsr to fireworksAnim
        else 
            .word fireworksAnim
        endif 
        rts

;;
;; various final cutscene steps [$B49D]
;;
;; Each routine is described below
;;
playSirenSFX:        
        lda #sq0_sq1_UFO_siren      ;Plays the UFO "siren" sfx                
        sta sfx_toPlay_sq0_sq1   
        inc finalCutsceneStep    
        rts                      

playUFO_flyAwaySFX:      
        jsr updateSprite_UFO        ;Plays the UFO flying away sfx
        lda #noise_UFO_leaves                 
        sta sfx_toPlay_noise     
        inc finalCutsceneStep    
        rts                      
     
playBeamSFX:             
        jsr updateSprite_UFO        ;Plays the UFO beam sfx (trg + noise)
        lda #trg_UFO_beam                 
        sta sfx_toPlay_trg       
        lda #noise_beam_start                 
        sta sfx_toPlay_noise     
        inc finalCutsceneStep    
        rts                      
      
stopBeamSFX:             
        jsr updateSprite_UFO        ;Stop the UFO beam sfx and increase the motor speed sfx
        lda #trg_UFO_motor_fast                 
        sta sfx_toPlay_trg       
        lda #noise_beam_stop                 
        sta sfx_toPlay_noise     
        inc finalCutsceneStep    
        rts                      
      
playEndingMusic:         
        jsr updateSprite_UFO        ;Plays ending music
        lda #mus_cutscene_explosion ;Includes music + explosion at start             
        sta music_toPlay         
        inc finalCutsceneStep    
        rts                      
      
finalCutscene_incStep:   
        lda #cutsceneFrame_removeTxt    ;Changes cutscene frame (this has the effect of removing "transparent" letters) and increases step      
        sta cutsceneFrame        
        inc finalCutsceneStep    
        rts                      
     
if !removeUnused     
    finalCutscene_incStep_UNUSED:
            lda #$41                ;Probably used to wait longer or shorter than previous routine
            sta cutsceneFrame        
            inc finalCutsceneStep    
            rts                      
endif

updateLightning:         
        lda frameCounter         
        cmp #lightning_delay        ;Update lightning only if frame counter = or > $C0                
        bcc waitFrame0           
        and #$0F                    ;Isolate low 4-bits                            
        tax                      
        lda finalCutscene_lightningPAL_change,X     ;16 frames of animation
        sta palToChangeTo     
        jmp waitFrame0

beamBlink:               
        jsr blinkBeam               ;Blinks the beam then waits for frame 0         
        jmp waitFrame0

spriteUpdate_clouds:     
        jsr cutscene_spriteUpdate_clouds    ;Moves the clouds then wait for frame 0
        jmp waitFrame0

spriteUpdate_UFO:        
        jsr updateSprite_UFO        ;Updates the UFO metasprite, then segues into the next routine

waitFrame0:              
        lda frameCounter            ;Increase step only when frame counter wraps around to zero   
        bne @exit_finalCutscene_step
        inc finalCutsceneStep    
    @exit_finalCutscene_step:
        rts                      
       
changeBKGTo_dusk1:       
        lda #palNb_cutscene_dusk1   ;Changes palette to dusk 1 then increase cutscene step                 
        sta palToChangeTo     
        inc finalCutsceneStep    
        rts                      
       
changeBKGTo_dusk2:       
        lda #palNb_cutscene_dusk2   ;Changes palette to dusk 2 then increase cutscene step                
        sta palToChangeTo     
        inc finalCutsceneStep    
        rts                      
       
changeBKGTo_night:       
        lda #palNb_cutscene_night   ;Changes palette to night then increase cutscene step                
        sta palToChangeTo     
        inc finalCutsceneStep    
        rts                      
       
changeBKGTo_fireworks:   
        lda #palNb_cutscene_fireworks   ;Changes palette to fireworks then increase cutscene step                
        sta palToChangeTo     
        inc finalCutsceneStep    
        rts                      
       
changeBKGTo_UFOBeam_fireworks:
        jsr updateSprite_UFO        ;Update UFO sprite then change palette
        lda #palNb_cutscene_UFO_fireworks    ;Shared by both UFO beam and fireworks              
        sta palToChangeTo     
        inc finalCutsceneStep    
        rts                      
       
UFOArrives:              
        lda spriteYPos_UFO  
        cmp #spr_UFO_y_low          ;Increase UFO y until reaching $44        
        bne @increaseUFO_yPos    
        inc finalCutsceneStep    
        jmp @exit_UFOArrives     
    @increaseUFO_yPos:       
        lda frameCounter         
        and #spr_UFO_ver_speed_slow ;Move every 4 frames    
        bne @exit_UFOArrives     
        inc spriteYPos_UFO  
    @exit_UFOArrives:        
        jsr updateSprite_UFO
        rts                      
         
UFOLeaves_slow:          
        lda spriteYPos_UFO  
        cmp #spr_UFO_y_high         ;Decrease UFO y until reaching $44 
        bne @decreaseUFO_yPos    
        inc finalCutsceneStep    
        jmp @exit_UFOLeaves_slow 
    @decreaseUFO_yPos:       
        lda frameCounter         
        and #spr_UFO_ver_speed_slow ;Move every 4 frames 
        bne @exit_UFOLeaves_slow 
        dec spriteYPos_UFO  
    @exit_UFOLeaves_slow:    
        jsr updateSprite_UFO
        rts                      
         
UFOLeaves_fast:          
        lda spriteXPos_UFO  
        cmp #spr_UFO_x_final        ;Move UFO until x reaches $E0 (meaning it is offscreen) 
        bne @decreaseUFO_xPos_yPos
        inc finalCutsceneStep    
        jmp @exit_UFOLeaves_fast 
    @decreaseUFO_xPos_yPos:  
    rept spr_UFO_hor_speed_fast
        dec spriteXPos_UFO
    endr
        ;dec spriteXPos_UFO          ;Move twice in x every frame
        ;dec spriteXPos_UFO  
        lda frameCounter         
        and #spr_UFO_ver_speed_fast ;Move in y every 2 frames 
        bne @exit_UFOLeaves_fast 
        dec spriteYPos_UFO  
    @exit_UFOLeaves_fast:    
        jsr updateSprite_UFO
        rts                      
         
jsrTo_fireworksAnim:     
        jsr fireworksAnim           ;Seems unecessary to have a step that is just a jsr and then an rts      
        rts                      
        
updateSprite_UFO:
        lda spriteXPos_UFO          ;Updates the UFO's position and animations (bypassed if UFO x position is zero)
        beq @exit_updateSprite_UFO
        sta spriteXPos           
        lda spriteYPos_UFO  
        sta spriteYPos           
        lda #spr_UFO_top            ;Start with UFO top       
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda frameCounter         
        and #spr_UFO_bottom_speed   ;Every 4 frames, change the UFO bottom anim frame
        lsr A                    
        lsr A                    
        clc                      
        adc #spr_UFO_bottom_frame0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @exit_updateSprite_UFO:
        rts                      
       
blinkBeam_absorbVirusGroup:
        jsr blinkBeam                   ;First update UFO and blink beam        
        lda virusGroup_YPos         
        sec                      
        sbc #spr_virusGroup_minDist_UFO ;Until within a distance of $24 of the UFO, decrease virus group Y
        cmp spriteYPos_UFO  
        bcs @updateVirusGroup_yPos
        lda #spr_offscreen_y            ;When reach predetermined height, set Y to $F8 (puts it offscreen)
        sta virusGroup_YPos  
        inc finalCutsceneStep    
        jmp @exit_blinkBeam_absorbVirusGroup
    @updateVirusGroup_yPos:  
        lda frameCounter         
        and #spr_virusGroupCutscene_ver_speed   ;Move every 4 frames
        bne @exit_blinkBeam_absorbVirusGroup
        dec virusGroup_YPos  
    @exit_blinkBeam_absorbVirusGroup:
        rts                      

blinkBeam:               
        jsr updateSprite_UFO            ;Updates the UFO sprite then blinks the beam
        lda frameCounter         
        and #spr_UFO_beam_speed         ;Blink beam every 2 frames        
        beq @exit_blinkBeam      
        lda #spr_UFO_beam                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @exit_blinkBeam:         
        rts                      

;;
;; cutscene_spriteUpdate_flyingObject [$B5D2]
;;
;; Decides when, where and how the flying object in the cutscene moves
;;
;; Local variables:
flyingObject_moveFrame  = tmp47
flyingObject_animSpeed  = tmp47     ;Shared
cutscene_spriteUpdate_flyingObject:
    if !optimize
        lda currentP_speedSetting
        asl A                    
        asl A                    
        asl A                    
        asl A                    
        asl A                       
        clc                      
        adc currentP_level          
        tax                      
        lda cutscene_objectFlying_basedOnSpeedAndLvl,X      
    else 
        jsr cutscene_objectFlying_check
    endif 
        bne @cutsceneNotEmpty                               ;If table returns NOT a zero, than there is a cutscene
        jmp @exit_cutscene_spriteUpdate_flyingObject
    @cutsceneNotEmpty:       
        lda flyingObjectStatus    
        cmp #flyingObjectStatus_removeTxt                 
        bne @flyingObjectStatus_not4
        lda #cutsceneFrame_removeTxt                 
        sta cutsceneFrame        
        inc flyingObjectStatus              ;If flying object status is 4, increase it to 5
    @flyingObjectStatus_not4:
        lda flyingObjectStatus    
        cmp #flyingObjectStatus_moving                 
        beq @flyingObject_checkIf_moveX
    @flyingObjectStatus_not6:
        lda frameCounter         
        beq @frameCounter_isZero 
        jmp @exit_cutscene_spriteUpdate_flyingObject
    @frameCounter_isZero:    
        inc flyingObjectStatus              ;If flying object status is NOT 4 nor 6, and that we are at frame 0, then increase flying object status
        lda flyingObjectStatus    
        cmp #flyingObjectStatus_appears                 
        beq @flyingObject_appears
        jmp @exit_cutscene_spriteUpdate_flyingObject
    @flyingObject_appears: 
    if !optimize
        lda currentP_speedSetting           ;If flying object status is 2 after increasing, then display the object
        asl A                    
        asl A                    
        asl A                    
        asl A                    
        asl A                    
        clc                      
        adc currentP_level                  
        tax                      
        lda cutscene_objectFlying_basedOnSpeedAndLvl,X
    else 
        jsr cutscene_objectFlying_check
    endif 
        sta flyingObjectNb                  ;There probably is a way to store this way before and optimize some more   
        lda flyingObjectNb     
        tax                      
        lda cutscene_objectFlying_leftOrRight,X     ;Gives the starting position, either left or right of screen
        sta flyingObject_XPos     
        lda #spr_cutscene_flyingObject_y                 
        sta flyingObject_YPos    
    @flyingObject_checkIf_moveX: 
        ldx flyingObjectNb     
        lda cutscene_objectFlying_moveFrame,X       ;Get at what frame interval the object moves
        sta flyingObject_moveFrame                
        lda frameCounter         
        and flyingObject_moveFrame                
        bne @check_changeAnimFrame
    @flyingObject_moveX: 
        lda cutscene_objectFlying_XOffset,X         ;Every time the object is moving, it moves in X by what is in this table
        clc                      
        adc flyingObject_XPos     
        sta flyingObject_XPos     
        cmp #spr_cutscene_right_boundary_x+1        ;Keep moving until x pos is = or > $F1
        bcc @check_changeAnimFrame
        lda #spr_cutscene_offscreen_x               ;Don't bother changing anim frame if we are offscreen         
        sta flyingObject_XPos     
        jmp @exit_cutscene_spriteUpdate_flyingObject
    @check_changeAnimFrame:  
        lda cutscene_objectFlying_flipFrame,X       ;This tells us at what frame interval we update the anim       
        sta flyingObject_animSpeed                
        lda frameCounter         
        and flyingObject_animSpeed                
        bne @spriteUpdate_flyingObject
    @changeAnimFrame:     
        lda flyingObject_IndexOffset 
        eor #spr_cutscene_flyingObject_frames       ;All anims are only 2 frames, this switches between frames 0 and 1
        and #spr_cutscene_flyingObject_frames                 
        sta flyingObject_IndexOffset 
    @spriteUpdate_flyingObject:                 
        lda flyingObject_XPos                       ;Then store all data and update metasprite    
        sta spriteXPos           
        lda flyingObject_YPos    
        sta spriteYPos           
        ldx flyingObjectNb     
        lda cutscene_objectFlying_sprIndex,X
        clc                      
        adc flyingObject_IndexOffset 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @exit_cutscene_spriteUpdate_flyingObject:
        rts                      