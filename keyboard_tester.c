#include <system.h>
#include <qgraph.h>
#include <psv.h>

void drawKeyboard(void);
unsigned char getColor(unsigned char v);
void mapKeyboard(void);
void updateDrawKeyboard(void);

unsigned char hw_keyboard[5];
unsigned char maped_keyboard[40];
unsigned char display_keyboard[40];

rectangle rect;

int main(void){
    unsigned char i;
    
    fillScreen(CIAN);
    
    for(i=0; i<40; i++) {
        display_keyboard[i]=0;
    }
    
    while(1) {
        for(i=0; i<5; i++) {
            hw_keyboard[i]=read_keyboard_row(i);
        }
        mapKeyboard();
        updateDrawKeyboard();
        drawKeyboard();
    }
    
    return 0;
}

void drawKeyboard() {
    unsigned char i, r, c, x, y;
    i=0;
    x=6;
    y=30;
    
    for(r=0; r<4; r++) {
        for(c=0; c<10; c++) {
            rect.color=getColor(display_keyboard[i++]);
            rect.x=x;
			rect.y=y;
			rect.height=8;
			rect.width=8;
			drawRect(&rect);
            x+=12;
        }
        x=6;
        y+=12;
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
    return ORANGE;
}

void mapKeyboard() {
    maped_keyboard[0]=get_bit(hw_keyboard[0],0);
    maped_keyboard[1]=get_bit(hw_keyboard[1],0);
    maped_keyboard[2]=get_bit(hw_keyboard[2],0);
    maped_keyboard[3]=get_bit(hw_keyboard[3],0);
    maped_keyboard[4]=get_bit(hw_keyboard[4],0);
    maped_keyboard[5]=get_bit(hw_keyboard[4],3);
    maped_keyboard[6]=get_bit(hw_keyboard[3],3);
    maped_keyboard[7]=get_bit(hw_keyboard[2],3);
    maped_keyboard[8]=get_bit(hw_keyboard[1],3);
    maped_keyboard[9]=get_bit(hw_keyboard[0],3);
    maped_keyboard[10]=get_bit(hw_keyboard[0],1);
    maped_keyboard[11]=get_bit(hw_keyboard[1],1);
    maped_keyboard[12]=get_bit(hw_keyboard[2],1);
    maped_keyboard[13]=get_bit(hw_keyboard[3],1);
    maped_keyboard[14]=get_bit(hw_keyboard[4],1);
    maped_keyboard[15]=get_bit(hw_keyboard[4],4);
    maped_keyboard[16]=get_bit(hw_keyboard[3],4);
    maped_keyboard[17]=get_bit(hw_keyboard[2],4);
    maped_keyboard[18]=get_bit(hw_keyboard[1],4);
    maped_keyboard[19]=get_bit(hw_keyboard[0],4);
    maped_keyboard[20]=get_bit(hw_keyboard[0],2);
    maped_keyboard[21]=get_bit(hw_keyboard[1],2);
    maped_keyboard[22]=get_bit(hw_keyboard[2],2);
    maped_keyboard[23]=get_bit(hw_keyboard[3],2);
    maped_keyboard[24]=get_bit(hw_keyboard[4],2);
    maped_keyboard[25]=get_bit(hw_keyboard[4],6);
    maped_keyboard[26]=get_bit(hw_keyboard[3],6);
    maped_keyboard[27]=get_bit(hw_keyboard[2],6);
    maped_keyboard[28]=get_bit(hw_keyboard[1],6);
    maped_keyboard[29]=get_bit(hw_keyboard[0],6);
    maped_keyboard[30]=get_bit(hw_keyboard[0],5);
    maped_keyboard[31]=get_bit(hw_keyboard[1],5);
    maped_keyboard[32]=get_bit(hw_keyboard[2],5);
    maped_keyboard[33]=get_bit(hw_keyboard[3],5);
    maped_keyboard[34]=get_bit(hw_keyboard[4],5);
    maped_keyboard[35]=get_bit(hw_keyboard[4],7);
    maped_keyboard[36]=get_bit(hw_keyboard[3],7);
    maped_keyboard[37]=get_bit(hw_keyboard[2],7);
    maped_keyboard[38]=get_bit(hw_keyboard[1],7);
    maped_keyboard[39]=get_bit(hw_keyboard[0],7);
}

void updateDrawKeyboard() {
    unsigned char i;
    for(i=0; i<40; i++) {
        display_keyboard[i]=maped_keyboard[i];
    }
}
