;;
;; toLevel [$817E]
;;
;; Changes the background, init score/victories and move on to next mode
;;
toLevel:                 
        jsr audioUpdate_NMI_disableRendering    ;Disable rendering while changing graphics
        jsr NMI_off          
        lda #CHR_levelSprites                   ;Load level sprites
        jsr changeCHRBank0       
    if !optimize
        lda #CHR_titleTiles_frame0              ;Why is the title CHR loaded for a brief moment?                 
        jsr changeCHRBank1       
    endif 
        lda nbPlayers                           ;Depending on nb of players, prep approriate visual           
        cmp #$01                 
        bne @prepLevelVisual_2P  
        jsr prepLevelVisual_1P   
        jmp @initLevelRAM         
    @prepLevelVisual_2P:     
        jsr copyBkgOrPalToPPU                   ;Copy 2-player level bkg to PPU nametable
    @bkgLevel_2P_ptr:        
        .word bkgLevel_2P             
    @displaySpeedText_2P:     
        setPPUADDR_absolute speedText_P1_VRAMaddr   ;Display speed text for player 1 (as bkg, not sprite)
        ;lda #>speedText_P1_VRAMaddr                 
        ;sta PPUADDR              
        ;lda #<speedText_P1_VRAMaddr                  
        ;sta PPUADDR              
        lda p1_speedSetting      
        asl A                    
        asl A                    
        tax                      
        lda textLevelSpeed+0,X   
        sta PPUDATA              
        lda textLevelSpeed+1,X   
        sta PPUDATA              
        lda textLevelSpeed+2,X   
        sta PPUDATA              
        setPPUADDR_absolute speedText_P2_VRAMaddr   ;Display speed text for player 2 (as bkg, not sprite)
        ;lda #>speedText_P2_VRAMaddr                 
        ;sta PPUADDR              
        ;lda #<speedText_P2_VRAMaddr                  
        ;sta PPUADDR              
        lda p2_speedSetting      
        asl A                    
        asl A                    
        tax                      
        lda textLevelSpeed+0,X   
        sta PPUDATA              
        lda textLevelSpeed+1,X   
        sta PPUDATA              
        lda textLevelSpeed+2,X   
        sta PPUDATA              
        lda #palNb_level_2p                  ;Indicate that we have changed screen              
        sta palToChangeTo        
    @initLevelRAM:            
        lda #$FF                                ;We are in a level, so set the level flag for level sprites          
        sta flag_inLevel_NMI              
        jsr finishVblank_NMI_on
        jsr audioUpdate_NMI_enableRendering
        lda #$0F                                ;Still not completely sure how the status works, but seems to hold the value of current playfield row being rendered 
        sta currentP_status      
        jsr initField_bothPlayers
        lda #$00                                ;Reset score regardless of if we play 1 or 2 players  
        sta score+0              
        sta score+1              
        sta score+2              
        sta score+3              
        sta score+4              
        sta score+5              
        sta p1_victories                        ;Reset victories regardless of if we play 1 or 2 players     
        sta p2_victories         
        inc mode                                ;Increase mode to initData_level (which is the next routine)
        rts                      


;;
;; initData_level [$8216]
;;
;; Init many variables, generates pill reserve, determines how many viruses to add and which music to play
;;
initData_level:          
        lda #$00                        ;Init a whole lot of variables
        sta currentP_speedCounter
        sta currentP_fieldPointer
        sta currentP_comboCounter
        sta currentP_chainLength 
        sta currentP_attackSize  
        sta currentP_nextAction  
        sta currentP_pillPlacedStep
    if !removeMoreUnused
        sta currentP_UNK_88             ;This value seems never used anywhere
    endif 
        sta currentP_levelFailFlag
        sta currentP_status      
        sta currentP_pillsCounter_decimal
        sta currentP_pillsCounter_hundreds
        sta pillThrownFrame      
        sta currentP_pillsCounter
        sta lvlsOver20           
        sta bigVirusYellow_state 
        sta bigVirusRed_state    
        sta bigVirusBlue_state   
        sta bigVirusYellow_frame 
        sta bigVirusRed_frame    
        sta bigVirusBlue_frame   
        sta bigVirusYellow_health
        sta bigVirusRed_health   
        sta bigVirusBlue_health  
        sta marioThrowFrame      
        sta whoFailed            
        sta whoWon               
        sta bigVirus_circularPos 
        lda #nextAction_sendPill                
        sta currentP_nextAction  
        lda #player1                 
        sta currentP             
        lda #$FF                        ;Enable pause  
        sta enablePause          
        lda lvlsOver20           
        sta currentP_speedUps           ;Starts 1 step further in speed table for each level over 20
        sta currentP_speedIndex  
        jsr generatePillsReserve        ;Same reserve used by both players
        jsr generateNextPill     
        jsr generateNextPill            ;Unsure why this is called twice here, but if not, it screws with the pills in the demo
        lda #$01                        ;Start counting pills sent
        sta currentP_pillsCounter_decimal
        jsr storeStatsAndOptions 
        jsr currentP_toP1               ;Both players start with same init
        jsr currentP_toP2    
        jsr restoreStatsAndOptions
        lda p1_level                    ;Then perform some calculations to find how many viruses to add  
        cmp #selectableLvCap+1                 
        bmi @setVirusToAdd              ;If player level doesn't surpass the selectable level cap, add viruses now
        sec                             ;Otherwise, store overflow of level cap in appropriate variable
        sbc #selectableLvCap                 
        sta lvlsOver20           
        lda #selectableLvCap            ;And use the level cap as basis for virus quantity            
    @setVirusToAdd:          
        clc                             ;Nb of virus = (lvNb + 1) * 4
        adc #$01                 
        asl A                    
        asl A                    
        sta p1_virusToAdd           
        lda p2_level                    ;No need to check level cap for player 2     
        clc                      
        adc #$01                 
        asl A                    
        asl A                    
        sta p2_virusToAdd        
        lda #vu_all                        
        sta visualUpdateFlags           ;Mark pretty much everything visual for update
        ldx musicType                   ;Play selected music
        lda selectableMusicIndex,X
        sta music_toPlay          
        jsr visualAudioUpdate_NMI
        rts                      


;;
;; generatePillsReserve [$82B0]
;;
;; Generates a pills reserve of a given size
;;
;; Local variables:
pillsToGenerate = tmp47
pillId = tmp48                  ;An index number that determines what color combination will we get for the pill
generatePillsReserve:    
        lda #pillsReserveSize   ;Equals to the number of pills to generate           
        sta pillsToGenerate                
        lda #$00                ;Init the pill ID to zero for starters, could be any valid value 
        sta pillId           
    @generateNewPill:        
        generateRandNum
        ;ldx #rng0               ;Generate 2 random bytes (even though we will only be using the first)
        ;ldy #rngSize                 
        ;jsr randomNumberGenerator
        ldx pillsToGenerate     ;Since x here is the index where the pill is stored, we need to substract 1 to make it zero-based           
        dex                      
        lda rng0                ;Max the rng value at 15 
        and #$0F                 
        clc                     ;Add to index of previous pill (probably as a means to improve random)
        adc pillId               
    @checkIfValidIndex:      
        sta pillId                
        cmp #colorCombination_right - colorCombination_left                
        bcc @storePill          ;If within the array size (9), is a valid pill index  
    @invalidIndex:           
        sec                     ;If not, then substract the array size (9) and try again 
        sbc #colorCombination_right - colorCombination_left                
        jmp @checkIfValidIndex   
    @storePill:              
        sta pillsReserve,X      ;Starts from the end of the array
        dec pillsToGenerate                
        bne @generateNewPill     
    @pillsReserveComplete:   
        lda #mode_levelIntro    ;Once no more pills to generate, go to level intro next             
        sta mode                 
        rts      


;;
;; prepLevelVisual_1P [$82E1]
;;
;; Changes the bakground for 1-player level (pretty much a copy-paste of its 2-player equivalent seen in previous routine)
;;
prepLevelVisual_1P:      
        jsr copyBkgOrPalToPPU   ;Copy 1-player level bkg to PPU nametable      
    @bkgLevel_1P_ptr:        
        .word bkgLevel_1P             
    @displaySpeed_1P:         
        lda #palNb_level_1P  ;Indicate that we have changed screen                 
        sta palToChangeTo        
        lda p1_speedSetting     ;Display speed text for player 1 (as bkg, not sprite)  
        asl A                    
        asl A                    
        tax                      
        ldy #textLevelSpeedSize           
        setPPUADDR_absolute speedText_1P_VRAMaddr
        ;lda #>speedText_1P_VRAMaddr                 
        ;sta PPUADDR              
        ;lda #<speedText_1P_VRAMaddr                 
        ;sta PPUADDR              
    @displaySpeed_1P_loop:   
        lda textLevelSpeed,X   
        sta PPUDATA              
        inx                      
        dey                      
        bne @displaySpeed_1P_loop
        rts                   