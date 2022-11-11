#include <system.h>
#include <geometrics.h>
#include <psv.h>

void drawKeyboard(void);
unsigned char getColor(unsigned char v);


unsigned char display_keyboard[40];

int main(void){
    unsigned char i;
    
    drawFullScreen(CIAN);
    
    for(i=0; i<40; i++) {
        display_keyboard[i]=0;
    }
    
    display_keyboard[13]=1;
    display_keyboard[14]=2;
    
    while(1) {
        drawKeyboard();
    }
    
    return 0;
}

void drawKeyboard() {
    unsigned char i, r, c, x, y, color;
    i=0;
    x=15;
    y=10;
    
    for(r=0; r<4; r++) {
        for(c=0; c<10; c++) {
            color=getColor(display_keyboard[i++]);
            drawFillRect(x, y, 5, 5, color);
            x+=10;
        }
        x=15;
        y+=10;
    }
    
}

unsigned char getColor(unsigned char v) {
    if(v==0) {
        return RED;
    }
    if(v==1) {
        return NAVY_BLUE;
    }
    if(v==2) {
        return PHARMACY_GREEN;
    }
}
