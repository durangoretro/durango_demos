#include <geometrics.h>

int main(void){
    drawFullScreen(0x22);
    drawPixel(10,20,0x33);
    drawRect(30,30, 10, 20, 0x44);
    drawLine(5,5, 100, 100, 0x55);
    
    while(1);
    
    return 0;
}
