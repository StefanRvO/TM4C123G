#include "ISR.h"
void onButtonDown()
{
		if (GPIOPinIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4) {
            // PF4 was interrupt cause
			GPIO_PORTF_DATA_R ^= 0b1000;
      GPIOPinIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);  // Clear interrupt flag
		}
}
