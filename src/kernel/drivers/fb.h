#pragma once

#include <stdint.h>
#include <stddef.h>

int  fb_init(void);
void put_pixel(size_t x, size_t y, uint32_t color);
void fill_rect(size_t x, size_t y, size_t w, size_t h, uint32_t color);
size_t fb_width(void);
size_t fb_height(void);
