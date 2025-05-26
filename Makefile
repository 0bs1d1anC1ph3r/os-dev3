ASM=nasm
CC=gcc

SRC_DIR=src
BUILD_DIR=build
INCLUDE_DIR = $(SRC_DIR)/include

.PHONY: all floppy_image kernel bootloader clean always

all: floppy_image

#
# Floppy image
#
floppy_image: bootloader kernel
	@echo "[+] Creating blank floppy image"
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	@echo "[+] Writing stage1 to boot sector (LBA 0)"
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	@echo "[+] Copying STAGE2.BIN into FAT12 filesystem"
	mcopy -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/stage2.bin ::STAGE2.BIN

#
# Bootloader
#
bootloader: stage1 stage2

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) INCLUDE_DIR=$(abspath $(INCLUDE_DIR))

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) INCLUDE_DIR=$(abspath $(INCLUDE_DIR))

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) INCLUDE_DIR=$(abspath $(INCLUDE_DIR))

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*
