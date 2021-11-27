if !removeUnused
    UNUSED_DATA_CED5:
    if ver_revA
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00
    elseif ver_EU
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF
    else 
        .db $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
        .db $FC,$FC,$FC,$23,$C0,$20,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$55
        .db $55,$55,$55,$55,$55,$FF,$FF,$55
        .db $55,$55,$55,$55,$55,$FF,$FF,$55
        .db $55,$55,$55,$55,$55,$FF,$23,$E0
        .db $20,$FF,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$F0,$F0,$F0  
    endif 
endif 