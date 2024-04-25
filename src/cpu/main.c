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
#include "adc.h"
#include "addresses.h"
#include "interrupt.h"
#include "display.h"

// #define ADC 1


void handler_routine_rotary(void *callback_ref);
void handler_routine_adc(void *callback_ref);


// ! ---------- INIT DDR ----------
uint32_t* ddr = (uint32_t*)DDR_BASEADDR;
//uint32_t ddr[100];



// Interrupt controller Instance
static XIntc interrupt_controller;

uint32_t chan;
uint16_t chan_val;
volatile uint32_t count = 0;


int main()
{

	// ! --------- INIT INTERRUPT ---------
	interrupt_init(&interrupt_controller);


    // ! --------- INIT ROTARY ---------
    int status = rotary_encoder_interrupt_init(handler_routine_rotary, &interrupt_controller);
	if (status != XST_SUCCESS) 
    {
		xil_printf("Failed to init the interrupt ROTARY\r\n");
		return XST_FAILURE;
	}

    // ! --------- INIT ADC ---------
#ifdef ADC
    status = adc_interrupt_init(handler_routine_adc, &interrupt_controller);
	if (status != XST_SUCCESS)
    {
		xil_printf("Failed to init the interrupt ADC\r\n");
		return XST_FAILURE;
	}
#endif

	// ! --------- START INTERRUPT ---------
	interrupt_start(&interrupt_controller);

	// ! --------- INIT EXCEPTION ---------
	interrupt_init_exception(&interrupt_controller);

	// display_text(1, "                              ");
	display_text(0, "        Time [ms / div]       ");
	display_text(1, "        Quickscope            ");

	while(1)
	{

		if((count % 256) == 0)
		{
			xil_printf("LAST SIDE : %s | %d | %d | %d\r\n", ddr, chan, chan_val, count); // DONT DO THIS
		}


	}

    return 0;
}


void handler_routine_rotary(void* callback_ref)
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

void handler_routine_adc(void* callback_ref)
{
	//chan = adc_get_channel((XSysMon*)callback_ref);
	chan_val = adc_read_channel(0);

	count++;
}


// MEMORY SETUP
// MAX 512 MB
//


