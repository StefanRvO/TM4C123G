#include <stdint.h>
#include "inc/tm4c123gh6pm.h"
#include "headers/setup.h"
#include "inc/hw_ints.h"
#include "inc/hw_types.h"
#include "driverlib/interrupt.h"
#include "driverlib/fpu.h"
#include "ISR.h"
#include "inc/hw_memmap.h"

#include "driverlib/interrupt.h"

#include "driverlib/gpio.h"

#include "driverlib/sysctl.h"
void setup_()
{
	int dummy;

	//Enable the GPIO port that is used for the on-board LED.
	SYSCTL_RCGC2_R = SYSCTL_RCGC2_GPIOF;

	//Do a dummy read to insert a few cycles after enabling peripheral.
	dummy = SYSCTL_RCGC2_R;

	//Set the direction as output (PF2).
	GPIO_PORTF_DIR_R = 0b1000;

	//Enable the GPIO pins for digital function (PF4 and PF2).
	GPIO_PORTF_DEN_R = 0b1000;
  SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);        // Enable port F
  GPIOPinTypeGPIOInput(GPIO_PORTF_BASE, GPIO_PIN_4);  // Init PF4 as input

  GPIOPadConfigSet(GPIO_PORTF_BASE, GPIO_PIN_4,
		GPIO_STRENGTH_2MA, GPIO_PIN_TYPE_STD_WPU);  // Enable weak pullup resistor for PF4
	//Enable internal pill-up (PF4).
	// Interrupt setup
	GPIO_PORTF_PUR_R = 0b10000;
    GPIOPinIntDisable(GPIO_PORTF_BASE, GPIO_PIN_4);        // Disable interrupt for PF4 (in case it was enabled)

    GPIOPinIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);      // Clear pending interrupts for PF4

    GPIOPortIntRegister(GPIO_PORTF_BASE, onButtonDown);     // Register our handler function for port F

    GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4,

        GPIO_FALLING_EDGE);             // Configure PF4 for falling edge trigger
    GPIOPinIntEnable(GPIO_PORTF_BASE, GPIO_PIN_4);     // Enable interrupt for PF4
}
