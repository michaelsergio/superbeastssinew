TOOLS:=~/code/snes/tools
PCX2SNES:=pcx2snes/pcx2snes

all: tictacxo.smc

tictacxo.o: tictacxo.s
	ca65 -g $^

tictacxo.smc: tictacxo.o
	ld65 -Ln tic.lbl -m tic.map -C lorom128.cfg -o $@ $^

.PHONY: imagegen
imagegen: imgraw/a.pcx
	$(TOOLS)/$(PCX2SNES) -n -s8 -c4 -o4 imgraw/a
	mv imgraw/a.clr imggen/a.clr
	mv imgraw/a.pic imggen/a.pic
 

.PHONY: clean
clean:
	rm -f *.smc *.o *.lbl *.map *.sym

#images: logo.pcx
	#$(TOOLS)/pcx2snes/pcx2snes -s32 %@

