#include <stdint.h>
#include "rotary_encoder.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "interrupt.h"



// This fully setup the interrupt and setup the given interrupt routine.
int interrupt_init(XIntc* interrupt_controller)
{
	int status;

    // ! Init Interrupt Controller driver
	status = XIntc_Initialize(interrupt_controller, INTC_DEVICE_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

// This fully setup the interrupt and setup the given interrupt routine.
int interrupt_start(XIntc* interrupt_controller)
{
	int status;

	//  * Start the interrupt controller such that interrupts are enabled for
	//  * all devices that cause interrupts, specify simulation mode so that
	//  * an interrupt can be caused by software rather than a real hardware
	//  * interrupt.
	status = XIntc_Start(interrupt_controller, XIN_REAL_MODE);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

int interrupt_init_exception(XIntc* interrupt_controller)
{
	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				(Xil_ExceptionHandler)XIntc_InterruptHandler,
				interrupt_controller);

	/*
	 * Enable exceptions.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

// PUT THIS TO SETUP YOUR DEVICE INTERRUPT
// XIntc_Enable(interrupt_controller, INTC_DEVICE_INT_ID);
// ! SETUP INTERRUPT SYSTEM

/*status = XIntc_Connect(&interrupt_controller, INTC_DEVICE_INT_ID,
			   (XInterruptHandler)handler_routine,
			   (void *)0);
if (status != XST_SUCCESS) {
	return XST_FAILURE;
}
*/
