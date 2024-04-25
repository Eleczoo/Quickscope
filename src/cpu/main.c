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
#include "stdbool.h"
// --- 
#include "rotary_encoder.h"
#include "adc.h"
#include "addresses.h"
#include "interrupt.h"
#include "display.h"

#define ADC 1
#define SAMPLING_TIME CHANNEL_SIZE // 10s @40 ksps


void handler_routine_rotary(void *callback_ref);
void handler_routine_adc(void *callback_ref);

uint32_t chan_val = 0;

// ! ---------- INIT DDR ----------
uint32_t* ddr = (uint32_t*)DDR_BASEADDR;
volatile uint32_t index_ddr = 0;
volatile uint16_t g_count = 0;


// Interrupt controller Instance
static XIntc interrupt_controller;

int main()
{

	display_text(0, "        Time [ms / div]       ");
	display_text(1, "        Quickscope            ");

	for(int i = 0; i < CHANNEL_SIZE; i++)
		ddr[i] = 500;

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


	while(1)
	{
		draw_signal(ddr);
		//printf("ADC : %ld\r\n", chan_val & 0xFFF);
		//usleep(100);
	}

    return 0;
}





void handler_routine_rotary(void* callback_ref)
{
	volatile uint32_t val = rotary_read_sr();
	rotary_write_cr(0xFF); // CLEAR

    //xil_printf("HANDLING ROTARY %d\r\n", val);
	switch(val & 0b11)
	{
		case LEFT_ROTATION:
			if(g_count > 0)
				g_count--;
			break;
		case RIGHT_ROTATION:
			if(g_count < 4095)
				g_count++;
			break;
	}

	if((val & 0b100) != 0)
	{
		g_count = 500;
	}

	//ddr[index_ddr++ % CHANNEL_SIZE] = g_count;
	//ddr[index_ddr++ % CHANNEL_SIZE] = g_count;
}

void handler_routine_adc(void* callback_ref)
{
	// WRITE SAMPLE IN DDR
	chan_val = adc_read_channel(0);
	ddr[index_ddr++ % SAMPLING_TIME] = chan_val;
}
