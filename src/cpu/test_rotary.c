#include <stdio.h>
#include "xil_printf.h"
#include <stdint.h>
#include "rotary_encoder.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "rotary_encoder.h"
#include "sleep.h"

void handler_routine(void *callback_ref);

int main()
{
    print("----- ROTARY ENCODER TEST -----");

    int status = rotary_encoder_interrupt_init(handler_routine);

	if (status != XST_SUCCESS) {
		xil_printf("Failed to init the interrupt\r\n");
		return XST_FAILURE;
	}

	xil_printf("Successfully setup the interrupt\r\n");

	while(1)
	{
		usleep(500000);
		xil_printf("0.5s passed\r\n");
	}

    return 0;
}


void handler_routine_rotary(void *callback_ref)
{
	volatile uint32_t val = rotary_read_sr();
	// Clear the interrupt
	rotary_write_cr(0xFF);

	xil_printf("%ld\r\n", val);
}