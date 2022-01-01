TOOLS:=~/code/snes/tools

all: tictacxo.smc

tictacxo.o: tictacxo.s
	ca65 -g $^

tictacxo.smc: tictacxo.o
	ld65 -Ln tic.lbl -m tic.map -C lorom128.cfg -o $@ $^

.PHONY: clean
clean:
	rm -f *.smc *.o *.lbl *.map *.sym

#images: logo.pcx
	#$(TOOLS)/pcx2snes/pcx2snes -s32 %@

