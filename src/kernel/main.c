#include "drivers/fb.h"
#include "drivers/text.h"
#include "drivers/keyboard/ps2.h"
#include <stdint.h>
static void hang(void) {
    for (;;) {
        __asm__ volatile ("hlt");
    }
}

void kmain(void) {
    if (!fb_init()) {
        hang();
    }
    size_t offset = 0;
    const size_t input_y = 60 + TEXT_CHAR_HEIGHT + 8;
    //fill_rect(0, 0, fb_width(), fb_height(), 0x00101030);
    draw_string(100, 60, "Hello from MarshOS!", 0x00FFFFFF);

    for(;;){
        if((inb(0x64) & 1) == 0){
            continue;
        }
        uint16_t code = inb(0x60);
        //masywne porównywanie znaków by się przydało
        if(code == 0x1E){
            draw_string(100 + offset, input_y, "A", 0x00FFFFFF);
            offset += TEXT_CHAR_WIDTH + 2;
        }
    }
}
