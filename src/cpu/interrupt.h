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

int interrupt_init(XIntc* interrupt_controller);
int interrupt_start(XIntc* interrupt_controller);
int interrupt_init_exception(XIntc* interrupt_controller);
