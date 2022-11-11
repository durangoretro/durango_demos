#include <system.h>
#include <geometrics.h>
#include <psv.h>

void drawKeyboard(void);


unsigned char display_keyboard[40];

int main(void){
    
    while(1) {
        drawKeyboard();
    }
    
    return 0;
}

void drawKeyboard() {
    unsigned char i, r, c, x, y;
    
    x=15;
    y=10;
    
    for(r=0; r<4; r++) {
        for(c=0; c<10; c++) {
            drawFillRect(x, y, 5, 5, RED);
            x+=10;
        }
        x=15;
        y+=10;
    }
    
}
