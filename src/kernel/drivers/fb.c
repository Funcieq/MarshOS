#include "fb.h"
#include "../limine_req.h"

static struct limine_framebuffer *fb;

int fb_init(void) {
    if (framebuffer_request.response == NULL ||
        framebuffer_request.response->framebuffer_count < 1) {
        return 0;
    }
    fb = framebuffer_request.response->framebuffers[0];
    return 1;
}

size_t fb_width(void)  { return fb->width; }
size_t fb_height(void) { return fb->height; }

void put_pixel(size_t x, size_t y, uint32_t color) {
    if (x >= fb->width || y >= fb->height) return;
    uint32_t *pixels = fb->address;
    pixels[y * (fb->pitch / 4) + x] = color;
}

void fill_rect(size_t x, size_t y, size_t w, size_t h, uint32_t color) {
    for (size_t j = 0; j < h; j++) {
        for (size_t i = 0; i < w; i++) {
            put_pixel(x + i, y + j, color);
        }
    }
}