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

volatile uint32_t chan_val = 0;

// // ! ---------- INIT DDR ----------
uint32_t* ddr = (uint32_t*)DDR_BASEADDR;
volatile uint32_t index_ddr = 0;

// ! ---------- INIT FAGS AND OFFSETS ----------
volatile uint16_t g_offset_vertical = 4 * 80;
volatile uint16_t g_offset_horizontal = 0;
volatile bool g_state_pressed = false;

// Interrupt controller Instance
static XIntc interrupt_controller;

int main()
{

	clear_text();
	display_text(1, "100 mV / div");


	//for(int i = 0; i < CHANNEL_SIZE; i++)
	//	ddr[i] = 500;

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

	char text[30];
	uint16_t toggle_step = 0;
	uint16_t old_vertical_offset = 0;
	uint16_t old_vertical_offset_display = 0;
	uint16_t old_horizontal_offset = 0;
	bool old_pressed = 0;
	while(1)
	{
		if(toggle_step++ >= g_offset_horizontal * 5)
		{
			toggle_step = 0;
			chan_val = adc_read_channel(0);
			ddr[index_ddr++] = chan_val >> 4;
		}

		if((old_vertical_offset != g_offset_vertical) || (old_horizontal_offset != g_offset_horizontal) || (old_pressed != g_state_pressed))
		{
			old_vertical_offset = g_offset_vertical;
			old_horizontal_offset = g_offset_horizontal;
			old_pressed = g_state_pressed;
			sprintf(text, "  %c SCALE : %d", g_state_pressed ? 'V' : 'H', g_state_pressed ? g_offset_vertical  : g_offset_horizontal + 1);
			display_text(0, text);
		}

		if((index_ddr == (SAMPLING_TIME)) || (old_vertical_offset_display != g_offset_vertical))
		{
			old_vertical_offset_display = g_offset_vertical;
			index_ddr = 0;
			draw_signal(ddr, g_offset_vertical);
		}




		//xil_printf("ADC : %ld | ROTARY = %d      \r", chan_val >> 6, g_count);
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
			if(g_state_pressed)
			{
				if(g_offset_vertical > 0)
					g_offset_vertical -= 5;
			}
			else
			{
				if(g_offset_horizontal > 0)
					g_offset_horizontal -= 1;
			}


			break;
		case RIGHT_ROTATION:
			if(g_state_pressed)
			{
				if(g_offset_vertical < 800)
					g_offset_vertical += 5;
			}
			else
			{
				if(g_offset_horizontal < 20)
					g_offset_horizontal += 1;
			}
			break;
	}

	if((val & 0b100) != 0)
		g_state_pressed = !g_state_pressed;

	//ddr[index_ddr++ % CHANNEL_SIZE] = g_count;
	//ddr[index_ddr++ % CHANNEL_SIZE] = g_count;
}

// NOT USED ANYMORE
void handler_routine_adc(void* callback_ref)
{
	// WRITE SAMPLE IN DDR
	chan_val = adc_read_channel(0);
	ddr[index_ddr++ % SAMPLING_TIME] = chan_val >> 4;
}
