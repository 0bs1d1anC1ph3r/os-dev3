BUILD_DIR?=build
ASM?=nasm

.PHONY: all clean

all: kernel

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin:
	$(ASM) -i $(INCLUDE_DIR) -f bin kernel.asm -o $@

clean:
	rm -f $(BUILD_DIR)/kernel.bin
