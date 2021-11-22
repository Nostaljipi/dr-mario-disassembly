;;
;; dmcSample_code20_and40 & others [$FD00]
;;
;; 1-bit delta-PCM samples used by DMC channel (both are bongo/snare-like instruments, third one is unused)
;; 
dmcSample_code20_and40:                 ;F4 written to Dmc Address (in vanilla), actually 113 bytes long, not the full 128 bytes here (dmcSample_code20_and40)
.db $74,$FF,$FF,$03,$24,$01,$82,$54
.db $01,$10,$FF,$FF,$FF,$FF,$0F,$00
.db $00,$B0,$FF,$7F,$09,$00,$00,$B8
.db $FF,$FF,$0F,$00,$E0,$FF,$FF,$02
.db $01,$00,$C0,$FF,$FF,$FF,$01,$00
.db $00,$FE,$FF,$FF,$01,$00,$C0,$FE
.db $5F,$02,$00,$FC,$FF,$FF,$FF,$00
.db $00,$00,$E0,$FF,$FF,$07,$00,$00
.db $FF,$FF,$1F,$00,$00,$F4,$FF,$FF
.db $03,$00,$00,$FC,$FF,$FF,$1F,$00
.db $00,$E0,$FF,$FF,$03,$00,$80,$FF
.db $FF,$3F,$00,$00,$F0,$FF,$FF,$0F
.db $00,$00,$80,$FF,$FF,$7F,$00,$00
.db $FE,$FF,$02,$00,$00,$F8,$FF,$FF
.db $3F
if !removeMoreUnused
    dmcSample_code20_and40_overflow:
    .db $01,$00,$C0,$FF,$FF,$3F,$00,$00     ;Unused, but can't really be used for anything else (unless this data would be $0F bytes long maximum)
    .db $C0,$FF,$BF,$04,$25,$A9,$FF
endif 

align 64                                ;Each sample must be aligned on a 64-byte boundary

dmcSample_code60_and80:                 ;F6 written to Dmc adress (in vanilla), actually 241 bytes long (dmcSample_code60_and80)
.db $FF,$02,$00,$00,$E0,$FF,$FF,$5F
.db $00,$00,$E0,$FF,$FF,$97,$04,$00
.db $AC,$55,$B7,$93,$44,$F7,$EF,$5F
.db $41,$00,$00,$D5,$7D,$EF,$5E,$11
.db $00,$F5,$7D,$DF,$57,$02,$24,$5A
.db $82,$6A,$35,$B5,$AA,$F6,$FD,$2F
.db $25,$02,$00,$B5,$75,$7F,$4B,$42
.db $04,$B4,$FD,$FF,$7E,$11,$00,$54
.db $AA,$FA,$56,$82,$52,$DB,$7D,$AF
.db $2A,$02,$80,$F6,$FF,$3F,$09,$00
.db $00,$FB,$FD,$BF,$46,$00,$A5,$F6
.db $FF,$2A,$00,$00,$E8,$FE,$FF,$2F
.db $01,$00,$6A,$FF,$FF,$25,$00,$00
.db $DC,$FF,$BF,$12,$00,$B0,$FB,$FF
.db $5F,$04,$00,$00,$FB,$FF,$BF,$00
.db $00,$E8,$FF,$FF,$13,$00,$00,$75
.db $FF,$FF,$09,$00,$40,$EE,$FF,$7F
.db $11,$00,$C0,$FD,$FF,$4B,$00,$00
.db $B5,$FD,$FF,$2B,$00,$80,$F6,$FE
.db $FF,$08,$02,$00,$F6,$FF,$5F,$49
.db $00,$50,$F7,$7F,$AF,$08,$00,$A4
.db $F6,$FF,$2D,$04,$11,$DA,$F7,$76
.db $2B,$04,$90,$6B,$DF,$AD,$12,$44
.db $50,$FD,$FE,$6A,$25,$41,$52,$D5
.db $F6,$AA,$24,$51,$69,$DB,$DE,$4A
.db $92,$28,$55,$DB,$B6,$AA,$52,$A1
.db $52,$5B,$37,$55,$95,$54,$A9,$AD
.db $5A,$55,$A5,$54,$55,$55,$AB,$55
.db $25,$55,$A9,$D3,$D6,$4A,$95,$A4
.db $AA,$5A,$AB,$4D,$95,$54,$B2,$DA
.db $B6
if !removeMoreUnused
    dmcSample_code60_and80_overflow:
    .db $A9,$92,$54,$54,$EB,$DA,$AA,$92
    .db $A4,$4A,$6B,$B7,$69,$92,$A4
endif

if !removeUnused
    dmcSample_UNUSED:                       ;If FA was written as sample addr, would have to be 113 bytes long I think (dmcSample_UNUSED)
    .db $52,$6F,$B5,$A9,$24,$A4,$6A,$DB
    .db $B6,$95,$22,$51,$6A,$FB,$56,$15
    .db $12,$29,$B5,$FB,$D6,$92,$90,$54
    .db $6D,$7B,$55,$91,$90,$A4,$77,$BF
    .db $A6,$02,$12,$A9,$F7,$DB,$4A,$11
    .db $92,$B4,$ED,$5D,$55,$82,$A4,$B6
    .db $B7,$2B,$49,$90,$A4,$F6,$77,$5B
    .db $49,$40,$52,$BB,$77,$2B,$09,$A1
    .db $6C,$BB,$6D,$95,$48,$A8,$DA,$DE
    .db $B5,$92,$08,$91,$6D,$F7,$B6,$24
    .db $89,$52,$6D,$DB,$AA,$24,$49,$55
    .db $AF,$5E,$95,$14,$A1,$B2,$7B,$B7
    .db $92,$92,$48,$69,$DB,$56,$95,$52
    .db $A9,$6A,$DB,$AA,$92,$24,$D5,$6A
    .db $AF
    dmcSample_UNUSED_overflow:
    .db $44,$44,$55,$44,$44,$44,$44,$33
    .db $22,$55,$AA,$00,$55,$00,$00
endif