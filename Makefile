CFG=../dclib/cfg/durango16k.cfg
DCLIB=../dclib/bin
DCINC=../dclib/inc

all: hello_world.bin filler.bin boat.bin gamepads.bin serial.bin pong.bin geometrics.bin conio.bin minstrel_test.bin

hello_world.bin: hello_world.s
	xa hello_world.s -o hello_world.bin

filler.bin: filler.s
	xa filler.s -o filler.bin

boat.bin: boat.s
	xa boat.s -o boat.bin
	
gamepads.bin: gamepads.s
	xa gamepads.s -o gamepads.bin

serial.bin: serial.s
	xa -w serial.s -o serial.bin

pong.bin: pong.s
	xa pong.s -o pong.bin
	

geometrics.casm: geometrics.c
	cc65 -I $(DCINC) geometrics.c -t none --cpu 65C02 -o geometrics.casm
geometrics.o: geometrics.casm
	ca65 -t none geometrics.casm -o geometrics.o
geometrics.bin: geometrics.o $(DCLIB)/durango.lib $(DCLIB)/geometrics.lib $(DCLIB)/psv.lib
	ld65 -C $(CFG) geometrics.o $(DCLIB)/geometrics.lib $(DCLIB)/psv.lib $(DCLIB)/durango.lib -o geometrics.bin	

conio.casm: conio.c
	cc65 -I $(DCINC) conio.c -t none --cpu 65C02 -o conio.casm
conio.o: conio.casm
	ca65 -t none conio.casm -o conio.o
conio.bin: conio.o $(DCLIB)/durango.lib $(DCLIB)/conio.lib $(DCLIB)/psv.lib
	ld65 -C $(CFG) conio.o $(DCLIB)/conio.lib $(DCLIB)/psv.lib $(DCLIB)/durango.lib -o conio.bin	
	
minstrel_test.bin: minstrel_test.s
	xa minstrel_test.s -o minstrel_test.bin
	
clean:
	rm -rf *.bin *.asm *.o
