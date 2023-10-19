ASM := nasm
ASM_FLAGS := -f elf32 -gdwarf
LD := i686-elf-ld
CC := i686-elf-gcc

BUILD_DIR := ./build

OSNAME := myos

C_SRC := $(shell find ./src -name *.c)
ASM_SRC := $(shell find ./src -name *.asm)
C_OBJ := $(C_SRC:.c=.o)
ASM_OBJ := $(ASM_SRC:.asm=.o)

# Werror
CFLAGS :=  -g -nostdlib -nostdinc -fno-builtin -fno-stack-protector -nostartfiles\
-nodefaultlibs -Wall -Wextra 

LDFLAGS := -T linker.ld -melf_i386

# MODULE_PROGRAM_DIR := ./random_program/


.PHONY: clean run debug build os-image # build_module


build: $(BUILD_DIR)/disk.img

# build_module: 
# 	make -c $(MODULE_PROGRAM_DIR)

$(BUILD_DIR)/kernel.elf: $(ASM_OBJ) $(C_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

os-image: $(BUILD_DIR)/$(OSNAME).iso

$(BUILD_DIR)/disk.img: $(BUILD_DIR)/$(OSNAME).iso
	dd if=/dev/zero of=$@ bs=512 count=65536
	dd if=$^ of=$@ conv=notrunc

$(BUILD_DIR)/$(OSNAME).iso: $(BUILD_DIR)/kernel.elf
	mkdir -pv $(BUILD_DIR)/iso/boot/grub
	# mkdir -v $(BUILD_DIR)/iso/modules
	cp $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/iso/boot/
	# cp $(MODULE_PROGRAM_DIR)/build/loop.bin $(BUILD_DIR)/iso/modules/
	cp grub.cfg $(BUILD_DIR)/iso/boot/grub/
	grub-mkrescue -o $(BUILD_DIR)/$(OSNAME).iso $(BUILD_DIR)/iso
	

run: $(BUILD_DIR)/disk.img
	qemu-system-i386 -hda $^ -serial stdio >> $(BUILD_DIR)/log
	

debug: $(BUILD_DIR)/disk.img
	qemu-system-i386 -s -S -hda $^ &
	gdb -ex "target remote localhost:1234" -ex "symbol-file $(BUILD_DIR)/kernel.elf" -ex "b loader"
	

clean:
	-find src/ -name *.o -delete
	-rm -r build/*
	-touch build/log
	-rm peda-session-*

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.asm
	$(ASM) $(ASM_FLAGS) $^ -o $@
