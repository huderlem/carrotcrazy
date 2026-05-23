#!/usr/bin/env python3
"""Find what references a ROM address in the carrotcrazy disassembly.

Before dumping an `INCBIN "baserom.gbc", $ADDR, ...`, you must know what points
at $ADDR so no dangling raw pointer is left behind. A reference can be:

  1. Visible in main.asm as a literal `$ADDR` (e.g. `dw $2C96`), OR
  2. Hidden inside another, still-opaque INCBIN region (the bytes of the
     pointer are included raw from baserom.gbc and not yet disassembled).

This script catches both. It greps main.asm for the literal, then scans the ROM
binary for the little-endian pointer bytes and reports, for each hit, whether it
lands inside an INCBIN range (a candidate hidden reference) or in already
disassembled code/data (usually coincidental -- a ~1MB ROM contains any given
byte pair ~16 times by chance -- but eyeball it).

Usage:
    find_refs.py <addr> [<addr> ...]        # addrs in hex: 2c96, $2c96, 0x2c96
    find_refs.py --rom baserom.gbc --asm main.asm <addr>
"""
import argparse
import re
import sys

INCBIN_RE = re.compile(r'INCBIN\s+"baserom\.gbc",\s*\$([0-9a-fA-F]+),\s*\$([0-9a-fA-F]+)')


def parse_incbins(asm_path):
    """Return list of (start, end, lineno, text) for every baserom INCBIN.
    File offset == the INCBIN's $start, so these ranges are ROM file offsets."""
    ranges = []
    with open(asm_path, encoding="utf-8", errors="replace") as f:
        for n, line in enumerate(f, 1):
            m = INCBIN_RE.search(line)
            if m:
                ranges.append((int(m.group(1), 16), int(m.group(2), 16), n, line.strip()))
    return ranges


def source_refs(asm_path, addr):
    """Lines in main.asm with a literal reference to addr (any leading zeros,
    case-insensitive -- the file uses UPPERCASE hex like $2C96)."""
    # Address literals are written 4-digit (`$0061`, `$2C96`); 2-digit `$61`
    # tokens are data bytes / section directives, not address references.
    tok = re.compile(r'\$([0-9a-fA-F]+)\b')
    hits = []
    with open(asm_path, encoding="utf-8", errors="replace") as f:
        for n, line in enumerate(f, 1):
            # INCBIN lines define a region, they are not references to it.
            if INCBIN_RE.search(line):
                continue
            if any(len(g) >= 4 and int(g, 16) == addr for g in tok.findall(line)):
                hits.append((n, line.rstrip()))
    return hits


def binary_hits(rom, addr):
    needle = bytes([addr & 0xFF, (addr >> 8) & 0xFF])
    out, i = [], 0
    while True:
        j = rom.find(needle, i)
        if j < 0:
            break
        out.append(j)
        i = j + 1
    return out


def containing_incbin(ranges, offset):
    for start, end, n, text in ranges:
        if start <= offset < end:
            return (start, end, n, text)
    return None


def parse_addr(s):
    return int(s.lstrip("$").lower().removeprefix("0x"), 16)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("addrs", nargs="+", help="target address(es) in hex")
    ap.add_argument("--rom", default="baserom.gbc")
    ap.add_argument("--asm", default="main.asm")
    args = ap.parse_args()

    rom = open(args.rom, "rb").read()
    ranges = parse_incbins(args.asm)
    expected = len(rom) / 65536.0
    print("Scanning %s (%d bytes); %d baserom INCBINs in %s; "
          "~%.0f coincidental hits expected per address.\n"
          % (args.rom, len(rom), len(ranges), args.asm, expected))

    for s in args.addrs:
        addr = parse_addr(s)
        print("=" * 64)
        print("Address $%04x" % addr)

        srefs = source_refs(args.asm, addr)
        print("\n  Visible source references in %s: %d" % (args.asm, len(srefs)))
        for n, line in srefs:
            print("    %s:%d  %s" % (args.asm, n, line.strip()))

        hits = binary_hits(rom, addr)
        hidden, plain = [], []
        for h in hits:
            inc = containing_incbin(ranges, h)
            (hidden if inc else plain).append((h, inc))

        print("\n  Binary pointer-byte hits: %d total, %d inside opaque INCBINs"
              % (len(hits), len(hidden)))
        for h, inc in hidden:
            start, end, n, text = inc
            size = end - start
            tag = "  <-- POINTER-SIZED INCBIN, strong reference signal" if size == 2 else ""
            print("    offset $%05x  INSIDE %s:%d (%d bytes)%s" % (h, args.asm, n, size, tag))
            print("           %s" % text)
        if plain:
            print("    (%d more in already-disassembled regions -- likely coincidental, verify)"
                  % len(plain))
        print()


if __name__ == "__main__":
    sys.exit(main())
