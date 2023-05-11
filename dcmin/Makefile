all: main.rom

# Generar codigo ensamblador a partir de codigo C
main.casm: main.c
	cc65 main.c -t none --cpu 65C02 -o main.casm

# Compilar codigo ensamblador a binario
main.o: main.casm
	ca65 -t none main.casm -o main.o

# Generar rom linkando binarios
main.rom: main.o
	ld65 -C lib/durango16k.cfg main.o lib/qgraph.lib lib/durango.lib -o main.rom
	
clean:
	rm -rf main.casm main.o main.rom
