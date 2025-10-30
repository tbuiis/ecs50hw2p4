all: editDist.out

editDist.out: editDist.o
	ld -melf_i386 -o editDist.out editDist.o

editDist.o: editDist.s
	as --gstabs --32 -o editDist.o editDist.s

clean:
	rm -f editDist.o editDist.out