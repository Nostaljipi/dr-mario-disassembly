;;
;; render_fieldRow_bothPlayers [$8307]
;;
;; Renders a single row for player 1 (and 2 if 2 players)
;;
render_fieldRow_bothPlayers:
        lda #player1            ;Make player 1 the current player         
        sta currentP             
        lda p1_status            
        sta currentP_status      
        jsr render_fieldRow     ;Render 1 row  
        lda currentP_status     ;Return player 1 status 
        sta p1_status            
        lda nbPlayers           ;If 2 players, do the same for player 2, otherwise exit 
        cmp #$02                 
        bne @exit_render_fieldRow_bothPlayers
        lda #player2                 
        sta currentP             
        lda p2_status            
        sta currentP_status      
        jsr render_fieldRow      
        lda currentP_status      
        sta p2_status            
    @exit_render_fieldRow_bothPlayers:
        rts                      


;;
;; render_fieldRow [$8331]
;;
;; Single field row render for current player
;;
render_fieldRow:         
        lda currentP_status     ;Check if a row needs update (if $FF, it doesn't) 
        cmp #$FF                 
        beq @exit_render_fieldRow
        lda nbPlayers           ;Different routine if 1 or 2 players  
        cmp #$01                 
        bne @render_fieldRow_2players
    @render_fieldRow_1player:
        lda currentP_status     ;Get field row to render, multiply by 2 to get an index to a 2-byte PPU address 
        asl A                    
        tay                      
        setPPUADDR_fromTable fieldRow_PPUADDR_1P
        ;lda fieldRow_PPUADDR_1P+0,Y
        ;sta PPUADDR              
        ;lda fieldRow_PPUADDR_1P+1,Y
        ;sta PPUADDR              
        jmp @render_fieldRow_prepare
    @render_fieldRow_2players:
        lda currentP            ;Different routine if player 1 or 2 in 2-player mode  
        cmp #player1                 
        bne @render_fieldRow_2players_p2
    @render_fieldRow_2players_p1:
        lda currentP_status     ;Same as 1-player, but with different PPU address table   
        asl A                    
        tay                      
        setPPUADDR_fromTable fieldRow_PPUADDR_2P_P1
        ;lda fieldRow_PPUADDR_2P_P1+0,Y
        ;sta PPUADDR              
        ;lda fieldRow_PPUADDR_2P_P1+1,Y
        ;sta PPUADDR              
        jmp @render_fieldRow_prepare
    @render_fieldRow_2players_p2:
        lda currentP_status     ;Same as 1-player, but with different PPU address table    
        asl A                    
        tay                      
        setPPUADDR_fromTable fieldRow_PPUADDR_2P_P2
        ;lda fieldRow_PPUADDR_2P_P2+0,Y
        ;sta PPUADDR              
        ;lda fieldRow_PPUADDR_2P_P2+1,Y
        ;sta PPUADDR              
    @render_fieldRow_prepare:
        lda #$00                ;Init field pointer     
        sta currentP_fieldPointer
        lda currentP_status     ;Get current row, and multiply by 8 to get current field position (since there are 8 positions per row) 
        asl A                    
        asl A                    
        asl A                    
        tay                     ;Becomes the offset to the field pointer    
        ldx #rowSize            ;We are going to loop rowSize times (8)      
    @render_fieldPos_loop:   
        lda (currentP_fieldPointer),Y   ;Get the field object type
        and #mask_fieldobject_type                       
        cmp #clearedPillOrVirus         ;Don't change anything unless it is a cleared pill or virus                 
        bne @keepFieldPosValue          
        lda (currentP_fieldPointer),Y   ;Get the field object color 
        and #mask_fieldobject_color     
        ora #fieldPosJustEmptied        ;And signal as empty field position
        jmp @render_fieldPos_PPUDATA
    @keepFieldPosValue:      
        lda (currentP_fieldPointer),Y
    @render_fieldPos_PPUDATA:
        sta PPUDATA              
        iny                             ;Check next field position, unless the loop (aka row) is finished
        dex                      
        bne @render_fieldPos_loop
        dec currentP_status             ;Rows are numbered from top to bottom, so decreasing it means the next row will be 1 higher 
    @exit_render_fieldRow:   
        rts                      


;;
;; render_palChange_or_bkgOverlays [$83A3]
;;
;; First checks if it needs to update the palette, if so, update the palette then exit. If not, render bkg overlays (options, score, text, victories).
;; Both cannot be done at the same time.
;; 
;; Local variables:
PPUADDR_tmp_hi = tmp48
PPUADDR_tmp_lo = tmp47
render_palChange_or_bkgOverlays:
        lda palToChangeTo               ;Check if we need to update the palette        
        beq @noPalChange         
        jmp palChange            
    @noPalChange:            
        lda visualUpdateFlags_options   ;If not, check if we need to update options overlays
        beq @noOptionsChange     
        jmp render_optionsOverlays   
    @noOptionsChange:        
        lda visualUpdateFlags           ;If not, check if we need to update any other overlays. and exit routine if still nothing to update
        bne @renderScore_Check   
        jmp @exit_render_palChange_or_bkgOverlays   
    @renderScore_Check:      
        lda nbPlayers                   ;Otherwise, check if we are in 1-player mode (so we have to display the score)
        cmp #$01                 
        beq @renderScore         
        jmp @renderVictories_Check      ;If not, skip both the score, highscore, virus left and level nb check
    @renderScore:            
        lda visualUpdateFlags           ;Check if the score is marked for update
        and #vu_pScore                               
        beq @renderHighScore            ;If not, skip to next check
        setPPUADDR_absolute score_VRAMaddr
        ;lda #$21                 
        ;sta PPUADDR              
        ;lda #$62                 
        ;sta PPUADDR              
        lda score+5                     ;Write score to appropriate PPU address
        sta PPUDATA              
        lda score+4              
        sta PPUDATA              
        lda score+3              
        sta PPUDATA              
        lda score+2              
        sta PPUDATA              
        lda score+1              
        sta PPUDATA              
        lda score+0              
        sta PPUDATA              
        lda visualUpdateFlags    
        and #~vu_pScore                 ;Remove player score from visual update flag                 
        sta visualUpdateFlags    
    @renderHighScore:        
        lda visualUpdateFlags           ;Same principle as player score, but this time for highscore
        and #vu_hScore                               
        beq @renderVirusLeft            
        setPPUADDR_absolute highScore_VRAMaddr
        ;lda #$21                 
        ;sta PPUADDR              
        ;lda #$02                 
        ;sta PPUADDR              
        lda highScore+5                 
        sta PPUDATA              
        lda highScore+4          
        sta PPUDATA              
        lda highScore+3          
        sta PPUDATA              
        lda highScore+2          
        sta PPUDATA              
        lda highScore+1          
        sta PPUDATA              
        lda highScore+0          
        sta PPUDATA              
        lda visualUpdateFlags    
        and #~vu_hScore                                  
        sta visualUpdateFlags    
    @renderVirusLeft:   
        lda visualUpdateFlags           ;Check if the nb of virus left is marked for update
        and #vu_virusLeft                               
        beq @renderLevelNb              ;If not, skip to next check
        setPPUADDR_absolute virusLeft_VRAMaddr
        ;lda #$23                 
        ;sta PPUADDR              
        ;lda #$3B                 
        ;sta PPUADDR              
        lda p1_virusLeft                ;This value is in decimal, so we isolate and write the first digit
        and #$F0                 
        lsr A                    
        lsr A                    
        lsr A                    
        lsr A                    
        sta PPUDATA              
        lda currentP_virusLeft          ;Strangely, currentP is used here instead of p1
        and #$0F                        ;We then isolate and write the second digit 
        sta PPUDATA              
        lda visualUpdateFlags    
        and #~vu_virusLeft              ;Remove virus left from visual update flag     
        sta visualUpdateFlags    
    @renderLevelNb:          
        lda visualUpdateFlags           ;Check if the lvl nb is marked for update
        and #vu_lvlNb                   
        beq @renderVictories_Check      ;If not, skip to next check
        setPPUADDR_absolute levelNb_VRAMaddr
        ;lda #$22                 
        ;sta PPUADDR              
        ;lda #$7B                 
        ;sta PPUADDR              
        ldx p1_level                    ;Transform hex lvl number into decimal with a lookup table (the lvl nb is capped to $18 (24 in decimal))
        lda levelForDisplay,X  
        jsr renderLevelNb_2digits
        lda visualUpdateFlags    
        and #~vu_lvlNb                  ;Remove lvl nb from visual update flag     
        sta visualUpdateFlags    
    @renderVictories_Check:  
        lda nbPlayers                   ;Check if 2 players, if so, we render victories, if not we exit this routine
        cmp #$02                 
        beq @renderVictories     
        jmp @exit_render_palChange_or_bkgOverlays
    @renderVictories:        
        lda visualUpdateFlags           ;Check if victories (which occur at end of level) are marked for update
        and #vu_endLvl                 
        bne @renderVictories_p1         ;If not, exit this routine
        jmp @exit_render_palChange_or_bkgOverlays
    @renderVictories_p1:     
        lda p1_victories                ;Check if p1 has victories, if not we skip to p2 
        beq @renderVictories_p2  
        asl A                           ;Otherwise, we transform p1 victories into a zero-based index for 2-bytes addresses    
        tax                      
        dex                      
        dex                      
        lda crownsP1_PPUADDR+0,X 
        sta PPUADDR              
        sta PPUADDR_tmp_hi              ;PPUADDR is stored so that the second row of graphics is relative to first row
        lda crownsP1_PPUADDR+1,X 
        sta PPUADDR              
        sta PPUADDR_tmp_lo                
        lda #tileNb_crown_topLeft                    
        sta PPUDATA              
        lda #tileNb_crown_topRight                 
        sta PPUDATA              
        lda PPUADDR_tmp_lo              ;We then offset the low byte by 1 row in the nametable ($20 aka 32 tiles)       
        clc                      
        adc #vram_row                    
        sta PPUADDR_tmp_lo                
        lda #$00                        ;Increase the high byte if ever there is a carry
        adc PPUADDR_tmp_hi                
        sta PPUADDR              
        lda PPUADDR_tmp_lo                
        sta PPUADDR              
        lda #tileNb_crown_bottomLeft                    
        sta PPUDATA              
        lda #tileNb_crown_bottomRight                 
        sta PPUDATA              
    @renderVictories_p2:     
        lda p2_victories                ;Same principle as p1 victories, only starting from a different PPU address table
        beq @renderVictories_finished
        asl A                    
        tax                      
        dex                      
        dex                      
        lda crownsP2_PPUADDR+0,X    
        sta PPUADDR              
        sta PPUADDR_tmp_hi                
        lda crownsP2_PPUADDR+1,X 
        sta PPUADDR              
        sta PPUADDR_tmp_lo                
        lda #tileNb_crown_topLeft                
        sta PPUDATA              
        lda #tileNb_crown_topRight                 
        sta PPUDATA              
        lda PPUADDR_tmp_lo                
        clc                      
        adc #vram_row                                     
        sta PPUADDR_tmp_lo                
        lda #$00                 
        adc PPUADDR_tmp_hi                
        sta PPUADDR              
        lda PPUADDR_tmp_lo                
        sta PPUADDR              
        lda #tileNb_crown_bottomLeft                 
        sta PPUDATA              
        lda #tileNb_crown_bottomRight                 
        sta PPUDATA              
    @renderVictories_finished:
        lda visualUpdateFlags    
    if !bugfix
        and cutsceneFrame               ;Seems like it was meant to be an absolute address (#~vu_endLvl and thus #$7F), but that the zero page mode was used instead, resulting in a reference to cutsceneFrame (and thus $7F) 
    else 
        and #vu_endLvl_mask             ;Suggested bugfix (inconsequential) (for some reasons "~vu_endLvl" doesn't compile, so I went for a seperate constant "vu_endLvl_mask")
    endif 
        sta visualUpdateFlags    
    @exit_render_palChange_or_bkgOverlays:      
        rts                      


;;
;; render_optionsOverlays [$8518]
;;
;; This routine updates the vertical options selector, as well as level nb in the box on the right
;;
render_optionsOverlays:      
        lda visualUpdateFlags_options
        and #vu_options_ver_mask            ;Checks if there's anything to update beside vertical options selector, if so then it means a lvl change                 
        bne @options_checkIfLvlChange
        lda visualUpdateFlags_options       ;No lvl change so we check if vertical options cursor is on the level
    @options_checkIfOnLvl:   
        cmp #vu_options_ver_lvl                 
        bne @options_checkIfOnSpeed
    @options_onLvl:          
        jsr copyBkgOrPalToPPU               ;If so we update PPU with the corresponding data  
        .word bkgOptions_cursorOnLvl             
        lda #$00                            ;Then we reset the options visual update flag and exit this routine
        sta visualUpdateFlags_options
        jmp @exit_render_optionsOverlays
    @options_checkIfOnSpeed: 
        cmp #vu_options_ver_speed           ;Same as for options on level, but for speed
        bne @options_checkIfOnMusic
    @options_onSpeed:        
        jsr copyBkgOrPalToPPU         
        .word bkgOptions_cursorOnSpeed             
        lda #$00                 
        sta visualUpdateFlags_options
        jmp @exit_render_optionsOverlays
    @options_checkIfOnMusic: 
        cmp #vu_options_ver_music           ;Same as for options on level, but for music type        
        bne @exit_render_optionsOverlays    ;Exit the routine if not on music since we already checked if there was a level change
    @options_onMusic:        
        jsr copyBkgOrPalToPPU         
        .word bkgOptions_cursorOnMusic             
        lda #$00                 
        sta visualUpdateFlags_options
        jmp @exit_render_optionsOverlays
    @options_checkIfLvlChange:
    if !optimize
        lda visualUpdateFlags_options       ;Check if the level nb display needs update (we already know that it's the case from a previous check, probably safe to remove)
        and #vu_options_lvl_nb                 
        beq @exit_render_optionsOverlays
    endif 
    @options_lvlChange:      
        lda visualUpdateFlags_options       ;If so, reset the level nb display update flag  
        and #~vu_options_lvl_nb                                       
        sta visualUpdateFlags_options
        setPPUADDR_absolute lvlNbP1_VRAMaddr
        ;lda #$21                 
        ;sta PPUADDR              
        ;lda #$57                 
        ;sta PPUADDR              
        ldx p1_level                        ;Update player 1 level display (in decimal) according to table
        lda levelForDisplay,X  
        jsr renderLevelNb_2digits
        lda nbPlayers                       ;Check if there's 2 players, if so, update the level display for player 2 also  
        cmp #$02                 
        bne @exit_render_optionsOverlays
        setPPUADDR_absolute lvlNbP2_VRAMaddr
        ;lda #$21                 
        ;sta PPUADDR              
        ;lda #$B7                 
        ;sta PPUADDR              
        ldx p2_level             
        lda levelForDisplay,X  
        jsr renderLevelNb_2digits
    @exit_render_optionsOverlays:
        rts                      


;;
;; palChange [$858A]
;;
;; This routine changes the palette according to the current screen (based on the value stored in palToChangeTo)
;;
palChange:               
        lda palToChangeTo               ;Checks if palette to update is for a 1-player level  
        cmp #palNb_level_1P                 
        bne @palChange_check_title
        jsr copyBkgOrPalToPPU           ;If so, copy the 1-player level palette
        .word palLevel_1P              
        jsr setBkgColor_basedOnSpeed    ;Then update the color according to speed
        jmp resetPalToChangeTo          
    @palChange_check_title:  
        cmp #palNb_title                ;Basically the same for all the different screen palettes
        bne @palChange_check_options
        jsr copyBkgOrPalToPPU              
        .word palTitle              
        jmp resetPalToChangeTo
    @palChange_check_options:
        cmp #palNb_options                 
        bne @palChange_check_level2p
        jsr copyBkgOrPalToPPU             
        .word palOptions              
        jmp resetPalToChangeTo
    @palChange_check_level2p:
        cmp #palNb_level_2p                 
        bne @palChange_check_cutscene
        jsr copyBkgOrPalToPPU           
        .word palLevel_2P              
        jsr setBkgColor_basedOnSpeed    ;2-player level also has the same principle of chanding the color based on speed
        jmp resetPalToChangeTo
    @palChange_check_cutscene:
        cmp #palNb_cutscene                
        bne @palChange_check_cutscene_night
        jsr copyBkgOrPalToPPU            
        .word palCutscene              
        jmp resetPalToChangeTo
    @palChange_check_cutscene_night:
        cmp #palNb_cutscene_night                 
        bne @palChange_check_lv20Low_ending
        jsr copyBkgOrPalToPPU     
        .word palCutscene_night              
        jmp resetPalToChangeTo
    @palChange_check_lv20Low_ending:
        cmp #palNb_lvl20Low_ending                 
        bne @palChange_check_cutscene_UFO_fireworks
        jsr copyBkgOrPalToPPU     
        .word palLvl20Low_ending             
        jmp resetPalToChangeTo
    @palChange_check_cutscene_UFO_fireworks:
        cmp #palNb_cutscene_UFO_fireworks                 
        bne @palChange_check_cutscene_dusk1
        jsr copyBkgOrPalToPPU    
        .word palCutscene_UFO_fireworks_spritesOnly              
        jmp resetPalToChangeTo
    @palChange_check_cutscene_dusk1:
        cmp #palNb_cutscene_dusk1                 
        bne @palChange_check_cutscene_dusk2
        jsr copyBkgOrPalToPPU    
        .word palCutscene_dusk1             
        jmp resetPalToChangeTo
    @palChange_check_cutscene_dusk2:
        cmp #palNb_cutscene_dusk2                 
        bne @palChange_check_cutscene_lightning
        jsr copyBkgOrPalToPPU    
        .word palCutscene_dusk2              
        jmp resetPalToChangeTo
    @palChange_check_cutscene_lightning:
        cmp #palNb_cutscene_lightning                 
        bne @palChange_check_cutscene_fireworks
        jsr copyBkgOrPalToPPU    
        .word palCutscene_lightning             
        jmp resetPalToChangeTo
    @palChange_check_cutscene_fireworks:
        cmp #palNb_cutscene_fireworks                 
        bne resetPalToChangeTo
        jsr copyBkgOrPalToPPU    
        .word palCutscene_fireworks_bkgOnly              
        jmp resetPalToChangeTo
resetPalToChangeTo:   
        lda #$00                        ;Reset palToChangeTo then exit    
        sta palToChangeTo     
        rts                      


;;
;; setBkgColor_basedOnSpeed [$8627]
;;
;; Updates the last color of bkg palette 0, 1 and 3 according to the speed setting of the current player
;; Since the checks are done p1, then p2, this is why p2 speed always determines the bkg in 2 player game
;;
setBkgColor_basedOnSpeed:
        setPPUADDR_absolute (PPUPAL_BKG0+3)      ;Set the PPUADDR to fourth color of bkg 0 palette       
        ;lda #$3F                 
        ;sta PPUADDR              
        ;lda #$03                 
        ;sta PPUADDR              
        ldx currentP_speedSetting               ;Use current speed as index to get color to use
        lda bkgColor_basedOnSpeed,X
        sta PPUDATA
        setPPUADDR_absolute (PPUPAL_BKG1+3)      ;Do the same for bkg 1 palette            
        ;lda #$3F                 
        ;sta PPUADDR              
        ;lda #$07                 
        ;sta PPUADDR              
        ldx currentP_speedSetting
        lda bkgColor_basedOnSpeed,X
        sta PPUDATA
        setPPUADDR_absolute (PPUPAL_BKG3+3)      ;Do the same for bkg 3 palette            
        ;lda #$3F                 
        ;sta PPUADDR              
        ;lda #$0F                 
        ;sta PPUADDR              
        ldx currentP_speedSetting
        lda bkgColor_basedOnSpeed,X
        sta PPUDATA              
        rts                      


;;
;; renderLevelNb_2digits [$865E]
;;
;; This helper routine writes both digits of a decimal number to PPUDATA
;;
;; Input:
;;  a: holds a two digit decimal number
;;
;; Local variables:
levelNb_2digits = tmp47
renderLevelNb_2digits:   
        sta levelNb_2digits                
        and #$F0        ;Isolate the first digit              
        lsr A           ;Shift 4 times to the right to get first digit in the lower 4 bits, then store it         
        lsr A                    
        lsr A                    
        lsr A                    
        sta PPUDATA              
        lda levelNb_2digits                
        and #$0F        ;Isolate the second digit, store as is 
        sta PPUDATA              
        rts                      


;;
;; render_cutscene_txt [$8671]
;;
;; These bundled routines add or remove text during the cutscenes
;;
render_cutscene_txt:     
        lda cutsceneFrame               ;Check cutscene frame, if 0, nothing to render
        beq @exit_render_cutscene_txt   
        cmp #$80                        ;If frame is $80 or more, this means text has to be removed
        bcs _cutscene_removeTxt           
        lda frameCounter                ;Update cutscene text only every txtScrollSpeed_cutscene frames from the frame COUNTER (not cutscene frame) (8 frames in vanilla)
        and #txtScrollSpeed_cutscene                 
        bne @exit_render_cutscene_txt   
        lda cutsceneFrame               ;Store the cutscene frame in X to use as an index later
        tax                      
        lda #sq0_letter_cutscene        ;Play sfx for letter added                 
        sta sfx_toPlay_sq0     
        lda #>cutsceneText_VRAMaddr     ;All text shares the same high byte address, and gets low byte and data from a table        
        sta PPUADDR              
        lda cutsceneText_PPUaddr,X
        sta PPUADDR              
        lda cutsceneText,X     
        jsr _cutsceneText_interpreter
        inc cutsceneFrame               ;Increase cutscene frame. If not $FF, exit routine. Otherwise the cutscene is finished   
        cmp #$FF                                      
        bne @exit_render_cutscene_txt
        lda #$00                        
        sta cutsceneFrame
    @exit_render_cutscene_txt:
        rts 

_cutsceneText_interpreter:
        bne @cutscene_lvlNb_check       ;Current cutsceneText data is in A. If $00, we add the level speed text, otherwise, check if we add lvl
    @cutscene_speedTxt:      
        lda currentP_speedSetting       ;Multiply current speed setting by four to get an index for the 3-letter speed text
        asl A                    
        asl A                    
        tax                      
        lda cutsceneText_speed+0,X
        sta PPUDATA             
        lda cutsceneText_speed+1,X      
        sta PPUDATA              
        lda cutsceneText_speed+2,X
        sta PPUDATA            
        rts                      
    @cutscene_lvlNb_check:   
        cmp #$01                        ;Current cutsceneText data is in A. If $01, we add the level nb, otherwise, data is a single letter
        bne @cutscene_txt_singleLetter
    @cutscene_lvlNb:         
        ldx currentP_level       
        dex                             ;Decrease by one because level was increased prior to cutscene 
        lda levelForDisplay,X  
    if !optimize    
        and #$F0                        ;Exact replica of the renderLevelNb_2digits helper routine              
        lsr A                    
        lsr A                    
        lsr A                    
        lsr A                    
        sta PPUDATA              
        lda levelForDisplay,X  
        and #$0F                                        
        sta PPUDATA              
        rts 
    else 
        jmp renderLevelNb_2digits
    endif 
    @cutscene_txt_singleLetter:
        sta PPUDATA                     ;Current cutsceneText letter is in A, store as is             
        rts 
                      
_cutscene_removeTxt:     
        lda cutsceneFrame               ;Drop highest bit from cutscene frame (is the equivalent of subtracting $80) 
        and #$7F                                        
        tax                             ;Set the PPUADDR similarly to how it is done in the render_cutscene_txt routine                     
        lda #>cutsceneText_VRAMaddr                 
        sta PPUADDR              
        lda cutsceneText_PPUaddr,X
        sta PPUADDR              
        lda cutsceneText,X     
        jsr _cutsceneText_remove_interpreter
        inc cutsceneFrame        
        lda cutsceneText,X              ;If cutscene text data is $FF, then cutscene is finished, otherwise, exit routine
        cmp #$FF                                         
        bne @exit_cutscene_removeTxt
        lda #$00                 
        sta cutsceneFrame        
    @exit_cutscene_removeTxt:
        rts 

_cutsceneText_remove_interpreter:
        bne @cutscene_removeTxt_lvlNb_check     ;Same principle as cutsceneText_interpreter, but for removing characters instead of adding them  
        lda #$FF                 
        sta PPUDATA                             ;Speed is 3 letters long           
        sta PPUDATA              
        sta PPUDATA              
        rts                      
    @cutscene_removeTxt_lvlNb_check:
        cmp #$01                                
        bne @cutscene_removeTxt_singleLetter
        lda #$FF                 
        sta PPUDATA                             ;lvlNb is 2 letters long 
        sta PPUDATA              
        rts                               
    @cutscene_removeTxt_singleLetter:
        lda #$FF                                ;Everything else is 1-letter long
        sta PPUDATA              
        rts                      