;;
;; jumpTable_sprites [$A8DC]
;;
;; RENDU ICI
;; 
jumpTable_sprites:
.word txtPause, bigCursor_top, bigCursor_top, bigCursor_bottom
.word musicTypeBox_large, musicTypeBox_small, redVirus_holdSign_frame0, loseXsign
.word marioWin_frame0, marioWin_frame1, marioThrow_frame0, marioThrow_frame1
.word marioThrow_frame2, txtLow, txtMed, txtHi
.word txtStart, redVirus_holdSign_frame1, redVirus_laughing, redVirus_laughing
.word yellowVirus_laughing, blueVirus_laughing, bigCloud, middleCloud
.word smallCloud, smallCursor_top, smallCursor_top, smallCursor_top
.word smallCursor_top, smallCursor_top, smallCursor_bottom, virusGroupCutscene_frame0
.word virusGroupCutscene_frame0, heartCursor, virusGroupCutscene_frame1, redDancingVirus_frame0
.word redDancingVirus_frame1, redDancingVirus_frame1_flipped, blueDancingVirus_frame0, blueDancingVirus_frame1
.word blueDancingVirus_frame1_flipped, yellowDancingVirus_frame0, yellowDancingVirus_frame1, yellowDancingVirus_frame1_flipped
.word redVirusHurt_frame0, redVirusHurt_frame0_flipped, blueVirusHurt_frame0, blueVirusHurt_frame0_flipped
.word yellowVirusHurt_frame0, yellowVirusHurt_frame0_flipped, marioFail, bigVirusEradicated
.word UFO_top, UFO_bottom_frame0, UFO_bottom_frame1, UFO_beam
.word flyingPig_frame0, flyingPig_frame1, flyingTurtle_frame0, flyingTurtle_frame1
if !optimize
    .word UNUSED_flyingSnowman, UNUSED_flyingSnowman
endif 
.word witch_frame0, witch_frame1
.word rooster_frame0, rooster_frame1, sprayCan_frame0, sprayCan_frame1
.word flyingBook_frame0, flyingBook_frame1, flyingDinosaur_frame0, flyingDinosaur_frame1
.word marioTitle, marioTitle_rightFoot_frame0, marioTitle_rightFoot_frame1
 
spriteData:
    txtPause:
    .db $00,$0A,$00,$00,$00,$0B,$00,$08     ;In groups of 4 bytes: relative y-coordinate, tile index, attributes, relative x-coordinate
    .db $00,$0C,$00,$10,$00,$0D,$00,$18
    .db $00,$0E,$00,$20,$80                 ;$80 marks the end of the data
    bigCursor_top:
    .db $00,$F0,$03,$00,$00,$F1,$03,$08
    .db $00,$F2,$03,$10,$80
    bigCursor_bottom:
    .db $00,$F0,$83,$00,$00,$F1,$83,$08
    .db $00,$F2,$83,$10,$80
    musicTypeBox_large:
    .db $00,$3F,$03,$00,$00,$2F,$03,$08
    .db $00,$2F,$03,$10,$00,$2F,$03,$18
    .db $00,$2F,$03,$20,$00,$2F,$03,$28
    .db $00,$5F,$03,$30,$08,$2E,$03,$00
    .db $08,$2E,$03,$30,$10,$4F,$03,$00
    .db $10,$2F,$03,$08,$10,$2F,$03,$10
    .db $10,$2F,$03,$18,$10,$2F,$03,$20
    .db $10,$2F,$03,$28,$10,$6F,$03,$30
    .db $80
    musicTypeBox_small:
    .db $00,$3F,$03,$00,$00,$2F,$03,$08
    .db $00,$2F,$03,$10,$00,$2F,$03,$18
    .db $00,$5F,$03,$20,$08,$2E,$03,$00
    .db $08,$2E,$03,$20,$10,$4F,$03,$00
    .db $10,$2F,$03,$08,$10,$2F,$03,$10
    .db $10,$2F,$03,$18,$10,$6F,$03,$20
    .db $80
    redVirus_holdSign_frame0:
    .db $00,$20,$01,$00,$00,$21,$01,$08
    .db $00,$84,$01,$10,$00,$83,$41,$18
    .db $08,$22,$01,$00,$08,$23,$01,$08
    .db $08,$94,$01,$10,$08,$93,$41,$18
    .db $10,$24,$01,$08,$10,$A4,$01,$10
    .db $10,$A3,$41,$18,$80
    loseXsign:
    .db $E0,$10,$01,$F8,$E0,$11,$01,$00
    .db $E0,$11,$41,$08,$E0,$10,$41,$10
    .db $E8,$12,$01,$F8,$E8,$13,$01,$00
    .db $E8,$13,$41,$08,$E8,$12,$41,$10
    .db $F0,$12,$81,$F8,$F0,$13,$81,$00
    .db $F0,$13,$C1,$08,$F0,$12,$C1,$10
    .db $F8,$10,$81,$F8,$F8,$11,$81,$00
    .db $F8,$11,$C1,$08,$F8,$10,$C1,$10
    .db $80
    marioWin_frame0:
    .db $00,$67,$00,$00,$00,$68,$00,$08
    .db $00,$69,$00,$10,$08,$15,$00,$00
    .db $08,$16,$00,$08,$08,$17,$00,$10
    .db $10,$18,$00,$00,$10,$19,$00,$08
    .db $10,$1A,$00,$10,$18,$1B,$00,$00
    .db $18,$1C,$00,$08,$18,$1D,$00,$10
    .db $20,$30,$00,$00,$20,$31,$00,$08
    .db $20,$32,$00,$10,$80
    marioWin_frame1:
    .db $00,$1E,$00,$00,$00,$68,$00,$08
    .db $00,$69,$00,$10,$08,$2E,$00,$00
    .db $08,$16,$00,$08,$08,$17,$00,$10
    .db $10,$3E,$00,$00,$10,$19,$00,$08
    .db $10,$1A,$00,$10,$18,$4E,$00,$00
    .db $18,$1C,$00,$08,$18,$1D,$00,$10
    .db $20,$30,$00,$00,$20,$31,$00,$08
    .db $20,$32,$00,$10,$80
    marioThrow_frame0:
    .db $00,$33,$00,$00,$00,$34,$00,$08
    .db $00,$35,$00,$10,$08,$43,$00,$00
    .db $08,$44,$00,$08,$08,$45,$00,$10
    .db $10,$53,$00,$00,$10,$54,$00,$08
    .db $10,$55,$00,$10,$18,$63,$00,$00
    .db $18,$64,$00,$08,$18,$65,$00,$10
    .db $20,$73,$00,$00,$20,$74,$00,$08
    .db $20,$75,$00,$10,$80
    marioThrow_frame1:
    .db $00,$36,$00,$00,$00,$34,$00,$08
    .db $00,$35,$00,$10,$08,$66,$00,$F8
    .db $08,$46,$00,$00,$08,$44,$00,$08
    .db $08,$45,$00,$10,$10,$76,$00,$F8
    .db $10,$56,$00,$00,$10,$54,$00,$08
    .db $10,$55,$00,$10,$18,$63,$00,$00
    .db $18,$64,$00,$08,$18,$65,$00,$10
    .db $20,$73,$00,$00,$20,$74,$00,$08
    .db $20,$75,$00,$10,$80
    marioThrow_frame2:
    .db $00,$36,$00,$00,$00,$34,$00,$08
    .db $00,$35,$00,$10,$08,$37,$00,$00
    .db $08,$44,$00,$08,$08,$45,$00,$10
    .db $10,$47,$00,$00,$10,$54,$00,$08
    .db $10,$55,$00,$10,$18,$57,$00,$00
    .db $18,$64,$00,$08,$18,$65,$00,$10
    .db $20,$73,$00,$00,$20,$74,$00,$08
    .db $20,$75,$00,$10,$80
    txtLow:
    .db $00,$15,$00,$00,$00,$18,$00,$08
    .db $00,$20,$00,$10,$80
    txtMed:
    .db $00,$16,$00,$00,$00,$0E,$00,$08
    .db $00,$0D,$00,$10,$80
    txtHi:
    .db $00,$11,$00,$00,$00,$12,$00,$08
    .db $80
    txtStart:
    .db $00,$0D,$00,$00,$00,$0F,$00,$08
    .db $00,$0B,$00,$10,$00,$14,$00,$18
    .db $00,$0F,$00,$20,$80
    redVirus_holdSign_frame1:
    .db $00,$20,$01,$00,$00,$2B,$01,$08
    .db $00,$39,$01,$10,$00,$38,$41,$18
    .db $08,$22,$01,$00,$08,$2C,$01,$08
    .db $08,$49,$01,$10,$08,$48,$41,$18
    .db $10,$2D,$01,$08,$10,$59,$01,$10
    .db $10,$58,$41,$18,$80
    redVirus_laughing:
    .db $00,$38,$01,$00,$00,$39,$01,$08
    .db $00,$38,$41,$10,$08,$48,$01,$00
    .db $08,$49,$01,$08,$08,$48,$41,$10
    .db $10,$58,$01,$00,$10,$59,$01,$08
    .db $10,$58,$41,$10,$80
    yellowVirus_laughing:
    .db $00,$3A,$03,$00,$00,$3B,$03,$08
    .db $00,$3A,$43,$10,$08,$4A,$03,$00
    .db $08,$4B,$03,$08,$08,$4A,$43,$10
    .db $10,$5A,$03,$00,$10,$5B,$03,$08
    .db $10,$5A,$43,$10,$80
    blueVirus_laughing:
    .db $00,$3C,$03,$00,$00,$3D,$03,$08
    .db $00,$3C,$43,$10,$08,$4C,$03,$00
    .db $08,$4D,$03,$08,$08,$4C,$43,$10
    .db $10,$5C,$03,$00,$10,$5D,$03,$08
    .db $10,$5C,$43,$10,$80
    bigCloud:
    .db $00,$20,$21,$00,$00,$21,$21,$08
    .db $00,$22,$21,$10,$00,$23,$21,$18
    .db $00,$24,$21,$20,$08,$30,$21,$00
    .db $08,$31,$21,$08,$08,$32,$21,$10
    .db $08,$33,$21,$18,$08,$34,$21,$20
    .db $80
    middleCloud:
    .db $00,$03,$21,$00,$00,$04,$21,$08
    .db $00,$05,$21,$10,$08,$13,$21,$00
    .db $08,$14,$21,$08,$08,$15,$21,$10
    .db $80
    smallCloud:
    .db $00,$44,$21,$00,$00,$45,$21,$08
    .db $80
    smallCursor_top:
    .db $00,$45,$00,$00,$80
    smallCursor_bottom:
    .db $00,$45,$80,$00,$80
    virusGroupCutscene_frame0:
    .db $00,$00,$00,$00,$00,$01,$00,$0A
    .db $00,$02,$00,$14,$80
    heartCursor:
    .db $00,$29,$01,$00,$80
    virusGroupCutscene_frame1:
    .db $00,$10,$00,$00,$00,$11,$00,$0A
    .db $00,$12,$00,$14,$80
    redDancingVirus_frame0:
    .db $00,$83,$01,$00,$00,$84,$01,$08
    .db $00,$83,$41,$10,$08,$93,$01,$00
    .db $08,$94,$01,$08,$08,$93,$41,$10
    .db $10,$A3,$01,$00,$10,$A4,$01,$08
    .db $10,$A3,$41,$10,$80
    redDancingVirus_frame1:
    .db $00,$85,$01,$00,$00,$86,$01,$08
    .db $00,$87,$01,$10,$08,$95,$01,$00
    .db $08,$96,$01,$08,$08,$97,$01,$10
    .db $10,$A5,$01,$00,$10,$A6,$01,$08
    .db $10,$A7,$01,$10,$80
    redDancingVirus_frame1_flipped:
    .db $00,$87,$41,$00,$00,$86,$41,$08
    .db $00,$85,$41,$10,$08,$97,$41,$00
    .db $08,$96,$41,$08,$08,$95,$41,$10
    .db $10,$A7,$41,$00,$10,$A6,$41,$08
    .db $10,$A5,$41,$10,$80
    blueDancingVirus_frame0:
    .db $00,$B3,$03,$00,$00,$B4,$03,$08
    .db $00,$B3,$43,$10,$08,$C3,$03,$00
    .db $08,$C4,$03,$08,$08,$C3,$43,$10
    .db $10,$D3,$03,$00,$10,$D4,$03,$08
    .db $10,$D3,$43,$10,$80
    blueDancingVirus_frame1:
    .db $00,$B5,$03,$00,$00,$B6,$03,$08
    .db $00,$B7,$03,$10,$08,$C5,$03,$00
    .db $08,$C6,$03,$08,$08,$C7,$03,$10
    .db $10,$D5,$03,$00,$10,$D6,$03,$08
    .db $10,$D7,$03,$10,$80
    blueDancingVirus_frame1_flipped:
    .db $00,$B7,$43,$00,$00,$B6,$43,$08
    .db $00,$B5,$43,$10,$08,$C7,$43,$00
    .db $08,$C6,$43,$08,$08,$C5,$43,$10
    .db $10,$D7,$43,$00,$10,$D6,$43,$08
    .db $10,$D5,$43,$10,$80
    yellowDancingVirus_frame0:
    .db $00,$88,$03,$00,$00,$89,$03,$08
    .db $00,$88,$43,$10,$08,$98,$03,$00
    .db $08,$99,$03,$08,$08,$98,$43,$10
    .db $10,$A8,$03,$00,$10,$A9,$03,$08
    .db $10,$A8,$43,$10,$80
    yellowDancingVirus_frame1:
    .db $00,$8A,$03,$00,$00,$8B,$03,$08
    .db $00,$8C,$03,$10,$08,$9A,$03,$00
    .db $08,$9B,$03,$08,$08,$9C,$03,$10
    .db $10,$AA,$03,$00,$10,$AB,$03,$08
    .db $10,$AC,$03,$10,$80
    yellowDancingVirus_frame1_flipped:
    .db $00,$8C,$43,$00,$00,$8B,$43,$08
    .db $00,$8A,$43,$10,$08,$9C,$43,$00
    .db $08,$9B,$43,$08,$08,$9A,$43,$10
    .db $10,$AC,$43,$00,$10,$AB,$43,$08
    .db $10,$AA,$43,$10,$80
    redVirusHurt_frame0:
    .db $00,$BB,$01,$00,$00,$BC,$01,$08
    .db $08,$CB,$01,$00,$08,$CC,$01,$08
    .db $08,$CD,$01,$10,$10,$DB,$01,$00
    .db $10,$DC,$01,$08,$10,$DD,$01,$10
    .db $80
    redVirusHurt_frame0_flipped:
    .db $00,$BC,$41,$08,$00,$BB,$41,$10
    .db $08,$CD,$41,$00,$08,$CC,$41,$08
    .db $08,$CB,$41,$10,$10,$DD,$41,$00
    .db $10,$DC,$41,$08,$10,$DB,$41,$10
    .db $80
    blueVirusHurt_frame0:
    .db $00,$B8,$03,$00,$00,$B9,$03,$08
    .db $08,$C8,$03,$00,$08,$C9,$03,$08
    .db $08,$CA,$03,$10,$10,$D8,$03,$00
    .db $10,$D9,$03,$08,$10,$DA,$03,$10
    .db $80
    blueVirusHurt_frame0_flipped:
    .db $00,$B9,$43,$08,$00,$B8,$43,$10
    .db $08,$CA,$43,$00,$08,$C9,$43,$08
    .db $08,$C8,$43,$10,$10,$DA,$43,$00
    .db $10,$D9,$43,$08,$10,$D8,$43,$10
    .db $80
    yellowVirusHurt_frame0:
    .db $00,$8D,$03,$00,$00,$8E,$03,$08
    .db $08,$9D,$03,$00,$08,$9E,$03,$08
    .db $08,$9F,$03,$10,$10,$AD,$03,$00
    .db $10,$AE,$03,$08,$10,$AF,$03,$10
    .db $80
    yellowVirusHurt_frame0_flipped:
    .db $00,$8E,$43,$08,$00,$8D,$43,$10
    .db $08,$9F,$43,$00,$08,$9E,$43,$08
    .db $08,$9D,$43,$10,$10,$AF,$43,$00
    .db $10,$AE,$43,$08,$10,$AD,$43,$10
    .db $80
    marioFail:
    .db $00,$67,$00,$00,$00,$68,$00,$08
    .db $00,$69,$00,$10,$08,$6A,$00,$00
    .db $08,$6B,$00,$08,$08,$6C,$00,$10
    .db $10,$77,$00,$F8,$10,$78,$00,$00
    .db $10,$79,$00,$08,$10,$7A,$00,$10
    .db $10,$7B,$00,$18,$18,$7C,$00,$00
    .db $18,$7D,$00,$08,$18,$7E,$00,$10
    .db $18,$7F,$00,$18,$20,$73,$00,$00
    .db $20,$74,$00,$08,$20,$75,$00,$10
    .db $80
    bigVirusEradicated:
    .db $00,$90,$00,$00,$00,$91,$00,$08
    .db $00,$90,$40,$10,$08,$92,$00,$00
    .db $08,$92,$40,$10,$10,$90,$80,$00
    .db $10,$91,$80,$08,$10,$90,$C0,$10
    .db $80
    UFO_top:
    .db $00,$0A,$22,$10,$00,$0B,$22,$18
    .db $00,$0C,$22,$20,$00,$0D,$22,$28
    .db $08,$18,$22,$00,$08,$19,$22,$08
    .db $08,$1A,$22,$10,$08,$1B,$22,$18
    .db $08,$1C,$22,$20,$08,$1D,$22,$28
    .db $08,$1E,$22,$30,$08,$1F,$22,$38
    .db $10,$28,$22,$00,$10,$29,$22,$08
    .db $10,$2A,$22,$10,$10,$2B,$22,$18
    .db $10,$2C,$22,$20,$10,$2D,$22,$28
    .db $10,$2E,$22,$30,$10,$2F,$22,$38
    .db $18,$38,$22,$00,$18,$39,$22,$08
    .db $18,$3A,$22,$10,$18,$3B,$22,$18
    .db $18,$3C,$22,$20,$18,$3D,$22,$28
    .db $18,$3E,$22,$30,$18,$3F,$22,$38
    .db $80
    UFO_bottom_frame0:
    .db $20,$4A,$22,$10,$20,$4B,$22,$18
    .db $20,$4C,$22,$20,$20,$4D,$22,$28
    .db $80
    UFO_bottom_frame1:
    .db $20,$5A,$22,$10,$20,$5B,$22,$18
    .db $20,$5C,$22,$20,$20,$5D,$22,$28
    .db $80
    UFO_beam:
    .db $28,$07,$02,$18,$28,$07,$42,$20
    .db $30,$17,$02,$18,$30,$17,$42,$20
    .db $38,$26,$02,$10,$38,$27,$02,$18
    .db $38,$27,$42,$20,$38,$26,$42,$28
    .db $40,$36,$02,$10,$40,$37,$02,$18
    .db $40,$37,$42,$20,$40,$36,$42,$28
    .db $80
    flyingPig_frame0:
    .db $00,$54,$23,$00,$00,$55,$23,$08
    .db $00,$56,$23,$10,$08,$64,$23,$00
    .db $08,$65,$23,$08,$08,$66,$23,$10
    .db $80
    flyingPig_frame1:
    .db $00,$54,$23,$00,$00,$55,$23,$08
    .db $00,$57,$23,$10,$08,$64,$23,$00
    .db $08,$65,$23,$08,$08,$66,$23,$10
    .db $80
    flyingTurtle_frame0:
    .db $00,$72,$63,$00,$00,$71,$63,$08
    .db $00,$70,$63,$10,$08,$82,$63,$00
    .db $08,$81,$63,$08,$08,$80,$63,$10
    .db $80
    flyingTurtle_frame1:
    .db $00,$72,$63,$00,$00,$71,$63,$08
    .db $00,$70,$63,$10,$08,$92,$63,$00
    .db $08,$91,$63,$08,$08,$90,$63,$10
    .db $80
    if !optimize
        UNUSED_flyingSnowman:
        .db $00,$A0,$21,$00,$00,$A1,$21,$08
        .db $00,$A2,$21,$10,$08,$B0,$21,$00
        .db $08,$B1,$21,$08,$08,$B2,$21,$10
        .db $08,$B3,$21,$18,$10,$C1,$21,$08
        .db $10,$C2,$21,$10,$10,$C3,$21,$18
        .db $80
    endif 
    witch_frame0:
    .db $00,$74,$63,$08,$00,$73,$63,$10
    .db $08,$85,$63,$00,$08,$84,$63,$08
    .db $08,$83,$63,$10,$10,$95,$63,$00
    .db $10,$94,$63,$08,$10,$93,$63,$10
    .db $80
    witch_frame1:
    .db $00,$74,$63,$08,$00,$73,$63,$10
    .db $08,$75,$63,$00,$08,$84,$63,$08
    .db $08,$83,$63,$10,$10,$95,$63,$00
    .db $10,$94,$63,$08,$10,$93,$63,$10
    .db $80
    rooster_frame0:
    .db $00,$76,$22,$00,$00,$77,$22,$08
    .db $08,$86,$22,$00,$08,$87,$22,$08
    .db $08,$89,$22,$10,$80
    rooster_frame1:
    .db $00,$76,$22,$00,$00,$78,$22,$08
    .db $08,$86,$22,$00,$08,$88,$22,$08
    .db $08,$89,$22,$10,$80
    sprayCan_frame0:
    .db $00,$6A,$21,$00,$00,$6B,$21,$08
    .db $08,$7A,$21,$00,$08,$7B,$21,$08
    .db $10,$8A,$21,$00,$10,$8B,$21,$08
    .db $80
    sprayCan_frame1:
    .db $00,$6A,$21,$00,$00,$6B,$21,$08
    .db $08,$7A,$21,$00,$08,$7B,$21,$08
    .db $10,$8A,$21,$00,$10,$8B,$21,$08
    .db $10,$6C,$22,$10,$10,$6D,$22,$18
    .db $80
    flyingBook_frame0:
    .db $00,$7E,$62,$00,$00,$7D,$62,$08
    .db $00,$7C,$62,$10,$08,$8E,$62,$00
    .db $08,$8D,$62,$08,$08,$8C,$62,$10
    .db $80
    flyingBook_frame1:
    .db $00,$9E,$62,$00,$00,$9D,$62,$08
    .db $00,$9C,$62,$10,$08,$AE,$62,$00
    .db $08,$AD,$62,$08,$08,$AC,$62,$10
    .db $80
    flyingDinosaur_frame0:
    .db $00,$A6,$63,$08,$00,$A5,$63,$10
    .db $00,$A4,$63,$18,$08,$B7,$63,$00
    .db $08,$B6,$63,$08,$08,$B5,$63,$10
    .db $08,$B4,$63,$18,$10,$C7,$63,$00
    .db $10,$C6,$63,$08,$10,$C5,$63,$10
    .db $10,$C4,$63,$18,$18,$D7,$63,$00
    .db $18,$D6,$63,$08,$18,$D5,$63,$10
    .db $18,$D4,$63,$18,$80
    flyingDinosaur_frame1:
    .db $00,$A6,$63,$08,$00,$A5,$63,$10
    .db $00,$A4,$63,$18,$08,$B7,$63,$00
    .db $08,$98,$63,$08,$08,$97,$63,$10
    .db $08,$B4,$63,$18,$10,$C7,$63,$00
    .db $10,$A8,$63,$08,$10,$A7,$63,$10
    .db $10,$C4,$63,$18,$18,$D7,$63,$00
    .db $18,$D6,$63,$08,$18,$D5,$63,$10
    .db $18,$D4,$63,$18,$80
    marioTitle:
    .db $00,$67,$00,$00,$00,$68,$00,$08
    .db $00,$69,$00,$10,$08,$15,$00,$00
    .db $08,$16,$00,$08,$08,$17,$00,$10
    .db $10,$5E,$00,$00,$10,$5F,$00,$08
    .db $10,$3F,$00,$10,$18,$6E,$00,$00
    .db $18,$6F,$00,$08,$18,$4F,$00,$10
    .db $20,$30,$00,$00,$80
    marioTitle_rightFoot_frame0:
    .db $20,$31,$00,$08,$20,$32,$00,$10
    .db $80
    marioTitle_rightFoot_frame1:
    .db $20,$1F,$00,$08,$20,$2F,$00,$10
    .db $80