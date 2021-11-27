;;
;; Nintendo header [$FFE0]
;;
;; http://wiki.nesdev.com/w/index.php/Nintendo_header
;; Not used by the game, assumed safe to remove all this section
;;

if !removeMoreUnused
    header_gameName_UNUSED:  
    .db $20,$20,$20,$20,$20,$20,$20,$20
    header_gameName_DrMario: 
    .db 'D','R','.','M','A','R','I','O'
    header_PRG_checksum:     
    if ver_revA
        .db $2D,$85             ;16-bit checksum of all PRG (excluding only the 2 bytes for this checksum... therefore it must be calculated at the very end)  
    elseif ver_EU 
        .db $64,$05
    else 
        .db $1C,$87
    endif 
    header_CHR_checksum:     
    .db $C2,$A1             ;16-bit checksum of all CHR    
    header_dataSizes:        
    .db $22                 ;2 x 32 kb
    header_boardType:        
    .db $04                 ;MMC
    header_titleEncoding:    
    .db $01                 ;ASCII
    header_titleLength_minusOne:
    .db $07                  
    header_developer:        
    .db $01                 ;Nintendo
    header_selfChecksum:     
    .db $6E                 ;8-bit sum of header_CHR_checksum to header_developer. Then we take this sum and substract it from 0 to get this byte.
endif 