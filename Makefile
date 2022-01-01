TOOLS:=~/code/snes/tools
PCX2SNES:=pcx2snes/pcx2snes

ASSETS:=$(wildcard imgraw/*.pcx)

# Combine the assets outputs
ASSETS_PIC_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.pic, $(ASSETS)))
ASSETS_CLR_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.clr, $(ASSETS)))
ASSETS_OUT := $(ASSETS_PIC_OUT) $(ASSETS_CLR_OUT)


all: tictacxo.smc $(ASSETS_OUT)

tictacxo.o: tictacxo.s
	ca65 -g $^

tictacxo.smc: tictacxo.o
	ld65 -Ln tic.lbl -m tic.map -C lorom128.cfg -o $@ $^

# Generate the image assets 
imggen/%.clr imggen/%.pic: $(ASSETS)
	$(TOOLS)/$(PCX2SNES) -n -s8 -c4 -o4 imgraw/$*
	mv imgraw/$*.clr imggen/$*.clr
	mv imgraw/$*.pic imggen/$*.pic
 

# generate assets
.PHONY: assetgen
assetgen: $(ASSETS_OUT)
	$(info VAR="$(ASSETS_OUT)")

.PHONY: assetclean
assetclean:
	rm imggen/*.clr imggen/*.pic


.PHONY: clean
clean:
	rm -f *.smc *.o *.lbl *.map *.sym

#images: logo.pcx
	#$(TOOLS)/pcx2snes/pcx2snes -s32 %@

