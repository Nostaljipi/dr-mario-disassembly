if !removeUnused
    UNUSED_DATA_FF32:
    if ver_revA
        .db         $00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    elseif ver_EU
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF
    else
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    endif 
endif 