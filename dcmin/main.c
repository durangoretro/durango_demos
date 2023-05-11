/*
# Generar codigo ensamblador a partir de codigo C
cc65 main.c -t none --cpu 65C02 -o main.casm
# Compilar codigo ensamblador a binario
ca65 -t none main.casm -o main.o
# Generar rom linkando binarios
ld65 -C lib/durango16k.cfg main.o lib/qgraph.lib lib/durango.lib -o main.rom
# Ejecutar con perdita
perdita main.rom
*/

#include "inc/qgraph.h"

int main() {
    
    fillScreen(GREEN);
    while(1);
    
    return 0;
}
