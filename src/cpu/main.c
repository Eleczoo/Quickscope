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


void handler_routine(void *callback_ref);

// ! ---------- INIT DDR ----------
uint32_t* ddr = (uint32_t*)DDR_BASEADDR;
//uint32_t ddr[100];


int main()
{
    // ! --------- INIT ROTARY ---------
    int status = rotary_encoder_interrupt_init(handler_routine);
	if (status != XST_SUCCESS) 
    {
		xil_printf("Failed to init the interrupt\r\n");
		return XST_FAILURE;
	}



	while(1)
	{

		xil_printf("LAST SIDE : %s\r\n", ddr); // DONT DO THIS
        //usleep(50000);

	}

    return 0;
}


void handler_routine(void *callback_ref)
{
	volatile uint32_t val = rotary_read_sr();
	rotary_write_cr(0xFF); // CLEAR

    //xil_printf("HANDLING ROTARY %d\r\n", val);

    char gauche[7] = "GAUCHE";
    char droite[7] = "DROITE";

    if((val & 0b11) == 1)
    	strncpy((char*)ddr, gauche, 6);
    else if((val & 0b11) == 2)
    	strncpy((char*)ddr, droite, 6);

    ((char*)ddr)[6] = 0;
}

