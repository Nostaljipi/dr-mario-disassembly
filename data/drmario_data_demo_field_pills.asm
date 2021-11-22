;;
;; demo_field [$CF00]
;;
;; Distribution of virus in the demo
;; 
demo_field:
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.db $D2,$FF,$FF,$FF,$D2,$FF,$D1,$D0
.db $D2,$D1,$FF,$FF,$FF,$FF,$FF,$FF
.db $D0,$FF,$D2,$FF,$D0,$D2,$D2,$FF
.db $FF,$FF,$D2,$D0,$FF,$FF,$FF,$FF
.db $FF,$D2,$FF,$FF,$D1,$D0,$FF,$D1
.db $FF,$FF,$D1,$FF,$D2,$D1,$D1,$D2
.db $D2,$D1,$D0,$D2,$D2,$FF,$D1,$D0
.db $D1,$FF,$FF,$FF,$FF,$D0,$D0,$D1
.db $FF,$D2,$D2,$D0,$D0,$D1,$FF,$D2
.db $D2,$D1,$FF,$D0,$FF,$D1,$D1,$FF

;;
;; demo_pills [$CF80]
;;
;; Reserve of pills used in the demo 
;; 
demo_pills:
.db $00,$00,$07,$02,$01,$05,$03,$05
.db $00,$06,$06,$03,$05,$00,$05,$03
.db $05,$00,$06,$06,$04,$08,$07,$02
.db $00,$02,$05,$00,$06,$07,$06,$04
.db $08,$06,$00,$06,$06,$04,$00,$00
.db $07,$03,$04,$04,$03
if !removeMoreUnused
demo_pills_UNUSED:                              ;Unused because demo does not have time to get to those pills
.db $00,$03,$00,$00,$07,$03,$03,$00
.db $02,$05,$00,$05,$04,$00,$01,$01
.db $00,$06,$08,$02,$06,$02,$00,$02
.db $06,$02,$01,$05,$04,$08,$06,$00
.db $05,$04,$08,$06,$08,$03,$00,$01
.db $01,$01,$01,$00,$07,$02,$01,$05
.db $04,$08,$06,$00,$06,$06,$04,$08
.db $07,$02,$01,$06,$06,$03,$05,$08
.db $02,$06,$03,$04,$04,$03,$01,$05
.db $04,$00,$01,$00,$06,$00,$05,$04
.db $00,$01,$01
endif