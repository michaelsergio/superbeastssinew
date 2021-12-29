
To generate the images:
In imgraw/ directory:

../../tools/pcx2snes/pcx2snes -s32 -c16 -o16 -n logo

Where o is the number of colors in the palette. 
s is the size of each tile.
So a 16x8 with two tiles and 4 colors in the palette would be s8 o4

Move the clr and pic files to imggen directory
