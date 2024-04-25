#pragma once


#include "xparameters.h"
#include "xsysmon.h"
#include <stdint.h>
#include "rotary_encoder.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xil_printf.h"
#include "addresses.h"

#define INTC_DEVICE_INT_ID_ADC 1

#define XSM_SEQ_CH_AUX_MASK	XSM_SEQ_CH_AUX00

int adc_interrupt_init(XInterruptHandler handler_routine,
				XIntc* interrupt_controller);
uint16_t adc_read_channel(u8 aux_channel);
uint32_t adc_get_channel(XSysMon* callback_ref);


