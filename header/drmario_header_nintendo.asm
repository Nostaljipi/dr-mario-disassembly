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
    .db $2D,$85              ;TO DO: Change for checksum?  
    header_CHR_checksum:     
    .db $C2,$A1              
    header_dataSizes:        
    .db $22                  ;2 x 32 kb
    header_boardType:        
    .db $04                  ;MMC
    header_titleEncoding:    
    .db $01                  ;ASCII
    header_titleLength_minusOne:
    .db $07                  
    header_developer:        
    .db $01                  ;Nintendo
    header_selfChecksum:     
    .db $6E                  ;TO DO: Change for checksum? 
endif 