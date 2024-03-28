#include <stdint.h>
#include "xil_printf.h"

int main()
{
	uint32_t* ddr = (uint32_t*)0x80000000;

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
