#pragma once

#include <stddef.h>
#include <stdint.h>

enum {
    TEXT_SCALE = 2,
    TEXT_CHAR_WIDTH = 8 * TEXT_SCALE,
    TEXT_CHAR_HEIGHT = 16 * TEXT_SCALE
};

void draw_string(size_t x, size_t y, const char *text, uint32_t color);
