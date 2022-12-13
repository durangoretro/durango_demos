#include <durango.h>

int main(void){ 
    conioInit();
    printstr("Hello World!\r");
    
    printstr("\r\r\rPress any key to exit...");
    getChar();


    return 0;
}

