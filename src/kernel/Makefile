BUILD_DIR?=build/
ASM?=nasm

.PHONY: all clean

all: kernel

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin:
	$(ASM) kernel.asm -f bin -o $(BUILD_DIR)/kernel.bin

clean:
	rm -f $(BUILD_DIR)/kernel.bin
