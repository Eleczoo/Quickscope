#ifndef __DISPLAY_H__
#define __DISPLAY_H__

#include <stdint.h>

// (0x60000000 + 8192*4)
#define CHANNEL_SIZE 1700
#define VIDEO_CHAN_0 0x20000000
#define VIDEO_CHAN_1 (0x20000000 + (2048 * 4))

#define ASSETS_RAM_ADDR 0x20008000

#define FRAME_HEIGHT 800
#define FRAME_WIDTH 1700

#define VERTICAL_BORDER 140
#define HORIZONTAL_BORDER 110


#define SCREEN_HEIGHT 1080
#define SCREEN_WIDTH 1080



void draw_signal(uint32_t* ddr, uint16_t offset);
void display_char(int pos, int line, char c);
void display_text(int line, char* text);
void clear_text();

#endif
