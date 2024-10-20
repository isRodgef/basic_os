all: bootloader

bootloader:
	mkdir -p boot/bin
	nasm -f bin boot/boot.asm -o boot/bin/boot.bin
	nasm -f elf32 boot/kernel_entry.asm -o boot/bin/kernel_entry.o  # Use elf32 for 32-bit mode

	gcc -m32 -ffreestanding -c boot/main.c -o boot/bin/kernel.o
	ld -m elf_i386 -o boot/bin/kernel.img -Ttext 0x1000 boot/bin/kernel_entry.o boot/bin/kernel.o  # Use elf32 for 32-bit mode
	objcopy -O binary -j .text boot/bin/kernel.img boot/bin/kernel.bin
	cat boot/bin/boot.bin boot/bin/kernel.bin > os.img

clear:
	rm -fr os.img boot/bin

run: 
	qemu-system-x86_64 -drive file=os.img,format=raw -d int
