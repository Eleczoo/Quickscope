#include "display.h"
#include <stdint.h>
#include "font.h"
#include <string.h>

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
