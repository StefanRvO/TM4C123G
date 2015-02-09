#include "ISR.h"
char leds=0b000;
void onButtonDown()
{
		if (GPIOPinIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4) {
            // PF4 was interrupt cause
			leds++;
			if (leds>=0b1000)
			{
				leds=0b000;
			}
			GPIO_PORTF_DATA_R =  leds<<1;
      GPIOPinIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);  // Clear interrupt flag
		}
}
