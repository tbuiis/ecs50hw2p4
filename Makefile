all: 64bitAdd.out

64bitAdd.out: 64bitAdd.o
	ld -melf_i386 -o 64bitAdd.out 64bitAdd.o

64bitAdd.o: 64bitAdd.s
	as --gstabs --32 -o 64bitAdd.o 64bitAdd.s

clean:
	rm -f 64bitAdd.o 64bitAdd.out