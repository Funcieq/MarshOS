.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

include deps/limine.mk

CC      := cc
LD      := ld
HOST_CC ?= cc
QEMU    ?= qemu-system-x86_64
CFLAGS  ?= -O2 -g -Wall -Wextra
OVMF    ?=

BUILD      := build
KERNEL     := $(BUILD)/kernel.elf
ISO        := $(BUILD)/marshos.iso
ISO_ROOT   := $(BUILD)/iso
LINKER     := src/kernel/linker.ld
LIMINE     := .deps/limine-$(LIMINE_VERSION)
SOURCES    := $(shell find src -type f -name '*.c' | sort)
OBJECTS    := $(patsubst src/%.c,$(BUILD)/%.o,$(SOURCES))

KERNEL_CFLAGS := -std=gnu11 -ffreestanding -fno-stack-protector \
                -fno-pic -fno-pie -fno-lto -m64 -march=x86-64 \
                -mno-red-zone -mgeneral-regs-only -mcmodel=kernel
KERNEL_LDFLAGS := -m elf_x86_64 -nostdlib -static -z max-page-size=0x1000
QEMUFLAGS ?= -machine q35 -m 256M -serial stdio -no-reboot -no-shutdown

.PHONY: all kernel iso deps run run-uefi clean distclean
all: iso
kernel: $(KERNEL)
iso: $(ISO)
deps: $(LIMINE)/.ready

# Dependencies
$(LIMINE)/.ready: deps/limine.mk scripts/fetch-limine.sh
	sh scripts/fetch-limine.sh $(LIMINE_VERSION) $(LIMINE_SHA256) \
	    $(LIMINE_PROTOCOL_COMMIT) $(LIMINE_HEADER_SHA256) $(LIMINE)

$(LIMINE)/limine: $(LIMINE)/.ready
	$(MAKE) -C $(LIMINE) CC="$(HOST_CC)"

# Kernel
$(BUILD)/%.o: src/%.c $(LIMINE)/.ready Makefile
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) -Isrc -I$(LIMINE) $(CFLAGS) $(KERNEL_CFLAGS) -MMD -MP -c $< -o $@

$(KERNEL): $(OBJECTS) $(LINKER) Makefile
	$(LD) $(LDFLAGS) $(KERNEL_LDFLAGS) -T $(LINKER) $(OBJECTS) -o $@

# BIOS + UEFI boot image
$(ISO): $(KERNEL) limine.conf $(LIMINE)/limine Makefile
	@mkdir -p $(ISO_ROOT)/boot/limine $(ISO_ROOT)/EFI/BOOT
	cp $(KERNEL) $(ISO_ROOT)/boot/kernel.elf
	cp limine.conf $(LIMINE)/limine-bios.sys $(LIMINE)/limine-bios-cd.bin \
	    $(LIMINE)/limine-uefi-cd.bin $(ISO_ROOT)/boot/limine/
	cp $(LIMINE)/BOOTX64.EFI $(ISO_ROOT)/EFI/BOOT/
	xorriso -as mkisofs -R -r -J \
	    -b boot/limine/limine-bios-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
	    --efi-boot boot/limine/limine-uefi-cd.bin -efi-boot-part --efi-boot-image \
	    --protective-msdos-label $(ISO_ROOT) -o $@
	$(LIMINE)/limine bios-install $@

# Emulator
run: $(ISO)
	$(QEMU) $(QEMUFLAGS) -cdrom $(ISO) -boot d

run-uefi: $(ISO)
	@test -f "$(OVMF)" || { echo 'Usage: make run-uefi OVMF=/path/to/OVMF_CODE.fd'; exit 1; }
	$(QEMU) $(QEMUFLAGS) -drive if=pflash,format=raw,readonly=on,file="$(OVMF)" -cdrom $(ISO) -boot d

clean:
	$(RM) -r $(BUILD)

distclean: clean
	$(RM) -r .deps

-include $(OBJECTS:.o=.d)
