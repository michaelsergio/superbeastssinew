TOOLS:=~/code/snes/tools
PCX2SNES:=pcx2snes/pcx2snes

PROGRAM:=tictacxo
SOURCES:=tictacxo.s
LD_CONFIGS:= lorom128.cfg
BIN_DIR:=bin

ASSETS:=$(wildcard imgraw/*.pcx)
OUTPUTS := $(SOURCES:.s=.o)
OUTPUTS_BIN := $(OUTPUTS:%=bin/%)
EXECUTABLE := $(BIN_DIR)/$(PROGRAM).smc

# Combine the assets outputs
ASSETS_PIC_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.pic, $(ASSETS)))
ASSETS_CLR_OUT := $(patsubst imgraw/%, imggen/%, $(patsubst %.pcx, %.clr, $(ASSETS)))
ASSETS_OUT := $(ASSETS_PIC_OUT) $(ASSETS_CLR_OUT)


all: build $(EXECUTABLE) debuglabels


$(EXECUTABLE): $(OUTPUTS_BIN)
	ld65 -Ln $(BIN_DIR)/$(PROGRAM).lbl -m $(BIN_DIR)/$(PROGRAM).map -C $(LD_CONFIGS) -o $@ $^

$(BIN_DIR)/%.o: %.s
	ca65 -g $^ -o $@

build: $(ASSETS_OUT)
	@mkdir -p $(BIN_DIR)

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
	rm -f *.smc *.o *.lbl *.map *.sym $(BIN_DIR)/*


CPU_SYM:=$(BIN_DIR)/$(PROGRAM).cpu.sym
.PHONY: debuglabels
debuglabels: 
	$(shell echo '#SNES65816\n\n' > $(CPU_SYM))
	$(shell echo '[SYMBOL]' >> $(CPU_SYM))
	$(shell awk '{print tolower(substr($$2, 0, 2)) ":" tolower(substr($$2, 3)), $$3, "ANY", 1}' $(BIN_DIR)/$(PROGRAM).lbl >> $(CPU_SYM))
	$(shell echo '\n[COMMENT]' >> $(CPU_SYM))
	$(shell echo '\n[COMMAND]' >> $(CPU_SYM))
