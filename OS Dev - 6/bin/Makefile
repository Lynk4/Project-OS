# Makefile is located in Project-os/bin


# Create the OS.bin file (use 'make OS')
OS: boot.bin fileTable.bin kernel.bin calculator.bin
	cat boot.bin fileTable.bin kernel.bin calculator.bin > temp.bin;\
	dd if=/dev/zero of=OS.bin bs=512 count=2880;\
	dd if=temp.bin of=OS.bin conv=notrunc;\
	rm temp.bin

# Create a boot sector binary file
boot.bin:
	fasm ../src/asm/boot.asm
	mv ../src/asm/boot.bin ./

# Create a file table Binary file
fileTable.bin:
	fasm ../src/asm/fileTable.asm
	mv ../src/asm/fileTable.bin ./

# Create kelrnel binary file
kernel.bin:
	fasm ../src/asm/kernel.asm
	mv ../src/asm/kernel.bin ./

calculator.bin:
	fasm ../src/asm/calculator.asm
	mv ../src/asm/calculator.bin ./


# Clean up binary files (use 'make clean')
clean:
	rm *.bin
