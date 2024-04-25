#include <stdint.h>
#include "rotary_encoder.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"


// This fully setup the interrupt and setup the given interrupt routine.
int rotary_encoder_interrupt_init(	XInterruptHandler handler_routine,
									XIntc* interrupt_controller)
{
	int status;

    status = XIntc_Connect(interrupt_controller, INTC_DEVICE_INT_ID_ROTARY,
				   (XInterruptHandler)handler_routine,
				   (void *)0);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupt for the device and then cause (simulate) an
	 * interrupt so the handlers will be called.
	 */
	XIntc_Enable(interrupt_controller, INTC_DEVICE_INT_ID_ROTARY);

	return XST_SUCCESS;
}


uint32_t rotary_read_cr(void)
{
    return PERIPHERAL->CR;
}

void rotary_write_cr(uint32_t val)
{
    PERIPHERAL->CR = val;
}

uint32_t rotary_read_sr(void)
{
    return PERIPHERAL->SR;
}

void rotary_write_sr(uint32_t val)
{
    PERIPHERAL->SR = val;
}
