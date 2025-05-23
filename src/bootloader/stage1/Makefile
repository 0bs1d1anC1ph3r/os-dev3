BUILD_DIR?=build
ASM?=nasm
INCLUDE_DIR?=../include

.PHONY: all clean

all: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: stage1.asm
	$(ASM) -f bin -I$(INCLUDE_DIR)/ stage1.asm -o $@

clean:
	rm -f $(BUILD_DIR)/stage1.bin
