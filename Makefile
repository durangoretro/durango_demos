CFG=../dclib/cfg/durango16k.cfg
DCLIB=../dclib/bin
DCINC=../dclib/inc
RESCOMP ?= ../rescomp/target/rescomp.jar

all: hello_world.bin hello_world_dk.dux filler.bin boat.bin gamepads.bin serial.bin serial2.bin pong.bin geometrics.bin conio.bin minstrel_test.bin keyboard_tester.bin loops.casm newlib.bin datatypes.dux newconio.bin starter.bin music.dux

hello_world.bin: hello_world.s
	xa hello_world.s -o hello_world.bin
	
hello_world_dk.dux: hello_world_dk.s
	xa hello_world_dk.s -o hello_world_dk.dux

filler.bin: filler.s
	xa filler.s -o filler.bin

boat.bin: boat.s
	xa boat.s -o boat.bin
	
gamepads.bin: gamepads.s
	xa gamepads.s -o gamepads.bin

serial.bin: serial.s
	xa -w serial.s -o serial.bin

serial2.bin: serial2.s
	xa -w serial2.s -o serial2.bin

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

keyboard_tester.casm: keyboard_tester.c
	cc65 -I $(DCINC) keyboard_tester.c -t none --cpu 65C02 -o keyboard_tester.casm
keyboard_tester.o: keyboard_tester.casm
	ca65 -t none keyboard_tester.casm -o keyboard_tester.o
keyboard_tester.bin: keyboard_tester.o $(DCLIB)/durango.lib $(DCLIB)/psv.lib $(DCLIB)/geometrics.lib $(DCLIB)/system.lib
	ld65 -C $(CFG) keyboard_tester.o $(DCLIB)/psv.lib $(DCLIB)/geometrics.lib $(DCLIB)/system.lib $(DCLIB)/durango.lib -o keyboard_tester.bin
keyboard_tester.dux: keyboard_tester.bin $(BUILD_DIR)
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -t "KEYBOARD TESTER" -d "Simple keybaord tester" -i keyboard_tester.bin -o keyboard_tester.dux
	
loops.casm: loops.c
	cc65 -I $(DCINC) loops.c -t none --cpu 65C02 -o loops.casm
	
newlib.casm: newlib.c
	cc65 -I ../DurangoLib/inc newlib.c -t none --cpu 65C02 -o newlib.casm
newlib.o: newlib.casm
	ca65 -t none -l newliba.txt newlib.casm -o newlib.o
newlib.bin: newlib.o ../DurangoLib/bin/durango.lib
	ld65 -m newlib.txt -C ../DurangoLib/cfg/durango16k.cfg newlib.o ../DurangoLib/bin/durango.lib -o newlib.bin
	
newconio.casm: newconio.c
	cc65 -I ../DurangoLib/inc newconio.c -t none --cpu 65C02 -o newconio.casm
newconio.o: newconio.casm
	ca65 -t none -l newconio.txt newconio.casm -o newconio.o
newconio.bin: newconio.o ../DurangoLib/bin/durango.lib
	ld65 -m newconio.txt -C ../DurangoLib/cfg/durango16k.cfg newconio.o ../DurangoLib/bin/durango.lib -o newconio.bin

datatypes.casm: datatypes.c
	cc65 -I $(DCINC) datatypes.c -t none --cpu 65C02 -o datatypes.casm
datatypes.o: datatypes.casm
	ca65 -t none datatypes.casm -o datatypes.o
datatypes.bin: datatypes.o
	ld65 -C $(CFG) datatypes.o $(DCLIB)/psv.lib $(DCLIB)/durango.lib -o datatypes.bin
datatypes.dux: datatypes.bin $(BUILD_DIR)
	java -jar ${RESCOMP} -m SIGNER -n $$(git log -1 | head -1 | sed 's/commit //' | cut -c1-8) -i datatypes.bin -o datatypes.dux

starter.bin: starter.s
	xa starter.s -o starter.bin

music.dux: music.s
	xa music.s -o music.dux


clean:
	rm -rf *.bin *.asm *.casm *.o
