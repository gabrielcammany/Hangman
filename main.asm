LIST P=18F4321, F=INHX32
#include <P18F4321.INC>	

;******************
;* CONFIGURACIONS *
;******************
CONFIG	OSC = HSPLL          
CONFIG	PBADEN = DIG
CONFIG	WDT = OFF

;*************
;* VARIABLES *
;*************

LINIASL  EQU 0x03
LINIASH  EQU 0x04
COLOR EQU 0x05 ;variable la cual modificamos segun queremos un color o otro
FINAL EQU 0x06
AUX EQU 0x09

;*************
;* CONSTANTS *
;*************

BLANCO EQU 0x07
ROJO EQU 0x01
VERDE EQU 0x02

;*********************************
; VECTORS DE RESET I INTERRUPCI� *
;*********************************
    ORG 0x000000
RESET_VECTOR
    goto MAIN		

    ORG 0x000008
HI_INT_VECTOR
    goto HIGH_INT	

    ORG 0x000018
LOW_INT_VECTOR
    retfie FAST		


;***********************************
;* RUTINES DE SERVEI D'INTERRUPCI� *
;***********************************
HIGH_INT
    nop
    nop
    nop
    ;codi de interrupcio
    clrf LATA, 0;1
    call RESET_TIMER;2
    
    bsf LATE,0,0;1
    movlw 0x00;1
    cpfsgt LINIASH,0;1/2
    call PRIMERA_MITAD
    
    cpfslt LINIASH,0
    call ESPERA_PM;
    
    goto FINAL_SYNC;2

PRIMERA_MITAD
    movlw 0x02;1
    cpfsgt LINIASL, 0;1-2-3
    goto ACTIVA_VSYNC;1
    bcf LATE,1,0;1
    ;goto FINAL_SYNC;2
    return;2
   
ACTIVA_VSYNC
    bsf LATE,1,0;1
    ;goto FINAL_SYNC
    
FINAL_SYNC
    incf LINIASL,1,0;1
    btfsc STATUS, C, 0;1/2
    call INCREMENTA_HIGH;2 
    btfss STATUS, C, 0
    call ESPERA_IH;VR3
    ;3
    call COMPRUEBA_FINAL;2
    ;22
    retfie FAST;2

INCREMENTA_HIGH 
   incf LINIASH,1,0;1
   return;2
    
COMPRUEBA_FINAL
    movlw 0x02
    ;9
    cpfslt LINIASH,0
    call COMPRUEBA_LOW
    
    cpfsgt LINIASH,0
    call ESPERA_PM;vr8
  
    bcf LATE,0,0
    return

COMPRUEBA_LOW
    movlw 0x7F;1-Compensamos el periodo de vSync
    cpfslt LINIASL,0;2
    call Espera_Nou;2
    
    cpfsgt LINIASL,0
    call ESPERA_IVARS;vr5
    
    return
;****************************
;* MAIN I RESTA DE FUNCIONS *
;****************************

Espera_Nou
    clrf LINIASL, 0;1
    clrf LINIASH, 0;1
    NOP
    NOP
    NOP 
    NOP
    return
    
INIT_VARS
    clrf LINIASL, 0;1
    clrf LINIASH, 0;1
    clrf FINAL, 0
    nop
    ;NOP
    NOP 
    return;2
    
INIT_PORTS
    ;clrf TRISA, 0
    bcf TRISA, 0, 0	;Red
    bcf TRISA, 1, 0	;Green
    bcf TRISA, 2, 0	;Blue
    ;movlw 0x08
    ;movwf TRISE, 0
    bcf TRISE, 0, 0	;HSync
    bcf TRISE, 1, 0	;VSync
    ;setf TRISC, 0
    ;setf TRISD, 0
    bsf TRISC, 0, 0	;PartidaGuanyada
    bsf TRISD, 0, 0	;NumErrors[0]
    bsf TRISD, 1, 0	;NumErrors[1]
    bsf TRISD, 2, 0	;NumErrors[2]
    bsf TRISD, 3, 0	;NumErrors[3]
    return
    
INIT_TIMER
    ;10001000
    movlw 0x88
    movwf T0CON,0
    bcf RCON, IPEN, 0
    
    ;11100000
    movlw 0xE0
    movwf INTCON, 0
    
    call RESET_TIMER
    return
    
RESET_TIMER
    movlw 0xFE
    movwf TMR0H, 0
    ;movlw 0xD0
    movlw 0xD3
    movwf TMR0L, 0
    bcf INTCON, TMR0IF, 0
    return
    
;********
;* MAIN *
;********
;todos esp -2!!!

    
MAIN
    call INIT_VARS
    call INIT_PORTS
    call INIT_TIMER
    
PRIMERA
    movlw 0x5D ;Final Zona 1
    cpfsgt LINIASL,0
    goto LOOP
    movlw 0x71 ;Final Zona 1
    cpfsgt LINIASL,0
    goto LINEA_ZONA1
    movlw 0xAC ;Final zona 2
    cpfsgt LINIASL,0
    goto ZONA_2
    movlw 0xDE ;Final zona 3
    cpfsgt LINIASL,0
    goto ZONA_3
    movlw 0xF0 ;Final zona 4
    cpfsgt LINIASL,0
    goto ZONA_4
    movlw 0xF6 ;Final zona 4
    cpfsgt LINIASL,0
    goto ZONA_5
    movlw 0xFF ;Final zona 5
    cpfsgt LINIASL,0
    goto ZONA_6
    goto LOOP
    
LOOP
    call COLOR_FINAL
    movlw 0x00
    cpfsgt LINIASH,0
    goto PRIMERA	    
    movlw 0x01
    cpfsgt LINIASH,0
    goto SEGUNDA
    goto TERCERA
    goto LOOP
    
    
SEGUNDA
    movlw 0x2F ;Final Zona 7
    cpfsgt LINIASL,0
    goto ZONA_7 
    
ZONA8_ZONA9
    movlw 0x3F ;Final zona 8
    cpfsgt LINIASL,0
    goto ZONA_8

ZONA9_ZONA10
    movlw 0x77 ;Final zona 9
    cpfsgt LINIASL,0
    goto ZONA_9
   
ZONA10_ZONA11
    movlw 0xA5 ;Final zona 10
    cpfsgt LINIASL,0
    goto ZONA_10   
    
ZONA11_ZONA12
    movlw 0xB6 ;Final zona 11
    cpfsgt LINIASL,0
    goto ZONA_11

ZONA13_ZONA14
    movlw 0xF5 ;Final zona 11
    cpfslt LINIASL,0
    goto ZONA_12
    goto LOOP 


TERCERA
    movlw 0x2F ;Final Zona 7
    cpfsgt LINIASL,0
    goto ZONA_13
    movlw 0x3B ;Final Zona 7
    cpfsgt LINIASL,0
    goto ZONA_14
    movlw 0x75 ;Final Zona 7
    cpfsgt LINIASL,0
    goto ZONA_15
    goto LOOP

ZONA_15
    NOP
    NOP
    movlw 0x01
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    NOP
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    goto LOOP    
    
ZONA_14
    NOP
    movlw 0x07
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    
    
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    NOP
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    goto LOOP
    
    
ZONA_13
    NOP
    NOP
    movlw 0x03
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    
    
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    NOP
    call ESPERA_5
    NOP
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    movwf LATA,0
    NOP
    NOP
    NOP
    NOP
    clrf LATA,0 
    
    
    NOP
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    goto LOOP     
    
ZONA_12
    NOP
    movlw 0x03
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    movwf LATA,0
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    clrf LATA,0 
    NOP
    call ESPERA_5
    movwf LATA,0
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    clrf LATA,0 
    NOP
    call ESPERA_5
    movwf LATA,0
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    clrf LATA,0 
    NOP
    call ESPERA_5
    NOP
    goto LOOP 
    
ZONA_11
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP
    NOP
    call ESPERA_DEU
    NOP
    call ESPERA_5
    NOP
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    goto LOOP        
    
ZONA_10
    NOP
    NOP
    call ESPERA_5
    call ESPERA_5
    call ESPERA_DEU
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    NOP
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    NOP
    call ESPERA_5
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    goto LOOP        

ZONA_9
    NOP
    NOP
    call ESPERA_5
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP
    movlw 0x07
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    NOP
    movlw 0x07
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    call ESPERA_DEU
    goto LOOP   

ZONA_8
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU 
    movlw 0x06
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_DEU
    call ESPERA_5
    NOP
    call ESPERA_5
    call ESPERA_DEU
    clrf LATA,0 
    NOP
    call ESPERA_5
    call ESPERA_DEU
    NOP
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    goto LOOP

ZONA_7
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU 
    movlw 0x04
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    NOP
    NOP
    NOP
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    goto LOOP

ZONA_6
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    movlw 0x04
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    NOP
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_5
    call ESPERA_5
    call ESPERA_DEU
    goto LOOP
    
    
ZONA_5
    NOP
    NOP
    NOP
    call ESPERA_DEU
    NOP
    NOP
    NOP
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA 
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    movlw 0x04
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movlw 0x06
    cpfslt PORTD, 0 
    goto ZONA_5_SIN
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    movff COLOR, LATA 
    call ESPERA_5
    NOP
    NOP
    NOP
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    NOP
    goto LOOP

ZONA_5_SIN
    movff COLOR, LATA 
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_5
    call ESPERA_5
    NOP
    goto LOOP
    
ZONA_4
    NOP
    NOP
    NOP
    call ESPERA_DEU
    NOP
    call ESPERA_5
    NOP
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA 
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    movlw 0x04
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA 
    call ESPERA_5
    NOP
    NOP
    NOP
    clrf LATA,0 
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    NOP    
    goto LOOP
    
    

ZONA_3
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    NOP
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    NOP
    movlw 0x03
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA 
    call ESPERA_5
    call ESPERA_5
    call ESPERA_5
    NOP
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP 
    goto LOOP
        
    
ZONA_2
    NOP
    NOP
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    movlw 0x00
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    movlw 0x02
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA 
    NOP
    NOP
    clrf LATA,0 
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    goto LOOP
    
LINEA_ZONA1
    NOP
    NOP
    NOP
    NOP
    NOP
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    movlw 0x01
    cpfsgt PORTD, 0 
    clrf COLOR, 0
    movff COLOR, LATA
    NOP
    NOP
    call ESPERA_5
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    clrf LATA,0 
    call ESPERA_DEU
    call ESPERA_DEU
    call ESPERA_5
    NOP
    NOP
    NOP
    NOP
    NOP
    nop
    goto LOOP
    
    
ESPERA_IH
    NOP
    return
    
ESPERA_IVARS
    NOP
    NOP
    NOP
    return
    
ESPERA_PM
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    return
    
ESPERA_5
    NOP
    RETURN
    
ESPERA_DEU
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    return
  
	
	  
COLOR_FINAL
    movlw BLANCO ;1 1 1
    btfsc PORTC, 0, 0;2 1 2 
    movlw VERDE ;0 1 0
    btfsc PORTD, 3, 0 ;1 2 2
    movlw ROJO ;1 0 0
    movwf COLOR, 0 ;1 1 1
    NOP ;1 
    NOP ;1
    NOP ;1
    NOP ;1
    return
      
	
;*******
;* END *
;*******    
    END