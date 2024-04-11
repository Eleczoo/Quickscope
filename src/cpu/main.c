/**
 * Quickscope
 * 
 * HEPIA - ISC
 * 
 * 
 * Authors : 
 * - Albanesi Nicolas
 * - Kandiah Abivarman
 * - Stirnemann Jonas
 *          
 * Date : 11/04/2024 
*/

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "xil_printf.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

// --- 
#include "rotary_encoder.h"
#include "addresses.h"


int main()
{
    // ! --------- INIT ROTARY ---------
    int status = rotary_encoder_interrupt_init(handler_routine);
	if (status != XST_SUCCESS) 
    {
		xil_printf("Failed to init the interrupt\r\n");
		return XST_FAILURE;
	}

    // ! ---------- INIT DDR ----------
    uint32_t* ddr = (uint32_t*)DDR_BASEADDR;

	while(1)
	{
		usleep(500000);

        for(int i = 0; i < 6; i++)
	    	xil_printf("LAST SIDE : %s", ddr); // DONT DO THIS
        xil_printf("\r\n");
	}

    return 0;
}


void handler_routine(void *callback_ref)
{
	volatile uint32_t val = rotary_read_sr();
	rotary_write_cr(0xFF); // CLEAR

    xil_printf("HANDLING ROTARY %d\r\n", val);

    if((val & 0b11) == 1)
    	strncpy(ddr, "GAUCHE", 6);
    else if((val & 0b11) == 2)
    	strncpy(ddr, "DROITE", 6);

    ddr[6] = '\0';
}

