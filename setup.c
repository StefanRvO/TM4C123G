#include <stdint.h>
#include "inc/tm4c123gh6pm.h"
#include "headers/setup.h"
void setup()
{
	int dummy;

	//Enable the GPIO port that is used for the on-board LED.
	SYSCTL_RCGC2_R = SYSCTL_RCGC2_GPIOF;

	//Do a dummy read to insert a few cycles after enabling peripheral.
	dummy = SYSCTL_RCGC2_R;

	//Set the direction as output (PF1).
	GPIO_PORTF_DIR_R = 0x02;

	//Enable the GPIO pins for digital function (PF0 and PF1).
	GPIO_PORTF_DEN_R = 0x12;

	//Enable internal pill-up (PF1).
	GPIO_PORTF_PUR_R = 0x10;
}
