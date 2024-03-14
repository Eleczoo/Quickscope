/*
	XADC Documentation : https://docs.xilinx.com/r/en-US/ug480_7Series_XADC/7-Series-FPGAs-and-Zynq-7000-SoC-XADC-Dual-12-Bit-1-MSPS-Analog-to-Digital-Converter-User-Guide-UG480
*/

#include "xadc.h"

static XSysMon SysMonInst;      /* System Monitor driver instance */

void setup_xadc()
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
}

u16 get_adc_aux_raw(u8 aux_channel)
{
	u16 VAuxRawData;
	XSysMon *SysMonInstPtr = &SysMonInst;

	/*
	 * Wait till the End of Sequence occurs
	 */
	XSysMon_GetStatus(SysMonInstPtr); /* Clear the old status */
	while ((XSysMon_GetStatus(SysMonInstPtr) & XSM_SR_EOS_MASK) !=
			XSM_SR_EOS_MASK);

	XSysMon_GetStatus(SysMonInstPtr);	/* Clear the latched status */

	/*
	 * Read the ADC converted Data from the data registers.
	 */
	VAuxRawData = XSysMon_GetAdcData(SysMonInstPtr, XSM_CH_AUX_MIN + aux_channel);
	return VAuxRawData;
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
