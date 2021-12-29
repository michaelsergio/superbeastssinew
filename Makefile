TOOLS:=~/code/snes/tools

all: tictacxo.smc

tictacxo.o: tictacxo.s
	ca65 $^

tictacxo.smc: tictacxo.o
	ld65 -C lorom128.cfg -o $@ $^

.PHONY: clean
clean:
	rm -f *.smc *.o

#images: logo.pcx
	#$(TOOLS)/pcx2snes/pcx2snes -s32 %@

