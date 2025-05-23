BUILD_DIR?=build
ASM?=nasm
INCLUDE_DIR?=../include

.PHONY: all clean

all: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: stage2.asm
	$(ASM) -f bin -I$(INCLUDE_DIR)/ stage2.asm -o $@

clean:
	rm -f $(BUILD_DIR)/stage2.bin
