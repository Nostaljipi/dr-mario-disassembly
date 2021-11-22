;Macros
.macro setPPUADDR_absolute absADDR
    lda #>absADDR                 
    sta PPUADDR              
    lda #<absADDR                  
    sta PPUADDR
.endm

.macro setPPUADDR_fromTable table
    lda table+0,Y
    sta PPUADDR              
    lda table+1,Y
    sta PPUADDR
.endm

.macro setSpriteXY varX,varY
    lda #varX           
    sta spriteXPos           
    lda #varY                 
    sta spriteYPos 
.endm

.macro log2lsrA n
    i=n
    rept 8
        n = n >> 1 
        if n!=0
            lsr A 
        endif 
    endr
    n=i
.endm

.macro generateRandNum
    ldx #rng0                 
    ldy #rngSize                 
    jsr randomNumberGenerator
.endm

.macro _dw dwaddr
    .db >dwaddr
    .db <dwaddr
.endm