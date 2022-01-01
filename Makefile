TOOLS:=~/code/snes/tools
PCX2SNES:=pcx2snes/pcx2snes

PROGRAM:=tictacxo
SOURCES:=tictacxo.s
LD_CONFIGS:= lorom128.cfg
BIN_DIR:=bin

ASSETS:=$(wildcard imgraw/*.pcx)

OUTPUTS := $(SOURCES:.s=.o)

# Combine the assets outputs
ASSETS_PIC_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.pic, $(ASSETS)))
ASSETS_CLR_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.clr, $(ASSETS)))
ASSETS_OUT := $(ASSETS_PIC_OUT) $(ASSETS_CLR_OUT)

EXECUTABLE := $(BIN_DIR)/$(PROGRAM).smc

all: build $(EXECUTABLE)

%.o: %.s
	ca65 -g $^

build: $(ASSETS_OUT)
	@mkdir -p $(BIN_DIR)

bin/tictacxo.smc: $(OUTPUTS)
	ld65 -Ln $(BIN_DIR)/$(PROGRAM).lbl -m $(BIN_DIR)/$(PROGRAM).map -C $(LD_CONFIGS) -o $@ $^

# Generate the image assets 
imggen/%.clr imggen/%.pic: $(ASSETS)
	$(TOOLS)/$(PCX2SNES) -n -s8 -c4 -o4 imgraw/$*
	mv imgraw/$*.clr imggen/$*.clr
	mv imgraw/$*.pic imggen/$*.pic

# generate assets
.PHONY: assetgen
assetgen: $(ASSETS_OUT)
	#$(info VAR="$(ASSETS_OUT)")

# clean up the assets
.PHONY: assetclean
assetclean:
	rm -f imggen/*.clr imggen/*.pic


# Just the code output cleanup
.PHONY: clean
clean: assetclean
	rm -f *.smc *.o *.lbl *.map *.sym

#images: logo.pcx
	#$(TOOLS)/pcx2snes/pcx2snes -s32 %@

