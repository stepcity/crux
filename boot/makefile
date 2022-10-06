.PHONY: all qemu clean

all: boot

qemu: boot
	qemu-system-i386 -drive file=boot,format=raw

boot: boot0 boot1
	cat boot0 boot1 > boot

boot0: boot0.asm
	fasm boot0.asm boot0 > /dev/null

boot1: boot1.asm
	fasm boot1.asm boot1 > /dev/null

clean:
	rm -f boot0 boot1 boot
