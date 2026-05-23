This project builds a byte-identical ROM for the Game Boy (Color) game "Looney Tunes: Carrot Crazy". It aims to be a recreation of the source code so that it's fully documented and moddable.

To compile the ROM and compare it to the original, run `make -j8`. If the resulting `carrotcrazy.gbc` ROM matches the expected hash, it will report "OK".

It uses the RGBDS toolchain to assemble the code, along with with a few custom compile-time tools found in `tools/`.

Currently, the entirely of the actual game's assembly source code lives in `main.asm`, and there are still remaining direct INCBIN includes from `baserom.gbc`.

Single byte values are denoted with `db`, and 2-byte words are generally denoted with `dw`.

When dumping data or code from an INCBIN, try to give it a label. If something else references it, ensure to dump that too. This way, it all ties together logically. Ideally we won't leave dangling raw pointers, for example.
