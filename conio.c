#include <conio.h>
#include <default_font.h>

int main(void){
    conio_init();
    set_font(default_font);
    printf("Hello World!");
    
    return 0;
}
