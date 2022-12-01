#include <durango.h>

char key;
int main(void){    
    fillScreen(WHITE);
    fillRect(10, 10, 100, 50, RED);
    drawLine(10, 10, 110, 60, BLACK);
    drawCircle(50, 40, 30, GREEN);
	key=getChar();
	consoleLogHex(0x00);
	consoleLogHex(key);
    return 0;
}

