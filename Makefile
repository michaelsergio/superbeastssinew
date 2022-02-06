TOOLS:=~/code/snes/tools
PCX2SNES:=pcx2snes/pcx2snes

PROGRAM:=tictacxo
SOURCES:=tictacxo.asm
MORE_SOURCES:=$(wildcard *.asm)
LD_CONFIGS:= lorom128.cfg
BIN_DIR:=bin

ASSETS:=$(wildcard imgraw/*.pcx)
OUTPUTS := $(SOURCES:.asm=.o)
OUTPUTS_BIN := $(OUTPUTS:%=bin/%)
EXECUTABLE := $(BIN_DIR)/$(PROGRAM).smc

# Combine the assets outputs
ASSETS_PIC_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.pic, $(ASSETS)))
ASSETS_CLR_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.clr, $(ASSETS)))
ASSETS_OUT := $(ASSETS_PIC_OUT) $(ASSETS_CLR_OUT)

SPRITES:=$(wildcard sprites/*.pcx)
SPRITES_PIC_OUT := $(patsubst sprites/%, spritesgen/%, $(patsubst %.pcx, %.pic, $(SPRITES)))
SPRITES_CLR_OUT := $(patsubst sprites/%, spritesgen/%, $(patsubst %.pcx, %.clr, $(SPRITES)))
SPRITES_OUT := $(SPRITES_PIC_OUT) $(SPRITES_CLR_OUT)

all: build $(EXECUTABLE) debuglabels


$(EXECUTABLE): $(OUTPUTS_BIN)
	ld65 -Ln $(BIN_DIR)/$(PROGRAM).lbl -m $(BIN_DIR)/$(PROGRAM).map -C $(LD_CONFIGS) -o $@ $^

$(BIN_DIR)/%.o: $(SOURCES) $(MORE_SOURCES)
	ca65 -g $< -o $@

build: $(ASSETS_OUT) $(SPRITES_OUT)
	@mkdir -p $(BIN_DIR)

# Generate the image assets 
imggen/%.clr imggen/%.pic: $(ASSETS)
	$(TOOLS)/$(PCX2SNES) -n -s8 -c4 -o4 imgraw/$*
	mv imgraw/$*.clr imggen/$*.clr
	mv imgraw/$*.pic imggen/$*.pic

# Generate the image assets 
# These sprites are size 16x16  with 16 colors (4bpp) 
spritesgen/%.clr spritesgen/%.pic: $(SPRITES)
	$(TOOLS)/$(PCX2SNES) -n -s16 -c16 -o16 sprites/$*
	mv sprites/$*.clr spritesgen/$*.clr
	mv sprites/$*.pic spritesgen/$*.pic


# generate assets
.PHONY: assetgen
assetgen: $(ASSETS_OUT) $(SPRITES_OUT)
	#$(info VAR="$(ASSETS_OUT)")

# clean up the assets
.PHONY: assetclean
assetclean:
	rm -f imggen/*.clr imggen/*.pic 

spritesclean:
	rm -f spritesgen/*

# Just the code output cleanup
.PHONY: clean
clean: assetclean spritesclean
	rm -f *.smc *.o *.lbl *.map *.sym $(BIN_DIR)/*


CPU_SYM:=$(BIN_DIR)/$(PROGRAM).cpu.sym
.PHONY: debuglabels
debuglabels: 
	$(shell scripts/create_debug_labels.sh $(BIN_DIR)/$(PROGRAM).lbl > $(CPU_SYM))
