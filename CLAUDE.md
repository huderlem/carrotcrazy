This project builds a byte-identical ROM for the Game Boy (Color) game "Looney Tunes: Carrot Crazy". It aims to be a recreation of the source code so that it's fully documented and moddable.

To compile the ROM and compare it to the original, run `make -j8`. If the resulting `carrotcrazy.gbc` ROM matches the expected hash, it will report "OK".

It uses the RGBDS toolchain to assemble the code, along with with a few custom compile-time tools found in `tools/`.

Currently, the entirety of the actual game's assembly source code lives in `main.asm`, but there are aspirations to split out logical files and directories.

Single byte values are denoted with `db`, and 2-byte words are generally denoted with `dw`.

