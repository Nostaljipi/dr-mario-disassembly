INES_MAPPER = 1 ; 1 = Nintendo MMC1
INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 0 ; 0 = no SRAM

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG chunk count
.byte $04 ; 8k CHR chunk count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $0F) << 4)
.byte (INES_MAPPER & %11110000) ;mapper high nybble
.byte $00, $00, $00, $00, $00, $00, $00, $00 ; padding
