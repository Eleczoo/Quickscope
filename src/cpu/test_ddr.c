#include <stdint.h>
#include "xil_printf.h"
#include "addresses.h"

int main()
{
	uint32_t* ddr = (uint32_t*)DDR_BASEADDR;

	for (int x = 0; x < 100; x++)
	{
		ddr[x] = x * x;
	}

	for (int x = 0; x < 100; x++)
	{
		 uint32_t a = ddr[x];
		 xil_printf("%d == %d\n\r", a, x * x);
	}

}
