#include "text.h"
#include "fb.h"

enum {
    GLYPH_WIDTH = TEXT_CHAR_WIDTH / TEXT_SCALE,
    GLYPH_HEIGHT = TEXT_CHAR_HEIGHT / TEXT_SCALE
};

static const uint8_t glyphs[][GLYPH_HEIGHT] = {
#include "../../../assets/fonts/terminus/ascii_8x16.inc"
};

static void draw_char(size_t x, size_t y, unsigned char ch, uint32_t color) {
    if (ch < ' ' || ch > '~') {
        ch = '?';
    }

    const uint8_t *glyph = glyphs[ch - ' '];
    for (size_t row = 0; row < GLYPH_HEIGHT; ++row) {
        for (size_t col = 0; col < GLYPH_WIDTH; ++col) {
            // The high bit is the leftmost pixel.
            if (glyph[row] & (0x80u >> col)) {
                fill_rect(x + col * TEXT_SCALE, y + row * TEXT_SCALE,
                          TEXT_SCALE, TEXT_SCALE, color);
            }
        }
    }
}

void draw_string(size_t x, size_t y, const char *text, uint32_t color) {
    while (*text) {
        draw_char(x, y, (unsigned char)*text++, color);
        x += TEXT_CHAR_WIDTH;
    }
}
