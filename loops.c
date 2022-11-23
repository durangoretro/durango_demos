// https://github.com/cc65/cc65/tree/master/libsrc/runtime


#include <system.h>
#include <psv.h>

void test_if(void);
void test_ifnot(void);
void test_ifnumber(void);
void test_do_while(void);
void test_for(void);
void test_while(void);
void test_array(void);

struct point {
    unsigned char x, y,z;
};


unsigned char i, j;
struct point p[10];
unsigned char myarray[10];

int main(void){    
    return 0;
}

void test_array() {
    i=0;
    consoleLogHex(p[i].x);
}

void test_if(void) {
    if(i==0) {
        consoleLogHex(i);
    }
    else {
        consoleLogDecimal(i);
    }   
}

void test_ifnot(void) {
    if(i!=0) {
        consoleLogHex(i);
    }
}

void test_ifnumber(void) {
    if(i==5) {
        consoleLogHex(i);
    }
}

void test_do_while() {
    i=0;
    do {
        consoleLogHex(i);
        i++;
    }while(i!=10);
}

void test_for() {
    for(i=0; i!=10; i++) {
        consoleLogHex(i);
    }
}

void test_while() {
    while(i!=10) {
        consoleLogHex(i);
    }
}
