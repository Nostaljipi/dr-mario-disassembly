;;
;; visualAudioUpdate_NMI [$B66E]
;;
;; Performs visual and audio update then waits for a NMI, then clear sprites memory. Effectively advances 1 frame.
;; This routine is called every frame when not changing screen
;;
visualAudioUpdate_NMI:                              
        lda flag_inLevel_NMI                        
        beq @audioUpdate_then_clearNMIFlag          ;If not in level, skip the level sprites update
        jsr updateSprites_lvl    
    @audioUpdate_then_clearNMIFlag:
    if !optimize
        jsr toAudioUpdate
    else 
        jsr audioUpdate
    endif         
        lda #$00                 
        sta nmiFlag              
    @NMI_then_clearSprites:  
        lda nmiFlag                                 ;Loop here until return from NMI           
        beq @NMI_then_clearSprites
        lda #$FF                                    ;This resets the sprite memory       
        ldx #>sprites                               
        ldy #>sprites                 
        jsr copy_valueA_fromX00_toY00_plusFF
        rts                      

;;
;; audioUpdate_then_NMI [$B68A]
;;
;; Performs audio update then waits for a NMI. Only called when changing screen (except pause).
;;
audioUpdate_then_NMI:    
    if !optimize
        jsr toAudioUpdate
    else 
        jsr audioUpdate
    endif                               
        lda #$00                 
        sta nmiFlag              
    @waitNMI:                
        lda nmiFlag              
        beq @waitNMI             
        rts                      

;;
;; audioUpdate_NMI_disableRendering [$B696]
;;
;; Performs audioUpdate_then_NMI then disables rendering
;;
audioUpdate_NMI_disableRendering:
        jsr audioUpdate_then_NMI 
        lda PPUMASK_RAM          
        and #~ppumask_enable_all    ;This disables rendering            
    _setPPUMASK:                     
        sta PPUMASK                 ;This sub routine part is used by the next routine as well
        sta PPUMASK_RAM          
        rts                      

;;
;; audioUpdate_NMI_enableRendering [$B6A3]
;;
;; Performs audioUpdate_then_NMI then enables rendering
;;
audioUpdate_NMI_enableRendering:
        jsr audioUpdate_then_NMI 
        jsr setPPUSCROLL_and_PPUCTRL
        lda PPUMASK_RAM          
        ora #ppumask_enable_all     ;This enables rendering
        bne _setPPUMASK          

;;
;; finishVblank_NMI_on [$B6AF]
;;
;; As its name suggests, finishes vblank then enables NMI
;;
finishVblank_NMI_on: 
        lda PPUSTATUS            
        and #ppustatus_vblank_in                           
        bne finishVblank_NMI_on         ;Loop this while in vblank
        lda PPUCTRL_RAM                 
        ora #ppuctrl_nmi_on             ;Then enable NMI                 
        bne _storeA_PPUCTRL      

;;
;; NMI_off [$B6BC]
;;
;; Simply deactivates NMI
;;
NMI_off:              
        lda PPUCTRL_RAM          
        and #ppuctrl_nmi_off_mask       ;Deactivates NMI   (~ppuctrl_nmi_on does not compile)              
    _storeA_PPUCTRL:         
        sta PPUCTRL                     ;This sub routine part is used by the previous routine as well    
        sta PPUCTRL_RAM          
        rts                      

;;
;; initPPU_addrA_hiByte [$B6C6]
;;
;; Simply sets the values to use to init PPU memory
;;
;; Input:
;;  A = high byte of PPU address to init
;; 
initPPU_addrA_hiByte:    
        ldx #$FF                        ;Value used to init PPU nametable                 
        ldy #$00                        ;Value used to init PPU attribute table
        jsr initPPU_addrA_dataX_then_attrY
        rts                      

;;
;; setPPUSCROLL_and_PPUCTRL [$B6CE]
;;
;; Sets the PPUSCROLL to coordinates 0,0 and updates PPUCTRL with RAM
;;
setPPUSCROLL_and_PPUCTRL:
        lda #$00                 
        sta PPUSCROLL       ;x camera position         
        sta PPUSCROLL       ;y camera position      
        lda PPUCTRL_RAM          
        sta PPUCTRL              
        rts                      

;;
;; copyBkgOrPalToPPU [$B6DC]
;;
;; Copies the nametable data for a bkg or palette from RAM to PPU
;;
;; Input:
;;  The address to the data for the bkg/pal must be right after the  "jsr copyBkgOrPalToPPU" used to get to this routine (this is because we use stack manipulations to access this data)
;;
copyBkgOrPalToPPU:       
        jsr getPointer_fromStack    ;This gets the data address in ram address "ptr"
        jmp @getBkgData_nextByte 
    @setPPUADDR:             
        pha                     ;High byte of PPUADDR is pushed to stack         
        sta PPUADDR              
        iny                      
        lda (ptr),Y             ;Low byte is next in bkg data 
        sta PPUADDR              
        iny                      
        lda (ptr),Y             ;Next is the number of tiles to add 
        asl A                   ;Doubled than stored in stack, if a bit gets in carry, we store PPUDATA vertically, otherwise, we stay horizontal 
        pha                      
        lda PPUCTRL_RAM          
        ora #ppuctrl_vram_dir_down  ;PPUDATA will be added vertically       
        bcs @setPPUCTRL          
        and #~ppuctrl_vram_dir_down ;PPUDATA will be added horizontally
    @setPPUCTRL:             
        sta PPUCTRL              
        sta PPUCTRL_RAM          
        pla                     ;Restore number of tiles to add 
        asl A                   ;Double again, could potentially set the carry flag
        php                     ;Push processor status 
        bcc @checkIfTilesToAdd_isZero
        ora #$02                ;Never gets here, but it would if we added $40 tiles at a time instead of the usual row of $20, seems to be some sort of compression method (when having to fill entire rows with the same tile)   
        iny                      
    @checkIfTilesToAdd_isZero:
        plp                     ;Pull processor status then clear carry                      
        clc                      
        bne @restoreTilesToAdd   
        sec                     ;Never gets here, but makes so that if tiles to add is now zero, the next ROR and LSR will result in $40 (64) tiles 
    @restoreTilesToAdd:      
        ror A                    
        lsr A                    
        tax                     ;Tiles to add is now in x, and carry is set if we tried to add $40 tiles 
    @fill_PPUDATA_loop:         ;Most of the times, this loops for 1 row (32 tiles) (except maybe for palette data)
        bcs @storeBkgData_PPUDATA
        iny                     ;Gets the next tile in the data if carry bit is not set 
    @storeBkgData_PPUDATA:   
        lda (ptr),Y             
        sta PPUDATA              
        dex                      
        bne @fill_PPUDATA_loop   
    @checkIf_PPUADDR_3F:     
        pla                     ;High byte of PPUADDR is recovered from stack  
        cmp #>PPUPAL            ;Check if we just filled the palette data    
        bne @updateBkgDataPointer
    @reset_PPUADDR:             ;If so, then reset PPUADDR
    if !optimize
        sta PPUADDR             ;This seems unncessary since only the last two writes will count         
        stx PPUADDR              
    endif  
        stx PPUADDR              
        stx PPUADDR  
    @updateBkgDataPointer:   
        sec                      
        tya                      
        adc ptr_lo              ;Add data offset   
        sta ptr_lo                 
        lda #$00                 
        adc ptr_hi              ;This takes care of anything that carries over  
        sta ptr_hi                 
    @getBkgData_nextByte:       ;Here is the actual enrty to this routine
        ldx PPUSTATUS           ;Read PPUSTATUS, store it in x (not sure if the storing is useful though)     
        ldy #$00                 
        lda (ptr),Y             ;Get the first byte at the address from the pointer (aka, the actual bkg/pal data)
        bpl @bkgData_checkIf60   
        rts                     ;If it reaches a $FF then it means the bkg is fully loaded           
    @bkgData_checkIf60:      
        cmp #bkgData_restorePtr                 
        bne @bkgData_checkIf4C   
        pla                     ;Code never gets there... it seems to return back to the original bkg after jumping to a "sub" bkg (see next part of this routine)    
        sta ptr_hi                 
        pla                      
        sta ptr_lo                 
        ldy #$02                ;Restore previous data pointer from stack plus 2 bytes     
        bne @updateBkgDataPointer
    @bkgData_checkIf4C:      
        cmp #bkgData_changePtr                 
        bne @setPPUADDR          
        lda ptr_lo              ;Code never gets there... it seems to essentially change the bkg data address temporarily (ex: to reuse bkg parts from another bkg)     
        pha                      
        lda ptr_hi              ;Backs up both ptr_lo and ptr_hi    
        pha                      
        iny                      
        lda (ptr),Y             ;Get next 2 bytes in bkg data  
        tax                      
        iny                      
        lda (ptr),Y             
        sta ptr_hi              ;Then they become the new address for the bkg data    
        stx ptr_lo                 
        bcs @getBkgData_nextByte 

;;
;; getPointer_fromStack [$B765]
;;
;; As its name suggest, this gets a pointer from the stack
;; 
;; Input:
;;  The address we want to be the pointer must the before-last address on the stack (in other words, two jsr ago)
;;
getPointer_fromStack:    
        tsx                      
        lda stack+3,X           ;Gets before to last stack address that was accessed (low byte)  
        sta ptrTemp_low          
        lda stack+4,X           ;Gets before to last stack address that was accessed (high byte)   
        sta ptrTemp_high         
        ldy #$01                 
        lda (ptrTemp_low),Y      
        sta ptr_lo              ;Gets the value in the first byte following before to last stack address (becomes the low byte of the address we want to go t)    
        iny                      
        lda (ptrTemp_low),Y      
        sta ptr_hi              ;Gets the value in the second byte following before to last stack address (becomes the high byte of the address we want to go to)    
        clc                      
        lda #$02                ;Then increase the stack address that was "pulled" so that we jump over the data when returning  
        adc ptrTemp_low          
        sta stack+3,X            
        lda #$00                ;This here is in case we need to add carry        
        adc ptrTemp_high         
        sta stack+4,X            
        rts                      

;;
;; randomNumberGenerator [$B78B]
;;
;; Generates random number(s) into a given address
;; Always used with x=$17 and y=$02... fill 2 bytes, starting at memory $17 
;;
;; Inputs:
;;  X: The address at which to start generating random number(s)
;;  Y: The qty of numbers (and thus bytes)
;; 
;; Local variables:
rng0_tmp = tmp0

randomNumberGenerator:   
        lda rng0_offset,X                  
        and #$02        ;Get the number currently at the specified rnd address, then reduce it to either 0 or 2                
        sta rng0_tmp                 
        lda rng1_offset,X               
        and #$02        ;We do the same for a second address          
        eor rng0_tmp    ;Then we EOR to get either a 0 or 2, which will impact if we set the carry or not                 
        clc                      
        beq @RNG_loop            
        sec             ;Set carry if EOR was 2          
    @RNG_loop:               
        ror rng0_offset,X   ;ror gets us a new number, which can vary depending on carry flag status             
        inx             ;Increase to next address           
        dey             ;Decrease qty of rng numbers left to change           
        bne @RNG_loop   ;Loop until y = 0         
        rts                      

;;
;; render_sprites [$B7A2]
;;
;; Copies sprite data from RAM to PPUOAM
;;
render_sprites:          
        lda #$00        ;Init OAMADDR              
        sta OAMADDR              
        lda #>sprites   ;Copy all 256 bytes from $0200 to PPUOAM               
        sta OAMDMA               
        rts                      

;;
;; get_CTRL_inputs [$B7AD]
;;
;; Strobes controllers then reads button inputs for both controllers (as well as expansion ports for Famicom)
;;
get_CTRL_inputs:         
        ldx ctrlPort             
        inx                                  
        stx CTRL1                
        dex                      
        stx CTRL1               ;1/0 write to get button states 
        ldx #$08                ;Then eight sequential reads       
    @read_CTRL_loop:         
        lda CTRL1                
        lsr A                    
        rol p1_btns_pressed     ;Data from standard controller goes here   
        lsr A                    
        rol CTRL_exp1           ;Data from expansion port goes here (Famicom only)   
        lda CTRL2               ;Same principle for controller 2 and expansion 2   
        lsr A                    
        rol p2_btns_pressed      
        lsr A                    
        rol CTRL_exp2                 
        dex                      
        bne @read_CTRL_loop      
        rts                      

;;
;; addExpansionCTRL [$B7CF]
;;
;; Expansion controllers are considered duplicates of controllers 1 and 2 in this game. In other words, inputs from player 1 is the addition of inputs for controller 1 and expansion 1.
;;
addExpansionCTRL:        
        lda CTRL_exp1                 
        ora p1_btns_pressed      
        sta p1_btns_pressed      
        lda CTRL_exp2                 
        ora p2_btns_pressed      
        sta p2_btns_pressed      
        rts                      

if !removeUnused
    getInputs_UNUSED:        
            jsr get_CTRL_inputs     ;Looks like this simply skips the redundancy check for buttons pressed if no button presses are detected.  
            beq _pressedVsHeld       
endif

;;
;; getInputs [$B7E1]
;;
;; Get inputs twice to ensure accuracy, then process which ones are held or simply pressed
;;
;; Local variables:
p1_btns_pressed_tmp     = tmp48
p2_btns_pressed_tmp     = tmp49
getInputs:               
        jsr get_CTRL_inputs      
        jsr addExpansionCTRL     
        lda p1_btns_pressed      
        sta p1_btns_pressed_tmp                
        lda p2_btns_pressed      
        sta p2_btns_pressed_tmp                
        jsr get_CTRL_inputs     ;Redundancy to ensure the button press was not a false positive 
        jsr addExpansionCTRL     
        lda p1_btns_pressed      
        and p1_btns_pressed_tmp     
        sta p1_btns_pressed      
        lda p2_btns_pressed      
        and p2_btns_pressed_tmp                
        sta p2_btns_pressed      
    _pressedVsHeld:             
        ldx #$01                ;Loop once each time for each controller   
    @pressedVsHeld_loop:     
        lda p1_btns_pressed,X    
        tay                      
        eor p1_btns_held,X       
        and p1_btns_pressed,X    
        sta p1_btns_pressed,X   ;If a button was held, do not count as pressed   
        sty p1_btns_held,X      ;Keeps held, adds newly pressed, removes not held anymore (in other words, currently pressed buttons)    
        dex                      
        bpl @pressedVsHeld_loop  
        rts                      

if !removeUnused
    getInputs_redundancy_UNUSED:
            jsr get_CTRL_inputs     ;Alternate redundancy check for controllers, aims for perfect redundancy   
        @getInputs_redundancy_loop:
            ldy p1_btns_pressed      
            lda p2_btns_pressed      
            pha                      
            jsr get_CTRL_inputs      
            pla                      
            cmp p2_btns_pressed      
            bne @getInputs_redundancy_loop
            cpy p1_btns_pressed      
            bne @getInputs_redundancy_loop
            beq _pressedVsHeld
        
    getInputs_redundancy_expansion_UNUSED:
            jsr get_CTRL_inputs     ;Same as previous routine, but taking into consideration expansion controllers   
            jsr addExpansionCTRL     
        @getInputs_redundancy_expansion_loop:
            ldy p1_btns_pressed      
            lda p2_btns_pressed      
            pha                      
            jsr get_CTRL_inputs      
            jsr addExpansionCTRL     
            pla                      
            cmp p2_btns_pressed      
            bne @getInputs_redundancy_expansion_loop
            cpy p1_btns_pressed      
            bne @getInputs_redundancy_expansion_loop
            beq _pressedVsHeld
        
    getInputs_4players_UNUSED:
            jsr get_CTRL_inputs      
            lda tmp0                 
            sta exp1_btns_pressed_UNUSED        ;In this case, the expansion ctrl has its seperate RAM 
            lda tmp1                 
            sta exp2_btns_pressed_UNUSED         
            ldx #$03                 
        @pressedVsHeld_expansion_loop:
            lda p1_btns_pressed,X    
            tay                      
            eor p1_btns_held_UNUSED,X
            and p1_btns_pressed,X    
            sta p1_btns_pressed,X    
            sty p1_btns_held_UNUSED,X
            dex                      
            bpl @pressedVsHeld_expansion_loop
            rts                      
endif

;;
;; initPPU_addrA_dataX_then_attrY [$B860]
;;
;; Init PPU addresses (mainly nametables), with an optional different value for the pattern table
;;
;; Input:
;;  A = high byte of PPU address to init
;;  X = the value to copy in PPUDATA nametable
;;  Y = the value to copy in PPUDATA nametable attribute
;; 
;; Local variables:
PPUADDR_hiByte      = tmp0
PPUDATA_init        = tmp1

initPPU_addrA_dataX_then_attrY:
        sta PPUADDR_hiByte                 
        stx PPUDATA_init                 
        sty PPUDATA_init_attr                 
        lda PPUSTATUS           ;Read PPUSTATUS         
        lda PPUCTRL_RAM          
        and #~ppuctrl_vram_dir_down                 
        sta PPUCTRL             ;Makes sure VRAM increments horizontally   
        sta PPUCTRL_RAM          
        lda PPUADDR_hiByte                 
        sta PPUADDR                  
        ldy #$00                 
        sty PPUADDR             ;Sets the PPUADDR to xx00 (xx being the high byte input in A) 
        ldx #>nametable_size    ;Will init a complete nametable (4 times 256 bytes of data)   
    if !optimize
        cmp #>nametable0        ;This portion here seems pretty much unnecessary, seems to be in case we try to init more than $2000 bytes, then we'd use the PPUDATA_2 as the number of times to init 256 bytes... probably in case we want to init pattern tables as well?     
        bcs @storePPUData_loop1_prep
        ldx PPUDATA_init_attr                                  
    endif 
    @storePPUData_loop1_prep:
        ldy #$00                 
        lda PPUDATA_init                 
    @storePPUData_loop1:     
        sta PPUDATA              
        dey                      
        bne @storePPUData_loop1 ;Inner loop for 256 bytes  
        dex                      
        bne @storePPUData_loop1 ;Outer loop to do inner loop 4 times  
    @storePPUData_loop2_prep:
        ldy PPUDATA_init_attr                 
        lda PPUADDR_hiByte
    if !optimize                 
        cmp #>nametable0        ;Again, probably in case we want to init pattern tables                 
        bcc @restore_valX
        adc #$02
    else 
        clc                     ;It feels cleaner to just clear the carry flag and add the actual correct high byte relative address to the attribute table
        adc #>nametable_attr_addr
    endif      
        sta PPUADDR              
        lda #<nametable_attr_addr                 
        sta PPUADDR              
        ldx #nametable_attr_size                 
    @storePPUData_loop2:     
        sty PPUDATA              
        dex                      
        bne @storePPUData_loop2  
    @restore_valX:       
        ldx PPUDATA_init        ;Sets X back to what it was initially               
        rts                      

;;
;; copy_valueA_fromX00_toY00_plusFF [$B8AE]
;;
;; Initializes values from a given address range with a specified value
;;
;; Inputs:
;;  A: The value to copy
;;  X: The starting high byte (start adress is $xx00)
;;  Y: The ending high byte (end address is $yyFF)
;;
copy_valueA_fromX00_toY00_plusFF:
        pha         ;Push A to stack                      
        txa         ;Transfer X in A               
        sty ptr_hi  ;Make a copy of end address               
        clc         ;Clearing the carry here makes the subtract remove 1 extra             
        sbc ptr_hi  ;Subtract it from start address (giving $FF if same, or lower if different)                 
        tax         ;x now holds the difference between start and end address                       
        pla         ;Restore value to copy from stack              
        ldy #$00                 
        sty ptr_lo                 
    @copyData_Loop:          
        sta (ptr_lo),Y             
        dey                      
        bne @copyData_Loop  ;Does the inner loop 256 times       
        dec ptr_hi          ;Decrease high byte           
        inx                 ;Increase x, if 0, we are finished       
        bne @copyData_Loop       
        rts                      

;;
;; toAddressAtStackPointer_indexA [$B8C6]
;;
;; Jumps to the address stored at the last stack address (in other words, one jsr ago) plus an index specified in A
;; 
;; Input:
;;  A: the index to get to the address that contains the address we want to jump to
;;  Last stack address: base offset of the array of addresses that we can jump to
;;
toAddressAtStackPointer_indexA:
        asl A       ;Double A since these are two-bytes addresses                    
        tay         ;Transfer in y                     
        iny         ;Advance y 1 byte because the array starts 1 byte after the last stack address                 
        pla                      
        sta ptr_lo                 
        pla                       
        sta ptr_hi  ;Pull low and high byte of pointer from stack               
        lda (ptr),Y            
        tax         ;Load low byte of address we want to go to and transfer in x              
        iny                      
        lda (ptr),Y             
        sta ptr_hi  ;Get next byte (high byte of target address), and copy to pointer             
        stx ptr_lo                 
        jmp (ptr) 

if !removeUnused              
    to_basicMMCConfig_UNUSED:
            sei                 ;Game uses a different MMC config than this, no need to swap PRG.              
            inc resetMMC1_UNUSED    ;$8000, value at this address must be $80 or higher               
            lda #$1A            ;Vertical mirroring, fix $8000, switch $C000, 2 seperate 4K CHR       
            jsr basicMMCConfig       
            rts                      
endif

;;
;; basicMMCConfig & others [$B8E6]
;;
;; Memory mapper configuration & bankswitching, all work the same way (successive writes)
;;
;;
basicMMCConfig:          
        sta MMCConfig           ;Basic MMC config (input A: mmc1 control, 5 bits that define mirroring, prg bank mode and chr bank mode)                
        lsr A                    
        sta MMCConfig                
        lsr A                    
        sta MMCConfig                
        lsr A                    
        sta MMCConfig                
        lsr A                    
        sta MMCConfig                
        rts                      

changeCHRBank0:          
        sta CHRBank0            ;Bankswitch CHR0 (input A: chr bank number)
        lsr A                    
        sta CHRBank0      
        lsr A                    
        sta CHRBank0        
        lsr A                    
        sta CHRBank0         
        lsr A                    
        sta CHRBank0        
        rts                      

changeCHRBank1:          
        sta CHRBank1            ;Bankswitch CHR1 (input A: chr bank number)            
        lsr A                    
        sta CHRBank1                
        lsr A                    
        sta CHRBank1                
        lsr A                    
        sta CHRBank1                
        lsr A                    
        sta CHRBank1                
        rts                      

changePRGBank:               
        sta PRGBank             ;Bankswitch PRG (input A: prg bank number)
        lsr A                    
        sta PRGBank 
        lsr A                    
        sta PRGBank 
        lsr A                    
        sta PRGBank 
        lsr A                    
        sta PRGBank 
        rts                      