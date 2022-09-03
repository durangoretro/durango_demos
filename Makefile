all: hello_world.bin filler.bin boat.bin gamepads.bin pong.bin

hello_world.bin: hello_world.s
	xa hello_world.s -o hello_world.bin

filler.bin: filler.s
	xa filler.s -o filler.bin

boat.bin: boat.s
	xa boat.s -o boat.bin
	
gamepads.bin: gamepads.s
	xa gamepads.s -o gamepads.bin

pong.bin: pong.s
	xa pong.s -o pong.bin
	
clean:
	rm -rf *.bin
