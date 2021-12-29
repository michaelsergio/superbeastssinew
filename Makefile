all: tictacxo.smc

tictacxo.o: tictacxo.s
	ca65 $^

tictacxo.smc: tictacxo.o
	ld65 -C lorom128.cfg -o $@ $^

.PHONY: clean
clean:
	rm -f *.smc *.o
