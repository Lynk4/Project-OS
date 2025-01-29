OS: boot.bin fileTable.bin kernel.bin calculator.bin
	cat boot.bin fileTable.bin kernel.bin calculator.bin > OS.bin

boot.bin:
	fasm ../src/asm/boot.asm
	mv ../src/asm/boot.bin ./

fileTable.bin:
	fasm ../src/asm/fileTable.asm
	mv ../src/asm/fileTable.bin ./

kernel.bin:
	fasm ../src/asm/kernel.asm
	mv ../src/asm/kernel.bin ./

calculator.bin:
	fasm ../src/asm/calculator.asm
	mv ../src/asm/calculator.bin ./

clean:
	rm *.bin
