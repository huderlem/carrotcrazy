# Linux

Dependencies:

	sudo apt-get install make gcc bison git
	sudo easy_install pip

The assembler used is [**rgbds**](https://github.com/gbdev/rgbds).  Follow its installation instructions: https://rgbds.gbdev.io/install/linux

Set up the repository.

	git clone https://github.com/huderlem/carrotcrazy
	cd carrotcrazy

Install `libpng` becaause `tools/metasprite.c` depends on it for image processing.

To build `carrotcrazy.gbc`:

	make

This will take a few seconds the first time you build because it needs to process all of the graphics.

To remove all generated files by the build process:

	make clean

To compare the built `carrotcrazy.gbc` to the original ROM:

	make compare


# OS X

In the shell, run:

	xcode-select --install

Then follow the Linux instructions.


# Windows

To build on Windows, use WSL2 and follow the above Linux instructions.
