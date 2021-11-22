;;
;; initUnusedSpriteRAM [$8722]
;;
;; Have yet to encounter a moment when the sprite pointer is not at zero when calling this, so technically this routine could be bypassed, though it may not be safe to do so 
;;
initUnusedSpriteRAM:
    if !removeMoreUnused     
        ldx spritePointer               ;If sprite pointer is $00, exit this routine       
        beq @initUnusedSpriteRAM_exit
        lda #$FF                        ;Otherwise, fill all sprite data that remains with $FF
    @initUnusedSpriteRAM_loop:
        sta sprites,X          
        inx                      
        bne @initUnusedSpriteRAM_loop
    @initUnusedSpriteRAM_exit:
        rts 
    endif 


;;
;; fallingPill_spriteUpdate [$872F]
;;
;; Updates a full pill (broken down in half pills). Interestingly, this routine partially supports pill size up to 4 in length (though it stays a fixed 2 in vanilla game)
;;
;; Local variables:
fallingPill_startXPos_index = tmp47
fallingPill_startXPos_offset = tmp47
halfPill_tmp = tmp47
fallingPill_spriteUpdate:
        lda nbPlayers                       ;First we find the pill x coordinates based on the nb of players and which player. 
        sec                      
        sbc #$01                 
        asl A                       
        sta fallingPill_startXPos_index     ;Holds 0 if 1 player, 2 if 2 players              
        lda currentP             
        sec                      
        sbc #$04                            ;Adds 0 if current player is p1, 1 if p2
        clc                      
        adc fallingPill_startXPos_index                   
        tay                      
        lda fallingPill_startXPos,Y
        sta fallingPill_startXPos_offset                
        lda currentP_fallingPillX           ;This value being in field coordinates, we multiply by 8 to get pixels
        asl A                    
        asl A                    
        asl A                    
        clc                      
        adc fallingPill_startXPos_offset    ;We then add the offset previously calculated, which gives us the pill x coordinate
        sta spriteXPos           
        ldx currentP_fallingPillY           ;No offset required for Y pos, we simply use the value from the y pos table
        lda fallingPill_YPos,X 
        sta spriteYPos                         
        ldy spritePointer                   ;Store the sprite pointer in y for later use (for the halfPill_spriteUpdate routine)
    if !optimize
        lda currentP_fallingPillSize        ;Multiply the falling pill size by 4 and add rotation value to get an index for the sprite data
        asl A                               
        asl A                    
        clc                      
        adc currentP_fallingPillRotation
        tax 
    else 
        ldx currentP_fallingPillRotation
    endif               
        lda pillSpriteData_index,X          ;Store the data index in x for later use (pill size of more than 2 is NOT supported here... pill size of 3 or 4 will overflow from this table)
        tax                      
        lda currentP_fallingPill1stColor    ;We then update for all 4 "halves" of pill, even though only a size of 2 is ever used (and properly supported)
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
        lda currentP_fallingPill2ndColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
    if !optimize  
        lda currentP_fallingPill3rdColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
        lda currentP_fallingPill4thColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
    endif 
        rts                      


;;
;; halfPill_spriteUpdate [$8782]
;;
;; Updates a halfpill sprite according to the input below
;;
;; Input:
;;  tmp47: the half pill current tile index 
;;  x: pillSpriteData_index
;;  y: spritePointer
;;  spriteYPos (full pill y pos before the offset from pill size and rotation)
;;  spriteXPos (full pill x pos before the offset from pill size and rotation)
;;
;; Local variables:
halfPill_tmp = tmp47
halfPill_spriteUpdate:   
        lda pillSpriteData,X                ;If the sprite data is $FF, we have reached the end of the pill  
        cmp #$FF                                               
        beq @exit_halfPill_spriteUpdate
        clc                                 ;Otherwise, update all 4 bytes of the current sprite
        adc spriteYPos                      ;Add current y pos to offset from sprite data table (which is driven by pill size and rotation) 
        sta sprites,Y          
        inx                                 ;Increase pillSpriteData_index and spritePointer
        iny                      
        lda pillSpriteData,X                ;Get tile index from table, then add current half pill tile index
        clc                      
        adc halfPill_tmp                 
        sta sprites,Y          
        inx                      
        iny                      
        lda pillSpriteData,X                ;Get attributes, store as is
        sta sprites,Y          
        inx                      
        iny                      
        lda pillSpriteData,X                ;Add current x pos to offset from sprite data table (which is driven by pill size and rotation) 
        clc                      
        adc spriteXPos           
        sta sprites,Y          
        inx                      
        iny                      
        sty spritePointer                   ;Update sprite pointer
    @exit_halfPill_spriteUpdate:
        rts                      


;;
;; updateSprites_lvl [$87B2]
;;
;; Updates most if not all sprites/metasprites in a 1 or 2-player level
;;
updateSprites_lvl:       
        jsr smallVirusLvlAnim               ;Starts by updating small virus 2-frame anim    
        lda nbPlayers                       ;Check how many players, if 2 player update both players next pill
        cmp #$01                 
        bne @updateSprites_2p_nextPill
        jsr bigVirusLvlAnim                 ;If 1-player, update the big viruses inthe magnifier anim
        lda p1_levelFailFlag                ;Check if p1 had failed, branch accordingly
        beq @p1_hasNotFailed     
    @updateSprites_marioFail:               ;Player has failed in 1p mode, update Mario's state to fail
        setSpriteXY spr_mario_lvl_1p_x,spr_mario_lvl_1p_y                 
        ;lda #spr_mario_lvl_1p_x                        
        ;sta spriteXPos           
        ;lda #spr_mario_lvl_1p_y                 
        ;sta spriteYPos           
        lda #spr_mario_fail                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jmp @exit_updateSprites_lvl
    @p1_hasNotFailed:                       ;Player has not failed in 1p mode, copy p1 RAM, update Mario's throw animation and thrown pill accordingly
        jsr p1RAM_toCurrentP     
        jsr updateSprites_marioThrow
        jsr updateSprites_thrownPill
        jmp @exit_updateSprites_lvl
    @updateSprites_2p_nextPill:             ;If 2-player, check if anyone has failed/won, if so, skip next pill update
        lda whoFailed            
        bne @updateSprites_2p_lvlNb_virusNb
        lda whoWon               
        bne @updateSprites_2p_lvlNb_virusNb
        lda p1_nextPill1stColor             ;If no one failed or won, update the next pill (otherwise it disappears)  
        sta currentP_nextPill1stColor
        lda p1_nextPill2ndColor  
        sta currentP_nextPill2ndColor
    if !optimize
        lda p1_nextPill3rdColor             ;Manages 3rd and 4th color even though these are not fully supported
        sta currentP_nextPill3rdColor
        lda p1_nextPill4thColor  
        sta currentP_nextPill4thColor
        lda p1_fallingPillRotation          ;Unsure why we need the falling pill rotation here, assumed safe to remove
        sta currentP_fallingPillRotation
    endif 
        setSpriteXY spr_nextPill_2p_p1_x,spr_nextPill_2p_p1_y
        ;lda #spr_nextPill_2p_p1_x                 
        ;sta spriteXPos           
        ;lda #spr_nextPill_2p_p1_y                 
        ;sta spriteYPos           
        jsr updateSprites_nextPill
        lda p2_nextPill1stColor             ;Do the same for player 2
        sta currentP_nextPill1stColor
        lda p2_nextPill2ndColor  
        sta currentP_nextPill2ndColor
    if !optimize
        lda p2_nextPill3rdColor  
        sta currentP_nextPill3rdColor
        lda p2_nextPill4thColor  
        sta currentP_nextPill4thColor
        lda p2_fallingPillRotation
        sta currentP_fallingPillRotation
        setSpriteXY spr_nextPill_2p_p2_x,spr_nextPill_2p_p2_y
        ;lda #spr_nextPill_2p_p2_x                 
        ;sta spriteXPos           
        ;lda #spr_nextPill_2p_p2_y          ;Technically, y pos will not change for player 2, and so those 2 instructions could be skipped                 
        ;sta spriteYPos           
    else 
        lda #spr_nextPill_2p_p2_x                 
        sta spriteXPos   
    endif 
        jsr updateSprites_nextPill
    @updateSprites_2p_lvlNb_virusNb:
        lda #spr_lvlNb_2p_y                 ;Update player 1 lv nb      
        sta spriteYPos           
        lda #spr_txt_2p_attr                 
        sta spriteAttribute      
        lda #spr_lvlNb_2p_p1_x                 
        sta spriteXPos           
        ldx p1_level             
        lda levelForDisplay,X  
        sta spriteIndex          
        jsr spriteUpdate_2p_nb        
        lda #spr_lvlNb_2p_p2_x              ;Update player 2 lv nb
        sta spriteXPos           
        ldx p2_level             
        lda levelForDisplay,X  
        sta spriteIndex          
        jsr spriteUpdate_2p_nb      
        lda #spr_virusLeft_2p_y             ;Update player 1 virus left
        sta spriteYPos           
        lda #spr_virusLeft_2p_p1_x                 
        sta spriteXPos           
        lda p1_virusLeft         
        sta spriteIndex          
        jsr spriteUpdate_2p_nb      
        lda #spr_virusLeft_2p_p2_x          ;Update player 2 virus left
        sta spriteXPos           
        lda p2_virusLeft         
        sta spriteIndex          
        jsr spriteUpdate_2p_nb      
        lda #spr_endGame_2p_attr            ;Set attributes for end game sprites
        sta spriteAttribute      
        jsr updateSprites_2p_endGame
    @exit_updateSprites_lvl: 
        rts    


;;
;; updateSprites_2p_endGame [$887C]
;;
;; Small routine that displays either Mario win animation or the big red virus lose animation depending on the outcome of a 2-player game
;;
updateSprites_2p_endGame:
        lda whoWon                          ;First check if someone won, if not, branch to fail check
        beq @checkPlayerWhoFailed
    @updateSprites_marioWin: 
        tax                                 ;If someone won, play Mario's win animation on this player's side        
        lda marioWin_XPos_basedOnWinner,X
        sta spriteXPos           
        lda #spr_mario_win_y                 
        sta spriteYPos           
        lda frameCounter                    ;The animation is updated ever 8 frames
        and #spr_mario_win_speed                 
        log2lsrA spr_mario_win_speed
        ;lsr A                              ;Divide by 8 to get an offset of 0 or 1 for the animation frame  
        ;lsr A                    
        ;lsr A                    
        clc                      
        adc #spr_mario_win_frame0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jmp @exit_updateSprites_2p_endGame
    @checkPlayerWhoFailed:   
        lda whoFailed                       ;If no one failed either, exit this routine
        beq @exit_updateSprites_2p_endGame
    @updateSprites_redLoseVirus:
        tax                                 ;If someone failed, play big red virus lose animation on this player's side, starting with the X sign
        lda redLoseVirus_XPos_basedOnLoser,X
        sta spriteXPos           
        lda #spr_bigVirus_red_holdSign_y                 
        sta spriteYPos           
        lda #spr_loseXsign                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda frameCounter                    ;Next, the big red virus, the animation is updated every 4 frames       
        and #spr_bigVirus_red_holdSign_speed                  
        log2lsrA spr_bigVirus_red_holdSign_speed
        ;lsr A                              ;Divide by 4 to get an offset of 0 or 1 for the animation frame  
        ;lsr A                    
        tax                      
        lda redLoseVirus_spriteIndex_basedOnFrame,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @exit_updateSprites_2p_endGame:
        rts                      


;;
;; updateSprites_thrownPill [$88C1]
;;
;; This routine is for the 1-player throwing of pills by Mario
;;
;; Local variables:
pillThrown_posOffset = tmp47
updateSprites_thrownPill:
        lda currentP_nextPillRotation   ;We first get an offset from the current pill rotation (applied only when the pill is vertical)
        and #$01                 
        asl A                    
        asl A                           ;This results in an offset of either 0 or 4
        sta pillThrown_posOffset                
        ldx pillThrownFrame             ;Then according to the current anim frame and corresponding table, we update the x and y position of the pill
        lda pillThrownAnim_XPos,X
        clc                      
        adc pillThrown_posOffset                
        sta spriteXPos           
        lda pillThrownAnim_YPos,X
        clc                      
        adc pillThrown_posOffset                
        sta spriteYPos                  ;Since the thrown pill is also the next pill, we continue into the next subroutine


;;
;; updateSprites_nextPill [$88D8]
;;
;; This routine is for the 2-player next pill sprite display
;;
;; Local variables:
halfPill_tmp = tmp47
updateSprites_nextPill:  
        ldy spritePointer               ;Almost identical to the end og the fallingPill_spriteUpdate routine, except for the next pill instead of falling pill
    if !optimize
        lda currentP_nextPillSize       
        asl A                    
        asl A                    
        clc                      
        adc currentP_nextPillRotation
        tax 
    else 
        ldx currentP_nextPillRotation
    endif 
        lda pillSpriteData_index,X     
        tax                      
        lda currentP_nextPill1stColor           
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
        lda currentP_nextPill2ndColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
    if !optimize
        lda currentP_nextPill3rdColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
        lda currentP_nextPill4thColor
        sta halfPill_tmp                
        jsr halfPill_spriteUpdate
    endif 
        rts                      


;;
;; metaspriteUpdate [$8906]
;;
;; This displays all sprites contained within a metasprite
;;
;; Input:
;;  metaspriteIndex
;;  spriteYPos (in this case, actually the metasprite y position)   
;;  spriteXPos (in this case, actually the metasprite x position)
;;
;; Local variables:
metasprite_addr_lo = tmp47
metasprite_addr_hi = tmp48 
metaspriteUpdate:            
        clc                      
        lda metaspriteIndex             ;Multiply metasprite index by 2 because metasprite data jump table is 2-bytes addresses    
        rol A                                  
        tax                      
        lda jumpTable_sprites,X  
        sta metasprite_addr_lo          ;Store the metasprite data address       
        inx                      
        lda jumpTable_sprites,X  
        sta metasprite_addr_hi                
        ldx spritePointer               
        ldy #$00                        ;Initiate data offset
    @metaspriteUpdate_Loop:      
        lda (metasprite_addr_lo),Y      ;If sprite data is a $80, it means we have reached the end of the "meta-sprite"            
        cmp #$80                            
        beq @exit_metaspriteUpdate   
        clc                             ;Otherwise, store all 4 bytes for the current sprite 
        adc spriteYPos                
        sta sprites,X          
        inx                      
        iny                      
        lda (metasprite_addr_lo),Y            
        sta sprites,X          
        inx                      
        iny                      
        lda (metasprite_addr_lo),Y            
        sta sprites,X          
        inx                      
        iny                      
        lda (metasprite_addr_lo),Y            
        clc                      
        adc spriteXPos           
        sta sprites,X          
        inx                      
        iny                      
        lda #$04                        ;Increase the sprite pointer by four bytes  
        clc                      
        adc spritePointer        
        sta spritePointer          
        jmp @metaspriteUpdate_Loop      ;Loop for as long as metasprite data is not finished
    @exit_metaspriteUpdate:      
        rts                      


;;
;; spriteUpdate_2p_nb []
;;
;; This routine renders sprites for 2-player level nb and virus left
;;
;; Input:
;;  spriteYPos
;;  spriteIndex
;;  spriteAttribute
;;  spriteXPos
;;
spriteUpdate_2p_nb:      
        ldx spritePointer        
        lda spriteYPos           
        sta sprites+0,X          
        lda spriteIndex     ;Move bits four times right so that the first "high" digit in the byte is isolated        
        lsr A                    
        lsr A                    
        lsr A                    
        lsr A                    
        sta sprites+1,X          
        lda spriteAttribute      
        sta sprites+2,X          
        lda spriteXPos           
        sta sprites+3,X          
        lda spriteYPos      ;2nd digit starts here        
        sta sprites+4,X          
        lda spriteIndex          
        and #$0F            ;Mask the sprite index to get only the second digit                 
        sta sprites+5,X          
        lda spriteAttribute      
        sta sprites+6,X          
        lda spriteXPos           
        clc                      
        adc #spr_txt_width  ;Offset its position by 8 pixels                 
        sta sprites+7,X          
        lda spritePointer        
        clc                      
        adc #$08            ;2 sprites (4 bytes each) have been added, add $08 to sprite pointer     
        sta spritePointer        
        rts                      


;;
;; spriteUpdate_victories_UNUSED [$8986]
;;
;; Seems to be a remnant of earlier builds where victories required were configurable by the player
;;
if !removeUnused
    spriteUpdate_victories_UNUSED:
            lda nbPlayers            
            cmp #$02                 
            bne @exit_spriteUpdate_victories_UNUSED
            lda #$27                 
            sta spriteYPos           
            lda #$6C                 
            sta spriteXPos           
            lda config_victoriesRequired    ;This is always set to 3 in the final game, but can be set in earlier prototypes
            sta spriteIndex                 ;Display the number of victories required         
            lda #$00                 
            sta spriteAttribute      
            jsr spriteUpdate_2p_nb   
            lda #$3F                 
            sta spriteYPos           
            lda #$6C                 
            sta spriteXPos           
            lda p1_victories         
            sta spriteIndex                 ;Here victories are only displayed as numbers         
            lda #$00                 
            sta spriteAttribute      
            jsr spriteUpdate_2p_nb   
            lda #$84                 
            sta spriteXPos           
            lda p2_victories         
            sta spriteIndex          
            lda #$00                 
            sta spriteAttribute      
            jsr spriteUpdate_2p_nb   
        @exit_spriteUpdate_victories_UNUSED:
            rts
endif                      


;;
;; updateSprites_marioThrow [$89C6]
;;
;; Simple routine to update Mario's throw anim according to current anim frame
;;
updateSprites_marioThrow:
        setSpriteXY spr_mario_lvl_1p_x,spr_mario_lvl_1p_y 
        ;lda #spr_mario_lvl_1p_x                 
        ;sta spriteXPos           
        ;lda #spr_mario_lvl_1p_y                 
        ;sta spriteYPos           
        lda marioThrowFrame             ;3 frame animation, so this value is either 0, 1 or 2
        clc                      
        adc #spr_mario_throw_frame0     ;This here is the offset to get to Mario's throw anim sprites, frame 0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        rts                      


;;
;; smallVirusLvlAnim [$89D9]
;;
;; CHR bankswitch to simulate small virus animation
;;
smallVirusLvlAnim:       
        lda frameCounter         
        and #smallVirusLvlAnim_speed        ;Changes every 8 frames              
        log2lsrA smallVirusLvlAnim_speed
        ;lsr A                              ;lsr A times 3 to get to either 0 or 1 for the bank switching                    
        ;lsr A                    
        ;lsr A                    
        jsr changeCHRBank1       
        rts                      


;;
;; bigVirusLvlAnim [$89E4]
;;
;; A huge routine that updates the 3 big viruses in the magnifier. Almost a copy-paste of the same code 3 times, once for each virus
;;
bigVirusLvlAnim:                        
        lda currentP_levelFailFlag      ;First check if the player has failed the level, if so exit this routine to the lvl fail anim
        beq @levelNotFailed      
        jmp bigVirusAnim_lvlFail 
    @levelNotFailed:         
        lda musicBeatDuration           ;If not, sync animation to the tempo of the music (this is what makes the virus dance "on the beat")
        cmp musicFramesSinceLastBeat    
        bcs @updateCirclingPosition
    @updateDanceFrame                   ;If we hit the next beat, increase the dance frame
        inc danceFrame  
        lda danceFrame  
        and #spr_bigVirus_dance_frames  ;Wraparound at 3 frames (zero-based anim is thus 4 frames long)
        sta danceFrame  
        lda #$00                 
        sta musicFramesSinceLastBeat
    @checkBigVirusState                 
        ldx bigVirusYellow_state        ;State is as follows: 0 = alive and well, 1 = hurt in, 2 = hurt loop, 3 = dying, 4 = dead
        lda bigVirusState_haltTable,X
        bne @yellowUpdate               ;No virus must be on hurt/dying for the circular motion to take place
        ldx bigVirusRed_state    
        lda bigVirusState_haltTable,X
        bne @yellowUpdate        
        ldx bigVirusBlue_state   
        lda bigVirusState_haltTable,X
        bne @yellowUpdate        
        lda danceFrame                  ;Update circular position every other dance frame
        and #spr_bigVirus_circling_speed                        
        bne @yellowUpdate
    @checkCircularPos_wraparound        
        inc bigVirus_circularPos        ;+1, wraparound at $40 (64 circular positions)
        lda bigVirus_circularPos 
        cmp #spr_bigVirus_circling_frames                        
        bne @updateCirclingPosition
        lda #$00                 
        sta bigVirus_circularPos 
    @updateCirclingPosition: 
        ldx bigVirus_circularPos        ;Update circular position based on 64-entry x and y tables 
        lda bigVirus_XPos+0,X    
        sta bigVirusYellow_XPos  
        lda bigVirus_YPos+0,X    
        sta bigVirusYellow_YPos  
        lda bigVirus_XPos+21,X          ;Virus are roughly equi-distant based on this table  
        sta bigVirusRed_XPos     
        lda bigVirus_YPos+21,X   
        sta bigVirusRed_YPos     
        lda bigVirus_XPos+42,X   
        sta bigVirusBlue_XPos    
        lda bigVirus_YPos+42,X   
        sta bigVirusBlue_YPos    
    @yellowUpdate:           
        lda bigVirusYellow_XPos         ;Here starts the huge single big virus update routine, repeated pretty much as is for the 2 others 
        sta spriteXPos                  ;First prepare the coordinates
        lda bigVirusYellow_YPos  
        sta spriteYPos           
        lda bigVirusYellow_state        ;Then check what anim to play based on state
        bne @yellowState_not0
    @yellowState_is0:                   ;If zero, than virus is alive and well and dancing
        ldx danceFrame                  
        lda bigVirus_spriteIndex+8,X    ;Yellow is last in this 12 byte sprite index table
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda #$00                        ;We reset the frame to make sure it is at zero when changing state
        sta bigVirusYellow_frame        
        jmp @redUpdate           
    @yellowState_not0:                  ;Check if state 1
        cmp #spr_bigVirus_state_hurt_in      
        bne @yellowState_not1    
    @yellowState_is1:                   ;State 1 is the "in" of the hurt, when jumping
        inc bigVirusYellow_frame 
        lda #spr_bigVirus_yellow_hurt_frame0
        sta metaspriteIndex          
        ldx bigVirusYellow_frame 
        lda bigVirusHurt_YOffset,X      ;Get vertical offset according to frame of the jump anim
        clc                      
        adc bigVirusYellow_YPos  
        sta spriteYPos           
        jsr metaspriteUpdate         
        lda spriteYPos           
        cmp bigVirusYellow_YPos         ;Only when back to its original position do we move on to the next state 
        bne @redUpdate           
    @yellowState_incTo2:     
        inc bigVirusYellow_state 
        lda #$00                 
        sta bigVirusYellow_frame 
        jmp @redUpdate           
    @yellowState_not1:                  ;Check if state 2
        cmp #spr_bigVirus_state_hurt_loop                    
        bne @yellowState_not2        
    @yellowState_is2:                   ;State 2 is the "loop" of the hurt, when agonizing on the floor 
        inc bigVirusYellow_frame 
        lda bigVirusYellow_frame        ;Check duration in frames to stay on the floor 
        cmp #spr_bigVirus_hurt_loop_duration                                    
        bne @yellowHurt_sfx_anim    
        lda #spr_bigVirus_state_alive   ;Temporarily set state back to alive
        sta bigVirusYellow_state 
        lda bigVirusYellow_health       ;If health > 0, we handle sfx and the anim for hurt
        bne @yellowHurt_sfx_anim    
    @yellowState_incTo3:                ;Otherwise, move on to "disappearing" state 
        lda #sq0_bigVirus_eradicated                       
        sta sfx_toPlay_sq0     
        lda #spr_bigVirus_state_disappearing                 
        sta bigVirusYellow_state 
        lda #$00                 
        sta bigVirusYellow_frame 
    @yellowHurt_sfx_anim:    
        lda #noise_bigVirus_hurt        ;Always play the hurt sfx for as long as on the floor + the frame when getting up
        sta sfx_toPlay_noise     
        lda frameCounter                ;Every 4 frames, change the sprite index
        and #spr_bigVirus_hurt_speed                         
        log2lsrA spr_bigVirus_hurt_speed
        ;lsr A                          ;This here is to reduce to a 0 or 1 index                    
        ;lsr A                    
        clc                      
        adc #spr_bigVirus_yellow_hurt_frame0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jmp @redUpdate           
    @yellowState_not2:                  ;Check if state 3
        cmp #spr_bigVirus_state_disappearing                    
        bne @redUpdate           
    @yellowState_is3:                   ;State 3 is the disappearing anim
        lda #spr_bigVirus_eradicated                     
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        inc bigVirusYellow_frame        ;Once 5 frames have passed, increase to state 4 (gone) 
        lda bigVirusYellow_frame 
        cmp #spr_bigVirus_disappear_duration                            
        bcc @redUpdate           
        inc bigVirusYellow_state 
    @redUpdate:                         ;Essentially identical to yellow update   
        lda bigVirusRed_XPos     
        sta spriteXPos           
        lda bigVirusRed_YPos     
        sta spriteYPos           
        lda bigVirusRed_state    
        bne @redState_not0       
    @redState_is0:           
        ldx danceFrame  
        lda bigVirus_spriteIndex+0,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda #$00                 
        sta bigVirusRed_frame    
        jmp @blueUpdate          
    @redState_not0:          
        cmp #spr_bigVirus_state_hurt_in                 
        bne @redState_not1       
    @redState_is1:           
        inc bigVirusRed_frame    
        lda #spr_bigVirus_red_hurt_frame0                 
        sta metaspriteIndex          
        ldx bigVirusRed_frame    
        lda bigVirusHurt_YOffset,X
        clc                      
        adc bigVirusRed_YPos     
        sta spriteYPos           
        jsr metaspriteUpdate         
        lda spriteYPos           
        cmp bigVirusRed_YPos     
        bne @blueUpdate          
    @redState_incTo2:        
        inc bigVirusRed_state    
        lda #$00                 
        sta bigVirusRed_frame    
        jmp @blueUpdate          
    @redState_not1:          
        cmp #spr_bigVirus_state_hurt_loop                 
        bne @redState_not2       
    @redState_is2:           
        inc bigVirusRed_frame    
        lda bigVirusRed_frame    
        cmp #spr_bigVirus_hurt_loop_duration                 
        bne @redHurt_sfx_anim    
        lda #spr_bigVirus_state_alive                 
        sta bigVirusRed_state    
        lda bigVirusRed_health   
        bne @redHurt_sfx_anim    
    @redState_incTo3:        
        lda #sq0_bigVirus_eradicated                 
        sta sfx_toPlay_sq0     
        lda #spr_bigVirus_state_disappearing                 
        sta bigVirusRed_state    
        lda #$00                 
        sta bigVirusRed_frame    
    @redHurt_sfx_anim:       
        lda #noise_bigVirus_hurt                 
        sta sfx_toPlay_noise     
        lda frameCounter         
        and #spr_bigVirus_hurt_speed
        log2lsrA spr_bigVirus_hurt_speed                 
        ;lsr A                    
        ;lsr A                    
        clc                      
        adc #spr_bigVirus_red_hurt_frame0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jmp @blueUpdate          
    @redState_not2:          
        cmp #spr_bigVirus_state_disappearing                 
        bne @blueUpdate          
    @redState_is3:           
        lda #spr_bigVirus_eradicated                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        inc bigVirusRed_frame    
        lda bigVirusRed_frame    
        cmp #spr_bigVirus_disappear_duration                 
        bcc @blueUpdate          
        inc bigVirusRed_state    
    @blueUpdate:                        ;Essentially identical to yellow update            
        lda bigVirusBlue_XPos    
        sta spriteXPos           
        lda bigVirusBlue_YPos    
        sta spriteYPos           
        lda bigVirusBlue_state   
        bne @blueState_not0      
    @blueState_is0:          
        ldx danceFrame  
        lda bigVirus_spriteIndex+4,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda #$00                 
        sta bigVirusBlue_frame   
        jmp @exit_bigVirusLvlAnim
    @blueState_not0:         
        cmp #spr_bigVirus_state_hurt_in                 
        bne @blueState_not1      
    @blueState_is1:          
        inc bigVirusBlue_frame   
        lda #spr_bigVirus_blue_hurt_frame0                 
        sta metaspriteIndex          
        ldx bigVirusBlue_frame   
        lda bigVirusHurt_YOffset,X
        clc                      
        adc bigVirusBlue_YPos    
        sta spriteYPos           
        jsr metaspriteUpdate         
        lda spriteYPos           
        cmp bigVirusBlue_YPos    
        bne @exit_bigVirusLvlAnim
    @blueState_incTo2:       
        inc bigVirusBlue_state   
        lda #$00                 
        sta bigVirusBlue_frame   
        jmp @exit_bigVirusLvlAnim
    @blueState_not1:         
        cmp #spr_bigVirus_state_hurt_loop                 
        bne @blueState_not2      
    @blueState_is2:          
        inc bigVirusBlue_frame   
        lda bigVirusBlue_frame   
        cmp #spr_bigVirus_hurt_loop_duration                 
        bne @blueHurt_sfx_anim   
        lda #spr_bigVirus_state_alive                 
        sta bigVirusBlue_state   
        lda bigVirusBlue_health  
        bne @blueHurt_sfx_anim   
    @blueState_incTo3:       
        lda #sq0_bigVirus_eradicated                 
        sta sfx_toPlay_sq0     
        lda #spr_bigVirus_state_disappearing                 
        sta bigVirusBlue_state   
        lda #$00                 
        sta bigVirusBlue_frame   
    @blueHurt_sfx_anim:      
        lda #noise_bigVirus_hurt                 
        sta sfx_toPlay_noise     
        lda frameCounter         
        and #spr_bigVirus_hurt_speed                 
        log2lsrA spr_bigVirus_hurt_speed                 
        ;lsr A                    
        ;lsr A                       
        clc                      
        adc #spr_bigVirus_blue_hurt_frame0                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jmp @exit_bigVirusLvlAnim
    @blueState_not2:         
        cmp #spr_bigVirus_state_disappearing                 
        bne @exit_bigVirusLvlAnim
    @blueState_is3:          
        lda #spr_bigVirus_eradicated                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        inc bigVirusBlue_frame   
        lda bigVirusBlue_frame   
        cmp #spr_bigVirus_disappear_duration                 
        bcc @exit_bigVirusLvlAnim
        inc bigVirusBlue_state   
    @exit_bigVirusLvlAnim:   
        rts                      


;;
;; titleDanceAnim [$8BF5]
;;
;; Makes Mario and the big blue virus groove to the beat of Tanaka's amazing music on the title screen
;;
titleDanceAnim:          
        lda musicBeatDuration           ;Same tempo calculation as in the level
        cmp musicFramesSinceLastBeat
        bcs @renderDanceAnim     
    @changeDanceFrame:       
        inc danceFrame           
        lda danceFrame           
        and #spr_bigVirus_dance_frames  ;Wraparound at 3 frames (zero-based anim is thus 4 frames long)        
        sta danceFrame           
        lda #$00                        ;Reset tempo calculation
        sta musicFramesSinceLastBeat
    @renderDanceAnim:                   ;First we start with the blue virus
        setSpriteXY spr_bigVirus_blue_title_x,spr_bigVirus_blue_title_y
        ;lda #spr_bigVirus_blue_title_x                         
        ;sta spriteXPos           
        ;lda #spr_bigVirus_blue_title_y                 
        ;sta spriteYPos           
        ldx danceFrame           
        lda bigVirus_spriteIndex+4,X    ;Points to the blue virus
        sta metaspriteIndex          
        jsr metaspriteUpdate            
        setSpriteXY spr_mario_title_x,spr_mario_title_y
        ;lda #spr_mario_title_x         ;Then we update Mario's upper body (not animated)        
        ;sta spriteXPos           
        ;lda #spr_mario_title_y                
        ;sta spriteYPos           
        lda #spr_mario_title  
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        lda danceFrame                  ;And finally his lower body (considered a seperate metasprite)
        and #spr_mario_dance_frames     ;Wraparound at $01 (2 frames anim) 
        clc                      
        adc #spr_mario_title_rightFoot_frame0
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        rts                      


;;
;; bigVirusAnim_lvlFail [$8C38]
;;
;; Rather straight forward routine to update the anim of virus laughing, copy paste 3 times, once for each big virus
;;
bigVirusAnim_lvlFail:
    @yellow_lvlFail:     
        lda bigVirusYellow_XPos  
        sta spriteXPos           
        lda bigVirusYellow_YPos  
        sta spriteYPos           
        lda frameCounter         
        and #spr_bigVirus_yellow_laughing_speed             ;Updates the animation every 4 frames     
        log2lsrA spr_bigVirus_yellow_laughing_speed 
        ;lsr A                                              ;Boil down to either 0 or 1 (and thus, 2 frames anim)
        ;lsr A                    
        tax                      
        lda bigVirusYellow_failLvl_spriteIndex,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @red_lvlFail:            
        lda bigVirusRed_XPos     
        sta spriteXPos           
        lda bigVirusRed_YPos     
        sta spriteYPos           
        lda frameCounter         
        and #spr_bigVirus_red_laughing_speed                ;Updates the animation every 8 frames (red is slower)     
        log2lsrA spr_bigVirus_red_laughing_speed 
        ;lsr A                    
        ;lsr A                    
        ;lsr A                    
        tax                      
        lda bigVirusRed_failLvl_spriteIndex,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @blue_lvlFail:           
        lda bigVirusBlue_XPos    
        sta spriteXPos           
        lda bigVirusBlue_YPos    
        sta spriteYPos           
        lda frameCounter         
        and #spr_bigVirus_blue_laughing_speed               ;Updates the animation every 4 frames    
        log2lsrA spr_bigVirus_blue_laughing_speed 
        ;lsr A                    
        ;lsr A                     
        tax                      
        lda bigVirusBlue_failLvl_spriteIndex,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        rts                      