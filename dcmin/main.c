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

// Incluir una minilibreria con un par de funciones
#include "inc/qgraph.h"

int main() {
    // Declaramos una variable myrect de tipo estructura rectangulo
    rectangle myrect;
    
    // Pintamos la pantalla entera de un color solido
    fillScreen(GREEN);
    
    // Definimos los atributos del rectangulo
    myrect.x=10;
    myrect.y=20;
    myrect.color=RED;
    myrect.width=30;
    myrect.height=10;
    // Pintamos el rectangulo
    drawRect(&myrect);
    
    return 0;
}
