;PPU registers
PPUCTRL                     = $2000
PPUMASK                     = $2001
PPUSTATUS                   = $2002
OAMADDR                     = $2003         ;Set to zero, uses OAMDMA instead
OAMDATA                     = $2004         ;Unused in this game
PPUSCROLL                   = $2005
PPUADDR                     = $2006
PPUDATA                     = $2007
OAMDMA                      = $4014

;APU registers (general)
APU                         = $4000
APU_SQ0                     = $4000                             
APU_SQ1                     = $4004
APU_TRG                     = $4008
APU_NOISE                   = $400C
APU_DMC                     = $4010

;APU registers (specific)
SQ0_DUTY                    = $4000
SQ0_SWEEP                   = $4001
SQ0_TIMER                   = $4002
SQ0_LENGTH                  = $4003
SQ1_DUTY                    = $4004
SQ1_SWEEP                   = $4005
SQ1_TIMER                   = $4006
SQ1_LENGTH                  = $4007
TRG_LINEAR                  = $4008
TRG_TIMER                   = $400A
TRG_LENGTH                  = $400B
NOISE_VOLUME                = $400C
NOISE_PERIOD                = $400E
NOISE_LENGTH                = $400F
DMC_FREQ                    = $4010
DMC_COUNTER                 = $4011
DMC_ADDR                    = $4012
DMC_LENGTH                  = $4013
APUSTATUS                   = $4015
APUCOUNTER                  = $4017         ;Frame Counter, write-only

;Controller registers
CTRL1                       = $4016
CTRL2                       = $4017         ;Read-only

;Mapper registers (MMC1)
MMCConfig                   = $9FFF               
CHRBank0                    = $BFFF
CHRBank1                    = $DFFF
PRGBank                     = $FFF0

resetMMC1_UNUSED            = $8000     ;I think the value at this memory address must be $80 or higher