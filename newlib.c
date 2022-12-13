#include <durango.h>

char k;
int main(void){    
    fillScreen(WHITE);
    fillRect(10, 10, 100, 50, RED);
    drawLine(10, 10, 110, 60, BLACK);
    drawCircle(50, 40, 30, GREEN);
        
	do{
        k=getChar();
        consoleLogChar(k);
    }while(1);
    return 0;
}

