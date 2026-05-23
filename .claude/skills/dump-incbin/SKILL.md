---
name: dump-incbin
description: Dump a remaining `INCBIN "baserom.gbc", ...` in the carrotcrazy disassembly. Use when asked to dump, disassemble, or identify a baserom INCBIN, replace raw included bytes with labeled db/dw data (or code), or find what references a ROM address. Encodes the verify-before-dumping procedure and bundles a reference-scanning tool.
---

# Dumping baserom.gbc INCBINs

The goal is a fully documented, byte-identical disassembly. Don't just convert
raw bytes to `db`/`dw` -- understand what the data *is* and tie it to everything
that references it, so no dangling raw pointer is left behind. (See the repo
CLAUDE.md for the project's baseline conventions.)

Work one INCBIN at a time. `grep -c 'INCBIN "baserom.gbc"' main.asm` tracks how
many remain.

## Procedure

### 1. Locate and decode
Read the INCBIN line and the code/data around it. Dump the raw bytes:
`xxd -s $((0xADDR)) -l $((0xEND-0xADDR)) baserom.gbc`. File offset == the
INCBIN's `$start` (banked data uses raw file offsets). Look for structure
(counts, pointer pairs, fixed-point values, terminators) and for a label on the
bytes immediately before/after.

### 2. Identify what it is
Trace the consuming code before naming anything. Find functions that read the
address or that read a pointer which is later set to it. Follow the data flow
(e.g. a pointer copied into WRAM, then iterated) to learn the real meaning.
Don't settle for `Data_<addr>` if the purpose is recoverable.

### 3. Find every reference  (run the bundled tool)
```
python3 .claude/skills/dump-incbin/find_refs.py <addr>
```
It reports literal `$ADDR` references in main.asm **and** scans the ROM binary
for pointer bytes hidden inside other still-opaque INCBINs (a common case --
e.g. a 2-byte INCBIN holding a pointer). Notes:
- Source `grep` is case-sensitive; the file uses **UPPERCASE** hex (`$2C96`).
  The tool already searches case-insensitively and ignores leading zeros.
- A pointer-sized (2-byte) INCBIN hit is a strong "real reference" signal.
- Hits in already-disassembled regions are usually coincidental (~16 per
  address in a 1 MB ROM); confirm they aren't mid-instruction before dismissing.
- Account for GBC + mono variants -- screen/data tables are often duplicated.

### 4. Dump with labels, and dump the references too
- Give the data a real label using the `<ScreenName><Description>` convention
  (e.g. `TitlescreenBgScrollSpeeds`), matching sibling labels in the file.
- Format: `db` for count/length bytes and single bytes; `dw` for 16-bit words.
  Signed numeric values use **signed base-10** (`-64`, not `$FFC0`); raw
  filler/padding bytes stay hex (`$FF`).
- Update every reference to use the label (convert `dw $ADDR` and pointer-sized
  INCBINs to `dw Label`). If a reference is itself an opaque INCBIN, that's
  another INCBIN dumped -- the count goes down by more than one.
- For consistency, give identical sibling tables the same treatment, not just
  the one you were asked about.

### 5. Verify
`make compare` (or `make -j8`) must still report `carrotcrazy.gbc: OK` (byte
identical, md5 B6C357...). Spot-check the new labels resolved to the expected
addresses in `carrotcrazy.sym`.

## Worked example
The `*BgScrollSpeeds` raster-parallax tables. The INCBIN at `$2c8d` decoded as
two `db count` + signed-`dw` velocity tables. Tracing `Func_2c73`/`Func_2c2b`
showed they're per-screen background scroll speeds written to `rSCX` at fixed
scanlines. `find_refs.py` found `$2c96` referenced by visible `dw $2C96` and
`$2c8d` referenced only by two pointer-sized INCBINs ($1b192/$1bc8b) -- the
titlescreen screendata trailing pointers. All five sibling tables
($2c8d/$2c96/$0049/$0059/$0061) were labeled and all 10 references updated.
