#include "xparameters.h"
#include "xsysmon.h"

#define XSM_SEQ_CH_AUX_MASK	XSM_SEQ_CH_AUX00 | \
				XSM_SEQ_CH_AUX01 | \
				XSM_SEQ_CH_AUX08 | \
				XSM_SEQ_CH_AUX09

void setup_xadc();
u16 get_adc_aux_raw(u8 aux_channel);
