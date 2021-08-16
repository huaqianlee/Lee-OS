
MAKEFLAGS = -sR
MKDIR = mkdir
RMDIR = rmdir
CP = cp
CD = cd
DD = dd
RM = rm

ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy


ASMBFLAGS = -f elf -w-orphan-labels
CFLAGS = -c -Os -std=c99 -m32 -Wall -Wshadow -W -Wconversion -Wno-sign-conversion -fno-stack-protector -fomit-frame-pointer -fno-builtin -fno-common -ffreestanding -Wno-unused-parameter -Wunused-variable
LDFLAGS = -s -static -T LeeOS.lds -n -Map LeeOS.map 
OJCYFLAGS = -S -O binary

LEEOS_OBJS :=
LEEOS_OBJS += entry.o main.o vgastr.o
LEEOS_ELF = LeeOS.elf
LEEOS_BIN = LeeOS.bin

# Define two psudo target
.PHONY : build clean all link bin

all: clean build link bin

clean:
	$(RM) -f *.o *.bin *.elf

build: $(LEEOS_OBJS)

link: $(LEEOS_ELF)

$(LEEOS_ELF): $(LEEOS_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(LEEOS_OBJS)

bin: $(LEEOS_BIN)

$(LEEOS_BIN): $(LEEOS_ELF)
	$(OBJCOPY) $(OJCYFLAGS) $< $@

%.o : %.asm
	$(ASM) $(ASMBFLAGS) -o $@ $<

%.o : %.c
	$(CC) $(CFLAGS) -o $@ $<

update_image:
	sudo mount floppy.img /mnt/kernel
	sudo cp LeeOS.bin /mnt/kernel/hx_kernel

umount_image:
	sudo umount /mnt/kernel	

qemu:
	qemu-system-i386 -fda floppy.img -boot a
	#add '-nographic' option if using server of linux distro, such as fedora-server,or "gtk initialization failed" error will occur.


