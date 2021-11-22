;;
;; audio linkers [$FFD0]
;;
;; Seems to be there in order to support PRG bank swapping, assumed safe to optimize
;;
if !optimize
        toAudioUpdate:           
                jmp audioUpdate          

        toInitAPU_var_chan:      
                jmp initAPU_variablesAndChannels

        toInitAPU_status:        
                jmp initAPU_status  
endif 