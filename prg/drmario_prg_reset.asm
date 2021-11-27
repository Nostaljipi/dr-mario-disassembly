;;
;; reset handler [$FF00]
;;
;; 
;; 

reset:                   
        cld                     ;Clear decimal             
        sei                     ;Set interrupt
        ldx #$00                 
        stx PPUCTRL             ;Init PPU controller and mask (+ RAM)         
        stx PPUMASK
    if ver_revA              
        stx PPUMASK_RAM
    endif           
    @waitForPPUStatus_step1: 
        lda PPUSTATUS           ;Wait for 2 v-blank to start   
        bpl @waitForPPUStatus_step1
    @waitForPPUStatus_step2: 
        lda PPUSTATUS            
        bpl @waitForPPUStatus_step2
    @ppuStatus_finished:     
    if !ver_EU
        dex 
    else 
        ldx #$FF
    endif 
        txs                     ;Initiates the stack pointer to $FF
        inc reset               ;Value at this address must be $80 or higher to reset the MMC properly (vanilla rom = $FF00)
        lda #mmc_chr_4kb + mmc_prg_switch + mmc_mirroring_one_lower               
        jsr basicMMCConfig      ;Perform a couple MMC operations  
        lda #CHR_titleSprites                 
        jsr changeCHRBank0       
        lda #CHR_titleTiles_frame0                 
        jsr changeCHRBank1       
        lda #$00                ;We never change PRG, always set to the same 32 kb                
        jsr changePRGBank        
        jmp toInit              ;Finally, jump to init