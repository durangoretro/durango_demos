#include <geometrics.h>
#include <psv.h>

int main(void){
    consoleLogStr("Fill Screen\n");
    startStopwatch();
    drawFullScreen(0x22);
    stopStopwatch();
    
    consoleLogStr("Draw Pixel\n");
    startStopwatch();
    drawPixel(10,20,0x33);
    stopStopwatch();
    
    consoleLogStr("Draw Rect\n");
    startStopwatch();
    drawRect(30,30, 10, 20, 0x44);
    stopStopwatch();
    
    consoleLogStr("Draw Line\n");
    startStopwatch();
    drawLine(5,5, 100, 100, 0x55);
    stopStopwatch();
    
    consoleLogStr("Draw Circle\n");
    startStopwatch();
    drawCircle(64,64, 10, 0x55);
    stopStopwatch();
    
    while(1);
    
    return 0;
}
