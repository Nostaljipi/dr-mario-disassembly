if !removeUnused
    UNUSED_DATA_D2CC: 
    if !ver_EU  
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00,$00,$00,$00,$00
        .db $00,$00,$00,$00
    else 
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .db $FF,$FF,$FF,$FF
    endif 
endif 