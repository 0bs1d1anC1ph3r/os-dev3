BUILD_DIR?=build/
ASM?=nasm
INCLUDE_DIR ?= ./

.PHONY: all clean

all: stage1

stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: stage1.asm
	$(ASM) -f bin -I$(INCLUDE_DIR)/ stage1.asm -o $(BUILD_DIR)/stage1.bin

clean:
	rm -f $(BUILD_DIR)/stage1.bin
