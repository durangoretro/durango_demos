#ifndef _QGRAPHH
#define _QGRAPHH


// Paleta de colores de Durango-X (modo color)
#define BLACK 0x00
#define GREEN 0x11
#define RED 0x22
#define ORANGE 0x33
#define PHARMACY_GREEN 0x44
#define LIME 0x55
#define MYSTIC_RED 0x66
#define YELLOW 0x77
#define BLUE 0x88
#define DEEP_SKY_BLUE 0x99
#define MAGENTA 0xaa
#define LAVENDER_ROSE 0xbb
#define NAVY_BLUE 0xcc
#define CIAN 0xdd
#define PINK_FLAMINGO 0xee
#define WHITE 0xff


// Estructura rectangulo
typedef struct{
    char x, y;
    short mem;
    char color;
    char width, height;
} rectangle;


// Pinta la pantalla completa de un color
extern void __fastcall__ fillScreen(char color);
// Pinta en pantalla un rectangulo
extern void __fastcall__ drawRect(rectangle*);

#endif
