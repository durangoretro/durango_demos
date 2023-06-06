/* nanoBoot server for Raspberry Pi!   *
 * (c) 2020-2023 Carlos J. Santisteban *
 * last modified 20230308-1824         */

 // gcc tcpserver.c -lwiringPi -o tcpserver
// https://beej.us/guide/bgnet/html//index.html#client-server-background


#include <stdio.h>
#include <stdlib.h>
#include <wiringPi.h>
/* *** needs -lwiringPi option *** */

/* pin definitions, 36-38-40 at header, BCM 16-20-21 */
/* CB1 is clock, CB2 data, can use pin 34 as GND */
/* THIS VERSION NEEDS OPEN COLLECTOR (INVERTING) DRIVERS */
/* STB pin isn't currently used, just a placeholder for SS22 */
#define	CB1		16
#define	CB2		20
#define	STB		21

/* prototypes */
void cabe(int x);	/* send header byte in a slow way */
void dato(int x);	/* send data byte at full speed! */
void useg(int x);	/* delay for specified microseconds */
void sendRom(char *rom, int size);


/* *** main code *** */
int main(void) {
    FILE*	f;
	int		i, size;
    char rom[32768];
    
    
    /* open source file */
	if ((f = fopen("./rom.dux", "rb")) == NULL) {
		printf("*** NO SUCH FILE ***\n");
	}
    
/* compute header parameters */
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	printf("It's %d bytes long ($%04X)\n\n", size, size);
    
    rewind(f);
    for (i=0; i<size; i++) {
        rom[i] = fgetc(f);
    }
    fclose(f);
        
    
    sendRom(rom, size);
    
    return 0;
}

void sendRom(char *rom, int size) {
	int		i, c, fin, ini;
    
	printf("*** nanoBoot server (OC) ***\n\n");
	printf("pin 34=GND, 36=CLK, 38=DAT\n\n");
/* GPIO setup */
	wiringPiSetupGpio();	/* using BCM numbering! */
	digitalWrite(CB1, 0);	/* clock initially disabled, note OC */
	pinMode(CB1, OUTPUT);
	pinMode(CB2, OUTPUT);
	pinMode(STB, OUTPUT);	/* not actually used */

    
    
    
    
    
	printf("Address (HEX): ");
	ini=65536-size;
    printf("$%02X...\n", ini);
	fin = ini+size;				/* nanoBoot mandatory format */
/* send header */
	cabe(0x4B);
	cabe(fin>>8);
	cabe(fin&255);
	cabe(ini>>8);
	cabe(ini&255);
/* send binary */
	
	printf("*** GO!!! ***\n");
	for (i=0; i<size; i++) {
		if ((i&255) == 0) {
			delay(2);		/* page crossing may need some time */
			printf("$%02X...\n", (ini+i)>>8);
		}
		c = rom[i];
		if ((ini+i)>>8 != 0xDF)	dato(c);
	}
	printf("\nEnded at $%04X\n", fin);
	

	
}

/* *** function definitions *** */
/* for old nanoBoot ROM, invert bit (bit^1) */
void cabe(int x) {			/* just like dato() but with longer bit delay, whole header takes ~85 ms */
	int bit, i = 8;

	while(i>0) {
		bit = x & 1;
		digitalWrite(CB2, bit);		/* send bit for OC *** ^1 is NO LONGER needed *** */
		digitalWrite(CB1, 1);
		useg(15);			/* eeeeeek */
		digitalWrite(CB1, 0);
		delay(2);			/* way too long, just in case, note OC */
/* delay is best here in any case */
		x >>= 1;
		i--;
	}
	delay(1);				/* shouldn't be needed, but won't harm anyway */
}

void dato(int x) {			/* send a byte at 'top' speed */
	int bit, i = 8;

	while(i>0) {
		bit = x & 1;
		digitalWrite(CB2, bit);		/* note OC *** ^1 is NO LONGER needed *** */
		digitalWrite(CB1, 1);
		useg(15);			/* eeeeeeek */
		digitalWrite(CB1, 0);
		useg(65);			/* *** cranked up to 55 µs or so (at 1 MHz) is pretty unreliable *** */
/* delay is best here in any case */
		x >>= 1;
		i--;
	}
	digitalWrite(CB2, 0);	/* let data line float high, note OC */
	useg(125);				/* *** perhaps 200 µs or so *** */
}

void useg(int x){
	int i, t;

	for (t=0; t<x; t++){
		for (i=0; i<200; i++);	/* *** 200 iterations = 1 µs on RPi400 *** */
	}
}
