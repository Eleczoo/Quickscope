#pragma once

#include <stdint.h>
#include "rotary_encoder.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "addresses.h"


/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define INTC_DEVICE_ID		  XPAR_AXI_INTC_0_DEVICE_ID

/*
 *  This is the Interrupt Number of the Device whose Interrupt Output is
 *  connected to the Input of the Interrupt Controller
 */
#define INTC_DEVICE_INT_ID	  0



// Peripheral register map
typedef struct{
    volatile uint32_t CR; // Control register
    volatile uint32_t SR; // Status register
}peripheral_t;

typedef enum{
    LEFT,
    RIGHT,
}rotation_t;

#define PERIPHERAL ((peripheral_t *) ROTARY_BASEADDR)


// CONTROL REGISTER
uint32_t rotary_read_cr(void);
void rotary_write_cr(uint32_t val);

// STATUS REGISTER
uint32_t rotary_read_sr(void);
void rotary_write_sr(uint32_t val);

int rotary_encoder_interrupt_init(XInterruptHandler handler_routine);
