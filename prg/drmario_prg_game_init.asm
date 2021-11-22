;;
;; toInit [$8000]
;;
;; This routine is called by the reset handler, and simply jumps to the game init routine 
;; 
toInit:
    if !removeMoreUnused
        ldx #$00                        ;The value stored in x is never used. Seems to be used by unused MMC1 config routine (ldx has its bit 7 set, so writing this value would clear the shift register)           
    endif 
        jmp init          


;;
;; nmi [$8005]
;;
;; The nmi handler, renders graphics, increases the frame counter and gets players (or demo) inputs
;;
nmi:                 
        pha                             ;Store the values from registers A,X,Y in the stack
        txa                      
        pha                      
        tya                      
        pha                      
        lda PPUMASK_RAM                 ;Write to PPUMASK register according to value set in RAM (can change, for instance, when pausing)                             
        sta PPUMASK         
        jsr render_sprites              ;Render all things that can change/move while staying in the same screen       
        jsr render_palChange_or_bkgOverlays         
        jsr render_fieldRow_bothPlayers
        jsr render_cutscene_txt      
        lda frameCounter                ;Increase the frame counter         
        clc                      
        adc #$01                 
        sta frameCounter         
        lda #$00                        ;There is no background scrolling, so x and y both stay at 0                 
        sta PPUSCROLL       
        sta PPUSCROLL       
        lda #$01                        ;Sets the nmiFlag to indicate a nmi just occured
        sta nmiFlag             
        jsr getInputs_checkMode         ;Gets either players inputs, or demo inputs, depending on the current mode
        lda #$00                        ;Now that we have rendered the sprites, reset the sprite pointer
        sta spritePointer
        pla                             ;Restore the values of registers Y,X,A                     
        tay                      
        pla                      
        tax                      
        pla                             ;Continues into the next routine for the rti


;;
;; irq [$803A]
;;
;; IRQs are not used in this game, hence the single rti
;;
irq:                 
        rti


;;
;; init [$803B]
;;
;; Reset and cold boot memory init + PPU and APU registers init, then main loop
;;
;; Local variables:
currentLetter = tmp47
init: 
        lda p1_level                ;Saves option menu settings             
        sta p1_level_tmp        
        lda p2_level             
        sta p2_level_tmp        
        lda p1_speedSetting      
        sta p1_speedSetting_tmp 
        lda p2_speedSetting      
        sta p2_speedSetting_tmp 
        ldy #>(persistentRAM-1)     ;Wipe all non-persistent RAM (from $00 to $06FF)
        sty ptr_hi                  
        ldy #$00                 
        sty ptr_lo                  
        lda #$00                    ;Sets everything to value $00
    @wipeMemory:         
        sta (ptr),Y                
        dey                      
        bne @wipeMemory             ;Inner loop (256x)
        dec tmp1                  
        bpl @wipeMemory             ;Outer loop (7x)
    @restoreOptionSettings:
        lda p1_level_tmp            ;Restore option menu settings  
        sta p1_level             
        lda p2_level_tmp         
        sta p2_level             
        lda p1_speedSetting_tmp  
        sta p1_speedSetting      
        lda p2_speedSetting_tmp  
        sta p2_speedSetting      
        ldx #gameName_length        ;Checks if the game name is loaded in RAM
    @gameNameLoadedValidation:      
        lda gameName_RAM-1,X         
        sta currentLetter                
        lda gameName_ROM-1,X       
        cmp currentLetter                
        bne @coldBootInit           ;This is used to see if this is a cold boot or reset (name already loaded = reset)   
        dex                      
        bne @gameNameLoadedValidation
        jmp @storeRngSeeds
    @coldBootInit:           
    if !removeMoreUnused
        ldx #$00                    ;Not sure what this is used for
    endif            
        lda #$FF                    ;Wipe all memory from $700 to $07FF, using value $FF                 
        ldx #>persistentRAM                 
        ldy #>persistentRAM_end                 
        jsr copy_valueA_fromX00_toY00_plusFF    
        lda #$00                    ;Sets highscore to 1000 (display actually adds a 0 at the end to give the impression that it is 10x higher)
        sta highScore+0          
        sta highScore+1          
        sta highScore+2          
        sta highScore+4          
        sta highScore+5          
        lda #$01                 
        sta highScore+3          
        lda #$00                    ;Sets game config  
    if !optimize
        sta config_bypassSpeedUp                
        sta config_pillsStayMidAir
    endif 
        sta lvlsOver20           
        sta p1_level             
        sta p2_level             
        sta musicType            
        lda #$01                 
    if !removeMoreUnused
        sta config_unknown720
    endif                   
        sta nbPlayers            
        sta p1_speedSetting      
        sta p2_speedSetting
    if !removeMoreUnused              
        lda #$02                 
        sta config_unknown722
    endif                   
        lda #$03                 
        sta config_victoriesRequired            
        ldx #gameName_length        ;Copies game name from ROM to RAM             
    @copyGameName:           
        lda gameName_ROM-1,X       
        sta gameName_RAM-1,X     
        dex                      
        bne @copyGameName        
    @storeRngSeeds:          
        ldx #rngSeed                ;Store rng seed              
        stx rng0                 
        dex                      
        stx rng1
    @initPPUandAPU:                  
        ldy #$00                    ;Scroll position at 0,0
        sty PPUSCROLL_x          
        sty PPUSCROLL            
        ldy #$00                 
        sty PPUSCROLL_y          
        sty PPUSCROLL            
        lda #ppuctrl_nmi_on + ppuctrl_bkg_tbl_1              
        sta PPUCTRL_RAM             ;Generate an NMI at the start of the vertical blanking interval + background pattern table address = $1000
        sta PPUCTRL                           
        lda #ppumask_bkg_col1_enable + ppumask_spr_col1_enable              
        sta PPUMASK                 ;Show background + sprites in leftmost 8 pixels of screen, disable rendering              
        sta PPUMASK_RAM          
    if !optimize
        jsr toInitAPU_status        ;Init APU status and variables for each channels
        jsr toInitAPU_var_chan
    else 
        jsr initAPU_status
        jsr initAPU_variablesAndChannels   
    endif 
        lda #$C0                    ;*NOTE: Don't know what both these addresses are for, maybe some fallback in case of overflow?
        sta stack+0              
        lda #$80                 
        sta stack+1              
        lda #$35                        
        sta stack+3              
        lda #$AC                 
        sta stack+4              
        jsr audioUpdate_NMI_disableRendering
        jsr NMI_off           
        lda #>nametable0            ;Clears all 4 nametables
        jsr initPPU_addrA_hiByte 
        lda #>nametable1            ;*NOTE: It seems these are mirrored, so maybe we don't need to init all 4 nametables?       
        jsr initPPU_addrA_hiByte 
        lda #>nametable2                 
        jsr initPPU_addrA_hiByte 
        lda #>nametable3                 
        jsr initPPU_addrA_hiByte 
        lda #$00                 
        sta flag_inLevel_NMI        ;We are not in a level at this moment (heading to title screen)
        jsr initField_bothPlayers   ;Clear both players field RAM
        jsr finishVblank_NMI_on
        jsr visualAudioUpdate_NMI   ;Couple of updates (visual + audio), making sure everything is properly initiated
        jsr audioUpdate_NMI_enableRendering
        jsr visualAudioUpdate_NMI
    if !removeMoreUnused        
        lda #$0E                 
        sta flag_initDone           ;Sets a flag that is, as far as I know, never used
    endif 
    @mainLoop:               
        jsr toModeAddress               ;Loops in this when exiting any mode
        jsr checkPauseReset      
        jsr visualAudioUpdate_NMI
    if !removeMoreUnused
        jsr initUnusedSpriteRAM         ;This seems useless because sprite RAM is always reset in previous subroutine
    endif 
        jmp @mainLoop            


;;
;; toModeAddress [$8167]
;;
;; This routine changes the game's "mode", or current screen if you will
;;
toModeAddress:           
        lda mode                 
        jsr toAddressAtStackPointer_indexA
    _jumpTable_mode:
        .word toTitle
        .word toDemo_orOptions
        .word toLevel
        .word initData_level
        .word mainLoop_level
        .word anyPlayerLoses
    if !removeMoreUnused
        .word toMode4
    endif 
        .word playerLoses_endScreen
        .word levelIntro              