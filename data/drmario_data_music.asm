;;
;; music_metadata_offset [$E261]
;;
;; Offsets to the start of each music metadata
;; 
music_metadata_offset:
.db cutscene_metadata               - music_metadata_pointers
.db chill_metadata                  - music_metadata_pointers
.db silence_metadata                - music_metadata_pointers
.db fever_metadata                  - music_metadata_pointers
.db fail_metadata                   - music_metadata_pointers
.db title_metadata                  - music_metadata_pointers
.db options_metadata                - music_metadata_pointers
.db ending_lvl20Low_metadata        - music_metadata_pointers         
.db singleVictory_fever_metadata    - music_metadata_pointers
.db singleVictory_chill_metadata    - music_metadata_pointers
.db fullVictory_metadata            - music_metadata_pointers
.db cutscene_postUFO_metadata       - music_metadata_pointers
if !removeMoreUnused
    .db ending_alt_metadata             - music_metadata_pointers
endif 

;;
;; music_metadata_pointers [$E26E]
;;
;; Each song's metadata consists of 10 bytes:
;;
;; 1:       Transpose (in pitch index offset, thus mostly in semi tones)   
;; 2:       Tempo
;; 3-10:    Address for start of each channel's pointer (2 bytes address per channel x 4 channels = 8 bytes)
;; 
music_metadata_pointers:
singleVictory_fever_metadata:
.db transpose_lower + 5         
.db tempo_150bpm
.word singleVictory_fever_sq0_ptr, singleVictory_fever_sq1_ptr, singleVictory_fever_trg_ptr, singleVictory_fever_perc_ptr

singleVictory_chill_metadata:
.db $00
.db tempo_150bpm
.word singleVictory_chill_sq0_ptr, singleVictory_chill_sq1_ptr, singleVictory_chill_trg_ptr, singleVictory_chill_perc_ptr

fever_metadata:
.db $00
.db tempo_150bpm
.word fever_sq0_ptr, fever_sq1_ptr, fever_trg_ptr, fever_perc_ptr

chill_metadata:
.db $00
.db tempo_128bpm
.word chill_sq0_ptr, chill_sq1_ptr, chill_trg_ptr, chill_perc_ptr

silence_metadata:
.db $00
.db tempo_112bpm
.word silence_sq0_ptr, $FFFF, $FFFF, $FFFF

options_metadata:
.db transpose_lower + 1
.db tempo_150bpm
.word options_sq0_ptr, options_sq1_ptr, options_trg_ptr, options_perc_ptr

fail_metadata:
.db transpose_lower + 7
.db tempo_225bpm
.word fail_sq0_ptr, fail_sq1_ptr, fail_trg_ptr, fail_perc_ptr

fullVictory_metadata:
.db transpose_lower + 3
.db tempo_112bpm
.word fullVictory_sq0_ptr, fullVictory_sq1_ptr, fullVictory_trg_ptr, fullVictory_perc_ptr

title_metadata:
.db transpose_higher + 4
.db tempo_150bpm
.word title_sq0_ptr, title_sq1_ptr, title_trg_ptr, title_perc_ptr

cutscene_metadata:
.db $00
.db tempo_112bpm
.word cutscene_sq0_ptr, cutscene_sq1_ptr, cutscene_trg_ptr, cutscene_perc_ptr

cutscene_postUFO_metadata:
.db $00
.db tempo_112bpm
.word cutscene_postUFO_sq0_ptr, cutscene_postUFO_sq1_ptr, cutscene_postUFO_trg_ptr, cutscene_postUFO_perc_ptr

ending_lvl20Low_metadata:
.db transpose_higher + 8
.db tempo_90bpm
.word ending_lvl20Low_sq0_ptr, ending_lvl20Low_sq1_ptr, ending_lvl20Low_trg_ptr, $FFFF

if !removeMoreUnused
    ending_alt_metadata:
    .db transpose_higher + 8
    .db tempo_90bpm
    .word ending_lvl20Low_sq0_ptr, ending_lvl20Low_sq1_ptr, ending_lvl20Low_trg_ptr, $FFFF      ;Exactly the same thing as previous, I think this is unused
endif 

;;
;; chill & other music data [$E2F0]
;;
;; Seperated as pointers for each channels, then the whole data (all channels interlaced)
;; 
chill_sq0_ptr:
.word chill,chill+150,chill+248,chill+317
.word chill+332,chill+939,chill+1167,chill+1178
.word chill+1369,chill+568,chill+575,$FFFF
.word chill_sq0_ptr+2

chill_sq1_ptr:
.word chill+33,chill+355,chill+453,chill+522
.word chill+545,chill+981,chill+1175,chill+1348
.word chill+572,$FFFF,chill_sq1_ptr+2

chill_trg_ptr:
.word chill+66,chill+752,chill+800,chill+815
.word chill+1021,chill+1389,chill+698,$FFFF
.word chill_trg_ptr+2

chill_perc_ptr:
.word chill+118,chill+838,chill+864,chill+887
.word chill+919,chill+1090,chill+1429,chill+626
.word $FFFF,chill_perc_ptr+2

chill:
.db $9F,$11,$30,$B1,$02,$6C,$02,$02
.db $6C,$02,$02,$02,$6A,$02,$02,$6A
.db $02,$02,$02,$02,$02,$68,$02,$02
.db $68,$02,$02,$02,$64,$02,$B6,$02
.db $00,$9F,$09,$30,$B1,$02,$72,$02
.db $02,$72,$02,$02,$02,$70,$02,$02
.db $70,$02,$02,$02,$02,$02,$6E,$02
.db $02,$6E,$02,$02,$02,$6C,$02,$B6
.db $02,$00,$9F,$16,$00,$B1,$46,$46
.db $4C,$46,$B0,$3C,$3C,$B1,$3C,$42
.db $44,$46,$46,$4C,$46,$3C,$02,$02
.db $02,$02,$46,$4C,$46,$B0,$3C,$3C
.db $B1,$3C,$42,$3C,$B6,$46,$9F,$A0
.db $00,$BA,$3C,$3A,$38,$36,$34,$32
.db $30,$2E,$02,$BB,$02,$00,$B2,$04
.db $44,$04,$44,$04,$44,$B1,$04,$41
.db $44,$01,$B2,$04,$44,$04,$44,$B1
.db $07,$41,$81,$B0,$01,$81,$B0,$81
.db $81,$B1,$01,$81,$01,$00,$9F,$09
.db $30,$B1,$02,$54,$02,$02,$54,$02
.db $02,$02,$54,$02,$02,$54,$02,$02
.db $02,$02,$02,$54,$02,$02,$54,$02
.db $02,$02,$50,$02,$02,$54,$02,$02
.db $02,$02,$02,$54,$02,$02,$54,$02
.db $02,$02,$54,$02,$02,$54,$02,$02
.db $02,$02,$02,$54,$02,$02,$54,$02
.db $02,$02,$9F,$06,$30,$BC,$24,$BA
.db $24,$22,$22,$20,$BA,$20,$BC,$1E
.db $BA,$1E,$1E,$1C,$BC,$1C,$BA,$1A
.db $1A,$18,$18,$BA,$16,$16,$BC,$14
.db $BA,$14,$12,$B1,$1A,$B5,$02,$00
.db $9F,$6B,$B1,$B1,$02,$54,$4C,$54
.db $4C,$B5,$02,$B1,$46,$46,$4C,$46
.db $4C,$B5,$02,$B1,$02,$54,$4C,$54
.db $5A,$02,$58,$50,$9F,$8A,$B1,$B4
.db $56,$9F,$6B,$B1,$B1,$02,$B0,$54
.db $54,$B1,$4C,$54,$4C,$B5,$02,$B1
.db $46,$46,$4C,$46,$3C,$B5,$02,$B1
.db $02,$54,$4C,$54,$5A,$02,$58,$50
.db $54,$02,$B6,$02,$00,$9F,$AD,$36
.db $B4,$16,$12,$10,$B6,$0E,$B0,$0E
.db $02,$02,$02,$00,$9F,$09,$F1,$C4
.db $B1,$02,$76,$02,$02,$76,$02,$02
.db $02,$76,$02,$02,$76,$02,$02,$02
.db $02,$FF,$00,$9F,$09,$30,$B1,$02
.db $5E,$02,$02,$5E,$02,$02,$02,$5E
.db $02,$02,$5E,$02,$02,$02,$02,$02
.db $5E,$02,$02,$5E,$02,$02,$02,$5A
.db $02,$02,$5E,$02,$02,$02,$02,$02
.db $5E,$02,$02,$5E,$02,$02,$02,$5E
.db $02,$02,$5E,$02,$02,$02,$02,$02
.db $5E,$02,$02,$5E,$02,$02,$02,$9F
.db $06,$30,$BC,$24,$BA,$24,$22,$22
.db $20,$BA,$20,$BC,$1E,$BA,$1E,$1E
.db $1C,$BC,$1C,$BA,$1A,$1A,$18,$18
.db $BA,$16,$16,$BC,$14,$BA,$14,$12
.db $B1,$1A,$B5,$02,$00,$9F,$0A,$B1
.db $B1,$02,$54,$4C,$54,$4C,$B5,$02
.db $B1,$46,$46,$4C,$46,$4C,$B5,$02
.db $B1,$02,$54,$4C,$54,$5A,$02,$58
.db $50,$9F,$8A,$B1,$B4,$56,$9F,$0A
.db $B1,$B1,$02,$B0,$54,$54,$B1,$4C
.db $54,$4C,$B5,$02,$B1,$46,$46,$4C
.db $46,$3C,$B5,$02,$B1,$02,$54,$4C
.db $54,$5A,$02,$58,$50,$54,$02,$B6
.db $02,$00,$9F,$0C,$30,$C7,$B0,$46
.db $5E,$46,$46,$5E,$46,$46,$5E,$FF
.db $46,$5E,$46,$46,$5E,$02,$02,$02
.db $00,$9F,$09,$B0,$C4,$B1,$02,$7C
.db $76,$6C,$7E,$02,$76,$6C,$80,$76
.db $6C,$7E,$02,$02,$02,$02,$FF,$00
.db $9F,$19,$31,$00,$9F,$18,$31,$C8
.db $B1,$14,$16,$16,$16,$FF,$C2,$B0
.db $16,$16,$B1,$16,$1C,$20,$B0,$22
.db $22,$B1,$22,$20,$1C,$16,$16,$1C
.db $02,$16,$16,$1C,$02,$B0,$16,$16
.db $B1,$16,$1C,$20,$B0,$22,$22,$B1
.db $22,$20,$1C,$B2,$16,$02,$02,$02
.db $FF,$00,$C3,$B1,$41,$01,$01,$41
.db $41,$01,$01,$01,$FF,$41,$01,$01
.db $41,$B0,$81,$81,$01,$41,$41,$81
.db $81,$81,$C2,$B1,$44,$04,$84,$B0
.db $04,$07,$B1,$44,$44,$84,$07,$44
.db $41,$81,$B0,$01,$01,$B1,$41,$41
.db $81,$01,$44,$04,$84,$B0,$04,$07
.db $B1,$44,$44,$84,$07,$44,$01,$01
.db $B0,$41,$04,$B1,$41,$01,$01,$01
.db $FF,$00,$9F,$16,$00,$C8,$B1,$2C
.db $2E,$2E,$2E,$FF,$C2,$B0,$2E,$2E
.db $B1,$2E,$34,$38,$B0,$3A,$3A,$B1
.db $3A,$38,$34,$2E,$2E,$34,$02,$2E
.db $2E,$34,$02,$B0,$2E,$2E,$B1,$2E
.db $34,$38,$B0,$3A,$3A,$B1,$3A,$38
.db $34,$B2,$2E,$02,$02,$02,$FF,$00
.db $9F,$16,$00,$C4,$B1,$2E,$2E,$34
.db $2E,$B0,$24,$24,$B1,$24,$2A,$2C
.db $2E,$2E,$34,$2E,$24,$02,$02,$02
.db $02,$2E,$34,$2E,$B0,$24,$24,$B1
.db $24,$2A,$24,$B0,$2E,$2E,$B1,$2E
.db $34,$2E,$34,$02,$02,$02,$FF,$00
.db $9F,$A0,$00,$B4,$2E,$34,$38,$B6
.db $3A,$B0,$3A,$02,$02,$02,$00,$9F
.db $16,$00,$C4,$B1,$2E,$2E,$34,$34
.db $2E,$02,$02,$02,$02,$2E,$34,$34
.db $2E,$02,$02,$02,$FF,$00,$C7,$B1
.db $44,$04,$84,$04,$44,$04,$84,$04
.db $FF,$44,$04,$84,$B0,$04,$81,$B0
.db $81,$81,$81,$81,$B1,$81,$01,$00
.db $C7,$B1,$44,$04,$84,$04,$44,$04
.db $84,$04,$FF,$44,$04,$84,$07,$B0
.db $81,$81,$B1,$04,$81,$01,$00,$C2
.db $B1,$04,$04,$44,$04,$04,$04,$44
.db $04,$FF,$C4,$44,$04,$FF,$B1,$44
.db $44,$44,$B0,$44,$81,$B0,$81,$81
.db $81,$81,$81,$01,$01,$01,$00,$C4
.db $B1,$44,$04,$84,$44,$44,$04,$84
.db $04,$44,$04,$84,$41,$44,$01,$01
.db $01,$FF,$00,$9F,$09,$31,$9C,$04
.db $C3,$B1,$02,$50,$02,$02,$50,$02
.db $02,$02,$50,$02,$02,$50,$02,$02
.db $B2,$5A,$FF,$B1,$02,$50,$02,$02
.db $50,$02,$02,$5A,$50,$02,$02,$50
.db $02,$02,$02,$02,$00,$9F,$09,$31
.db $C3,$B1,$02,$5A,$02,$02,$5A,$02
.db $02,$02,$5A,$02,$02,$5A,$02,$02
.db $B2,$4C,$FF,$B1,$02,$5A,$02,$02
.db $5A,$02,$02,$02,$5A,$02,$02,$5A
.db $02,$02,$02,$02,$00,$C3,$B4,$02
.db $FF,$9F,$A0,$00,$B6,$02,$BA,$3C
.db $3A,$38,$36,$34,$32,$30,$2E,$02
.db $BB,$02,$9F,$14,$00,$B0,$2A,$2A
.db $B1,$2A,$2A,$30,$2A,$2A,$2A,$20
.db $B0,$2A,$2A,$B1,$2A,$2A,$30,$2A
.db $2C,$2A,$2C,$B0,$2A,$2A,$B1,$2A
.db $2A,$30,$2A,$2A,$2A,$20,$B0,$2A
.db $2A,$B1,$2A,$2A,$30,$02,$02,$02
.db $02,$00,$B1,$44,$04,$84,$04,$44
.db $04,$84,$07,$44,$04,$84,$41,$41
.db $01,$B0,$81,$81,$B1,$01,$44,$04
.db $84,$04,$44,$04,$84,$07,$44,$04
.db $BA,$81,$81,$BB,$01,$BA,$81,$81
.db $BB,$01,$B1,$44,$B9,$01,$81,$81
.db $BB,$01,$B9,$41,$41,$41,$BB,$01
.db $C3,$B0,$41,$04,$B1,$01,$84,$04
.db $44,$04,$81,$04,$FF,$B1,$44,$04
.db $84,$44,$01,$01,$01,$01,$00,$9F
.db $B7,$32,$B8,$02,$BC,$02,$00,$9F
.db $B6,$33,$C8,$B0,$60,$5A,$FF,$B0
.db $64,$54,$56,$58,$5A,$5E,$60,$5E
.db $02,$68,$64,$60,$5E,$5A,$56,$54
.db $B1,$56,$BA,$54,$50,$BB,$02,$BA
.db $4C,$42,$BB,$02,$B2,$3E,$B0,$02
.db $48,$38,$3C,$3E,$42,$46,$42,$50
.db $46,$48,$4C,$50,$54,$56,$54,$02
.db $5A,$48,$4C,$50,$54,$56,$54,$5A
.db $5A,$02,$46,$02,$48,$02,$4C,$50
.db $4C,$50,$02,$B2,$54,$B0,$5A,$5A
.db $02,$46,$02,$48,$02,$4C,$50,$4C
.db $50,$02,$B2,$54,$B9,$54,$60,$64
.db $BB,$02,$B9,$62,$60,$5E,$BB,$02
.db $B9,$5C,$5A,$58,$BB,$02,$B9,$56
.db $54,$52,$BB,$02,$B9,$50,$4E,$4C
.db $BB,$02,$B9,$4A,$48,$46,$BB,$02
.db $B0,$44,$42,$40,$3E,$BA,$3C,$3A
.db $BB,$02,$BA,$38,$36,$BB,$02,$BA
.db $34,$32,$BB,$02,$BA,$30,$2E,$BB
.db $02,$B7,$5A,$B0,$64,$B1,$62,$5E
.db $5A,$5E,$54,$56,$5A,$64,$62,$B3
.db $64,$B1,$02,$00,$B7,$5E,$B0,$6C
.db $B1,$68,$66,$62,$66,$9F,$96,$33
.db $B2,$5A,$5E,$68,$B3,$74,$9C,$00
.db $00,$B7,$5E,$B0,$6C,$B1,$68,$66
.db $62,$66,$9F,$97,$33,$B2,$5A,$5E
.db $68,$B8,$74,$02,$00,$9F,$13,$00
.db $C6,$B0,$34,$34,$02,$02,$02,$9F
.db $A0,$00,$B7,$24,$B2,$26,$2A,$9F
.db $13,$00,$B0,$30,$02,$2E,$02,$2A
.db $2E,$02,$02,$02,$02,$3A,$3C,$02
.db $34,$02,$1C,$FF,$00,$C6,$B0,$44
.db $44,$04,$01,$84,$44,$B1,$04,$44
.db $04,$84,$04,$44,$04,$84,$44,$B0
.db $44,$01,$81,$81,$01,$81,$01,$81
.db $FF,$00


fever_sq0_ptr:
.word fever+973,fever,fever+357,fever+716
.word fever+401,fever+864,fever+864,fever+1026
.word $FFFF,fever_sq0_ptr+2

fever_sq1_ptr:
.word fever+988,fever+117,fever+461,fever+758
.word fever+497,fever+887,fever+887,fever+1026
.word $FFFF,fever_sq1_ptr+2

fever_trg_ptr:
.word fever+1003,fever+231,fever+551,fever+790
.word fever+599,fever+910,fever+910,fever+1039
.word $FFFF,fever_trg_ptr+2

fever_perc_ptr:
.word fever+1018,fever+313,fever+663,fever+852
.word fever+674,fever+933,fever+953,fever+1053
.word $FFFF,fever_perc_ptr+2

fever:
.db $9F,$0E,$B1,$B1,$38,$3C,$38,$3C
.db $3C,$3A,$38,$34,$38,$3C,$38,$38
.db $3C,$02,$9F,$05,$B0,$BA,$02,$2A
.db $28,$26,$24,$22,$02,$02,$9F,$0E
.db $B1,$B1,$38,$3C,$3A,$3C,$3C,$3A
.db $38,$3C,$9F,$08,$F0,$C4,$B0,$2A
.db $2A,$B1,$2A,$FF,$9F,$0E,$B1,$B1
.db $38,$3C,$38,$3C,$3C,$3A,$38,$34
.db $38,$3C,$38,$38,$3C,$02,$02,$02
.db $38,$3C,$38,$3C,$3C,$3C,$3C,$3C
.db $9F,$05,$B0,$BA,$02,$74,$02,$68
.db $02,$02,$62,$02,$02,$4C,$02,$5E
.db $38,$02,$02,$02,$80,$74,$6C,$46
.db $02,$40,$68,$02,$52,$4E,$4A,$46
.db $48,$42,$02,$02,$00,$9F,$07,$B1
.db $B1,$60,$62,$60,$62,$5E,$5A,$5A
.db $5E,$60,$62,$5E,$5A,$5A,$02,$9F
.db $05,$B0,$BA,$02,$12,$10,$0E,$0C
.db $0A,$02,$02,$9F,$07,$B1,$B1,$60
.db $62,$60,$62,$5E,$5A,$5A,$5E,$9F
.db $08,$F0,$B0,$1A,$1A,$B1,$1A,$B0
.db $1C,$1C,$B1,$1C,$B0,$1E,$1E,$B1
.db $1E,$B0,$20,$20,$B1,$20,$9F,$07
.db $B1,$B1,$60,$62,$60,$62,$5E,$5A
.db $5A,$5E,$60,$62,$5E,$5A,$5A,$02
.db $02,$02,$60,$62,$60,$62,$5E,$5A
.db $5A,$5E,$9F,$01,$B0,$B0,$80,$74
.db $6C,$6A,$02,$74,$68,$02,$52,$4E
.db $02,$46,$02,$02,$02,$02,$00,$9F
.db $12,$00,$B1,$5A,$5A,$60,$62,$4C
.db $4C,$52,$54,$5A,$5A,$60,$62,$4C
.db $02,$02,$02,$5A,$5A,$60,$62,$4C
.db $4C,$52,$54,$9F,$00,$00,$B0,$2A
.db $2A,$B1,$2A,$B0,$2E,$2E,$B1,$2E
.db $B0,$30,$30,$B1,$30,$B0,$32,$32
.db $B1,$32,$9F,$12,$00,$B1,$5A,$5A
.db $60,$62,$4C,$4C,$52,$54,$5A,$5A
.db $60,$62,$4C,$02,$02,$02,$5A,$5A
.db $60,$62,$4C,$4C,$52,$54,$B4,$02
.db $00,$C6,$B0,$07,$04,$07,$01,$FF
.db $B2,$01,$20,$C4,$B0,$07,$04,$07
.db $01,$FF,$B2,$20,$60,$20,$60,$C6
.db $B0,$07,$04,$07,$01,$FF,$B2,$60
.db $01,$C4,$B0,$07,$04,$07,$01,$FF
.db $B6,$60,$B2,$20,$00,$9F,$0E,$B1
.db $B0,$42,$42,$B1,$42,$42,$42,$3E
.db $48,$46,$3E,$B0,$42,$42,$B1,$42
.db $42,$42,$46,$02,$02,$02,$B0,$42
.db $42,$B1,$42,$42,$42,$3E,$48,$46
.db $3E,$2E,$02,$02,$40,$42,$02,$3E
.db $02,$9F,$0E,$B1,$B0,$2A,$2A,$B1
.db $34,$32,$30,$2E,$02,$9F,$04,$30
.db $B2,$26,$9F,$0E,$B1,$B0,$2A,$2A
.db $B1,$34,$32,$30,$2E,$02,$9F,$05
.db $30,$B2,$28,$9F,$0E,$B1,$B0,$2A
.db $2A,$B1,$2A,$2A,$2A,$26,$26,$26
.db $26,$26,$02,$26,$02,$24,$02,$9F
.db $0F,$F1,$1C,$02,$00,$9F,$07,$B1
.db $B1,$52,$54,$52,$54,$50,$4C,$4C
.db $46,$52,$54,$50,$4C,$4C,$02,$02
.db $02,$52,$54,$52,$54,$50,$4C,$4C
.db $46,$40,$46,$4A,$50,$4C,$02,$4A
.db $02,$9F,$07,$B1,$B1,$52,$54,$50
.db $4C,$4C,$02,$9F,$01,$30,$B2,$0E
.db $9F,$07,$B1,$B1,$52,$54,$50,$4C
.db $4C,$02,$9F,$02,$30,$B2,$10,$9F
.db $07,$B1,$B1,$52,$54,$52,$54,$50
.db $4C,$4C,$46,$4C,$02,$50,$02,$4C
.db $02,$9F,$0F,$F0,$04,$02,$00,$9F
.db $15,$00,$B1,$34,$34,$3A,$3C,$B0
.db $26,$26,$B1,$26,$2C,$2E,$34,$34
.db $3A,$3C,$B0,$26,$26,$B1,$2C,$2E
.db $36,$34,$34,$3A,$3C,$B0,$26,$26
.db $B1,$26,$2C,$2E,$38,$38,$40,$46
.db $B0,$42,$42,$B1,$42,$42,$42,$9F
.db $15,$00,$B0,$34,$34,$B1,$34,$3A
.db $3C,$3E,$02,$9F,$00,$00,$B2,$26
.db $9F,$15,$00,$B0,$34,$34,$B1,$34
.db $3A,$3C,$3E,$02,$9F,$00,$00,$B2
.db $28,$9F,$15,$00,$B0,$3C,$3C,$B1
.db $3C,$3C,$3C,$38,$38,$38,$38,$C2
.db $B0,$42,$42,$42,$02,$FF,$B1,$34
.db $02,$9F,$00,$00,$B2,$34,$00,$C8
.db $B0,$60,$04,$07,$01,$20,$04,$60
.db $01,$FF,$C2,$B0,$60,$04,$07,$01
.db $20,$04,$60,$01,$B0,$20,$01,$01
.db $01,$60,$01,$01,$01,$FF,$C2,$B0
.db $60,$04,$07,$01,$20,$04,$60,$01
.db $FF,$B2,$60,$20,$B1,$60,$B0,$60
.db $60,$B2,$20,$00,$9F,$10,$F1,$C3
.db $B1,$34,$2A,$34,$38,$34,$2A,$42
.db $2A,$FF,$3E,$26,$34,$38,$34,$26
.db $32,$26,$C3,$B1,$34,$2A,$34,$38
.db $34,$2A,$42,$2A,$FF,$3E,$26,$34
.db $38,$34,$26,$32,$26,$00,$9F,$AF
.db $33,$B3,$24,$B2,$20,$2A,$B4,$1C
.db $B3,$2E,$B2,$2A,$34,$B4,$26,$B3
.db $24,$B2,$20,$2A,$B4,$1C,$B3,$2E
.db $B2,$2A,$32,$B4,$34,$00,$9F,$15
.db $00,$C2,$B1,$34,$34,$42,$B0,$34
.db $34,$B1,$32,$32,$42,$B0,$32,$32
.db $B1,$2E,$2E,$42,$B0,$2E,$2E,$B1
.db $2A,$2A,$42,$B0,$2A,$2A,$B1,$26
.db $26,$3E,$B0,$26,$26,$B1,$24,$24
.db $3E,$B0,$24,$24,$B1,$38,$38,$38
.db $B0,$38,$38,$B1,$2A,$2A,$2A,$B0
.db $2A,$2A,$FF,$00,$D0,$B0,$04,$04
.db $07,$01,$0A,$04,$04,$04,$FF,$00
.db $9F,$12,$F1,$C3,$B1,$04,$04,$0A
.db $0C,$0E,$0E,$10,$12,$FF,$22,$08
.db $1E,$1C,$1A,$18,$16,$14,$00,$9F
.db $11,$F1,$C3,$B1,$04,$04,$0A,$0C
.db $0E,$0E,$10,$12,$FF,$22,$20,$1E
.db $1C,$1A,$18,$16,$14,$00,$9F,$00
.db $00,$C3,$B1,$1C,$1C,$22,$24,$26
.db $26,$28,$2A,$FF,$3A,$38,$36,$34
.db $32,$30,$2E,$2C,$00,$C2,$B1,$60
.db $60,$04,$01,$04,$01,$04,$01,$60
.db $04,$20,$20,$01,$01,$04,$0A,$FF
.db $00,$C2,$B1,$60,$04,$20,$20,$60
.db $60,$20,$0A,$60,$04,$20,$20,$60
.db $01,$81,$0A,$FF,$00,$9F,$12,$F1
.db $C2,$B1,$12,$12,$18,$1A,$1C,$1A
.db $18,$16,$FF,$00,$9F,$11,$F1,$C2
.db $B1,$12,$12,$18,$1A,$1C,$1A,$18
.db $16,$FF,$00,$9F,$00,$00,$C2,$B1
.db $2A,$2A,$30,$32,$34,$32,$30,$2E
.db $FF,$00,$C2,$B1,$60,$60,$B6,$01
.db $FF,$00,$C3,$B1,$12,$10,$B6,$02
.db $FF,$B1,$14,$02,$B6,$02,$00,$C3
.db $B1,$2A,$28,$B6,$02,$FF,$B1,$2C
.db $02,$B6,$02,$FF,$00,$C3,$B1,$60
.db $60,$B6,$01,$FF,$B2,$60,$01,$01
.db $60,$00


fullVictory:
.db $9F,$B6,$32,$B0,$52,$4C,$52,$B5
.db $56,$00,$9F,$B6,$32,$B0,$64,$5C
.db $64,$B5,$68,$00,$9F,$00,$00,$B0
.db $5C,$5C,$5C,$9F,$A0,$00,$B5,$60
.db $00,$B0,$07,$07,$07,$C4,$BA,$04
.db $04,$04,$FF,$00

fullVictory_sq0_ptr:
.word fullVictory,fullVictory+90,fullVictory+121,fullVictory+405
.word fullVictory+412,$FFFF,fullVictory_sq0_ptr+4

fullVictory_sq1_ptr:
.word fullVictory+10,fullVictory+103,fullVictory+263,fullVictory+409
.word $FFFF,fullVictory_sq1_ptr+4

fullVictory_trg_ptr:
.word fullVictory+20,fullVictory+112,fullVictory+470,$FFFF
.word fullVictory_trg_ptr+4

fullVictory_perc_ptr:
.word fullVictory+33,fullVictory+115,fullVictory+572,$FFFF
.word fullVictory_perc_ptr+4

fullVictory_loop:
.db $9C,$08,$9E,$18,$9F,$11,$F1,$B1
.db $02,$4C,$50,$4C,$00,$9F,$B1,$F1
.db $B1,$02,$1C,$20,$1C,$00,$B3,$02
.db $00,$B1,$01,$20,$20,$20,$00,$B1
.db $5E,$02,$5A,$02,$54,$52,$50,$4C
.db $50,$4C,$02,$4C,$02,$02,$02,$4C
.db $50,$50,$50,$4C,$54,$4C,$02,$4C
.db $9F,$7D,$F1,$02,$7C,$64,$02,$7C
.db $02,$9F,$11,$F1,$4C,$4C,$5E,$5E
.db $5A,$5A,$52,$52,$50,$4C,$50,$4C
.db $02,$46,$02,$02,$02,$42,$50,$50
.db $50,$4C,$54,$4C,$02,$4C,$9F,$7D
.db $F1,$02,$02,$64,$7C,$02,$02,$9F
.db $11,$F1,$4C,$48,$46,$4C,$02,$4C
.db $02,$02,$02,$02,$42,$4C,$02,$4C
.db $02,$02,$02,$02,$3E,$4C,$02,$4C
.db $02,$02,$02,$42,$3C,$4C,$02,$4C
.db $02,$02,$02,$02,$46,$4C,$02,$4C
.db $9F,$7D,$F1,$02,$74,$72,$74,$9F
.db $11,$F1,$42,$4C,$02,$4C,$02,$02
.db $02,$02,$3E,$4C,$02,$4C,$02,$02
.db $02,$42,$B4,$02,$00,$B1,$2E,$02
.db $2A,$02,$24,$22,$20,$1C,$20,$1C
.db $02,$1C,$02,$02,$02,$1C,$20,$20
.db $20,$1C,$24,$1C,$02,$1C,$9F,$1C
.db $F1,$02,$7C,$64,$02,$7C,$02,$9F
.db $B1,$F1,$1C,$1C,$2E,$2E,$2A,$2A
.db $22,$22,$20,$1C,$20,$1C,$02,$16
.db $02,$02,$02,$12,$20,$20,$20,$1C
.db $24,$1C,$02,$1C,$9F,$1C,$F1,$02
.db $02,$64,$7C,$02,$02,$9F,$B1,$F1
.db $1C,$18,$16,$1C,$02,$1C,$02,$02
.db $02,$02,$12,$1C,$02,$1C,$02,$02
.db $02,$02,$0E,$1C,$02,$1C,$02,$02
.db $02,$12,$0C,$1C,$02,$1C,$02,$02
.db $02,$02,$16,$1C,$02,$1C,$9F,$1C
.db $F1,$02,$74,$72,$74,$9F,$B1,$F1
.db $12,$1C,$02,$1C,$02,$02,$02,$02
.db $0E,$1C,$02,$1C,$02,$02,$02,$12
.db $B4,$02,$00,$9F,$7D,$F1,$00,$9F
.db $1C,$F1,$C2,$B4,$02,$B1,$7C,$64
.db $02,$7C,$02,$02,$02,$02,$B4,$02
.db $B1,$02,$7C,$64,$02,$7C,$02,$02
.db $02,$FF,$C3,$B3,$02,$B1,$02,$76
.db $72,$02,$FF,$B3,$02,$B1,$02,$02
.db $7C,$02,$FF,$C3,$B3,$02,$B1,$02
.db $76,$72,$02,$FF,$B1,$74,$74,$74
.db $74,$B3,$02,$00,$9F,$00,$00,$C2
.db $B5,$34,$B1,$3A,$3C,$42,$46,$02
.db $B5,$26,$B1,$2C,$2E,$34,$38,$02
.db $B5,$2A,$B1,$30,$32,$38,$3C,$02
.db $B5,$34,$B1,$3A,$3C,$42,$46,$02
.db $FF,$B5,$26,$B1,$2C,$2E,$02,$34
.db $02,$B5,$24,$B1,$28,$2A,$02,$34
.db $02,$B5,$20,$B1,$26,$2E,$02,$34
.db $02,$B5,$1C,$B1,$22,$24,$02,$34
.db $02,$B5,$26,$B1,$2C,$2E,$02,$34
.db $02,$B5,$24,$B1,$28,$2A,$02,$34
.db $02,$B5,$20,$B1,$26,$2E,$02,$34
.db $02,$2A,$2A,$2A,$2A,$02,$02,$02
.db $02,$00,$C4,$B1,$44,$04,$20,$20
.db $04,$04,$60,$04,$44,$04,$20,$20
.db $04,$60,$60,$04,$FF,$C3,$44,$04
.db $04,$44,$44,$04,$60,$04,$FF,$44
.db $04,$04,$44,$44,$60,$20,$01,$C3
.db $44,$04,$04,$44,$44,$04,$60,$04
.db $FF,$60,$44,$44,$44,$01,$20,$60
.db $01,$00

options_sq0_ptr:
.word options,options+37,options+37,options+121
.word $FFFF,options_sq0_ptr+2

options_sq1_ptr:
.word options+10,options+79,options+79,options+136
.word $FFFF,options_sq1_ptr+2

options_trg_ptr:
.word options+20,options+151,options+151,options+259
.word $FFFF,options_trg_ptr+2

options_perc_ptr:
.word options+30,options+209,options+209,options+292
.word $FFFF,options_perc_ptr+2

options:
.db $9F,$1A,$F1,$B0,$38,$38,$38,$38
.db $02,$00,$9F,$1A,$F1,$B0,$42,$42
.db $42,$42,$02,$00,$9F,$10,$00,$B0
.db $2E,$2E,$2E,$2E,$02,$00,$B0,$07
.db $07,$07,$07,$01,$00,$9F,$11,$B0
.db $B2,$50,$B6,$02,$B9,$4C,$02,$02
.db $4C,$54,$5A,$B2,$58,$5E,$9F,$0B
.db $B0,$B9,$38,$02,$02,$38,$02,$20
.db $38,$02,$20,$38,$02,$20,$B2,$48
.db $4C,$46,$9F,$13,$B0,$28,$00,$9F
.db $13,$B0,$B2,$42,$B6,$02,$B9,$3C
.db $02,$02,$3C,$42,$4C,$B2,$46,$50
.db $9F,$0C,$B0,$B9,$42,$02,$02,$08
.db $02,$08,$08,$02,$08,$08,$02,$08
.db $B2,$3C,$42,$40,$9F,$0F,$B0,$10
.db $00,$9F,$11,$B0,$B4,$5A,$62,$5A
.db $9F,$13,$B0,$B6,$02,$B2,$1C,$00
.db $9F,$13,$B0,$B4,$50,$5A,$50,$9F
.db $13,$B0,$B6,$02,$B2,$0E,$00,$9F
.db $12,$00,$B8,$62,$9F,$A0,$00,$B9
.db $68,$6A,$68,$6A,$02,$68,$6A,$68
.db $6A,$68,$5A,$02,$02,$5A,$64,$54
.db $50,$02,$02,$B2,$58,$9F,$00,$00
.db $B9,$62,$02,$38,$50,$02,$38,$50
.db $02,$38,$50,$02,$38,$34,$02,$34
.db $3A,$02,$3A,$38,$02,$02,$B2,$28
.db $00,$B9,$60,$01,$07,$20,$01,$20
.db $04,$01,$07,$04,$01,$60,$60,$01
.db $07,$20,$01,$20,$04,$01,$07,$04
.db $01,$60,$60,$01,$07,$20,$01,$20
.db $04,$01,$07,$04,$01,$20,$20,$01
.db $60,$20,$01,$60,$20,$01,$04,$41
.db $01,$01,$00,$9F,$00,$00,$C3,$B8
.db $32,$B9,$34,$B9,$32,$02,$34,$B9
.db $32,$02,$34,$B9,$32,$02,$34,$FF
.db $B8,$32,$B9,$34,$B9,$32,$02,$34
.db $B2,$02,$26,$00,$B9,$41,$01,$07
.db $04,$01,$20,$60,$01,$07,$04,$01
.db $60,$60,$01,$07,$04,$01,$20,$44
.db $01,$07,$04,$01,$01,$41,$01,$07
.db $04,$01,$20,$60,$01,$07,$04,$01
.db $60,$60,$01,$07,$04,$01,$20,$60
.db $01,$07,$44,$01,$01,$00

title_sq0_ptr:
.word title,title+9,$FFFF,title_sq1_ptr+2       ;Shares the sq1 data after intro

title_sq1_ptr:
.word title+6,title+74,title+134,title+74
.word title+156,title+176,$FFFF,title_sq1_ptr+2

title_trg_ptr:
.word title+312,title+336,$FFFF,title_trg_ptr+2

title_perc_ptr:
.word title+549,title+563,$FFFF,title_perc_ptr+2

title:
.db $9F,$77,$32,$BD,$02,$00,$9F,$2D
.db $F4,$B2,$62,$62,$62,$02,$B7,$02
.db $B0,$64,$B7,$02,$B0,$64,$B7,$68
.db $B0,$68,$B2,$68,$B2,$62,$64,$62
.db $02,$B7,$02,$B0,$64,$B7,$02,$B0
.db $64,$B7,$68,$B0,$68,$B2,$68,$B2
.db $62,$62,$5A,$02,$B7,$02,$B0,$64
.db $B7,$02,$B0,$64,$B7,$68,$B0,$68
.db $B2,$68,$B2,$62,$64,$62,$02,$B4
.db $02,$00,$B2,$62,$B7,$68,$B0,$5A
.db $B2,$02,$02,$B7,$02,$B0,$6C,$B7
.db $02,$B0,$6C,$B7,$68,$B0,$64,$B7
.db $62,$B0,$5E,$B2,$62,$B7,$68,$B0
.db $5A,$B2,$02,$02,$B7,$02,$B0,$5A
.db $B7,$02,$B0,$5A,$B7,$58,$B0,$5A
.db $B7,$5E,$B0,$5A,$B2,$62,$B7,$68
.db $B0,$5A,$B2,$02,$02,$00,$B7,$02
.db $B0,$5A,$B7,$02,$B0,$6C,$B7,$68
.db $B0,$64,$B7,$62,$B0,$5E,$B3,$5A
.db $02,$B4,$02,$00,$B7,$02,$B0,$5A
.db $B7,$02,$B0,$5A,$B7,$58,$B0,$5A
.db $B7,$5E,$B0,$58,$B4,$5A,$02,$00
.db $B7,$02,$B0,$72,$B2,$02,$B2,$6C
.db $64,$B2,$64,$B7,$68,$B0,$6C,$B2
.db $02,$02,$B7,$02,$B0,$62,$B2,$02
.db $B2,$62,$64,$B2,$68,$B6,$02,$B7
.db $02,$B0,$72,$B2,$02,$B2,$6C,$64
.db $B2,$64,$B7,$68,$B0,$6C,$B2,$02
.db $02,$B8,$68,$68,$68,$68,$68,$68
.db $B3,$68,$02,$B2,$62,$B7,$68,$B0
.db $72,$B2,$02,$02,$B7,$02,$B0,$5E
.db $B7,$02,$B0,$5A,$B7,$5E,$B0,$62
.db $B7,$64,$B0,$68,$B2,$62,$B7,$5A
.db $B0,$50,$B3,$02,$B7,$02,$B0,$5E
.db $B7,$02,$B0,$5A,$B7,$5E,$B0,$62
.db $B7,$64,$B0,$68,$B2,$62,$68,$5A
.db $02,$B7,$02,$B0,$5A,$B7,$02,$B0
.db $5A,$B7,$58,$B0,$5A,$B7,$5E,$B0
.db $58,$B6,$5A,$B2,$02,$B4,$02,$00
.db $9F,$00,$00,$C7,$B4,$02,$FF,$B7
.db $02,$B0,$50,$B7,$4C,$B0,$02,$B7
.db $4A,$B0,$02,$B7,$46,$B0,$02,$00
.db $C3,$B2,$42,$4A,$3C,$42,$B7,$34
.db $B0,$34,$B2,$3C,$B2,$38,$40,$FF
.db $42,$32,$3C,$30,$2E,$3A,$38,$2C
.db $B7,$2A,$B0,$2A,$B2,$42,$3C,$42
.db $B7,$34,$B0,$34,$B2,$3C,$B2,$38
.db $40,$B2,$42,$4A,$3C,$42,$B7,$34
.db $B0,$34,$B2,$3C,$B2,$38,$40,$42
.db $38,$32,$2A,$34,$3C,$38,$28,$2A
.db $B7,$2A,$B0,$42,$B2,$2E,$B7,$2E
.db $B0,$42,$B2,$30,$B7,$30,$B0,$42
.db $B2,$32,$32,$34,$3C,$B7,$42,$B0
.db $34,$B7,$46,$B0,$34,$B7,$48,$B0
.db $34,$B7,$46,$B0,$34,$B7,$42,$B0
.db $34,$B7,$3C,$B0,$34,$B2,$2A,$32
.db $B7,$38,$B0,$2A,$B7,$3C,$B0,$2A
.db $B7,$3E,$B0,$2A,$B7,$3C,$B0,$2A
.db $B7,$38,$B0,$2A,$B7,$32,$B0,$2A
.db $B7,$34,$B0,$34,$B2,$3C,$B7,$42
.db $B0,$34,$B7,$46,$B0,$34,$B7,$48
.db $B0,$34,$B7,$46,$B0,$34,$B7,$42
.db $B0,$34,$B7,$3C,$B0,$34,$B7,$38
.db $B0,$38,$B2,$40,$46,$40,$9F,$A0
.db $00,$B6,$48,$B2,$02,$9F,$00,$00
.db $C3,$B2,$42,$4A,$3C,$42,$B7,$34
.db $B0,$34,$B2,$3C,$B2,$38,$40,$FF
.db $3E,$3E,$3E,$3E,$C3,$B9,$34,$34
.db $34,$FF,$B2,$34,$00,$CF,$B2,$01
.db $07,$FF,$B7,$01,$B0,$41,$B7,$84
.db $B0,$01,$00,$C7,$B2,$04,$B7,$60
.db $B0,$60,$B2,$04,$B7,$20,$B0,$01
.db $FF,$B7,$01,$B0,$20,$B7,$44,$B0
.db $01,$BC,$60,$60,$B9,$60,$60,$60
.db $20,$20,$B2,$44,$B7,$60,$B0,$60
.db $B7,$01,$B0,$01,$B7,$20,$B0,$07
.db $B7,$04,$B0,$01,$B7,$60,$B0,$60
.db $B7,$04,$B0,$84,$B7,$44,$B0,$41
.db $C3,$B2,$04,$B7,$60,$B0,$60,$B7
.db $01,$B0,$01,$B7,$20,$B0,$07,$B7
.db $04,$B0,$01,$B7,$60,$B0,$60,$B7
.db $04,$B0,$84,$B7,$44,$B0,$41,$FF
.db $C6,$B7,$04,$B0,$04,$B7,$44,$B0
.db $04,$B7,$04,$B0,$07,$B7,$44,$B0
.db $84,$FF,$B8,$60,$60,$60,$41,$41
.db $41,$B0,$60,$C7,$20,$FF,$C6,$BC
.db $20,$20,$FF,$C3,$B2,$04,$B7,$60
.db $B0,$60,$B2,$04,$B7,$20,$B0,$41
.db $B2,$04,$B7,$60,$B0,$60,$B2,$04
.db $B7,$20,$B0,$07,$FF,$B2,$04,$B7
.db $60,$B0,$60,$B2,$04,$B7,$20,$B0
.db $07,$B9,$41,$41,$41,$81,$81,$81
.db $20,$20,$20,$60,$01,$01,$00


singleVictory_fever_sq0_ptr:
.word singleVictory_fever, singleVictory_fever+83, singleVictory_fever+185, singleVictory_fever+90
.word singleVictory_fever+193, singleVictory_fever+90, singleVictory_fever+210, $0000

singleVictory_fever_sq1_ptr:
.word singleVictory_fever+24, singleVictory_fever+125, singleVictory_fever+189, singleVictory_fever+128
.word singleVictory_fever+197, singleVictory_fever+128, singleVictory_fever+201

singleVictory_fever_trg_ptr:
.word singleVictory_fever+48, singleVictory_fever+163, singleVictory_fever+219, $FFFF
.word singleVictory_fever_trg_ptr+4

singleVictory_fever_perc_ptr:
.word singleVictory_fever+72, singleVictory_fever+224, singleVictory_fever+296, $FFFF
.word singleVictory_fever_perc_ptr+4

singleVictory_fever:
.db $9F,$11,$F3,$BD,$52,$54,$56,$58
.db $5A,$5C,$5E,$60,$62,$9F,$B4,$F7
.db $B0,$52,$02,$B2,$3C,$B3,$3E,$00
.db $9F,$11,$F7,$BD,$58,$5A,$5C,$5E
.db $60,$62,$64,$66,$68,$9F,$B4,$F8
.db $B0,$78,$02,$B2,$4A,$B3,$4C,$00
.db $9F,$0F,$00,$BD,$62,$64,$66,$68
.db $6A,$6C,$6E,$70,$72,$9F,$A0,$00
.db $B0,$5A,$02,$B2,$5C,$B3,$5E,$00
.db $C9,$BD,$04,$FF,$01,$B0,$07,$01
.db $B6,$07,$00,$9F,$BA,$B1,$C4,$BD
.db $02,$FF,$C2,$B8,$80,$B9,$72,$B8
.db $72,$B9,$72,$B8,$68,$B9,$72,$B8
.db $68,$B9,$72,$B8,$7C,$B9,$72,$B8
.db $68,$B9,$72,$B8,$68,$B9,$72,$B8
.db $68,$B9,$72,$FF,$00,$9F,$0B,$B1
.db $C2,$B8,$68,$B9,$5A,$B8,$5A,$B9
.db $5A,$B8,$50,$B9,$5A,$B8,$50,$B9
.db $5A,$B8,$64,$B9,$5A,$B8,$50,$B9
.db $5A,$B8,$50,$B9,$5A,$B8,$50,$B9
.db $5A,$FF,$00,$9F,$12,$00,$B2,$7A
.db $9F,$A0,$00,$B2,$2A,$02,$02,$9F
.db $12,$00,$B4,$80,$7A,$B3,$80,$02
.db $00,$9F,$1F,$B1,$00,$9F,$1E,$B1
.db $00,$9F,$03,$B1,$00,$9F,$1F,$B1
.db $00,$9F,$0D,$B3,$C2,$B1,$72,$02
.db $FF,$00,$9F,$0D,$B3,$B1,$72,$02
.db $70,$02,$00,$C5,$B4,$02,$FF,$00
.db $B9,$07,$01,$04,$44,$01,$04,$60
.db $01,$20,$01,$01,$04,$C2,$07,$01
.db $04,$04,$01,$04,$FF,$07,$01,$04
.db $41,$01,$04,$60,$01,$20,$01,$01
.db $07,$04,$01,$07,$04,$01,$04,$07
.db $01,$04,$44,$01,$01,$00,$B9,$07
.db $01,$04,$04,$01,$60,$44,$01,$04
.db $04,$01,$20,$60,$01,$04,$07,$01
.db $04,$60,$01,$20,$44,$01,$01,$00
.db $B9,$04,$01,$07,$04,$01,$60,$44
.db $01,$04,$60,$01,$20,$C4,$04,$01
.db $04,$04,$04,$01,$FF,$00


singleVictory_chill_sq0_ptr:
.word singleVictory_fever,singleVictory_chill,$0000

singleVictory_chill_sq1_ptr:
.word singleVictory_fever+24,singleVictory_chill+39

singleVictory_chill_trg_ptr:
.word singleVictory_fever+48,singleVictory_chill+75

singleVictory_chill_perc_ptr:
.word singleVictory_fever+72,singleVictory_chill+97

singleVictory_chill:
.db $9F,$0B,$B1,$C4,$B2,$0E,$0A,$0E
.db $1A,$FF,$9F,$0B,$31,$C4,$B1,$0E
.db $0E,$0E,$0E,$0E,$0E,$0E,$10,$FF
.db $C4,$B1,$16,$16,$16,$16,$16,$16
.db $16,$18,$FF,$BD,$02,$02,$00,$9F
.db $06,$34,$C4,$B2,$0E,$0A,$0E,$1A
.db $FF,$9F,$07,$31,$C4,$B1,$1C,$1C
.db $1C,$1C,$1C,$1C,$1C,$1E,$FF,$C4
.db $B1,$24,$24,$24,$24,$24,$24,$24
.db $26,$FF,$00,$9F,$A0,$00,$C8,$B2
.db $26,$22,$26,$32,$FF,$C4,$B1,$2E
.db $46,$24,$3C,$2E,$46,$30,$48,$FF
.db $00,$E0,$B2,$44,$07,$44,$07,$44
.db $07,$FF,$00


silence_sq0_ptr:
.word silence, $FFFF, silence_sq0_ptr

silence:
.db $B4,$02,$02,$02,$02,$00


fail_sq0_ptr:
.word fail,fail+234,fail+324,fail+99
.word fail+99,fail+71,fail+71,$0000

fail_sq1_ptr:
.word fail+22,fail+278,fail+366,fail+161
.word fail+161,fail+85,fail+85

fail_trg_ptr:
.word fail+44,fail+316,fail+405,fail+223
.word $FFFF,fail_trg_ptr+6

fail_perc_ptr:
.word fail+59,fail+320,fail+445,fail+228
.word $FFFF,fail_perc_ptr+6

fail:
.db $9F,$05,$B1,$BA,$08,$02,$40,$B7
.db $02,$9F,$85,$B1,$BC,$02,$2C,$BC
.db $02,$28,$BC,$02,$30,$00,$9F,$05
.db $B1,$BA,$0C,$02,$46,$B7,$02,$9F
.db $85,$B1,$BC,$02,$2E,$BC,$02,$2A
.db $BC,$02,$32,$00,$9F,$13,$00,$BA
.db $2A,$02,$62,$B7,$02,$C3,$BC,$02
.db $20,$FF,$00,$BA,$41,$01,$0A,$B7
.db $01,$C3,$BC,$01,$0A,$FF,$00,$9F
.db $63,$F1,$C2,$B7,$6E,$B0,$6C,$B7
.db $6A,$B0,$64,$FF,$00,$9F,$1F,$F1
.db $C2,$B7,$6E,$B0,$6C,$B7,$6A,$B0
.db $64,$FF,$00,$9F,$63,$F1,$C2,$B7
.db $6E,$B0,$6C,$B7,$6A,$B0,$64,$FF
.db $9F,$7F,$F1,$C2,$B7,$6E,$B0,$6C
.db $B7,$6A,$B0,$64,$FF,$9F,$7E,$F1
.db $C2,$B7,$6E,$B0,$6C,$B7,$6A,$B0
.db $64,$FF,$9F,$7D,$F1,$B7,$6E,$B0
.db $6C,$B7,$6A,$B0,$64,$9F,$7C,$F1
.db $B7,$6E,$B0,$6C,$B7,$6A,$B0,$64
.db $00,$9F,$03,$F1,$C2,$B7,$6E,$B0
.db $6C,$B7,$6A,$B0,$64,$FF,$9F,$1F
.db $F1,$C2,$B7,$6E,$B0,$6C,$B7,$6A
.db $B0,$64,$FF,$9F,$1E,$F1,$C2,$B7
.db $6E,$B0,$6C,$B7,$6A,$B0,$64,$FF
.db $9F,$1D,$F1,$B7,$6E,$B0,$6C,$B7
.db $6A,$B0,$64,$9F,$1C,$F1,$B7,$6E
.db $B0,$6C,$B7,$6A,$B0,$64,$00,$B4
.db $02,$02,$02,$00,$B4,$01,$01,$01
.db $01,$00,$9E,$28,$9C,$00,$BA,$02
.db $9F,$63,$F1,$C2,$B0,$6E,$6C,$6A
.db $64,$FF,$9F,$7F,$F1,$C2,$6E,$6C
.db $6A,$64,$FF,$9F,$7E,$F1,$C2,$6E
.db $6C,$6A,$64,$FF,$9F,$7D,$F1,$C2
.db $6E,$6C,$6A,$64,$FF,$00,$9F,$03
.db $F1,$C2,$B0,$6E,$6C,$6A,$64,$FF
.db $9F,$1F,$F1,$C2,$6E,$6C,$6A,$64
.db $FF,$9F,$1E,$F1,$C2,$6E,$6C,$6A
.db $64,$FF,$9F,$1D,$F1,$C2,$6E,$6C
.db $6A,$64,$FF,$00,$B4,$02,$02,$00
.db $B4,$01,$01,$00,$9F,$1E,$B1,$B0
.db $12,$10,$02,$0E,$02,$0C,$02,$0A
.db $02,$08,$12,$10,$02,$0E,$02,$0C
.db $02,$0A,$02,$08,$B2,$14,$B0,$2A
.db $B8,$02,$9F,$8A,$31,$B6,$72,$B8
.db $02,$9E,$0C,$9C,$06,$00,$9F,$1D
.db $31,$B0,$12,$10,$02,$0E,$02,$0C
.db $02,$0A,$02,$08,$12,$10,$02,$0E
.db $02,$0C,$02,$0A,$02,$08,$B2,$14
.db $B0,$12,$B8,$02,$9F,$8A,$31,$BA
.db $02,$02,$B6,$74,$00,$9F,$00,$00
.db $B0,$2A,$28,$02,$26,$02,$24,$02
.db $22,$02,$20,$2A,$28,$02,$26,$02
.db $24,$02,$22,$02,$20,$B2,$2C,$B0
.db $2A,$B8,$02,$9F,$80,$00,$BA,$02
.db $02,$02,$B4,$5A,$00,$B1,$44,$04
.db $84,$04,$44,$04,$84,$04,$44,$04
.db $B0,$81,$81,$B1,$01,$B0,$41,$B8
.db $01,$BA,$01,$01,$01,$B4,$41,$00


cutscene_sq0_ptr:                ;Both versions, post UFO starts later in the data
.word cutscene,cutscene+71,cutscene+108,cutscene+115
.word cutscene+56,cutscene+115,cutscene+71,cutscene+108
.word cutscene+115,cutscene+56,cutscene+115,cutscene+71

cutscene_postUFO_sq0_ptr:
.word cutscene+115,cutscene+115,$FFFF,cutscene_sq0_ptr+22

cutscene_sq1_ptr:
.word cutscene+13,cutscene+152,cutscene+185,cutscene+192
.word cutscene+206,cutscene+213,cutscene+152,cutscene+185
.word cutscene+192,cutscene+206,cutscene+213,cutscene+152

cutscene_postUFO_sq1_ptr:
.word cutscene+192,cutscene+213,$FFFF,cutscene_sq1_ptr+22

cutscene_trg_ptr:
.word cutscene+42,cutscene+225,cutscene+240,cutscene+244
.word cutscene+63,cutscene+244,cutscene+225,cutscene+240
.word cutscene+244,cutscene+63,cutscene+285,cutscene+225

cutscene_postUFO_trg_ptr:
.word cutscene+244,cutscene+285,$FFFF,cutscene_trg_ptr+22

cutscene_perc_ptr:
.word cutscene+49,cutscene+257,cutscene+269,cutscene+273
.word cutscene+67,cutscene+273,cutscene+257,cutscene+269
.word cutscene+273,cutscene+67,cutscene+309,cutscene+257

cutscene_postUFO_perc_ptr:
.word cutscene+273,cutscene+309,$FFFF,cutscene_perc_ptr+22

cutscene:
.db $9F,$7A,$F2,$C5,$B1,$72,$70,$68
.db $64,$FF,$B6,$02,$00,$9F,$BE,$F1
.db $B1,$72,$70,$68,$64,$9F,$BC,$F1
.db $B1,$72,$70,$68,$64,$9F,$B4,$F1
.db $C3,$B1,$72,$70,$68,$64,$FF,$B6
.db $02,$00,$C5,$B3,$02,$FF,$B6,$02
.db $00,$C5,$B3,$01,$FF,$B6,$01,$00
.db $9F,$B7,$B1,$B9,$02,$74,$00,$B9
.db $02,$02,$00,$B9,$01,$04,$00,$9F
.db $B7,$B1,$B1,$68,$50,$5A,$50,$5E
.db $50,$58,$5A,$68,$50,$5A,$50,$5E
.db $50,$62,$5A,$5A,$50,$5E,$50,$68
.db $50,$5A,$50,$5A,$48,$4C,$50,$4C
.db $42,$4C,$3A,$00,$9F,$B7,$B1,$B9
.db $66,$6A,$00,$9F,$B7,$B1,$B1,$5A
.db $50,$4A,$42,$38,$42,$4A,$50,$58
.db $50,$46,$40,$38,$40,$46,$50,$5A
.db $54,$4C,$42,$3C,$42,$4C,$54,$5A
.db $52,$4C,$42,$52,$42,$4C,$52,$00
.db $9F,$B6,$B2,$B1,$62,$64,$68,$6C
.db $B3,$68,$B1,$5A,$5E,$62,$64,$B3
.db $62,$B1,$54,$5A,$B2,$5A,$B1,$50
.db $5A,$B2,$5A,$B3,$4C,$B2,$4A,$50
.db $00,$9F,$B7,$B2,$B9,$68,$6C,$00
.db $9F,$B6,$F4,$B4,$62,$B3,$5E,$B2
.db $5A,$58,$B4,$5A,$4C,$00,$9F,$B7
.db $B1,$B9,$02,$76,$00,$9F,$B6,$F4
.db $B4,$62,$B3,$5E,$68,$B4,$72,$76
.db $00,$9F,$A0,$00,$B3,$5A,$58,$54
.db $50,$4C,$4A,$48,$B2,$46,$44,$00
.db $B9,$02,$02,$00,$9F,$A0,$00,$C3
.db $B3,$2A,$42,$FF,$2A,$B2,$42,$2A
.db $00,$C3,$B2,$44,$04,$81,$04,$FF
.db $44,$01,$41,$44,$00,$B9,$04,$04
.db $00,$C3,$B2,$44,$04,$81,$04,$FF
.db $44,$01,$41,$44,$00,$B3,$2A,$42
.db $2A,$42,$4A,$4C,$B8,$3A,$38,$34
.db $BB,$02,$B8,$30,$9F,$00,$00,$B8
.db $2E,$2A,$BB,$02,$00,$C3,$B1,$41
.db $01,$04,$04,$81,$04,$07,$01,$FF
.db $B8,$44,$04,$07,$BB,$01,$B8,$41
.db $41,$81,$BB,$01,$00


ending_lvl20Low_sq0_ptr:
.word ending_lvl20Low,ending_lvl20Low+24,ending_lvl20Low+48,$FFFF
.word ending_lvl20Low_sq0_ptr+4

ending_lvl20Low_sq1_ptr:
.word ending_lvl20Low+9,ending_lvl20Low+91,$FFFF,ending_lvl20Low_sq1_ptr+2

ending_lvl20Low_trg_ptr:
.word ending_lvl20Low+32,ending_lvl20Low+130,$FFFF,ending_lvl20Low_trg_ptr+2

ending_lvl20Low:
.db $9F,$72,$B1,$C2,$B7,$7A,$72,$FF
.db $00,$9F,$1E,$B1,$B7,$7A,$72,$9F
.db $1C,$B1,$B7,$7A,$72,$9F,$17,$B1
.db $C3,$B7,$7A,$72,$FF,$B3,$02,$00
.db $C5,$B7,$02,$02,$FF,$B3,$02,$00
.db $C5,$B7,$01,$01,$FF,$B3,$01,$00
.db $9F,$19,$B1,$B1,$68,$50,$5A,$50
.db $5E,$50,$58,$5A,$68,$50,$5A,$50
.db $5E,$50,$62,$5A,$5A,$50,$54,$50
.db $68,$50,$62,$50,$5A,$48,$4C,$50
.db $4C,$42,$4C,$3A,$9F,$B6,$B1,$B9
.db $02,$82,$00,$9F,$08,$B0,$B1,$62
.db $64,$68,$6C,$B3,$68,$B1,$5A,$5E
.db $62,$64,$B3,$62,$B1,$54,$5A,$B2
.db $5A,$B1,$50,$5A,$B2,$5A,$B3,$4C
.db $B2,$4A,$50,$9F,$B6,$B2,$B9,$02
.db $84,$00,$9F,$12,$00,$B3,$72,$70
.db $6C,$68,$64,$62,$60,$B2,$5E,$5C
.db $B9,$02,$02,$00