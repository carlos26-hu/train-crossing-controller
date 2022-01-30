;
; AssemblerApplication1.asm
;
; Created: 2019. 06. 09. 19:55:03
; Author : Lovasz Karoly
;


.include "m128def.inc"
.def TEMP      = R16
.DEF COUNTER  = R17
.DEF SREGCOPY = R18
.DEF GOMB      = R19
.DEF UZEM		=R20
/*---------------------------------- INTERRUPT VECTORS ---------------------------------------------------*/
.org 0
	rjmp MAIN                 ;  (0x00 memcim, ez a RESET vector)


.ORG 0X20                   ;TIMER0 OVERFLOW VECTOR
	JMP ISRT0


/*---------------------------------- MAIN PROGRAM ---------------------------------------------------------*/
.org 0x46
MAIN:

//	STACK_INIT: stack pointer beallitasa az adatmemoria legutolso rekeszere
    	LDI TEMP,HIGH(RAMEND)	;TMP-be betoltjuk az adatmemoria veget (4351-es szam felso 8 bitjet)    
	OUT SPH,TEMP             ; ezt atmozgatjuk a STACK POINTER HIGH REGISZTERBE 					
	LDI TEMP,LOW(RAMEND)	 	;TMP-be betoltjuk az adatmemoria veget (4351-es szam also 8 bitjet)	  
	OUT SPL,TEMP             ; ezt atmozgatjuk a STACK POINTER LOW REGISZTERBE                   

	LDI TEMP,1				
	OUT TIMSK,TEMP

	LDI TEMP,7
	OUT TCCR0,TEMP    

	LDI UZEM,0				; uzem valtozo 0, mivel szabad az atjaras

	LDI TEMP,16				;16ot irunk a temp valtozoba,
	OUT PORTB, TEMP			;hogy a led0 bekapcsoljon
	CLR COUNTER
	
	CLR TEMP

	SEI						;GLOBAL INTERRUPTS ENABLE

	
LOOP:
	LDS GOMB,PING			;gombsor beolvasas
	CPI GOMB,1				;ha a k0-t lenyomjak,
	BREQ LEZAR				;ugrik a lezar cimkere
	CPI GOMB,2				;ha a k1-t lenyomjak
	BREQ KINYIT				;ugrik a kinyit cimkere
	JMP LOOP				

;***********************************************
LEZAR:
	LDI UZEM,1				;uzem valtozo 1re
	JMP LOOP

;***********************************************
KINYIT:
	LDI UZEM,0				;uzem valtozo 0ra
	JMP LOOP




;---------------------MEGSZAKITAS RUTINOK
ISRT0:

	IN SREGCOPY, SREG	;STATUS REGISZTER ALLAPOTANAK MENTESE!!!!!
	INC COUNTER		;szamlalo novelese
	CPI COUNTER, 43		;ha szamlalo nem 43,
	BRNE ISRT0VEGE		;ugrik a megszakitas rutin vegere
	CLR COUNTER		;ha szamlalo 43, torli a szamlalot
	CPI UZEM,0		; ha uzem 0,
	BREQ NYIT		;ugrik a nyitasra
	CPI UZEM,1		; ha uzem 1,
	BREQ ZAR		;ugrik a zarasra

;******************************************************
NYIT:
	LDI TEMP,0		;0 ertek a temp valtozoba
	OUT PORTD,TEMP		;temp valtozo a portd-re, hogy kikapcsoljon a led
	IN TEMP, PORTB		;portb beolvasas tempbe
	CPI TEMP,0		;ha temp (portb) 0,
	BREQ BEKAPCS		;ugrik a bekapcsolasra
	CPI TEMP,16		;ha temp (portb) 16;
	BREQ KIKAPCS		;ugrik a kikapcsolasra
	RETI			;visszater a megszakitashoz
	;******************************************************
	KIKAPCS:
		LDI TEMP,0
		OUT PORTB, TEMP    ;portb led kikapcsol
		RETI
	;******************************************************
	BEKAPCS:
		LDI TEMP,16
		OUT PORTB,TEMP		;portb led bekapcsol
		RETI

;**********************************************************
ZAR:
	LDI TEMP,0
	OUT PORTB,TEMP			;portb led kikapcsol
	IN TEMP, PORTD			;portd beolvasas tempbe
	CPI TEMP,64			;ha temp (portd) nem 64,
	BRNE LED6			;ugrik a led 7re
	CPI TEMP,128			;ha temp (portd) nem 128,
	BRNE LED7			;ugrik a led6ra
	RETI

	;*******************************************************
	LED6:
		LDI TEMP,64
		OUT PORTD, TEMP    	;portd 6os led bekapcsol
		RETI
	;********************************************************
	LED7:
		LDI TEMP,128
		OUT PORTD, TEMP		;portd 7es led bekapcsol
		RETI

;************************************************************
ISRT0VEGE:
	OUT SREG,SREGCOPY ; STATUS REGISZTER ALLAPOTANAK VISSZAALLITASA!!!!
	RETI


    