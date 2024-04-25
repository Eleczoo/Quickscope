/*
	XADC Documentation : https://docs.xilinx.com/r/en-US/ug480_7Series_XADC/7-Series-FPGAs-and-Zynq-7000-SoC-XADC-Dual-12-Bit-1-MSPS-Analog-to-Digital-Converter-User-Guide-UG480
*/

#include "adc.h"

static XSysMon SysMonInst;      /* System Monitor driver instance */

int adc_interrupt_init(XInterruptHandler handler_routine,
						XIntc* interrupt_controller)
{
	u16 SysMonDeviceId = XPAR_XADC_WIZ_0_DEVICE_ID;
	XSysMon_Config *ConfigPtr;
	XSysMon *SysMonInstPtr = &SysMonInst;

	/*
	 * Initialize the SysMon driver.
	 */
	ConfigPtr = XSysMon_LookupConfig(SysMonDeviceId);
	XSysMon_CfgInitialize(SysMonInstPtr, ConfigPtr,
				ConfigPtr->BaseAddress);

	/*
	 * Disable the Channel Sequencer before configuring the Sequence
	 * registers.
	 */
	XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_SAFE);

	/*
	 * Setup the Sequence register for 0, 1, 8, 9 Auxiliary in unipolar mode
	 * channels
	 */
	XSysMon_SetSeqInputMode(SysMonInstPtr, 0);
	XSysMon_SetSeqAcqTime(SysMonInstPtr, XSM_SEQ_CH_AUX_MASK);

	/*
	 * Enable the following channels in the Sequencer registers:
	 * 	- Auxiliary Channels - 0, 1, 8, 9
	 */
	XSysMon_SetSeqChEnables(SysMonInstPtr, XSM_SEQ_CH_AUX_MASK);

	/*
	 * Enable the Channel Sequencer in continuous sequencer cycling mode.
	 */
	XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_CONTINPASS);




	// -----------------------------------
	// ------ INTERRUPT SETUP -----
	// -----------------------------------

    // ! SETUP INTERRUPT SYSTEM
	int status;

    status = XIntc_Connect(interrupt_controller, INTC_DEVICE_INT_ID_ADC,
				   (XInterruptHandler)handler_routine,
				   (void*)SysMonInstPtr);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupt for the device and then cause (simulate) an
	 * interrupt so the handlers will be called.
	 */
	XIntc_Enable(interrupt_controller, INTC_DEVICE_INT_ID_ADC);

	return XST_SUCCESS;

}

uint16_t adc_read_channel(u8 channel)
{
	u16 VAuxRawData;
	XSysMon *SysMonInstPtr = &SysMonInst;

	XSysMon_GetStatus(SysMonInstPtr);	/* Clear the latched status */

	VAuxRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_AUX_MIN + channel);
	return VAuxRawData;
}

/**
 * Return the channel that was last converted
 */
uint32_t adc_get_channel(XSysMon* callback_ref)
{
	return XSysMon_IntrGetStatus(callback_ref);
}

/* EXAMPLE
 * ****************************************
#include "xil_printf.h"
#include "xparameters.h"
#include "xadc.h"
#include "sleep.h"

int main( void )
{
  //----------------------------------------------------------------
  print("SETUP !\r\n");

  volatile uint32_t *leds = (uint32_t*)0x40000000;
  leds[0] = 0xFF;

  setup_xadc();

  print("START !\r\n");

  while(1)
  {
	xil_printf("RAW ID %d : %x \r\n", 0, get_adc_aux_raw(0) >> 4);
	usleep(100000);
  }
}
* *******************************************
*/
