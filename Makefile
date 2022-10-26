CFG=../dclib/cfg/durango16k.cfg
DCLIB=../dclib/bin
DCINC=../dclib/inc

all: hello_world.bin filler.bin boat.bin gamepads.bin serial.bin pong.bin geometrics.bin

hello_world.bin: hello_world.s
	xa hello_world.s -o hello_world.bin

filler.bin: filler.s
	xa filler.s -o filler.bin

boat.bin: boat.s
	xa boat.s -o boat.bin
	
gamepads.bin: gamepads.s
	xa gamepads.s -o gamepads.bin

serial.bin: serial.s
	xa serial.s -w -o serial.bin

pong.bin: pong.s
	xa pong.s -o pong.bin
	

geometrics.casm: geometrics.c
	cc65 -I $(DCINC) geometrics.c -t none --cpu 65C02 -o geometrics.casm
geometrics.o: geometrics.casm
	ca65 -t none geometrics.casm -o geometrics.o
geometrics.bin: geometrics.o $(DCLIB)/durango.lib $(DCLIB)/geometrics.lib $(DCLIB)/psv.lib
	ld65 -C $(CFG) geometrics.o $(DCLIB)/geometrics.lib $(DCLIB)/psv.lib $(DCLIB)/durango.lib -o geometrics.bin	
	
clean:
	rm -rf *.bin *.asm *.o
