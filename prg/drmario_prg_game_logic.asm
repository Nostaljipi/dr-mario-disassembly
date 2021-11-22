;;
;; action_pillPlaced [$8C7F]
;;
;; Jumps to the routine which is right after, seems redundant
;;
action_pillPlaced:
    if !optimize       
        jsr toPillPlacedStep     
        rts 
    endif 


;;
;; toPillPlacedStep [$8C83]
;;
;; Simple dispatcher, jumps to one of several routines according to a player's current step after a pill has just been placed
;;        
toPillPlacedStep:        
        lda currentP_pillPlacedStep
        jsr toAddressAtStackPointer_indexA
    @jumpTable_pillPlacedStep:
        .word resetCombo
    if !optimize
        .word incPillPlacedStep
        .word incPillPlacedStep
    endif 
        .word checkDrop
        .word resetMatchFlag
        .word checkHorMatch
        .word checkVerMatch
        .word updateField
        .word resetPillPlacedStep


;;
;; resetCombo [$8C9A]
;;
;; Simply resets the score multiplier
;;
resetCombo:              
        lda #$00                 
        sta currentP_scoreMultiplier
        inc currentP_pillPlacedStep
        rts                      


;;
;; incPillPlacedStep [$8CA1]
;;
;; Unsure what this routine is for
;;
incPillPlacedStep:
    if !optimize       
        inc currentP_pillPlacedStep
        rts 
    endif 


;;
;; checkDrop [$8CA4]
;;
;; This routine manages the "auto-drops" that occur after a match
;;
;; Local variables:
dropCounter=tmp47
fieldData_top=tmp48
fieldPointerOffset=tmp49
fieldPointerOffset_topLeft=tmp4A
fieldPointerOffset_left=tmp4B
fieldPointerOffset_top=tmp4C
checkDrop:               
        lda currentP_status         ;First check current player status, only if $FF are pills allowed to drop, otherwise exit this routine  
        cmp #$FF                 
        beq @checkDrop_initLoop  
        jmp @exit_checkDrop      
    @checkDrop_initLoop:     
        lda #$00                    ;Init drop counter and field pointer
        sta dropCounter                
        sta currentP_fieldPointer
        ldy #lastFieldPos                 
        sty fieldPointerOffset      ;Starts at the end and goes backward            
    @checkDrop_loop:         
        ldy fieldPointerOffset                
        lda (currentP_fieldPointer),Y 
        cmp #fieldPosJustEmptied    ;If not empty, then no drop possible
        bcs @fieldPosIsEmpty     
        jmp @fieldPosIsFinished  
    @fieldPosIsEmpty:        
        lda #fieldPosEmpty          ;Mark the field pos as empty ($FF)
        sta (currentP_fieldPointer),Y 
    if !optimize
        sta fieldData_top           ;Unsure this is needed since this variable is not read until next write
        lda config_pillsStayMidAir  ;Option only used in prototype normally, but functional here nonetheless
        bne @fieldPosIsFinished  
    ;endif 
    @pillsDontStayMidAir:    
        sty fieldPointerOffset      ;Don't think this is necessary, how can the value Y be different than tmp49 at this point?
    endif 
        tya                      
        sec                      
        sbc #rowSize                ;Substract 1 row to check what's on top
        tay                      
        lda (currentP_fieldPointer),Y 
        cmp #middleHorHalfPill      ;If middle hor pill / cleared pill / virus, nothing can drop
        bcs @fieldPosIsFinished  
        and #mask_fieldobject_type  ;Discard color information
        cmp #leftHalfPill           
        beq @fieldPosIsFinished  
        cmp #middleHorHalfPill      
        beq @fieldPosIsFinished     ;If is left or middle pill, we assuredly checked right half pill already, not dropping  
        cmp #rightHalfPill                 
        bne @verticalOrSinglePill_onTop ;If not a right half pill, then it must be vertical or single
    @rightHalfPill_onTop:    
        sty fieldPointerOffset_topLeft  ;Make copies of playfield position on top         
        sty fieldPointerOffset_top                
        lda fieldPointerOffset          ;Make copy of current playfield position 
        sta fieldPointerOffset_left                
    @nextPillHalf_toTheLeft: 
        dec fieldPointerOffset_topLeft  ;Offset to the left, for current and top row          
        dec fieldPointerOffset_left                
        ldy fieldPointerOffset_left     ;Then check position to the left             
        lda (currentP_fieldPointer),Y 
        cmp #fieldPosJustEmptied        ;If not empty, then no drop possible
        bcc @fieldPosIsFinished
    if !optimize  
    @posToLeftIsEmpty:       
        ldy fieldPointerOffset_topLeft  ;Get what's in position top-left, this is only necessary if pills are longer than 2              
        lda (currentP_fieldPointer),Y   
        and #mask_fieldobject_type                 
        cmp #leftHalfPill               ;Checks if the pill ends there with a left half pill      
        bne @nextPillHalf_toTheLeft     
    endif     
    @canDrop:                
        ldy fieldPointerOffset_top      ;Get what was on top
        lda (currentP_fieldPointer),Y 
        ldy fieldPointerOffset          ;Store it in current position      
        sta (currentP_fieldPointer),Y   
        lda #fieldPosEmpty              ;Store empty on top   
        ldy fieldPointerOffset_top                
        sta (currentP_fieldPointer),Y   
        lda fieldPointerOffset          ;Check if end of the dropping pill has been reached      
        cmp fieldPointerOffset_left                
        beq @fieldPosIsFinished         
        dec fieldPointerOffset          ;If not, loop till reached end of the pill 
        dec fieldPointerOffset_top                
        inc dropCounter                 
        lda #sq0_pill_remains_drop      ;Play dropping sfx                     
        sta sfx_toPlay_sq0     
        jmp @canDrop             
    @verticalOrSinglePill_onTop:
    if !optimize
        ldy fieldPointerOffset          ;First get a copy of what's on top                
        tya                             ;Why not lda directly here?    
    else 
        lda fieldPointerOffset
    endif 
        sec                      
        sbc #rowSize                 
        tay                      
        lda (currentP_fieldPointer),Y 
        sta fieldData_top                       
        lda #fieldPosEmpty              ;Then empty the position on top   
        sta (currentP_fieldPointer),Y   
        ldy fieldPointerOffset          ;Then store what was on top in the current position      
        lda fieldData_top                
        sta (currentP_fieldPointer),Y   
        inc dropCounter                 
        lda #sq0_pill_remains_drop      ;Play dropping sfx              
        sta sfx_toPlay_sq0     
    @fieldPosIsFinished:     
        dec fieldPointerOffset          ;Check previous position      
        ldy fieldPointerOffset                
        cpy #$FF                        ;Have we reached the end of the playfield? ($FF in this case would be a wraparound of $00)
        beq @checkDrop_finished  
        jmp @checkDrop_loop             ;If not, continue with checking the drops
    @checkDrop_finished:     
        lda #$0F                        ;Once we have checked all the field, update player status
        sta currentP_status      
        lda dropCounter                 ;Check if something in the field dropped
        beq @incPillPlacedStep   
    @decPillPlacedStep:                 ;If so, check all over again before moving on to next step
    if !optimize    
        dec currentP_pillPlacedStep
    endif 
        jmp @exit_checkDrop      
    @incPillPlacedStep:      
        inc currentP_pillPlacedStep     ;Otherwise, move to next step (which will eventually check for matches)
    @exit_checkDrop:         
        rts                              


;;
;; resetPillPlacedStep [$8D5F]
;;
;; Simply resets the pill placed step and increases to the next action
;;
resetPillPlacedStep:     
        lda #pillPlaced_resetCombo                 
        sta currentP_pillPlacedStep
        inc currentP_nextAction  
        rts                      


;;
;; action_pillFalling [$8D66]
;;
;; This handles the pill falling and movement by the player (through subroutines)
;;
action_pillFalling:
    if !optimize      
        lda currentP_virusToAdd         ;Checks if we need to add virus (which never occurs, probably a remnant from earlier build or even Tetris)
        beq @noVirusToAdd               
        inc currentP_nextAction  
        jmp @exit_action_pillFalling
    endif 
    @noVirusToAdd:           
        lda #$00                        ;Reset chain length    
        sta currentP_chainLength 
        jsr fallingPill_spriteUpdate    ;Handle movement through several subroutines
        jsr fallingPill_checkYMove
        jsr fallingPill_checkXMove
        jsr fallingPill_checkRotate
    @exit_action_pillFalling:
        rts                      


;;
;; fallingPill_checkYMove [$8D80]
;;
;; This handles the falling pill's y position changes (either through gravity or through player input), also includes anti-piracy
;;
fallingPill_checkYMove:  
        lda frameCounter         
        and #fast_drop_speed                 
        beq @checkGravity           ;Down button is only checked every 2 frames, change to bne if btn_down_drop_speed = $00
    @checkDownBtn
        lda currentP_btnsHeld    
        and #btns_dpad              ;Isolate d-pad         
        cmp #btn_down               ;This implies that ONLY down must be pressed on the d-pad for the fast drop to occur
        beq @lowerPillY          
    @checkGravity:           
        inc currentP_speedCounter   ;Down not pressed, get amount of frames (speed counter) spent at this vertical position so far
        lda currentP_speedUps       ;Then get the amount of frames which we must reach before dropping at the current level and speed
        sta currentP_speedIndex  
        ldx currentP_speedSetting
        lda baseSpeedSettingValue,X
        clc                      
        adc currentP_speedIndex  
        tax                      
        lda speedCounterTable,X
        cmp currentP_speedCounter   ;The speed counter must be over the data in the table for the gravity to occur
        bcs @exit_fallingPill_checkYMove    
    @lowerPillY:             
        dec currentP_fallingPillY   ;Decrease the pill's y position
        lda #$00                    ;Reset the speed counter
        sta currentP_speedCounter
        jsr pillMoveValidation      ;Checks if move is valid, returns zero if valid   
        bne @pillHasLanded          ;If can't move down anymore, the pill has landed
        lda currentP_fallingPillY   ;Otherwise, check if we try to go lower than the bottom, if so, the pill has landed
        cmp #$FF                 
        bne @exit_fallingPill_checkYMove
    @pillHasLanded:          
        inc currentP_fallingPillY   ;Returns Y to its previous value because it couldn't be lowered
        lda #sq0_pill_land          ;Play pill land sfx         
        sta sfx_toPlay_sq0       
        jsr confirmPlacement        ;"Print" (or "cement") the pill in position
    if !bypassChecksum
        lda flag_antiPiracy         ;Then checks if pirated    
        beq @notPirated          
    @pirated:                
        lda spriteIndex             ;If so, perform stack operation tha will make the game crash      
        pha                      
        pha                      
        pha 
    endif                       
    @notPirated:             
        inc currentP_nextAction     ;Increment to next action: action_pillPlaced
    if !optimize
        jmp @exit_fallingPill_checkYMove    ;This seems utterly unnecessary
    endif 
    @exit_fallingPill_checkYMove:
        rts                      


;;
;; fallingPill_checkXMove [$8DCF]
;;
;; This handles the falling pill's x position changes through player input
;;
fallingPill_checkXMove:  
        lda currentP_btnsPressed            ;First checks if left/right are being pressed/held
        and #btns_left_right                 
        bne @btnsPressed_move    
        lda currentP_btnsHeld    
        and #btns_left_right                 
        beq @exit_fallingPill_checkXMove
    @btnsHeld_move:                         
        inc currentP_horVelocity            ;If held, we increase the horizontal velocity
        lda currentP_horVelocity 
        cmp #hor_accel_speed                ;Takes 16 frames for initial build up of speed
        bmi @exit_fallingPill_checkXMove
        lda #hor_accel_speed - hor_max_speed    ;Then it takes 6 frames for subsequent movements
        sta currentP_horVelocity 
        jmp @checkInput_right    
    @btnsPressed_move:       
        lda #$00                            ;If btn was instead pressed, reset horizontal velocity                 
        sta currentP_horVelocity 
        lda #sq0_pill_moveX                 ;The sfx will play regardless if the pill can move or not (on btn PRESS only)
        sta sfx_toPlay_sq0       
    @checkInput_right:       
        lda currentP_btnsHeld               ;Check if the right button is being held (and consequently pressed)
        and #btn_right                 
        beq @checkInput_left     
    @checkBoundary_right:                   ;Check if pill is at the rightmost position ($06 or $07 depending if pill is horizontal or vertical)
        lda currentP_fallingPillRotation    
        and #$01                                        
        clc                      
        adc #lastColumn-1                 
        cmp currentP_fallingPillX           ;If pill already at full right, do not even check to validate movement
        beq @checkInput_left     
    @validateMove_right:     
        inc currentP_fallingPillX           ;Simulate movement to evaluate if it is valid
        jsr pillMoveValidation   
        bne @cantMove_right      
        lda #sq0_pill_moveX                 ;Plays the sfx again, in case the movement is a result of a btn HELD
        sta sfx_toPlay_sq0       
        jmp @checkInput_left                ;This implies that left and right movement at the same time are possible
    @cantMove_right:         
        dec currentP_fallingPillX           ;Restore the previous x value
        lda #hor_accel_speed-1              ;This makes so that as soon as the pill can move, it will move without delay with regard to velocity
        sta currentP_horVelocity 
    @checkInput_left:        
        lda currentP_btnsHeld               ;We perform the left check regardless if we did the right or not, meaning both buttons could be pressed at the same time
        and #btn_left                       ;Pretty much the same as the right counterpart 
        beq @exit_fallingPill_checkXMove
    @checkBoundary_left:
        lda currentP_fallingPillX           ;Boundary check is simpler since we don't have to account for pill rotation
        cmp #$00                             
        beq @exit_fallingPill_checkXMove
    @validateMove_left:      
        dec currentP_fallingPillX
        jsr pillMoveValidation   
        bne @cantMove_left       
        lda #sq0_pill_moveX                 
        sta sfx_toPlay_sq0       
        jmp @exit_fallingPill_checkXMove
    @cantMove_left:          
        inc currentP_fallingPillX           
        lda #hor_accel_speed-1                 
        sta currentP_horVelocity 
    @exit_fallingPill_checkXMove:
        rts                      


;;
;; fallingPill_checkRotate [$8E3B]
;;
;; Checks if player input a pill rotation and if such a rotation is possible
;;
;; Local variables:
currentP_fallingPillRotation_copy = tmp4A
currentP_fallingPillX_copy = tmp4B
fallingPill_checkRotate: 
        lda currentP_fallingPillRotation    ;First copy pill rotation and x in case we need to restore them (if can't rotate)
        sta currentP_fallingPillRotation_copy                
        lda currentP_fallingPillX
        sta currentP_fallingPillX_copy                
    @checkInput_A:           
        lda currentP_btnsPressed            ;Check if A pressed 
        and #btn_a                 
        beq @checkInput_B        
    @A_pressed:              
        lda #sq0_pill_rotate                ;Will play the sfx regardless if it can flip or not             
        sta sfx_toPlay_sq0       
        dec currentP_fallingPillRotation    ;Decrease rotation (which counterintuitively is a clockwise rotation)
        lda currentP_fallingPillRotation
        and #$03                            ;If we were to decrease to $FF, this sets it to $03
        sta currentP_fallingPillRotation
        jsr pillRotateValidation            ;Check and confirm/infirm rotation
    @checkInput_B:           
        lda currentP_btnsPressed            ;Basically same thing, but for B button with reverse rotation direction
        and #btn_b                          ;This implies here that if both A and B are pressed on the same frame, both will be taken into account
        beq @exit_fallingPill_checkRotate
    @B_pressed:              
        lda #sq0_pill_rotate                 
        sta sfx_toPlay_sq0       
        inc currentP_fallingPillRotation
        lda currentP_fallingPillRotation
        and #$03                 
        sta currentP_fallingPillRotation
        jsr pillRotateValidation 
    @exit_fallingPill_checkRotate:
        rts                      


;;
;; pillRotateValidation [$8E70]
;;
;; Confirms or infirms a pill rotation, also handles "wall kick" (aka trying to rotate next to something blocking)
;;
;; Input: (from routine fallingPill_checkRotate)
;;  currentP_fallingPillRotation_copy = tmp4A      
;;  currentP_fallingPillX_copy = tmp4B
;;
pillRotateValidation:    
        lda currentP_fallingPillRotation    ;First reduce to two states: vertical or horizontal
        and #$01                 
        bne @pill_wouldBeVertical_orWallKicked
    @pill_wouldBeHorizontal: 
        jsr pillMoveValidation              ;This will return zero if movement is valid
        bne @checkWallKick
        lda currentP_btnsHeld               ;We next check if left is pressed/held (this happens only when flipping from vertical to horizontal)
        and #btn_left                 
        beq @exit_pillRotateValidation
    @leftIsPressedAlso:      
        dec currentP_fallingPillX           ;Very curiously, this allows for a "double" movement to the left, because the isolated movement to the left was already processed in a previous routine
        jsr pillMoveValidation              ;It is arguable whether this should be there or not, as this can give an impression of inconsistent movement
        beq @exit_pillRotateValidation
    @cantDoDoubleLeft:       
        inc currentP_fallingPillX           ;If double left is not possible, we stick to single left
        jmp @exit_pillRotateValidation
    @checkWallKick: 
        dec currentP_fallingPillX           ;This here is the "wall kick", the offset to the left when trying to flip with something blocking to the right but not to the left
    @pill_wouldBeVertical_orWallKicked:   
        jsr pillMoveValidation              ;Check for vertical or wall kick depending
        beq @exit_pillRotateValidation
    @cantRotate:   
        lda currentP_fallingPillRotation_copy   ;Restore rotation and x values from before the rotation attempt
        sta currentP_fallingPillRotation
        lda currentP_fallingPillX_copy                
        sta currentP_fallingPillX
    @exit_pillRotateValidation:
        rts                      


;;
;; generateNextPill [$8E9D]
;;
;; Generates the next pill (either for player or demo), calculates the decimal pill counter, checks for speedups
;;
generateNextPill:        
        lda currentP_nextPill1stColor
        sta currentP_fallingPill1stColor
        lda currentP_nextPill2ndColor
        sta currentP_fallingPill2ndColor
    if !optimize
        lda currentP_nextPill3rdColor       ;Evidence that 4 halves were supported
        sta currentP_fallingPill3rdColor
        lda currentP_nextPill4thColor
        sta currentP_fallingPill4thColor
    endif 
        lda #$00                 
        sta currentP_fallingPillRotation
        lda currentP_nextPillSize           ;This should always be size 2
        sta currentP_fallingPillSize
        lda flag_demo                       ;Check if we are in demo mode    
        beq @notDemo      
    @isDemo:          
        ldx currentP_pillsCounter           ;Demo has its own pill reserve
        lda demo_pills,X                    ;The pill here is actually an index used to get colors from the following data 
        tax                      
        jmp @pillSelected        
    @notDemo:         
        ldx currentP_pillsCounter           ;If not demo, then use the player's pill reserve
        lda pillsReserve,X     
        tax                                 
    @pillSelected:           
        lda colorCombination_left,X         ;Get actual left and right colors from index
        sta currentP_nextPill1stColor
        lda colorCombination_right,X 
        sta currentP_nextPill2ndColor
        inc currentP_pillsCounter           ;Increase the pills counter
        lda currentP_pillsCounter
        and #pillsReserveSize-1             ;Wraparound over $7F because we have a maximum of 128 pills stored        
        sta currentP_pillsCounter
        lda #$00                            ;Reset pill thrown anim frame and rotation                 
        sta pillThrownFrame      
        sta currentP_nextPillRotation
        lda #defaultPillSize                ;Set size for next pill, only size 2 is supported                            
        sta currentP_nextPillSize
        lda #pillStartingX                  ;Set starting position for the falling pill                 
        sta currentP_fallingPillX
        lda #pillStartingY                 
        sta currentP_fallingPillY
        inc currentP_pillsCounter_decimal   ;We calculate the decimal equivalent of the pills counter, used to detect speedups at every 10 pills
    @checkPillCounter_tens:                 
        lda currentP_pillsCounter_decimal
        and #$0F                 
        cmp #$0A                 
        bcc @checkPillCounter_hundreds
    @increasePillsCounter_tens:
        lda currentP_pillsCounter_decimal
        clc                      
        adc #$06                 
        sta currentP_pillsCounter_decimal
    @checkPillCounter_hundreds:
        lda currentP_pillsCounter_decimal
        and #$F0                 
        cmp #$A0                
        bcc @checkPillCounter_thousands
    @increasePillsCounter_hundreds:
        lda currentP_pillsCounter_decimal
        clc                      
        adc #$60                 
        sta currentP_pillsCounter_decimal
        inc currentP_pillsCounter_hundreds  ;At some point in development, the nb of pills thrown was actually shown I think, which would explain why we compute hundreds as well
    @checkPillCounter_thousands:
    if !optimize
        lda currentP_pillsCounter_hundreds
        and #$0F                 
        cmp #$0A                 
        bcc @checkPillCounter_maxout
    @increasePillsCounter_thousands:
        lda currentP_pillsCounter_hundreds
        clc                      
        adc #$06                 
        sta currentP_pillsCounter_hundreds
    @checkPillCounter_maxout:
        lda currentP_pillsCounter_hundreds
        and #$F0                 
        cmp #$A0                 
        bcc @checkSpeedUp        
    @setPillsCounter_9999:   
        lda currentP_pillsCounter_hundreds  ;This addition here seems useless since we don't store the result  
        clc                      
        adc #$60
        lda #$99                 
        sta currentP_pillsCounter_decimal
        sta currentP_pillsCounter_hundreds
    @checkSpeedUp:        
        lda config_bypassSpeedUp            ;This option was selectable by players in earlier prototypes
        bne @resetComboCounter_thenRTS
    endif 
        lda currentP_pillsCounter_decimal
        cmp #$00                            ;Every time this is reset to $00 (only occurs on each 100 pills), check if we speed up
        beq @checkSpeedUp_max    
        and #$0F                            ;Every 10 pills, check if we speed up
        cmp #$00                 
        bne @resetComboCounter_thenRTS
    @checkSpeedUp_max:       
        lda currentP_speedUps    
        cmp #speedUps_max                   ;Prevents speed increase after 49 increases
        beq @resetComboCounter_thenRTS
    @speedUp:                
        inc currentP_speedUps               ;We speed up, play the associated sfx, 
        lda #sq0_speed_up                 
        sta sfx_toPlay_sq0       
    if !optimize
        lda visualUpdateFlags
        ora #vu_virusLeft+vu_lvlNb          ;Probably remnants from the past, because why would we want to update those visual specifically on speed up?
        ora #vu_lvlNb                       ;Definitely redundant
        sta visualUpdateFlags
    endif     
    @resetComboCounter_thenRTS:
        lda #$00                 
        sta currentP_comboCounter
        lda visualUpdateFlags               ;Flag pill for visual update
        ora #vu_pill                 
        sta visualUpdateFlags    
        rts                      


;;
;; confirmPlacement [$8F62]
;;
;; This takes a pill from its "sprite" state and confirms its placement, transforming it into tile
;;
;; Local variables
pill_fieldPos=tmp47
pillSize_tmpIndex=tmp48
halfPill_index=tmp49
halfPill_tile=tmp4A
confirmPlacement:        
        ldx currentP_fallingPillY           ;First get the pill's field position
        lda pill_fieldPos_relativeToPillY,X 
        clc                      
        adc currentP_fallingPillX
        sta pill_fieldPos
    if !optimize                
        lda currentP_fallingPillSize
        sec                      
        sbc #$02                 
        asl A                    
        asl A                    
        asl A                    
        asl A                    
        sta pillSize_tmpIndex               ;Would add an offset if pill size was bigger than 2, but this does strictly nothing with pills of size 2          
    endif 
        lda currentP_fallingPillRotation    ;Then get an index from the pill's rotation
        asl A                    
        asl A 
    if !optimize                    
        clc                      
        adc pillSize_tmpIndex
    endif                 
        tax                                 ;Store the rotation index in X and init halfpill index    
        lda #$00                 
        sta halfPill_index                
    @checkAllPillHalves_loop:               ;Next, get field position offsets for all halfpills in the pill (alway 2, but supports up to 4)
        lda halfPill_posOffset_rotationAndSizeBased,X 
        cmp #$63                            ;This code ($63) means pill is finished at this size
        beq @finishedRecordingPillToField
        clc                      
        adc pill_fieldPos                   
        sta currentP_fieldPointer           ;So this now holds the current half-pill correct position
        cmp #fieldSize                      ;If half pill is over the max playfield, don't record it (this is what makes half pills disappear when over the top row)
        bcs @postHalfPillPlacement
    @addHalfPillToField:     
        lda halfPill_shape_rotationAndSizeBased,X 
        clc                      
        sta halfPill_tile                
        ldy halfPill_index                  ;This holds the current number of the half pill we are treating, zero-based
        lda currentP_fallingPill1stColor,Y 
        clc                      
        adc halfPill_tile                   ;We add the color to the tile shape to get correct tile        
        ldy #$00                 
        sta (currentP_fieldPointer),Y       ;We finally add the pill to the field
    @postHalfPillPlacement:  
        inx                                 ;Check next half   
        inc halfPill_index                
        lda halfPill_index                
        cmp #maxPillSize                    ;This here is evidence of 4-length pills
        bne @checkAllPillHalves_loop
    @finishedRecordingPillToField:
        lda currentP_fallingPillY
        eor #$0F                 
        sta currentP_status                 ;Row indication from the status goes from top to bottom, as opposed to the falling pill Y
        rts                      


;;
;; storeStatsAndOptions [$8FB5]
;;
;; Copies stats and options to RAM to be restored later
;;
storeStatsAndOptions:    
        lda p1_victories                             
        sta p1_victories_tmp         
        lda p2_victories         
        sta p2_victories_tmp         
        lda p1_level             
        sta p1_level_tmp2  
        lda p2_level             
        sta p2_level_tmp2  
        lda p1_speedSetting      
        sta p1_speedSetting_tmp2 
        lda p2_speedSetting      
        sta p2_speedSetting_tmp2 
        rts                      


;;
;; restoreStatsAndOptions [$8FDA]
;;
;; Restores stats and options from RAM
;;
restoreStatsAndOptions:  
        lda p1_victories_tmp                    
        sta p1_victories         
        lda p2_victories_tmp         
        sta p2_victories         
        lda p1_level_tmp2  
        sta p1_level             
        lda p2_level_tmp2  
        sta p2_level             
        lda p1_speedSetting_tmp2 
        sta p1_speedSetting      
        lda p2_speedSetting_tmp2 
        sta p2_speedSetting      
        rts                      


;;
;; toMode4 [$8FFF]
;;
;; This here is the unreachable mode 6 that simply changes the mode to 4  
;;
if !removeMoreUnused
    toMode4:                 
            lda #mode_mainLoop_level                        
            sta mode                      
            rts                                 
endif


;;
;; scoreIncrease [$9004]
;;
;; Calculates the score increase when eliminating a virus. This is the routine that is responsible for glitching the game when big combos are performed
;;
scoreIncrease:           
        lda nbPlayers                   ;Check nb of players
        cmp #$01                 
        bne @exit_scoreIncrease         ;No score increase if 2 players
        ldx currentP_scoreMultiplier    ;Problem here is that the score combo multiplier is not capped, and so it can overflow
    if bugfix
        cmp #$0B
        bcc @getScoreMultipler
        ldx #$0A
    @getScoreMultipler
    endif 
        lda scoreMultiplier_table,X
        tax                         
    @addPoints_loop:                    ;Inefficient loop when big combos, causes the game to behave erratically (multiplier is actually the number of times this is going to loop)
        lda currentP_speedSetting       ;Score is impacted by speed setting (Low = 100, Med = 200, Hi = 300)
        clc                      
        adc score+1              
        sta score+1              
        inc score+1              
        jsr scoreIncrease_carry         ;This subroutine here adds to the inefficiency of the whole thing
        dex                      
        bne @addPoints_loop      
        lda visualUpdateFlags    
        ora #vu_pScore                    
        sta visualUpdateFlags    
        inc currentP_scoreMultiplier
    @exit_scoreIncrease:     
        rts                      


;;
;; scoreIncrease_carry [$902C]
;;
;; This subroutine checks all score digits one after the other to see if the have reached a value of 10
;;
scoreIncrease_carry:     
    if !optimize
        lda score+0                 ;First digit is actually the tens here, because there are no single points possible (in this version, score increase always a multiple of 100)
        cmp #$0A
        bmi @check2ndDigit       
    @1stDigit_over10:        
        sec                      
        sbc #$0A                 
        sta score+0              
        inc score+1              
    endif 
    @check2ndDigit:          
        lda score+1                   
        cmp #$0A                 
        bmi @check3rdDigit       
    @2ndDigit_over10:        
        sec                      
        sbc #$0A                 
        sta score+1              
        inc score+2              
    @check3rdDigit:          
        lda score+2              
        cmp #$0A                 
        bmi @check4thDigit       
    @3rdDigit_over10:        
        sec                      
        sbc #$0A                 
        sta score+2              
        inc score+3              
    @check4thDigit:          
        lda score+3              
        cmp #$0A                 
        bne @check5thDigit       
    @4thDigit_over10:        
        lda #$00                 
        sta score+3              
        inc score+4              
    @check5thDigit:          
        lda score+4              
        cmp #$0A                 
        bne @check6thDigit       
    @5thDigit_over10:        
        lda #$00                 
        sta score+4              
        inc score+5              
    @check6thDigit:          
        lda score+5              
        cmp #$0A                 
        bne @exit_scoreIncrease_carry
    @6thDigit_over10:        
        dec score+5                     ;The 6th digit maxes out at 9, while all other digits wraparound to zero (so technically, after 9,999,999 we roll back to 9,000,000)
    @exit_scoreIncrease_carry:
        rts                      


;;
;; p1RAM_toCurrentP [$9085]
;;
;; Copies the $30 bytes of player 1 RAM to current player RAM + controller input
;;
p1RAM_toCurrentP:        
        ldx #$00                 
    @p1RAM_toCurrentP_loop:  
        lda p1_RAM,X          
        sta currentP_RAM,X    
        inx                      
        cpx #playerRAMsize                  ;$30 times
        bne @p1RAM_toCurrentP_loop
    @p1_copyBtns:            
        lda p1_btns_pressed      
        sta currentP_btnsPressed 
        lda p1_btns_held         
        sta currentP_btnsHeld    
        lda #$00                            ;Resets field pointer
        sta currentP_fieldPointer
        lda #player1                 
        sta currentP             
        rts                      


;;
;; p2RAM_toCurrentP [$90A2]
;;
;; Same as for player 1
;;
p2RAM_toCurrentP:        
        ldx #$00                 
    @p2RAM_toCurrentP_loop:  
        lda p2_RAM,X          
        sta currentP_RAM,X    
        inx                      
        cpx #playerRAMsize                 
        bne @p2RAM_toCurrentP_loop
    @p2_copyBtns:            
        lda p2_btns_pressed      
        sta currentP_btnsPressed 
        lda p2_btns_held         
        sta currentP_btnsHeld    
        lda #$00                 
        sta currentP_fieldPointer
        lda #player2                 
        sta currentP             
        rts                      


;;
;; currentP_toP1 [$90BF]
;;
;; Return current player ram ($30 bytes) to player 1 ram
;;
currentP_toP1:           
        ldx #$00                 
    @currentP_toP1_loop:     
        lda currentP_RAM,X    
        sta p1_RAM,X          
        inx                      
        cpx #playerRAMsize                 
        bne @currentP_toP1_loop  
        rts                      


;;
;; currentP_toP2 [$90CC]
;;
;; Same as for player 1
;;
currentP_toP2:           
        ldx #$00                 
    @currentP_toP2_loop:     
        lda currentP_RAM,X    
        sta p2_RAM,X          
        inx                      
        cpx #playerRAMsize                 
        bne @currentP_toP2_loop  
        rts                      


;;
;; initField_bothPlayers [$90D9]
;;
;; Makes both player fields empty
;;
initField_bothPlayers:   
        lda #fieldPosEmpty                 
        ldx #>p1_field                             
        ldy #>p2_field                 
        jsr copy_valueA_fromX00_toY00_plusFF
        rts                      


;;
;; pillMoveValidation [$90E3]
;;
;; This routine returns whether or not a "simulated" move is valid
;;
;; Returns:
;;  A: true ($00) or false ($FF)
;;
;; Local variables:
fieldPos_sim                =tmp47
fieldValidation_loop_nb     =tmp48
pillSize_indexOffset_sim    =tmp49
pillMoveValidation:      
    if !optimize
        ldx currentP_fallingPillSize            ;Always set to 2, so X always equals 0... furthermore, we don't actually need thix x value here since it would only be used in places that can be optimized            
        dex                      
        dex 
    endif                       
        lda currentP_fallingPillRotation
        and #$01                                ;Pill is vertical if rotation is $01 or $03
        bne @pill_isVertical     
    @pill_isHorizontal:      
    if !optimize
        lda horPillBoundaries_leftHalf,X        ;The pill size is used as an offset to check the pill boundaries
        clc                      
        adc currentP_fallingPillX               ;Checks if we have reached the boundaries of the bottle, according to pill size
    else 
        lda currentP_fallingPillX               ;Can directly load the falling pill's x if pill size is always set to 2
    endif     
        bmi @cantMove
    if !optimize            
        lda horPillBoundaries_rightHalf,X
    else 
        lda #$F9
    endif 
        clc                      
        adc currentP_fallingPillX
        bpl @cantMove            
        jmp @prepFieldValidation 
    @pill_isVertical:        
    if !optimize
        lda verPillBoundaries,X                 ;Checks if we have reached the bottom
        clc                      
        adc currentP_fallingPillY
    else 
        lda currentP_fallingPillY               ;Can directly load the falling pill's y if pill size is always set to 2
    endif 
        bmi @cantMove            
    @prepFieldValidation:    
        lda #$00                 
        sta currentP_fieldPointer
        ldx currentP_fallingPillY
        lda pill_fieldPos_relativeToPillY,X
        clc                      
        adc currentP_fallingPillX
        sta fieldPos_sim                        ;This here gives us the current field pos of the pill
    if !optimize
        lda currentP_fallingPillSize            ;Always set to 2
        sec                      
        sbc #$02                 
        asl A                    
        sta pillSize_indexOffset_sim
    endif                
        lda currentP_fallingPillRotation
        and #$01
    if !optimize                
        clc                      
        adc pillSize_indexOffset_sim
    endif                
        asl A                    
        asl A                    
        tax                      
        lda #$04                                ;Still here evidence that there could be 4-long pills
        sta fieldValidation_loop_nb                
    @fieldValidation_loop:   
        lda relativeFieldPos_halfPills_rotationAndSizeBased,X
        clc                                     ;This loops through all field positions occupied by the pill to see if all of them are empty
        adc fieldPos_sim                
        tay                      
        lda (currentP_fieldPointer),Y
        cmp #fieldPosEmpty                      
        bne @cantMove            
        inx                      
        dec fieldValidation_loop_nb                
        bne @fieldValidation_loop
    @canMove:                
        lda #true                               ;If all conditions are met, return true 
        rts                             
    @cantMove:               
        lda #false                 
        rts                      


;;
;; getInputs_checkMode [$9144]
;;
;; Either gets player inputs, or manages the demo cpu inputs (this is called during NMI). Also includes non-functional code for recording player input in order to play them back during demo.
;; 
;; Local variables:
demo_inputs_next = tmp47
getInputs_checkMode:                
        lda flag_demo               ;First checks if we are in the demo, if not, then simply get inputs and RTS 
        bne @demoFlag_set        
        jsr getInputs           
        rts                      
    @demoFlag_set:                  ;Then check if we are in "record mode" (which is not functional on regular hardware since it tries to record in a rom address)  
    if !optimize
        lda flag_demo            
        cmp #flag_demo_record                 
        beq @recordDemoInputs 
    endif 
    @inDemo:                 
        jsr getInputs               ;Otherwise, we are in demo mode. Get inputs.
        lda p1_btns_pressed         ;If start is pressed, reset demo move pointer and exit 
        cmp #btn_start                 
        beq @resetDemoMovePointer
    @startNotPressed:        
        lda counterDemoInstruction  ;A counter is set, and then decreases every frame until clear, then we check the next demo input
        beq @nextDemoInstruction 
    @decreaseCounterDemoInstruction:
        dec counterDemoInstruction
        jmp @initBtnsPressed     
    @nextDemoInstruction:    
        ldx #$00                    ;Instructions are pairs of bytes, first is the demo inputs (btns held by the cpu at this precise moment), second is the duration of this input state until it changes           
        lda (ptr_demoInstruction_low,X)
        sta demo_inputs_next                
        jsr increaseDemoInstructionPointer
        lda demo_inputs          
        eor demo_inputs_next                
        and demo_inputs_next        ;Performs a manipulation so that btns pressed exclude the btns that were previously pressed (and still are) so that they become instead btns held 
        sta p1_btns_pressed      
        lda demo_inputs_next                
        sta demo_inputs          
        ldx #$00                    ;Demo instruction now points toward counter before next instruction (through previous jsr increaseDemoInstructionPointer)      
        lda (ptr_demoInstruction_low,X)
        sta counterDemoInstruction
        jsr increaseDemoInstructionPointer
        lda ptr_demoInstruction_high    ;Check if we have reached the max address of demo instructions
        cmp #>(demo_instructionSet+512)     
        beq @exitDemo               ;Reached end of demo instructions
        jmp @storeBtnsHeld_untilNextInstruction
    @initBtnsPressed:        
        lda #$00                    ;Btns pressed are cleared when a frame passes without changes in cpu input state 
        sta p1_btns_pressed      
    @storeBtnsHeld_untilNextInstruction:
        lda demo_inputs          
        sta p1_btns_held            ;Cpu inputs become buttons held until a change in input state        
        rts                             
    @exitDemo:               
        lda #mode_toTitle           ;Return to title when end of demo instructions are reached         
        sta mode                 
        rts                             
    @resetDemoMovePointer:   
        lda #>demo_instructionSet   ;Resets demo instruction high byte pointer when start is pressed and we exit demo mode 
        sta ptr_demoInstruction_high
        rts 
if !optimize                              
    @recordDemoInputs:       
        jsr getInputs               ;This routine was (probably) used during development to record inputs from a player to playback during demo
        lda p1_btns_held            ;Can probably safely be deleted   
        cmp demo_inputs          
        beq @noInputChanges      
    @storeInputChange:       
        ldx #$00                 
        lda demo_inputs          
        sta (ptr_demoInstruction_low,X)
        jsr increaseDemoInstructionPointer
        lda counterDemoInstruction
        sta (ptr_demoInstruction_low,X)
        jsr increaseDemoInstructionPointer
        lda ptr_demoInstruction_high
        cmp #>(demo_instructionSet+512)                 
        beq @stopRecording       
    @prepareNextInstruction: 
        lda p1_btns_held         
        sta demo_inputs          
        lda #$00                 
        sta counterDemoInstruction
        rts                             
    @noInputChanges:         
        inc counterDemoInstruction
        rts                              
    @stopRecording:          
        lda #$00                 
        sta ptr_demoInstruction_low
        sta mode                 
        rts 
endif                       


;;
;; increaseDemoInstructionPointer [$91D2]
;;
;; Simple helper routine that increases the 2-byte demo instruction pointer
;;
increaseDemoInstructionPointer:
        lda ptr_demoInstruction_low
        clc                      
        adc #$01                 
        sta ptr_demoInstruction_low
        lda #$00                        ;"A" now holds carry if ptr_demoInstruction_low overflows
        adc ptr_demoInstruction_high
        sta ptr_demoInstruction_high
        rts                      


;;
;; antiPiracy_checksum [$91E0]
;;
;; Checksum to prevent hacking the rom
;;
;; Local variables:
checksumAddr_lo_start   = tmp47
checksumAddr_hi         = tmp48
checksum                = tmp49
if !bypassChecksum
antiPiracy_checksum:     
        lda #>checksumAddr_start                 
        sta checksumAddr_hi                
        ldy #<checksumAddr_start                 
        sty checksumAddr_lo_start       ;So start address for checksum is $B900, and it ends at $BDFF      
        sty checksum                    ;Checksum starts at $00 
        sty flag_antiPiracy             ;Init anti pircay flag
    @checksum_loop:          
        lda (checksumAddr_lo_start),Y   ;Continously add values from $00 to $FF         
        clc                      
        adc checksum                
        sta checksum                
        iny                      
        bne @checksum_loop       
        inc checksumAddr_hi             ;Every $100 bytes, increase the higher byte for the checksum address     
        lda checksumAddr_hi                
        cmp #>checksumAddr_end                 
        bne @checksum_loop       
        lda checksum                    ;Once we reach $BDFF, value in checksum (tmp49) has to be $98, otherwise it is pirated      
        cmp #checksumValue                 
        beq @exit_antiPiracy_checksum
    @isPirated:           
        lda #$FF        
        sta flag_antiPiracy      
    @exit_antiPiracy_checksum:
        rts
endif                       


;;
;; checkHorMatch [$920B]
;;
;; Checks if there is any horizontal match to process and clear, from top left to bottom right, row by row
;;
;; Local variables:
colorChain      = tmp47
startingColor   = tmp48
fieldPos_last   = tmp49
checkHorMatch:
    if !optimize           
        lda currentP_matchFlag      ;Checks if there are matches stored (there never seems to be since this is always reset on the step just before)
        beq @noMatchInMemory     
    @matchInMemory:          
        lda currentP_status         ;Unsure how it would be possible to get here
        cmp #$FF                 
        beq @noMatchInMemory     
        jmp @exit_checkHorMatch  
    endif 
    @noMatchInMemory:        
        lda #$00                 
        sta fieldPos                ;Will check field pos from top left to bottom right, row after row     
    @checkHorMatch_loop:     
        lda fieldPos             
        sta fieldPos_tmp         
        lda #$00                    ;Init color chain      
        sta colorChain                
        ldy fieldPos             
        lda (currentP_fieldPointer),Y
        sta startingColor           ;Holds the sprite at current field pos
        cmp #fieldPosJustEmptied    ;If it's empty, no match possible
        bcc @isolateColor_hor    
        jmp @nextFieldPos        
    @isolateColor_hor:       
        lda startingColor           ;Otherwise, isolate color     
        and #mask_fieldobject_color                    
        sta startingColor                
    @checkHorColorChain_loop:
        inc fieldPos_tmp            ;Checks next horizontal
        lda fieldPos_tmp         
        and #lastColumn             ;Check if reached right end of bottle
        beq @horColorChainBroken 
        ldy fieldPos_tmp            ;Get next horizontal
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        cmp startingColor           ;Is it the same color as the first one I checked
        bne @horColorChainBroken 
        inc colorChain              ;If so, increase color chain and check next in line 
        jmp @checkHorColorChain_loop
    @horColorChainBroken:    
        lda colorChain                   
        cmp #match_length-1         ;Checks if enough for a match (does not include the starting color, which explains the "-1")         
        bmi @nextFieldPos_colorChainBreak
    @horMatchOccured:        
        inc currentP_comboCounter   ;Increase combo counter and store color chain length
        sta currentP_chainLength_0based
        jsr updateAttackColor       ;Update colors stored for attack on opponent (even though this does not necessarily combo)
        lda currentP_chainLength    ;Most likely this is at $00 at this point
        clc                      
        adc colorChain                
        sta currentP_chainLength 
        inc currentP_chainLength    ;Make this value not zero-based
    if !optimize
        lda fieldPos             
        and #mask_fieldPos_row      ;Isolate row
        lsr A                    
        lsr A                    
        lsr A                    
        sta currentP_chainStartRow  ;Dont think this value is ever used
    endif 
        lda fieldPos_tmp         
        sta fieldPos_last                
        lda fieldPos             
        sta fieldPos_tmp            ;fieldPos_tmp here becomes the first position of the match, whereas fieldPos_last becomes the last   
    if bugfix
        lda #sq0_pills_cleared      ;if this was moved before @clearHorChain_loop, this would (maybe) fix the bug where the pill clear sfx plays even when a virus is eliminated 
        sta sfx_toPlay_sq0   
    endif 
    @clearHorChain_loop:     
        ldy fieldPos_tmp         
    if !optimize
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #singleHalfPill         ;Checks if single half pill
        bne @playPillClearSfx       ;Looks like there is a bug here, because branching assuredly all lead to same place
    endif 
    @playPillClearSfx:       
    if !bugfix
        lda #sq0_pills_cleared      ;if this was moved before @clearHorChain_loop, this would (maybe) fix the bug where the pill clear sfx plays even when a virus is eliminated 
        sta sfx_toPlay_sq0       
    endif 
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #virus                  ;Checks if a virus
        bne @changeSpriteToCleared_hor
    @isAVirus_hor:           
        lda #sq0_virus_cleared      ;If so, play the appropriate sfx               
        sta sfx_toPlay_sq0       
        jsr virusDestroyed          ;Handle virus destruction (and outcomes)   
        lda #vu_virusLeft           ;Update virus left      
        ora visualUpdateFlags    
        sta visualUpdateFlags    
        lda currentP_virusLeft      ;Check if there are still viruses left  
        bne @changeSpriteToCleared_hor
        inc currentP_victories      ;If not, victory (since this is done for each player, in 2-player mode, this is why we can have DRAW)
    @changeSpriteToCleared_hor:
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color         ;Isolate color                 
        ora #clearedPillOrVirus             ;Transforms sprite into matched pill/virus       
        sta (currentP_fieldPointer),Y
        inc fieldPos_tmp                    ;Increase to next horizontal
        ldy fieldPos_tmp         
        cpy fieldPos_last                   ;Check if reached the end of the color chain
        bne @clearHorChain_loop  
        inc currentP_matchFlag              ;Make it known that there was a match (needed for the updateField routine)
        lda fieldPos_last                
        sta fieldPos_tmp                    ;Restore tmp to end of color chain
    @nextFieldPos_colorChainBreak:
        lda fieldPos_tmp         
        sta fieldPos                        ;And finally restore current field position so that it's the same as tmp
        jmp @checkReach_rightLimit
    @nextFieldPos:           
        inc fieldPos             
    @checkReach_rightLimit:  
        lda fieldPos                        ;Check a couple boundaries
        and #lastColumn                     
        beq @checkReach_endField            ;If zero, we just started a new row, make sure we're still in the field
        cmp #lastColumn_forMatch+1          ;If 5 or more, stop checking, we know it is not possible to have a hor match
        bpl @checkReach_endField 
        jmp @checkHorMatch_loop             ;Continue checking for a match if not past the limit
    @checkReach_endField:    
        lda fieldPos                        ;Otherwise, check if we reach the end of the field
        cmp #fieldSize                 
        beq @incPillPlacedStep_thenRTS
    @checkReach_rightLimit_again:
        and #lastColumn                     ;Check again so that we prevent increasing to next row if we just increased to a new row
        beq @checkReach_endField_again      
    @nextRow:                
        lda fieldPos             
        and #mask_fieldPos_row              ;Isolate current row
        clc                      
        adc #rowSize                        ;Then add $08 to get to start of next row
        sta fieldPos             
    @checkReach_endField_again:
        lda fieldPos                        ;Check if we reached end of field after increasing the row
        cmp #fieldSize                 
        beq @incPillPlacedStep_thenRTS
        jmp @checkHorMatch_loop             ;For as long as we have not reached the end of the field, keep looping to find matches
    @incPillPlacedStep_thenRTS:
        inc currentP_pillPlacedStep         ;Inc to pillPlaced_checkVerMatch
    @exit_checkHorMatch:        
        rts                      


;;
;; updateField[$92EB]
;;
;; This updates the state of all objects in the field (ex: after a match). Does not move them, simply updates their visual.
;; This is what "breaks down" pills into individual halves following a match of either half of the pill
;;
;; Local variables:
fieldPos_pointer    = tmp47
updateField:             
        ldy #lastFieldPos                   ;Field size-1
        sty fieldPos_pointer                
    @checkMatchedVirusOrPill:
        ldy fieldPos_pointer                ;Checks from the end (bottom right) and rewinds row after row
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type          ;Isolate type of sprite
        cmp #clearedPillOrVirus             ;Check if a match just occured on this field position                 
        bne @checkTopHalfPill    
    @isMatchedVirusOrPill:   
        lda (currentP_fieldPointer),Y
        ora #fieldPosJustEmptied            ;Makes the pill disappears (displays the empty color "circle")
        sta (currentP_fieldPointer),Y
        jmp @moveToPreviousFieldPos
    @checkTopHalfPill:       
        cmp #topHalfPill                    ;Check if what's in field pos is a top half pill             
        bne @checkBottomHalfPill 
    @isTopHalfPill:          
        lda fieldPos_pointer                ;If so, check what's below
        clc                      
        adc #rowSize                 
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type
    if !optimize                 
        cmp #middleVerHalfPill              ;Evidence here that pills size longer than 2 were supported             
        beq @staysTopHalfPill
    endif  
        cmp #bottomHalfPill                 ;Checks if attached to other half, if not, transform into single pill
        beq @staysTopHalfPill 
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
    @staysTopHalfPill:    
        jmp @moveToPreviousFieldPos
    @checkBottomHalfPill:    
        cmp #bottomHalfPill                 ;Pretty much the same principle as for top half pill
        bne @checkLeftHalfPill   
    @isBottomHalfPill:       
        lda fieldPos_pointer                
        sec                      
        sbc #rowSize                 
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type 
    if !optimize                
        cmp #middleVerHalfPill                 
        beq @staysBottomHalfPill
    endif 
        cmp #topHalfPill                 
        beq @staysBottomHalfPill
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
    @staysBottomHalfPill: 
        jmp @moveToPreviousFieldPos
    @checkLeftHalfPill:      
        cmp #leftHalfPill                   ;Again very similar principle for both horizontal halves    
        bne @checkRightHalfPill  
    @isLeftHalfPill:         
        lda fieldPos_pointer                                
        clc                      
        adc #$01                            ;Check position to the right
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type
    if !optimize                 
        cmp #middleHorHalfPill                 
        beq @staysLeftHalfPill
    endif 
        cmp #rightHalfPill                 
        beq @staysLeftHalfPill
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
    @staysLeftHalfPill:   
        jmp @moveToPreviousFieldPos
    @checkRightHalfPill:     
        cmp #rightHalfPill                 
        bne @checkMiddleVerPill  
    @isRightHalfPill:        
        lda fieldPos_pointer                
        sec                         
        sbc #$01                            ;Check position to the left
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type
    if !optimize                 
        cmp #middleHorHalfPill                 
        beq @staysRightHalfPill
    endif 
        cmp #leftHalfPill                 
        beq @staysRightHalfPill
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
    @staysRightHalfPill:  
        jmp @moveToPreviousFieldPos
    @checkMiddleVerPill:     
    if !optimize
        cmp #middleVerHalfPill              ;This whole section supports for pill length higher than 2 (which has "middle" half pills)                        
        bne @checkMiddleHorPill  
    @isMiddleVerPill:        
        lda fieldPos_pointer                
        sec                      
        sbc #rowSize                        ;Check what's on top     
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #middleVerHalfPill                 
        beq @checkChangeToBottomHalfPill
        cmp #topHalfPill                 
        beq @checkChangeToBottomHalfPill
    @changeToTopHalfPill:    
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #topHalfPill                 
        sta (currentP_fieldPointer),Y
    @checkChangeToBottomHalfPill:
        lda fieldPos_pointer                
        clc                      
        adc #rowSize                        ;Check what's beneath        
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #middleVerHalfPill                 
        beq @staysMiddleVerPill
        cmp #bottomHalfPill                 
        beq @staysMiddleVerPill
    @changeToBottomHalfPill: 
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #bottomHalfPill                 
        sta (currentP_fieldPointer),Y
    @staysMiddleVerPill:  
        jmp @moveToPreviousFieldPos
    @checkMiddleHorPill:     
        cmp #middleHorHalfPill                 
        bne @moveToPreviousFieldPos
    @isMiddleHorPill:        
        lda fieldPos_pointer                
        sec                      
        sbc #$01                            ;Check what's to the left          
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #middleHorHalfPill                 
        beq @checkChangeToRightHalfPill
        cmp #leftHalfPill                 
        beq @checkChangeToRightHalfPill
    @changeToLeftHalfPill:   
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #leftHalfPill                 
        sta (currentP_fieldPointer),Y
    @checkChangeToRightHalfPill:
        lda fieldPos_pointer                
        clc                      
        adc #$01                            ;Check what's to the right          
        tay                         
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #middleHorHalfPill                 
        beq @moveToPreviousFieldPos
        cmp #rightHalfPill                 
        beq @moveToPreviousFieldPos
    @changeToRightHalfPill:  
        ldy fieldPos_pointer                
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #rightHalfPill                 
        sta (currentP_fieldPointer),Y
    endif 
    @moveToPreviousFieldPos: 
        dec fieldPos_pointer                
        lda fieldPos_pointer                
        cmp #$FF                        ;If we decreased from $00 to $FF, this means we are done
        beq @finishedUpdatingField
        jmp @checkMatchedVirusOrPill
    @finishedUpdatingField:  
        inc currentP_pillPlacedStep     ;Increase to resetPillPlacedStep
        lda #$0F                        ;Set status to last row checked
        sta currentP_status      
        lda currentP_matchFlag          ;Check if there was a match (and thus if we need to process drops and further field update)
        beq @exit_updateField
    if !optimize    
        lda #pillPlaced_nextStep1       ;If there was a match, we need to update the field again to process the impacts of this match (ex: pill drops)
    else 
        lda #pillPlaced_checkDrop
    endif 
        sta currentP_pillPlacedStep
    @exit_updateField:       
        rts                      


;;
;; resetMatchFlag [$9423]
;;
;; Resets the match flag and increases to next pill placed step
;;
resetMatchFlag:          
        lda #$00                 
        sta currentP_matchFlag   
        inc currentP_pillPlacedStep     ;Increase to checkHorMatch
        rts                      


;;
;; virusDestroyed [$942A]
;;
;; Puts the big virus animation in "hurt mode" (done regardless if 1 or 2 player), increases score and decreases nb of virus left
;;
virusDestroyed:          
        lda (currentP_fieldPointer),Y   ;Get color, store in x as an index for which big virus      
        and #mask_fieldobject_color     
        tax                      
        lda #spr_bigVirus_state_hurt_in ;Change the corresponding big virus state to "jump hurt"                
        sta bigVirusYellow_state,X      
        lda #$00                        ;Reset animation frame
        sta bigVirusYellow_frame,X
        lda bigVirusYellow_health,X     ;Substract 1 from big virus health
        sec                      
        sbc #$01                 
        sta bigVirusYellow_health,X
        jsr scoreIncrease               ;Update score
    if !optimize
        lda currentP_virusLeft          ;Checks if any virus left (strangely, this is performed before the decrease, which means this will never be zero)
        beq @changeStatus
    endif         
        dec currentP_virusLeft          ;If there are virus left, decrease by 1
        lda currentP_virusLeft   
        and #$0F                        ;The value is decimal based so the following handles this
        cmp #$0F                 
        bne @changeStatus        
        lda currentP_virusLeft   
        sec                      
        sbc #$06                        ;Removes 6 in case we just went from, for exemple, $10 virus to $0F virus, so that we now have $09 and effectively stay in "decimal"
        sta currentP_virusLeft   
    @changeStatus:           
        lda #$0F                 
        sta currentP_status      
        rts                      


;;
;; updateAttackColor [$945B]
;;
;; This decides if we update the "attack reserve", and with which color
;;
;; Input
;;  startingColor = tmp48 (from checkHorMatch / checkVerMatch)
;;
updateAttackColor:       
        lda currentP_comboCounter       ;Check if there is a combo
        beq @exit_updateAttackColor
        cmp #attackSize_max+1           ;Any combo that goes over 4 does not register any more attacks   
        bcs @exit_updateAttackColor
        tax                             ;If combo is registered for attack, use the combo counter as index for the attack reserve
        dex                                      
        lda startingColor               ;Latest match color is used to send opponent
        sta currentP_attackColors,X
    @exit_updateAttackColor: 
        rts                      


if !removeUnused     
    checkComboCounterForAttack_UNUSED:
            lda currentP_comboCounter       ;Unused alternative to the routine checkComboCounterForAttack (the real routine resets the comboCounter at the end)
            cmp #$02                 
            bne @exit_checkComboCounterForAttack_UNUSED
            lda currentP             
            sec                      
            sbc #$03                 
            sta sfx_toPlay_sq0_sq1   
        @exit_checkComboCounterForAttack_UNUSED:
            rts                      
endif


;;
;; checkVerMatch [$9479]
;;
;; Checks if there is any vertical match to process and clear, column after column, from left to right, starting on top
;; Very similar to the checkHorMatch routine.
;;
;; Local variables: (same as for checkHorMatch)
;;  colorChain      = tmp47
;;  startingColor   = tmp48
;;  fieldPos_last   = tmp49
;;
checkVerMatch:           
        lda #$00                    ;Very similar to checkHorMatch, differences in commentaries     
        sta fieldPos
    @checkVerMatch_loop:     
        lda fieldPos                  
        sta fieldPos_tmp         
        lda #$00                 
        sta colorChain                
        ldy fieldPos             
        lda (currentP_fieldPointer),Y
        sta startingColor                
        cmp #fieldPosJustEmptied                 
        bcc @isolateColor_ver    
        jmp @nextVerFieldPos     
    @isolateColor_ver:       
        lda startingColor                
        and #mask_fieldobject_color                 
        sta startingColor                
    @checkVerColorChain_loop:
        lda fieldPos_tmp         
        clc                      
        adc #rowSize                ;Checks next vertical 
        sta fieldPos_tmp         
        lda fieldPos_tmp         
        and #mask_fieldPos_row_alt  ;Check if reached bottom
        beq @verColorChainBroken 
        ldy fieldPos_tmp         
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        cmp startingColor           
        bne @verColorChainBroken 
        inc colorChain                
        jmp @checkVerColorChain_loop
    @verColorChainBroken:    
        lda colorChain                
        cmp #match_length-1
        bmi @nextVerFieldPos_colorChainBreak
    @verMatchOccured:        
        inc currentP_comboCounter
        sta currentP_chainLength_0based
        jsr updateAttackColor    
        lda currentP_chainLength 
        clc                      
        adc colorChain                
        sta currentP_chainLength 
        inc currentP_chainLength
    if !optimize 
        lda fieldPos             
        and #mask_fieldPos_row                 
        lsr A                    
        lsr A                    
        lsr A                    
        sta currentP_chainStartRow
    endif 
        lda fieldPos_tmp         
        sta fieldPos_last                
        lda fieldPos             
        sta fieldPos_tmp
    if bugfix
        lda #sq0_pills_cleared                 
        sta sfx_toPlay_sq0  
    endif               
    @clearVerChain_loop:
    if !bugfix     
        lda #sq0_pills_cleared      ;Not exactly at same place than for horMatch, but has the same effect             
        sta sfx_toPlay_sq0
    endif          
        ldy fieldPos_tmp       
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_type                 
        cmp #virus                 
        bne @changeSpriteToCleared_ver
    @isAVirus_ver:           
        lda #sq0_virus_cleared                 
        sta sfx_toPlay_sq0       
        jsr virusDestroyed       
        lda #vu_virusLeft                 
        ora visualUpdateFlags    
        sta visualUpdateFlags    
        lda currentP_virusLeft   
        bne @changeSpriteToCleared_ver
        inc currentP_victories   
    @changeSpriteToCleared_ver:
        lda (currentP_fieldPointer),Y
        and #mask_fieldobject_color                 
        ora #clearedPillOrVirus                   
        sta (currentP_fieldPointer),Y
        lda fieldPos_tmp            ;Increase to next vertical                
        clc                      
        adc #rowSize                 
        sta fieldPos_tmp         
        ldy fieldPos_tmp         
        cpy fieldPos_last           
        bne @clearVerChain_loop  
        inc currentP_matchFlag   
        lda fieldPos_last                
        sta fieldPos_tmp         
    @nextVerFieldPos_colorChainBreak:
        lda fieldPos_tmp         
        sta fieldPos             
        jmp @checkReach_bottomLimit
    @nextVerFieldPos:        
        lda fieldPos                ;Increase to next vertical 
        clc                      
        adc #rowSize                 
        sta fieldPos             
    @checkReach_bottomLimit: 
        lda fieldPos             
        cmp #lastRow_forMatch       ;This is actually 3 up from the bottom, as a 3 chain does not need to be computed            
        bcs @nextColumn          
        jmp @checkVerMatch_loop  
    @nextColumn:             
        inc fieldPos                ;Increase column          
        lda fieldPos             
        and #lastColumn             ;Isolate column (removes row information)      
        sta fieldPos             
        lda fieldPos                ;Check if we wrapped around to $00 (which means we have checked all columns)
        beq @incPillPlacedStep_thenRTS_ver
        jmp @checkVerMatch_loop     ;Keep looping to find matches until last column is finished
    @incPillPlacedStep_thenRTS_ver:
        inc currentP_pillPlacedStep ;Inc to the pill placed step: updateField
        rts                      


;;
;; anyPlayerLoses [$9542]
;;
;; This routine checks which player (or if both players) failed, then updates graphics accordingly
;;
anyPlayerLoses:          
        lda #$00                    ;Disable pause         
        sta enablePause
    if !optimize          
        sta p1_level_tmp            ;Unsure what this is for
    endif 
        lda #player1                ;Check if this is player 1 who failed
        sta currentP             
        lda p1_levelFailFlag     
        bne @p1Failed            
        inc p1_victories            ;If not, increase p1 victories and check if p2 failed (assuredly)         
        jmp @p2Failed_check      
    @p1Failed:               
        lda nbPlayers               ;Check if 1 player game,   
        cmp #$01                 
        beq @switchMode_thenRTS  
        jsr emptyLowerFieldOnLose_2P    ;If not, we empty the losing player's lower field 
        lda #$01                    ;Mark player 1 as the one who failed
        sta whoFailed            
    @p2Failed_check:         
        lda currentP_status         ;Update player 1 current status  
        sta p1_status            
        lda #player2                ;Same check as for player 1
        sta currentP             
        lda p2_levelFailFlag     
        bne @p2Failed            
        inc p2_victories         
        jmp @storeP2Status       
    @p2Failed:               
        lda p1_levelFailFlag        ;If p2 failed, we also check if p1 failed, in case we have a draw
        beq @onlyP2Failed        
    @bothFailed:             
        jsr renderDraw_bothPlayers  ;If both player failed, display draw
        lda #$00                 
        sta whoFailed            
        jmp @storeP2Status       
    @onlyP2Failed:           
        jsr emptyLowerFieldOnLose_2P
        lda #$02                 
        sta whoFailed            
    @storeP2Status:          
        lda currentP_status      
        sta p2_status            
    @switchMode_thenRTS:     
        lda #mode_playerLoses_endScreen               
        sta mode                 
        rts                      


;;
;; playerLoses_endScreen [$959A]
;;
;; Handles end screen display and music for both players
;;
playerLoses_endScreen:   
        lda #endScreen_delay            ;Waits some frames             
        jsr waitFor_A_frames     
        lda #vu_endLvl                  ;Mark end level for visual update
        ora visualUpdateFlags    
        sta visualUpdateFlags    
        lda nbPlayers                   ;Check how many players
        cmp #$02                 
        bne @endLevel         
    @checkVictories:         
        lda p1_victories                ;If 2 players, we check the number of victories     
        cmp config_victoriesRequired    ;Is hard coded to 3, but earlier prototypes allowed to customize this
        beq @gameOver            
        lda p2_victories         
        cmp config_victoriesRequired
        beq @gameOver            
    @notEnoughVictories:     
        ldx musicType                   ;Not enough victories for the game to be over
        lda winMusic_basedOnMusicType,X ;Plays a different end game music depending on music type selected
        sta music_toPlay         
        jmp @victory_notFinal    
    @gameOver:               
        lda #mus_fail                   ;Game is over, prepare fail music    
        sta music_toPlay         
        lda nbPlayers                   ;Check how many polayers
        cmp #$02                 
        bne @endLevel         
        lda #mus_victory_final          ;If 2 players, change music prepared to final victory         
        sta music_toPlay         
    @endLevel:            
        lda #endLevel_delay             ;Wait then empty both fields (this lets music play a little while)             
        jsr waitFor_A_frames     
    if !optimize
        lda #fieldPosEmpty              ;We have a routine that does just this, probably safe to spend a few cycles to save space               
        ldx #>p1_field                             
        ldy #>p2_field                 
        jsr copy_valueA_fromX00_toY00_plusFF
    else 
        jsr initField_bothPlayers
    endif 
        lda #player1                    ;Render game over for player 1         
        sta currentP             
        jsr renderGameOver       
        lda #$0F                        ;Update status
        sta p1_status            
        lda #player2                    ;Render game over for player 2 (even though we might be in a single player game)
        sta currentP             
        jsr renderGameOver       
        lda #$0F                 
        sta p2_status
    if !optimize            
        lda #$0F                        ;Not sure why we need to update the current player status here since both players were already updated 
        sta currentP_status      
    endif 
        lda #$00                        ;Someone won, so it doesn't matter if the other player failed         
        sta whoFailed            
        lda #$01                        ;Temporarily mark player 1 as the winner
        sta whoWon               
        lda p1_victories                ;Check if enough victories
        cmp config_victoriesRequired
        beq @waitForInput_loop   
        lda #$02                        ;If not, then this means player 2 won
        sta whoWon
    @waitForInput_loop:      
    if !optimize 
        lda frameCounter                ;Every 8 frames, blink the start txt
        and #spr_txt_start_speed                 
        beq @postSpriteUpdate    
    @startTxtBlink:          
        lda #spr_txt_start_x                 
        sta spriteXPos           
        ldx nbPlayers                   ;y pos is based on number of players
        lda startTxt_YPos_basedOnNbPlayers,X
        sta spriteYPos           
        lda #spr_txt_start                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @postSpriteUpdate:       
        jsr visualAudioUpdate_NMI       ;Update visuals and audio, and loop until p1 presses start
        lda p1_btns_pressed      
        and #btn_start                 
        beq @waitForInput_loop   
    else 
        jsr startBlink_waitForInput
    endif 
    @startPressed:                      ;Start pressed, we go back to options
    if !optimize
        if !bugfix           
            lda #$FE                        ;Not sure why the value set here is $FE instead of $FF               
        else 
            lda #fieldPosEmpty              ;Inconsequential bug fix
        endif 
        ldx #>p1_field                      ;We have a routine that does just this, probably safe to spend a few cycles to save space          
        ldy #>p2_field                  
        jsr copy_valueA_fromX00_toY00_plusFF                     
    else 
        jsr initField_bothPlayers
    endif 
        lda #mode_toOptions                 
        sta mode                 
        lda #$00                        ;Reset level fail flag (in case this was what led to end of game)             
        sta currentP_levelFailFlag
        jsr checkHighscore              ;Check if we update highscore  
        lda #$00                        ;Reset btns pressed (to make sure we don't double press start)
        sta p1_btns_pressed      
    if !optimize
        lda #$FF                        ;Enable pause (why do we do this at this moment?)
        sta enablePause
    endif           
        rts                             
    @victory_notFinal:       
        jsr fullStatusUpdate            ;Perform full status update
    if !optimize
    @victory_notFinal_waitForInput_loop:
        lda frameCounter                ;Then blink start until p1 presses start (copy-paste of final victory earlier in this routine)
        and #spr_txt_start_speed                 
        beq @victory_notFinal_postSpriteUpdate
    @victory_notFinal_startTxtBlink:
        lda #spr_txt_start_x                 
        sta spriteXPos           
        ldx nbPlayers            
        lda startTxt_YPos_basedOnNbPlayers+0,X
        sta spriteYPos           
        lda #spr_txt_start                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @victory_notFinal_postSpriteUpdate:
        jsr visualAudioUpdate_NMI
        lda p1_btns_pressed      
        cmp #btn_start                 
        bne @victory_notFinal_waitForInput_loop
    else 
        jsr startBlink_waitForInput
    endif 
    @victory_notFinal_startPressed:
        jsr initField_bothPlayers       ;Start pressed, init field for both players, then perform a full status update
        jsr fullStatusUpdate     
        lda #mode_initData_level        ;Change mode, then init level fail flag, buttons pressed dans enable pause          
        sta mode                 
        lda #$00                 
        sta currentP_levelFailFlag
        lda #$00                 
        sta p1_btns_pressed      
    if !optimize
        lda #$FF                        ;Enable pause (is this redundant?)
        sta enablePause
    endif           
        rts                      


if optimize
;;
;; startBlink_waitForInput [n/a]
;;
;; Added routine, this was copy-pasted almost as is at 3 places in the code
;;
startBlink_waitForInput:
        lda frameCounter                ;Every 8 frames, blink the start txt
        and #spr_txt_start_speed                 
        beq @dontBlink    
    @startBlink:          
        lda #spr_txt_start_x                 
        sta spriteXPos           
        ldx nbPlayers                   ;y pos is based on number of players
        lda startTxt_YPos_basedOnNbPlayers,X
        sta spriteYPos           
        lda #spr_txt_start                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @dontBlink:       
        jsr visualAudioUpdate_NMI       ;Update visuals and audio, and loop until p1 presses start
        lda p1_btns_pressed 
        ora p1_btns_held                ;This was only present in one of the three copies of the routine, but seems safer to include
        and #btn_start                 
        beq startBlink_waitForInput
    @exit_startBlink_waitForInput
        rts  
endif 


;;
;; renderDraw_bothPlayers [$9692]
;;
;; Simply calls the routine renderDraw for both players
;;
renderDraw_bothPlayers:  
        lda #player1                 
        sta currentP             
        jsr renderDraw           
        lda #player2                 
        sta currentP             
        jsr renderDraw           
        rts                      


;;
;; renderDraw [$96A1]
;;
;; Renders the "DRAW" text box (tiles considered as field objects)
;;
renderDraw:              
        lda #$00                    ;Reset field pointer
        sta currentP_fieldPointer
        ldy #txtBox_draw_fieldPos   ;Get field position for the text box                 
    @renderDraw_loop:         
        tya                         ;Perform simple equation so that X follows the value of Y 
        sec                      
        sbc #txtBox_draw_fieldPos                  
        tax                      
        lda txtBox_draw,X        
        beq @renderDraw_finished    ;If data equals $00, the text box is finished
        sta (currentP_fieldPointer),Y
        iny                      
        jmp @renderDraw_loop      
    @renderDraw_finished:    
        lda #$0F                 
        sta currentP_status      
        rts                      

if !removeUnused
    emptyFieldOnLose_2P_UNUSED:
            lda #$00                        ;Alternative to emptyLowerFieldOnLose_2P, but empties the whole field instead of just the lower part
            sta currentP_fieldPointer
            ldy #lastFieldPos                 
        @emptyField_loop:        
            lda #fieldPosEmpty                 
            sta (currentP_fieldPointer),Y
            dey                      
            cpy #$FF                 
            bne @emptyField_loop     
            lda #$0F                 
            sta currentP_status      
            rts 
endif


;;
;; emptyLowerFieldOnLose_2P [$96D0]
;;
;; Removes virus below a certain threshold to display end game animations
;;
emptyLowerFieldOnLose_2P:
        lda #$00                 
        sta currentP_fieldPointer
        ldy #lowerFieldPos                 
    @emptyLowerField_loop:   
        lda #fieldPosEmpty                 
        sta (currentP_fieldPointer),Y
        iny                      
        cpy #fieldSize                 
        bne @emptyLowerField_loop
        lda #$0F                 
        sta currentP_status      
        rts                      


;;
;; renderGameOver [$96E4]
;;
;; Renders the "GAME OVER" text box (very similar to how this is done in renderDraw)
;;
renderGameOver:          
        lda #$00                 
        sta currentP_fieldPointer
        ldx #$00                 
        ldy #txtBox_gameOver_fieldPos                 
    @renderGameOver_loop:    
        lda txtBox_gameOver,X    
        beq @renderGameOver_finished
        sta (currentP_fieldPointer),Y
        inx                      
        iny                      
        jmp @renderGameOver_loop 
    @renderGameOver_finished:
        lda #$0F                 
        sta currentP_status      
        rts                      


;;
;; fullStatusUpdate [$96FD]
;;
;; This routine seems to wait until enough NMIs have passed to have checked the status of all field rows (16 of them)
;;
fullStatusUpdate:        
        lda #$0F                       
        sta p1_status            
        sta p2_status            
    @statusUpdateLoop:       
        jsr visualAudioUpdate_NMI
        lda p1_status            
        cmp #$FF                 
        bne @statusUpdateLoop    
        rts                      


if !removeMoreUnused
action_doNothing_UNUSED:        
        rts                         ;Some code could theoritically get there, but it never does, and if it would, it would do nothing         
endif


;;
;; waitFor_A_frames [$9711]
;;
;; This routine waits for the number of frames specified in A 
;;
;; Input:
;;  A = number of frames to wait
;; 
waitFor_A_frames:        
        sta waitFrames 
        lda #$01                 
        sta flag_inLevel_NMI     
    @nextFrame:              
        jsr visualAudioUpdate_NMI
        dec waitFrames           
        lda waitFrames           
        bne @nextFrame           
        rts                      

if !removeUnused
    waitFor_A_frames_notInLevel_UNUSED:
            sta waitFrames           
            lda #$00                    ;Same as the previous routine, except the inLevel flag is cleared... this is unused, maybe this was used earlier in development           
            sta flag_inLevel_NMI     
        @nextFrame_notInLevel:   
            jsr visualAudioUpdate_NMI
            dec waitFrames           
            lda waitFrames           
            bne @nextFrame_notInLevel
            rts                      
endif


;;
;; checkHighscore [$9731]
;;
;; Checks if the score is higher than the high score, and if so, update the high score
;; 
checkHighscore:          
    @check6thDigit_highscore:    
        lda highScore+5                 ;This here is the highest digit (leftmost), it is the sixth digit because the score displayed adds a zero at the end just for swag
        cmp score+5              
        beq @check5thDigit_highscore    ;If this digit is the same, continue the check
        bcs @exit_checkHighscore        ;If this digit is lower, we know it is not a highscore, exit
        bcc @updateHighscore            ;If this digit is higher, we know it is a highscore, update
    @check5thDigit_highscore:
    if !optimize
        iny                             ;Not sure why we increase y here, probably safe to remove 
    endif 
        lda highScore+4                 ;Do the same check for all the following digits         
        cmp score+4              
        beq @check4thDigit_highscore
        bcs @exit_checkHighscore 
        bcc @updateHighscore     
    @check4thDigit_highscore:
    if !optimize
        iny                      
    endif 
        lda highScore+3          
        cmp score+3              
        beq @check3rdDigit_highscore
        bcs @exit_checkHighscore 
        bcc @updateHighscore     
    @check3rdDigit_highscore:
        lda highScore+2          
        cmp score+2              
        beq @check2ndDigit_highscore
        bcs @exit_checkHighscore 
        bcc @updateHighscore     
    @check2ndDigit_highscore:
    if !optimize
        iny                      
    endif 
        lda highScore+1          
        cmp score+1              
    if !optimize
        beq @check1stDigit_highscore
    endif 
        bcs @exit_checkHighscore 
    if !optimize
        bcc @updateHighscore     
    @check1stDigit_highscore:
        iny                         ;This actually never changes because score can only increase by multiples of 100 
        lda highScore+0          
        cmp score+0              
        bcs @exit_checkHighscore
    endif  
    @updateHighscore:        
        lda score+5              
        sta highScore+5          
        lda score+4              
        sta highScore+4          
        lda score+3              
        sta highScore+3          
        lda score+2              
        sta highScore+2          
        lda score+1              
        sta highScore+1          
        lda score+0              
        sta highScore+0          
    @exit_checkHighscore:    
        rts                      


;;
;; checkPauseReset [$979E]
;;
;; Checks if we pause/unpause the game, or if we quit the demo
;;
checkPauseReset:         
        lda flag_demo           ;First check if we are in the demo           
        bne @checkStartBtn_demo  
        lda p1_btns_held        ;If not, then check if all buttons required for a soft reset are held
        cmp #btns_reset                 
        bne @noSoftReset         
    @softReset:              
        lda #mode_toTitle       ;If soft reset, we simply return to the title              
        sta mode                 
        sta flag_pause_forAudio ;We make sure the audio is unpaused (mode_toTitle being equal to zero)
        jmp @exit_checkPauseReset
    @noSoftReset:            
        lda enablePause         ;If no soft reset, we check if pause is enabled, and if so, if it is pressed   
        beq @exit_checkPauseReset
        lda p1_btns_pressed      
        and #btn_start                 
        beq @exit_checkPauseReset
    @pause:                  
        lda #pauseAudio         ;If pause, we pause the audio           
        sta flag_pause_forAudio  
        lda #$00                ;Then clear flag identifying if we are in a level or not (for graphics rendering), and wait for next frame  
        sta flag_inLevel_NMI     
        jsr visualAudioUpdate_NMI
        lda #ppumask_bkg_col1_enable + ppumask_spr_col1_enable + ppumask_spr_show              
        sta PPUMASK_RAM         ;We show only sprites because the word PAUSE is actually sprites  
        lda #$FF                 
        ldx #>sprites           ;Clear sprites RAM                
        ldy #>sprites                 
        jsr copy_valueA_fromX00_toY00_plusFF
    @pause_loop:                ;Then render the PAUSE sprite 
        setSpriteXY spr_txt_pause_x,spr_txt_pause_y
        ;lda #$70                 
        ;sta spriteXPos           
        ;lda #$77                 
        ;sta spriteYPos           
        lda #spr_txt_pause                 
        sta metaspriteIndex          
        jsr metaspriteUpdate        
        lda p1_btns_pressed     ;Check if start is pressed to unpause game      
        cmp #btn_start                 
        beq @unpause             
    @checkSoftReset_onPause: 
        lda p1_btns_held        ;If start was not pressed, check for soft reset (this is useful in the case a player kept holding start to pause, then pressed other buttons to reset) 
        cmp #btns_reset                 
        beq @softReset           
    @noSoftReset_onPause:       ;If no reset either, we wait 1 frame then check again  
        jsr visualAudioUpdate_NMI
        jmp @pause_loop          
    @unpause:                
        lda #$FF                ;If unpause, we return to the level    
        sta flag_inLevel_NMI     
        lda #ppumask_bkg_col1_enable + ppumask_spr_col1_enable + ppumask_bkg_show + ppumask_spr_show         
        sta PPUMASK_RAM         ;We re-enable bkg and 1 column render 
        lda #$00                ;And we unpause the audio 
        sta flag_pause_forAudio  
    @exit_checkPauseReset:   
        rts                             
    @checkStartBtn_demo:     
        lda p1_btns_pressed     ;If in the demo, check if pause is pressed   
        cmp #btn_start                 
        bne @exit_checkStartBtn_demo
    @startPressed_demo:      
        lda #$00                ;If so, we reset demo instructions pointer for next time the demo starts    
        sta ptr_demoInstruction_low
        sta mode                ;$00 here is title screen       
        lda p1_level_cache      ;We restore saved p1 data (and not p2 because it was not changed when going to the demo)
        sta p1_level             
        lda p1_speedSetting_cache 
        sta p1_speedSetting      
        lda nbPlayers_cache     ;We restore nb of players as well as music type options 
        sta nbPlayers            
        lda musicType_cache      
        sta musicType            
    @exit_checkStartBtn_demo:
        rts                      


;;
;; toTitle [$982A]
;;
;; This routine moves us to the title screen (visual + audio), manages title screen anims, handles nb of players changes, and moves us to demo/options when conditions are met
;;
toTitle:                 
        lda flag_demo           ;Check if we come from demo        
        cmp #flag_demo_playing                 
        bne @switchMusicGraphics         
    @fromDemo:               
        lda #$00                ;If so, reset demo instruction pointer (this part here is to prevent any problems from returning to title screen without pressing start)
        sta ptr_demoInstruction_low
        sta mode                 
        lda p1_level_cache       
        sta p1_level             
        lda p1_speedSetting_cache 
        sta p1_speedSetting      
        lda nbPlayers_cache      
        sta nbPlayers            
        lda musicType_cache      
        sta musicType            
    @switchMusicGraphics:            
        lda #mus_title          ;Set music to title music            
        sta music_toPlay         
        lda #CHR_titleSprites   ;First load sprites                              
        jsr changeCHRBank0       
        lda #$00                ;Clear "in level" flag and disable visual update 
        sta flag_inLevel_NMI     
        sta visualUpdateFlags    
        sta flag_demo           ;Clear demo flag  
        sta waitFrames          ;Reset wait frames  
        lda #$FF                ;Set status for both players      
        sta currentP_status      
        sta p1_status            
        sta p2_status          
        lda #$00                ;We reset demo instructions pointer (this here is needed because we can get there on initial boot without having this data initialized)  
        sta ptr_demoInstruction_low
        lda #>demo_instructionSet   ;Then we reset the high byte of the demo instrucitons pointer
        sta ptr_demoInstruction_high
        jsr audioUpdate_NMI_disableRendering    ;Wait 1 frame, audio only
        jsr NMI_off                             ;Then we prepare for tiles switch/rendering and palette switch as well
        jsr copyBkgOrPalToPPU    
    @bkgTitle_ptr:           
        .word bkgTitle                     
        lda #palNb_title                 
        sta palToChangeTo
    if !bypassChecksum     
        jsr antiPiracy_checksum     ;Perform the anti-piracy checksum
    endif   
        jsr finishVblank_NMI_on     ;Finish vblank then wait 1 frame (audio + visual)
        jsr audioUpdate_NMI_enableRendering
        lda #$00                    ;Disable pause
        sta enablePause          
    if !optimize
        lda #$FF                    ;Reset player status (was already done previously)
        sta currentP_status      
    endif 
    @title_mainLoop:         
        lda frameCounter         
        and #titleAnim_speed        ;Update title anim every $10 frames      
        log2lsrA titleAnim_speed
        ;lsr A                    
        ;lsr A                    
        ;lsr A                    
        ;lsr A                    
        clc                      
        adc #CHR_titleTiles_frame0  ;Anim is done through tile swapping                 
        jsr changeCHRBank1              
    @checkUpPressed:         
        lda p1_btns_pressed         ;Check if p1 pressed up
        cmp #btn_up                 
        bne @checkDownPressed    
    @upPressed:              
        lda nbPlayers               ;If so, check if cursor is on 1 player or 2 player game
        cmp #$01                 
        beq @checkDownPressed       ;If 1 player game, we don't wraparound
    @cursorTo_1P:            
        lda #sq0_cursor_vertical    ;If we're going to 1p game from 2p game, play cursor sfx and update nb of players                 
        sta sfx_toPlay_sq0       
        lda #$01                 
        sta nbPlayers            
        lda #$00                    ;Then reset wait frames for demo           
        sta waitFrames           
    @checkDownPressed:       
        lda p1_btns_pressed         ;Same principle but for down button
        cmp #btn_down                 
        bne @checkSelectPressed  
    @downPressed:            
        lda nbPlayers            
        cmp #$02                 
        beq @checkSelectPressed  
    @cursorTo_2P:            
        lda #sq0_cursor_vertical                 
        sta sfx_toPlay_sq0       
        lda #$02                 
        sta nbPlayers            
        lda #$00                 
        sta waitFrames           
    @checkSelectPressed:            ;Checks if select is pressed   
    if bugfix
        lda p1_btns_pressed         ;There is a slight bug here: the cmp is sometimes in relation to something else than p1_btns_pressed because it is not properly lda before 
    endif      
        cmp #btn_select                      
        bne @renderTitleCursor      
    @selectPressed:          
        lda #sq0_cursor_vertical    ;If select is pressed, we don't check actual nb of players, we simply switch between both options              
        sta sfx_toPlay_sq0       
        lda nbPlayers            
        eor #$03                    ;This effectively changes 1p into 2p, and 2p into 1p            
        sta nbPlayers            
        lda #$00                 
        sta waitFrames           
    @renderTitleCursor:             ;Regardless if nb of players changed or not, we render the title cursor
        lda #spr_cursor_heart_x                 
        sta spriteXPos           
        ldx nbPlayers            
        lda titleCursorYPos,X    
        sta spriteYPos           
        lda #spr_cursor_heart                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jsr titleDanceAnim          ;We then update the title screen dance anim   
        jsr visualAudioUpdate_NMI
        lda frameCounter            ;Check if frame counter is back to 0 after 256 ticks
        bne @checkStartPressed   
    @incDemoStartCounter:           ;If so, increase demo start counter
        inc waitFrames              ;They are not actually frames here, rather every $FF frames      
        lda waitFrames           
        cmp #demoStart_delay        ;Check if we go to demo            
        beq @toDemo              
    @checkStartPressed:      
        lda p1_btns_pressed         ;If not, check if p1 pressed start
        cmp #btn_start                 
        beq @incMode                ;If so, increase mode to options menu. If not, loop on the title screen
        jmp @title_mainLoop      
    @incMode:                
        inc mode                 
        rts                              
    @toDemo:                 
        lda #flag_demo_playing      ;Set demo flag to playing                          
        sta flag_demo            
        lda p1_level                ;Save p1 data and global options
        sta p1_level_cache       
        lda p1_speedSetting      
        sta p1_speedSetting_cache 
        lda nbPlayers            
        sta nbPlayers_cache      
        lda musicType            
        sta musicType_cache      
        lda #$00                    ;Init demo_inputs and demo instruction counter
        sta demo_inputs          
        sta counterDemoInstruction
        lda #$01                    ;Med speed (we don't change to a constant here because it also sets other values)      
        sta currentP_speedSetting
        sta p1_speedSetting      
        sta nbPlayers            
        lda #musicType_demo         ;Continues the title screen music
        sta musicType              
        lda #demo_virus             ;44 virus left
        sta currentP_virusLeft   
        sta p1_virusLeft         
        lda #demo_level             ;Level 10
        sta p1_level             
        jmp @incMode                ;Increase mode to demo mode


;;
;; toDemo_orOptions [$9961]
;;
;; Briefly checks if we're going to options or demo. If options, perform some init, then go into the options main loop.
;;
toDemo_orOptions:        
        lda flag_demo            
        beq @notInDemo           
        jmp @toInitGame             ;If in demo skip this whole routine  
    @notInDemo:              
    if !optimize
        jsr toInitAPU_var_chan      ;Prep audio
    else 
        jsr initAPU_variablesAndChannels   
    endif    
        lda #CHR_optionsSprites     ;Load visuals                 
        jsr changeCHRBank0              
        lda #CHR_optionsTiles                 
        jsr changeCHRBank1       
        lda #$00                    
        sta flag_inLevel_NMI        ;We are not in a level at this moment
        sta visualUpdateFlags       ;Init flags   
        sta optionSectionHighlight  ;Section highlight in initial position (level)
        sta lvlsOver20              ;Make sure we reset back to level 20 at max           
    if !optimize
        lda #$03                    ;Already set in init and can never change
        sta config_victoriesRequired
    endif 
        lda #$FF                    ;Reset both players status 
        sta currentP_status      
        sta p1_status            
        sta p2_status            
        lda musicType            
        cmp #musicType_demo         ;Here if music type was set to 3, that means we came from demo          
        bcc @checkLvlCap         
    @musicTypeIsDemo:           
        lda #musicType_fever        ;Set music to Fever            
        sta musicType            
    @checkLvlCap:            
        lda p1_level             
        cmp #selectableLvCap+1      ;Check if player 1's level is higher than lvl cap
        bmi @prepBkgChange_options
    @applyLvlCap:            
        lda #selectableLvCap        ;If over lvl cap, reset to lvl cap    
        sta p1_level             
    @prepBkgChange_options:  
        jsr audioUpdate_NMI_disableRendering
        jsr NMI_off          
        jsr copyBkgOrPalToPPU    
    @bkgOptions_ptr:         
        .word bkgOptions              
        lda #vu_options_ver_lvl     ;Put options highlight on top (level) section                
        sta visualUpdateFlags_options
        jsr render_optionsOverlays
        lda #palNb_options                 
        sta palToChangeTo     
        setPPUADDR_absolute optionsNbP_VRAMaddr
        ;lda #$20                 
        ;sta PPUADDR              
        ;lda #$AA                 
        ;sta PPUADDR              
        lda nbPlayers            
        sta PPUDATA                 ;Write "1" or "2" in options title for nb of players        
    if !optimize
        lda nbPlayers               ;No need to LDA the same variable twice since STA does not affect flags
    endif            
        cmp #$01                 
        bne @options_init        
        jsr copyBkgOrPalToPPU       ;Since the following is only loaded when going into options in 1 player mode, the information in this table HIDES stuff
    @bkgOptions_eraseP2_ptr: 
        .word bkgOptions_eraseP2              
    @options_init:           
        lda #vu_options_lvl_nb      ;Update lvl nb visual             
        sta visualUpdateFlags_options
        jsr finishVblank_NMI_on
        jsr audioUpdate_NMI_enableRendering
        lda #$00                    ;Disable pause    
        sta enablePause          
    if !optimize
        lda #$FF                    ;Reset p1 status (was already done previously)
        sta p1_status
    endif            
        lda #mus_options                 
        sta music_toPlay         
    @options_mainLoop:       
        generateRandNum
        ;ldx #rng0                   ;Generate 2 random bytes                 
        ;ldy #rngSize                 
        ;jsr randomNumberGenerator
        lda p1_btns_pressed         ;Check if b pressed   
        cmp #btn_b                 
        bne @checkStartPress     
    @backToTitle:            
        lda #mode_toTitle           ;If so, back to title                 
        sta mode                 
        jmp @exit_toDemo_orOptions
    @checkStartPress:        
        cmp #btn_start              ;Check if start pressed          
        bne @sectionCheck_lvl    
        jmp @toInitGame             ;If so, start game
    @sectionCheck_lvl:       
        lda optionSectionHighlight  ;Otherwise, check which section is highlighted
        cmp #options_section_lvl                 
        bne @sectionCheck_speed  
    @updateLvlCursor_p1:     
        jsr p1RAM_toCurrentP        ;If lvl section, update p1 lvl cursor    
        jsr updateLvlCursor      
        jsr currentP_toP1        
        lda nbPlayers    
        cmp #$02                 
        bne @sectionCheck_speed  
    @updateLvlCursor_p2:     
        jsr p2RAM_toCurrentP        ;Then p2 lvl cursor (if 2 players) 
        jsr updateLvlCursor      
        jsr currentP_toP2        
    @sectionCheck_speed:     
        lda optionSectionHighlight
        cmp #options_section_speed                 
        bne @sectionCheck_musicType
    @updateSpeedCursor_p1:   
        jsr p1RAM_toCurrentP        ;If speed section, update p1 speed cursor   
        jsr updateSpeedCursor    
        jsr currentP_toP1        
        lda nbPlayers            
        cmp #$02                 
        bne @sectionCheck_musicType
    @updateSpeedCursor_p2:   
        jsr p2RAM_toCurrentP        ;Then p2 speed cursor (if 2 players) 
        jsr updateSpeedCursor    
        jsr currentP_toP2        
    @sectionCheck_musicType: 
        lda optionSectionHighlight
        cmp #options_section_music                 
        bne @sectionChange_upPress_check 
    @updateMusicType:        
        lda p1_btns_pressed         ;If music section, check p1 btns pressed (interestingly, only p1 can change the music)   
        and #btn_right                 
        beq @updateMusicTypeBox_leftPress_check
    @updateMusicType_rightPress:
        lda musicType            
        cmp #musicType_silence      ;If not max to the right, update music cursor (no wraparound)
        beq @updateMusicTypeBox_leftPress_check
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        inc musicType            
    @updateMusicTypeBox_leftPress_check:
        lda p1_btns_pressed      
        and #btn_left                 
        beq @sectionChange_upPress_check            
    @updateMusicTypeBox_leftPress:
        lda musicType               ;If not max to the left, update music cursor (again, no wraparound)  
        beq @sectionChange_upPress_check 
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        dec musicType            
    @sectionChange_upPress_check:    
        lda p1_btns_pressed         ;Then check if we need to change section
        cmp #btn_up                 
        bne @sectionChange_downPress_check
    @sectionChanged_upPress: 
        lda optionSectionHighlight  ;If not already on top position go up
        beq @sectionChange_downPress_check          
        lda #sq0_cursor_vertical                 
        sta sfx_toPlay_sq0       
        dec optionSectionHighlight
        lda optionSectionHighlight
        sta visualUpdateFlags_options
        inc visualUpdateFlags_options
    @sectionChange_downPress_check:
        lda p1_btns_pressed      
        cmp #btn_down                 
        bne @p1_options_sprUpdate
    @sectionChanged_downPress:
        lda optionSectionHighlight
        cmp #options_section_music  ;If not already on bottom position go down
        beq @p1_options_sprUpdate
        lda #sq0_cursor_vertical                 
        sta sfx_toPlay_sq0       
        inc optionSectionHighlight
        lda optionSectionHighlight
        sta visualUpdateFlags_options
        inc visualUpdateFlags_options
    @p1_options_sprUpdate:   
        jsr p1RAM_toCurrentP        ;Then perform visual update for p1 cursors
        jsr updateOptions_cursors
        jsr currentP_toP1        
        lda nbPlayers            
        cmp #$02                 
        bne @musicTypeBox_sprUpdate
    @p2_options_sprUpdate:   
        jsr p2RAM_toCurrentP        ;And p2 cursors if 2-players
        jsr updateOptions_cursors
        jsr currentP_toP2        
    @musicTypeBox_sprUpdate: 
        ldx musicType               ;And finally music type box        
        lda musicTypeBox_XPos,X  
        sta spriteXPos           
        lda #spr_musicTypeBox_y                 
        sta spriteYPos           
        lda musicTypeBox_sprIndex,X
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        jsr visualAudioUpdate_NMI
        jmp @options_mainLoop       ;Then go back to the beginning of the options main loop
    @toInitGame:             
        inc mode                    ;If we start game (or go to demo), increase mode, then exit                 
    @exit_toDemo_orOptions:  
        rts                      


;;
;; updateLvlCursor [$9ADF]
;;
;; Updates a single lvl cursor during a single frame
;;
updateLvlCursor:         
        lda currentP_horVelocity    ;Uses hor velocity just like horizontal pill movement
        bne @isMoving            
        lda currentP_btnsPressed
        and #btns_left_right                 
        beq @exit_updateLvlCursor
        lda #options_change_speed-1 ;Will be incremented later to insure cursor moves                 
        sta currentP_horVelocity 
    @isMoving:               
        lda currentP_btnsHeld    
        and #btns_left_right                 
        bne @leftOrRight_pressed 
        lda #$00                    ;If nor left or right are held anymore, stop moving      
        sta currentP_horVelocity 
        jmp @exit_updateLvlCursor
    @leftOrRight_pressed:    
        inc currentP_horVelocity 
        lda currentP_horVelocity 
        cmp #options_change_speed                 
        bcc @exit_updateLvlCursor
        lda #$01                    ;After reaching movement threshold, reset the velocity to 1 (make sure it is non-zero)                 
        sta currentP_horVelocity 
        lda currentP_btnsHeld       ;Finally, check if we are moving left or right   
        and #btn_right                 
        beq @checkMoving_left    
    @isMoving_right:         
        lda currentP_level       
        cmp #selectableLvCap        ;Move cursor only if not max level
        beq @checkMoving_left    
    @isMoving_right_notMaxLvl:
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        lda visualUpdateFlags_options
        ora #vu_options_lvl_nb                 
        sta visualUpdateFlags_options
        inc currentP_level       
    @checkMoving_left:       
        lda currentP_btnsHeld    
        and #btn_left                 
        beq @exit_updateLvlCursor
    @isMoving_left:          
        lda currentP_level          ;Move cursor only if not level 0
        beq @exit_updateLvlCursor
    @isMoving_left_notMaxLvl:
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        lda visualUpdateFlags_options
        ora #vu_options_lvl_nb                 
        sta visualUpdateFlags_options
        dec currentP_level       
    @exit_updateLvlCursor:   
        rts                      


;;
;; updateSpeedCursor [$9B37]
;;
;; Updates a single speed cursor during a single frame
;;
updateSpeedCursor:       
        lda currentP_btnsPressed            ;Roughly same principle as for lvl cursor update
        cmp #btn_right                 
        bne @check_leftPressed   
    @rightPressed:           
        lda currentP_speedSetting
        cmp #speed_hi                 
        beq @check_leftPressed   
    @notMaxSpeed:            
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        inc currentP_speedSetting
    @check_leftPressed:      
        lda currentP_btnsPressed 
        cmp #btn_left                 
        bne @exit_updateSpeedCursor
    @leftPressed:            
        lda currentP_speedSetting
        beq @exit_updateSpeedCursor
    @notMinSpeed:            
        lda #sq0_cursor_horizontal                 
        sta sfx_toPlay_sq0       
        dec currentP_speedSetting
    @exit_updateSpeedCursor: 
        rts                      


;;
;; updateOptions_cursors [$9B5C]
;;
;; Updates the sprites for lvl and speed cursor for a single player
;;
updateOptions_cursors:   
        ldx currentP_level       
        lda lvlCursor_XPos,X   
        sta spriteXPos           
        ldx currentP             
        lda lvlCursor_YPos,X   
        sta spriteYPos           
        lda currentP             
        clc                      
        adc #spr_cursor_small_top                 
        sta metaspriteIndex          
        jsr metaspriteUpdate         
    @updateOptions_cursor_speed:
        ldx currentP_speedSetting
        lda speedCursor_XPos,X 
        sta spriteXPos           
        ldx currentP             
        lda speedCursor_YPos,X 
        sta spriteYPos           
        lda currentP             
        clc                      
        adc #spr_cursor_big_top-player1
        sta metaspriteIndex          
        jsr metaspriteUpdate         
        rts                      


;;
;; mainLoop_level [$9B8D]
;;
;; Manages each player's action and performs checks related to end level/game
;;
mainLoop_level:          
        jsr p1RAM_toCurrentP            ;First process player 1's state     
        jsr nextAction           
        jsr currentP_toP1        
        lda nbPlayers            
        cmp #$02                 
        bne @checkVirusLeft_checkFail
    @victoriesCheck:                    ;If 2 players, check total victories for p1
        lda currentP_victories          ;Since we check for player 1 total victories before handling player 2's last match, this is why a win DRAW when both players already have 2 victories yields a player 1 victory 
        cmp config_victoriesRequired
        beq @mode_endScreen_thenExit
    @mainLoop_level_p2:      
        jsr p2RAM_toCurrentP            ;Then process player 2's state
        jsr nextAction           
        jsr currentP_toP2        
        lda currentP_victories   
        cmp config_victoriesRequired
        beq @mode_endScreen_thenExit    ;If either player has 3 victories, move to next mode
    @checkVirusLeft_checkFail:
        jsr checkVirusLeft              ;Checks if no more virus left for either player (and also loops on end level if needed) 
        lda p2_levelFailFlag            ;Now that we've checked if any player "won", we check if any player "failed"
        bne @aPlayerFailed       
        lda p1_levelFailFlag     
        beq @exit_mainLoop_level        
    @aPlayerFailed:          
        lda #mode_anyPlayerLoses               
        sta mode
    if !removeMoreUnused                 
        lda #nextAction_doNothing       ;This is useless I think as we exit level mode before we get to the next action            
        sta p1_nextAction        
        sta p2_nextAction
    endif         
    @exit_mainLoop_level:    
        rts                            
    @mode_endScreen_thenExit:
        lda #mode_playerLoses_endScreen                 
        sta mode                 
        rts                      

;;
;; nextAction [$9BD3]
;;
;; Jumps to the current player's next action
;;
nextAction:              
        lda currentP_nextAction  
        jsr toAddressAtStackPointer_indexA
    @jumpTable_nextAction:   
        .word action_pillFalling
        .word action_pillPlaced
        .word action_checkAttack
        .word action_sendPillFinished
    if !removeMoreUnused
        .word action_doNothing_UNUSED
    endif 
        .word action_incNextAction
        .word action_sendPill


;;
;; action_incNextAction [$9BE6]
;;
;; Simply increases the current player's next action
;;
action_incNextAction:    
        inc currentP_nextAction  
        rts                      


;;
;; action_sendPillFinished [$9BE9]
;;
;; Set the current player's next action to pill falling (after being sent by Mario)
;;         
action_sendPillFinished: 
        lda #nextAction_pillFalling                 
        sta currentP_nextAction  
        rts                      


;;
;; action_checkAttack [$9BEE]
;;
;; Checks if 2 players, and if so, check if there is any new attack being stored, or if we have to release any attack
;;   
action_checkAttack:      
        lda nbPlayers            
        cmp #$02                 
        bne @bypassAttack        
        jsr checkComboCounterForAttack
        jsr checkReleaseAttack   
        jmp @exit_action_checkAttack
    @bypassAttack:           
        lda #nextAction_incNextAction                 
        sta currentP_nextAction  
    @exit_action_checkAttack:
        rts                      


;;
;; checkComboCounterForAttack [$9C03]
;;
;; Checks current player's combo counter to see if enough for an attack
;;  
checkComboCounterForAttack:
        lda currentP_comboCounter
        cmp #attackSize_min         ;Threshold for an attack
        bcc @resetComboCounter      ;If not enough, reset the counter
        clc                      
        adc currentP_attackSize     ;Otherwise, add combo counter value to current attack size
        sta currentP_attackSize  
        lda currentP                ;Plays an attack jingle according to which player sends the attack        
        sec                      
        sbc #player1-sq0_sq1_attack_p1                 
        sta sfx_toPlay_sq0_sq1  
    @resetComboCounter:      
        lda #$00                 
        sta currentP_comboCounter
        rts                      


;;
;; checkReleaseAttack [$9C1B]
;;
;; Checks if the other player has an attack in store, if so, release it
;;  
checkReleaseAttack:      
        lda #$00                 
        sta currentP_fieldPointer
        ldx currentP             
        lda otherPlayerRAM_addrOffset,X
        tax                                 ;Is actually the offset to the other player, so that we can check what the other player has in store for us in terms of attack
        lda p1_attackSize,X      
        cmp #attackSize_min                 
        bcc @noAttack                       ;If attack size below minimum, no attack 
        bne @attackSize_check3              ;If over the minimum (2) check if 3
    @attackSize_2:           
        lda frameCounter         
        and #attackSize_2_pos               ;Position of attack is based on frame
        tay                      
        lda p1_attackColors+0,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_2_gap+1
            iny
        endr
        ;iny                                        
        ;iny                      
        ;iny                      
        ;iny                      
        lda p1_attackColors+1,X  
        ora #singleHalfPill                
        sta (currentP_fieldPointer),Y
        jmp @resetAttackSize_changeAction
    @attackSize_check3:      
        cmp #$03                 
        bne @attackSize_4        
    @attackSize_3:           
        lda frameCounter                    ;Same principle as size 2  
        and #attackSize_3_pos                 
        tay                      
        lda p1_attackColors+0,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_3_gap+1
            iny
        endr
        ;iny                                 
        ;iny                      
        lda p1_attackColors+1,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_3_gap+1
            iny
        endr
        ;iny                                 
        ;iny                        
        lda p1_attackColors+2,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        jmp @resetAttackSize_changeAction
    @attackSize_4:           
        lda frameCounter                    ;Same principle as size 2  
        and #attackSize_4_pos                 
        tay                      
        lda p1_attackColors+0,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_4_gap+1
            iny
        endr
        ;iny                                 
        ;iny                        
        lda p1_attackColors+1,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_4_gap+1
            iny
        endr
        ;iny                                 
        ;iny                       
        lda p1_attackColors+2,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
        rept attackSize_4_gap+1
            iny
        endr
        ;iny                                 
        ;iny                       
        lda p1_attackColors+3,X  
        ora #singleHalfPill                 
        sta (currentP_fieldPointer),Y
    @resetAttackSize_changeAction:
        ldx currentP                        ;Resets the other player's attack size
        lda otherPlayerRAM_addrOffset,X
        tax                      
        lda #$00                 
        sta p1_attackSize,X      
        lda #nextAction_pillPlaced          ;The attack is managed as if a pill had just been placed             
        sta currentP_nextAction  
        jmp @exit_checkReleaseAttack
    @noAttack:               
        lda #nextAction_incNextAction       ;If there was no attack, we simply increase to next action              
        sta currentP_nextAction  
    @exit_checkReleaseAttack:
        rts                      


;;
;; levelIntro [$9CAB]
;;
;; Adds virus, waits a little bit, then starts the level
;;  
levelIntro:              
        lda flag_demo               ;Check if demo, if so skip ahead        
        bne @startDemo           
        lda #$00                    ;If not, init virus left
        sta p1_virusLeft         
        sta p2_virusLeft         
    @levelIntro_loop:        
        jsr storeStatsAndOptions    ;Then store stats and options
        jsr p1RAM_toCurrentP        ;Add 1 virus for p1
        jsr addVirus             
        jsr currentP_toP1        
        lda nbPlayers            
        cmp #$02                 
        bne @check_virusToAdd       ;Does not load P2 data if 1 player
    @checkSameLevel:         
        lda p1_level                ;Nor if 2 players, but same virus level (since they have the exact same virus field)
        cmp p2_level             
        beq @check_virusToAdd    
    @addVirus_p2:            
        jsr p2RAM_toCurrentP        ;If different level, add 1 virus for p2
        jsr addVirus             
    @check_virusToAdd:       
        jsr currentP_toP2        
        jsr restoreStatsAndOptions  ;Restore stats and options
        jsr visualAudioUpdate_NMI   ;Make new virus visible
        lda p1_virusToAdd           ;While at least one player still has virus to add, loop this
        bne @levelIntro_loop     
        lda p2_virusToAdd        
        bne @levelIntro_loop     
    @levelIntro_finished:           ;Hijacked entry from demo here (see below in this very same routine)
        lda #player1                ;Make p1 the current player      
        sta currentP             
        lda #$0F                    ;Init both players status
        sta currentP_status      
        sta p1_status            
        sta p2_status            
        lda #levelIntro_delay       ;Wait before starting level                 
        jsr waitFor_A_frames     
        lda #mode_mainLoop_level                 
        sta mode                 
        rts                               
    @startDemo:              
        ldx #demo_startPos                 
    @fillDemoField_loop:     
        lda demo_field,X            ;Fills the field for the demo according to the data recorded
        sta p1_field,X         
        dex                      
        cpx #$FF                    ;When x wraps around, we have reached the end of the data
        bne @fillDemoField_loop  
        lda #$00                 
        sta p1_virusToAdd        
        jmp @levelIntro_finished 


;;
;; addVirus [$9D19]
;;
;; Adds a virus, performing checks for a valid position and color, then increases big virus health
;; 
;; Local variables:
virusHeight             = tmp47
virusHeight_fieldPos    = tmp47
virusColor              = tmp48
virusPos                = tmp49
virusVerOffset          = tmp4A     ;This holds the vertical offset to check ($10 = 2 rows higher or lower) 
virusHorOffset          = tmp4B     ;This holds the horizontal offset to check ($02 = 2 columns left or right)
virusColorVerif         = tmp4C
addVirus:                
        lda currentP_virusToAdd  
        bne @getValidHeight      
        jmp @exit_addVirus              ;If zero virus to add, exit 
    @getValidHeight:                    ;First we loop until we get a valid random virus height
        generateRandNum
        ;ldx #rng0                             
        ;ldy #rngSize                 
        ;jsr randomNumberGenerator
        lda rng0                 
        and #lastRow                    ;Maxout at 16  
        sta virusHeight                
        ldx currentP_level       
        lda addVirus_maxHeight_basedOnLvl,X
        cmp virusHeight                
        bcc @getValidHeight             ;New random number if height is over the max
    @setVirusYPos:                      ;Then valid height is transformed in field position
        lda virusHeight                
        tax                      
        lda pill_fieldPos_relativeToPillY,X
        sta virusHeight_fieldPos                
    @setVirusXPos:                      ;We then get a random column
        lda rng1                 
        and #lastColumn                 ;Maxout at 8             
        clc                      
        adc virusHeight_fieldPos                
        sta currentP_fieldPointer
        sta virusPos                
    @getVirusColor:          
        lda currentP_virusToAdd         ;This here is to ensure for evey 4 viruses, there are guaranteed 1 for each color. The 4th virus is random.
        and #virusRndMask                 
        sta virusColor                
        cmp #virusRndColor
    if !bugfix                 
        bne @findEmptyPos_loop
    else 
        bcc @findEmptyPos_loop          ;As a safety in case we decide that there should be more than 1 in 4 random color
    endif    
    @getVirusColor_random:   
        generateRandNum
        ;ldx #rng0                 
        ;ldy #rngSize                 
        ;jsr randomNumberGenerator
        lda rng1                 
        and #virusColor_random_size     ;Random table is 16 bytes long
        tax                      
        lda virusColor_random,X
    if !optimize
        and #mask_color                 ;This not necessary since values in this table never exceed $02                 
    endif 
        sta virusColor                
    @findEmptyPos_loop:      
        ldy #$00                        ;Now that we have a color and position, check if the position is actually available    
        lda (currentP_fieldPointer),Y
        cmp #fieldPosEmpty                 
        beq @posEmpty            
    @tryNextPos:             
        inc virusPos                    ;Attempt next position in line
        lda virusPos                
        sta currentP_fieldPointer
        cmp #fieldSize                 
        bcc @findEmptyPos_loop   
        jmp @exit_addVirus              ;If reached the end of the field, exit the routine and start again next frame
    @posEmpty:               
    if !optimize
        lda virusColor                
        sta tmp47                       ;We store virusColor in tmp47, but tmp47 is never used again
        ldx currentP_speedSetting       ;Seems odd the speed has anything to do with virus placement, it is a remnant of prototype where speed was actually difficulty, and difficulty impacted placement of virus... we can safely bypass by using immediate values later for this
        lda virusPlacement_verOffset,X  ;Changing the values in these tables will affect the virus placement dramatically
        sta virusVerOffset              ;This holds the vertical offset to check ($10 = 2 rows higher or lower)
        ldx currentP_speedSetting
        lda virusPlacement_horOffset,X
        sta virusHorOffset              ;This holds the horizontal offset to check ($02 = 2 columns left or right)
    endif 
        lda #$00                 
        sta virusColorVerif             ;A bit will be added to this everytime a different virus color is detected around the virus we want to add           
    @checkSameColor_higher:  
        lda #$00                        ;Checks what virus color is present 2 rows higher
        sta currentP_fieldPointer
        lda virusPos                
        sec                      
    if !optimize
        sbc virusVerOffset                
    else 
        sbc #virusVerCheck 
    endif 
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_color                 
        tax                      
        lda virusPlacement_colorBits,X
        ora virusColorVerif             ;All those ORA add a bit if color is detected (bit 0 = yellow, bit 1 = red, bit 2 = blue)
        sta virusColorVerif                
    @checkSameColor_lower:   
        lda #$00                        ;Same principle, but lower
        sta currentP_fieldPointer
        lda virusPos                
        clc                      
    if !optimize
        adc virusVerOffset                
    else 
        adc #virusVerCheck 
    endif               
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_color                 
        tax                      
        lda virusPlacement_colorBits,X
        ora virusColorVerif                
        sta virusColorVerif                
    @checkSameColor_left:    
        lda #$00                        ;Same principle but horizontally, to the left
        sta currentP_fieldPointer
        lda virusPos                
        and #mask_column                 
        cmp #virusHorCheck              ;No need to check if close enough to the left
        bcc @checkSameColor_right
        lda virusPos                
        sec                      
    if !optimize
        sbc virusHorOffset                
    else 
        sbc #virusHorCheck 
    endif                
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_color                 
        tax                      
        lda virusPlacement_colorBits,X
        ora virusColorVerif                
        sta virusColorVerif                
    @checkSameColor_right:   
        lda #$00                        ;Same principle, but to the right 
        sta currentP_fieldPointer
        lda virusPos                
        and #mask_column                 
        cmp #rowSize - virusHorCheck                 
        bcs @checkValidColor            ;No need to check if close enough to the right
        lda virusPos                
        clc                      
    if !optimize
        adc virusHorOffset                
    else 
        adc #virusHorCheck 
    endif                
        tay                      
        lda (currentP_fieldPointer),Y
        and #mask_color                 
        tax                      
        lda virusPlacement_colorBits,X
        ora virusColorVerif                
        sta virusColorVerif                
    @checkValidColor:        
        lda virusColorVerif                
        cmp #%00000111                 
        bne @checkValidColor_loop
        jmp @tryNextPos             ;If all 3 virus colors were detected two apart, then position is assuredly not viable, otherwise position IS viable for at least 1 color
    @checkValidColor_loop:   	
        lda #$00                    ;Reset wait frames (probably as a safety)
        sta waitFrames        
        ldx virusColor                
        lda virusPlacement_colorBits,X
        and virusColorVerif         ;If virus color is not present at 2 of distance in any direction, we have a valid virus to add        
        beq @posAndColorValid_addVirus
        dec virusColor              ;Otherwise, cycle through other colors
        lda virusColor                
        bpl @checkValidColor     
    @checkValidColor_wraparound:
        lda #blue                 
        sta virusColor                
        jmp @checkValidColor     
    @posAndColorValid_addVirus:
        lda virusPos                ;Actually add the selected virus color at the selected position   
        sta currentP_fieldPointer
        ldy #$00                 
        lda virusColor                
        ora #virus                 
        sta (currentP_fieldPointer),Y
    @incBigVirus_health:     
    if !bugfix
        and #$07                    ;Strangely here, we mask the first 3 bits, whereas we should only mask the first 2 bits to isolate color
    else 
        and #mask_color
    endif                  
        tax                      
        lda bigVirusYellow_health,X
        clc                      
        adc #$01                 
        sta bigVirusYellow_health,X
        lda p1_level                ;If both players have the same level...        
        cmp p2_level             
        bne @incVirusLeft        
    @addSameVirus_p2:               ;...add virus in the same place      
        lda virusColor                
        ora #virus                 
        ldy virusPos                
        sta p2_field,Y         
    @incVirusLeft:           
        inc currentP_virusLeft      ;Increase the current player's viruses left, with calculations to keep it decimal based  
        lda currentP_virusLeft   
        and #$0F                 
        cmp #$0A                 
        bne @updatePlayerStatus  
    @virusLeft_decimalBased: 
        lda currentP_virusLeft   
        clc                      
        adc #$06                 
        sta currentP_virusLeft   
    @updatePlayerStatus:     
        lda currentP_fieldPointer
        lsr A                       ;Bring it back to a 4-bit value to indicate which row this was added in player status
        lsr A                    
        lsr A                    
        sta currentP_status
    if !optimize      
        lda currentP_virusLeft      ;Looks like this should be removed, it does nothing at all
    endif    
        lda #vu_virusLeft           ;Update the visual for nb of virus left, then decreases viruses to add                 
        ora visualUpdateFlags    
        sta visualUpdateFlags    
        dec currentP_virusToAdd
    @exit_addVirus:          
        rts                      

;;
;; toNextLevel [$9E66]
;;
;; Checks if we should play a cutscene, does so if necessary, then preps the next level
;; 
toNextLevel:             
        lda currentP_level       
        cmp #selectableLvCap + 1    ;Check if we just finished last selectable level (20), if so, play "special" cutscene             
        beq @prepCutscene_orEnding
        bcc @checkCutscene          ;if below the level cap (20), check if we need to play a cutscene      
        jmp @prepNextLevel          ;Otherwise, just prep next level without cutscene
    @checkCutscene:          
    if !optimize
        lda currentP_speedSetting   ;This block of code is repeated several times, can be transformed into its own routine
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
        beq @prepNextLevel          ;If value is zero, no cutscene     
    @prepCutscene_orEnding:  
        lda #CHR_cutsceneSprites    ;Load appropriate graphics banks for cutscenes                 
        jsr changeCHRBank0       
        lda #CHR_cutsceneTiles                 
        jsr changeCHRBank1       
        jsr audioUpdate_NMI_disableRendering
        jsr NMI_off          
        ldx currentP_speedSetting   ;Load palette according to speed (is only used to make so that level 20 low has different background)
        lda cutscenePal_basedOnSpeed,X
        sta palToChangeTo     
        jsr copyBkgOrPalToPPU       ;Both the lvl 20 low ending and the cutscene use the same background, but with a different palette
    @bkgCutscene_andEnding_ptr:
        .word bkgCutscene_andEnding              
    @startCutscene_orEnding: 
        lda #$00                 
        sta flag_inLevel_NMI        ;We are not in a level anymore 
        sta finalCutsceneStep       ;Init final cutscene step 
        lda #$FF                    ;Set status so that both players are not in level anymore  
        sta p1_status            
        sta p2_status            
        jsr finishVblank_NMI_on
        jsr audioUpdate_NMI_enableRendering
        ldx currentP_speedSetting   ;Play a different music based on speed (low is different from med/hi)
        lda cutscene_musicToPlay_basedOnSpeed,X
        sta music_toPlay         
        lda #$01                    ;Init a couple variables for the cutscene               
        sta cutsceneFrame        
        lda #$FF                 
        sta waitFrames           
        jsr cloudData_toRAM      
        jsr fireworksData_toRAM  
        lda #spr_virusGroupCutscene_x                 
        sta virusGroup_XPos             
        lda #spr_virusGroupCutscene_y                 
        sta virusGroup_YPos  
        lda #spr_UFO_x                 
        sta spriteXPos_UFO  
        lda #spr_offscreen_y        ;Puts the UFO somewhere offscreen                 
        sta spriteYPos_UFO  
        lda #$00                 
        sta flyingObjectNb          ;Holds the sprite TEMP index position of flying object in cutscene
        sta flyingObjectStatus      ;Also used as some sprite counter in cutscene
    @cutscene_mainLoop:             ;Loops the cutscene until the player presses start
        jsr cutscene_spriteUpdate_clouds_check
        jsr checkFinalCutscene   
        jsr cutscene_spriteUpdate_virusGroup
        jsr cutscene_spriteUpdate_flyingObject
        jsr visualAudioUpdate_NMI
        dec waitFrames           
        lda p1_btns_pressed      
        cmp #btn_start                 
        bne @cutscene_mainLoop   
    @prepNextLevel:          
        lda #$00                    ;Reset cutscene frame in case we were in a cutscene (don't think this is necessary, but a good practice)  
        sta cutsceneFrame        
    if !optimize
        lda #fieldPosEmpty          ;We have a routine that does just this, probably safe to spend a few cycles to save space               
        ldx #>p1_field                             
        ldy #>p2_field                 
        jsr copy_valueA_fromX00_toY00_plusFF
    else 
        jsr initField_bothPlayers
    endif 
        lda #$01                    ;Set players as "in level" 
        sta flag_inLevel_NMI     
        lda #CHR_levelSprites       ;Switch graphics banks              
        jsr changeCHRBank0       
    if !optimize
        lda #CHR_titleTiles_frame0  ;Once again, not sure why the title here                 
        jsr changeCHRBank1
    endif        
        jsr audioUpdate_NMI_disableRendering
        jsr NMI_off           
        jsr prepLevelVisual_1P   
        lda #vu_lvlNb + vu_pScore + vu_hScore + vu_virusLeft + vu_endLvl
        sta visualUpdateFlags    
        jsr finishVblank_NMI_on
        jsr audioUpdate_NMI_enableRendering
        rts                      


;;
;; cutscene_objectFlying_check [n/a]
;;
;; Added routine that returns which object needs to be flying in the cutscene (if any)
;; 
;; Returns:
;;  A: no flying object/no regular cutscene ($00) or which object is flying ($0x)
if optimize
cutscene_objectFlying_check:
        lda currentP_speedSetting   ;Get speed setting
        asl A                    
        asl A                    
        asl A                    
        asl A                    
        asl A                       ;Multiply by 32 to get base index for object flying according to speed
        clc                      
        adc currentP_level          ;Add lvl nb to get final index
        tax                      
        lda cutscene_objectFlying_basedOnSpeedAndLvl,X      ;Get appropriate flying object
        rts                         ;Return value in A
endif

;;
;; cloudData_toRAM [$9F23]
;;
;; Simple routine to copy the initial cloud sprites data to RAM for cutscenes
;; 
cloudData_toRAM:         
        ldx #$00                 
    @cloudData_toRAM_loop:   
        lda cutscene_cloudSpritesData,X
        sta cutscene_cloudSpritesData_RAM,X
        beq @exit_cloudData_toRAM       ;When it reaches a value of zero, exits
        inx                      
        jmp @cloudData_toRAM_loop
    @exit_cloudData_toRAM:   
        rts                      


;;
;; cutscene_spriteUpdate_clouds_check [$9F32]
;;
;; A rather convoluted way of checking if we have to update cloud sprites, at this point, we always have to, unless we are on level 20 low or level 20 high
;; 
cutscene_spriteUpdate_clouds_check:
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
        lda cutscene_objectFlying_basedOnSpeedAndLvl,X      ;This table tells us if we should play a cutscene according to speed and level
    else 
        jsr cutscene_objectFlying_check
    endif 
        beq _exit_cutscene_spriteUpdate_clouds_check        ;Segues into the next routine if not zero


;;
;; cutscene_spriteUpdate_clouds [$9F42]
;;
;; Successively update all three clouds position from the cutscene during 1 frame
;; 
;; Local variables
cloudSpritesData_offset = tmp49
cloudSprite_id          = tmp4A
cloudSprite_speed       = tmp4B

cutscene_spriteUpdate_clouds:
        lda #$00                 
        sta cloudSpritesData_offset                
    @spriteUpdate_clouds_loop:
        lda cloudSpritesData_offset                
        tax                      
        lda cutscene_cloudSpritesData_RAM+0,X       ;Once the data reaches zero, we know the data is finished
        beq _exit_cutscene_spriteUpdate_clouds_check
        sta cloudSprite_id                
        tax                      
        lda cutscene_cloudSprites_speed,X
        sta cloudSprite_speed                
        lda frameCounter         
        and cloudSprite_speed                       ;The cloud moves every cloudSprite_speed frames               
        bne @spriteUpdate_cloud_prep
    @moveCloudLeft:          
        lda cloudSpritesData_offset                
        tax                      
        lda cutscene_cloudSpritesData_RAM+1,X
        sec                      
        sbc #$01                                    ;Removes 1 from the sprite x pos, effectively moving to the left
        sta cutscene_cloudSpritesData_RAM+1,X
    @spriteUpdate_cloud_prep:
        lda cloudSprite_id                
        tax                      
        lda cutscene_cloudSprites_index,X
        sta metaspriteIndex          
        lda cloudSpritesData_offset                
        tax                      
        lda cutscene_cloudSpritesData_RAM+1,X
        sta spriteXPos           
        lda cutscene_cloudSpritesData_RAM+2,X
        sta spriteYPos           
        jsr metaspriteUpdate         
        inc cloudSpritesData_offset                
        inc cloudSpritesData_offset                
        inc cloudSpritesData_offset                
        jmp @spriteUpdate_clouds_loop
    _exit_cutscene_spriteUpdate_clouds_check:
        rts                      


;;
;; cutscene_spriteUpdate_virusGroup [$9F8A]
;;
;; Animates the virus group on top of the tree during the cutscene
;; 
cutscene_spriteUpdate_virusGroup:
    lda virusGroup_XPos             ;First set their position (they can move in y during the UFO cutscene)    
    sta spriteXPos           
    lda virusGroup_YPos  
    sta spriteYPos           
    lda frameCounter                ;Animate virus group in cutscene every 8 frames
    and #spr_virusGroupCutscene_speed                      
    lsr A                    
    lsr A                           ;Reduces it to a value of 0 or 2 (strangely, instead of 0 or 1)                
    clc                      
    adc #spr_virusGroupCutscene_frame0                 
    sta metaspriteIndex          
    jsr metaspriteUpdate         
    rts                      


;;
;; action_sendPill [$9FA1]
;;
;; If 1 player, updates the Mario throw animation. Generates next pill if needed.
;; 
action_sendPill:         
        lda nbPlayers            
        cmp #$01                 
        beq @checkFrame_pillThrown
        jmp @pillThrown_toField  
    @checkFrame_pillThrown:  
        lda currentP_speedSetting
    if !optimize
        cmp #speed_hi                   ;This can be simplified to "if not low, update anim"    
        beq @incFrame_pillThrown 
        cmp #speed_med                 
        beq @incFrame_pillThrown
    else 
        bne @incFrame_pillThrown
    endif  
        lda frameCounter         
        and #spr_mario_throw_speed_low  ;On Low speed setting, pill rotates only every other frame
        beq @exit_action_sendPill
    @incFrame_pillThrown:    
        inc pillThrownFrame      
        ldx pillThrownFrame      
        lda pillThrownAnim_XPos,X
        cmp #$FF                        ;This value ends the anim 
        beq @pillThrown_toField  
        and #$F0                        ;These values mean we update Mario's sprite anim, not just the pill                 
        cmp #$F0                 
        bne @checkRotation_pillThrown
    @updateMarioThrowFrame:  
        lda pillThrownAnim_XPos,X
        and #spr_mario_throw_frames_mask    ;3 last bits of a value of "Fx" in the above table are reserved for the mario throw anim     
        sta marioThrowFrame      
        jmp @incFrame_pillThrown 
    @checkRotation_pillThrown:
        lda pillThrownFrame      
        and #pillThrown_rotation_speed  ;Rotates every other frame
        bne @exit_action_sendPill
        dec currentP_nextPillRotation
        lda currentP_nextPillRotation
        and #$03                        ;Make sure it caps at 3 since there are 4 possible rotations
        sta currentP_nextPillRotation
        jmp @exit_action_sendPill
    @pillThrown_toField:     
        jsr generateNextPill     
        lda #$00                        ;Init couple variables when generating a new pill      
        sta currentP_nextPillRotation
        lda #$00                 
        sta pillThrownFrame      
        lda #nextAction_sendPillFinished                 
        sta currentP_nextAction  
        jsr pillMoveValidation          ;If the pill that was just thrown by mario can't confirm its placement, it means the player has failed
        beq @exit_action_sendPill
    @failLvl:                
        lda #mus_fail                 
        sta music_toPlay         
        jsr confirmPlacement     
        lda #$01                        ;Set level fail flag
        sta currentP_levelFailFlag
    @exit_action_sendPill:   
        rts                      