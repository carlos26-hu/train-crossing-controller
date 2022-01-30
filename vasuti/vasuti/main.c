/*
 * vasuti.c
 *
 * Created: 2019. 05. 28. 20:20:50
 * Author : carlo
 */ 


#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

volatile int i=0,uzem=0;

int main(void)
{
	sei();  //global interrupts enable
	TIMSK=1; //Timer0 Interrupt enable
	TCCR0 = 7;  //Timer0 on
    while (1) 
    {
		if (PING==2)
		{
			uzem=1;
		}else if (PING==1)
		{
			uzem=0;
		}
	}
}

ISR(TIMER0_OVF_vect)
{
	i++;
	if (uzem == 0)
	{	PORTD=0;
		if(i>=43) //ha eltelt 0.7 mp
		{
			i = 0;
			if(PORTB==16)
				{
				PORTB=0;
				}else { i=0; PORTB=16;}
		}
	}else if (uzem ==1 )
			{ PORTB=0;
				if (i>=43)
				{	if (PORTD==64)
					{
					i=0;		
					PORTD=128;
					}
				 else {i=0; PORTD=64;}
				}
			}
}