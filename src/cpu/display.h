#ifndef __DISPLAY_H__
#define __DISPLAY_H__

// (0x60000000 + 8192*4)
#define ASSETS_RAM_ADDR 0x60008000

void display_char(int pos, int line, char c);
void display_text(int line, char* text);

#endif
