#include "display.h"
#include <stdint.h>
#include "font.h"
#include <string.h>


uint32_t* chan0 = (uint32_t*)VIDEO_CHAN_0 + HORIZONTAL_BORDER;

uint32_t map(long x, long in_min, long in_max, long out_min, long out_max)
{
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}


// magnitude will be processed in this
void draw_signal( uint32_t* ddr)
{
	for(int i = 0; i < CHANNEL_SIZE; i++)
	{
		//uint32_t val = map(ddr[i], 0, 4096, VERTICAL_BORDER, FRAME_HEIGHT + VERTICAL_BORDER);
		//val = SCREEN_HEIGHT - val;

		uint32_t val = (((ddr[i] & 0xFFF)  * FRAME_HEIGHT) / 4096) + VERTICAL_BORDER;
		val = SCREEN_HEIGHT - val;

		chan0[i] = val;
	}
}


void display_char(int pos, int line, char c)
{
	int char_index = c - Font16x16[2];
	uint32_t* assets = (uint32_t*)(ASSETS_RAM_ADDR);
	// Shift the bitmap pointer to the right char position
	assets += Font16x16[1] * pos;
	assets += line * 32 * 16 * 16;

	char data;
	// Loop all the lines
	for (int y = 0; y < Font16x16[1]; y++)
	{
		// Loop 2 bytes for the cols
		for (int x = 0; x < 2; x++)
		{
			data = Font16x16[char_index*32 + 4 + y * 2 + x];
			// Loop all bits in byte
			for (int b = 0; b < 8; b++)
			{
				// Write 0 if we want to turn on the pixel on the screen
				if (data & (0x80 >> b)) { *assets++ = 0; }
				else { *assets++ = 1; }
			}
		}
		assets += 16*31-2;
	}
}

void display_text(int line, char* text)
{
	int len = strlen(text);
	for (int c = 0; c < 32; c++)
	{
		if (c < len)
		{
			display_char(c, line, text[c]);
		}
		else
		{
			display_char(c, line, ' ');
		}
	}
}
