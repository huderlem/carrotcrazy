.PHONY: all tools compare clean tidy

.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:

ROM := carrotcrazy.gbc
OBJS := main.o wram.o

MD5 := md5sum -c

all: $(ROM) compare

ifeq (,$(filter tools clean tidy,$(MAKECMDGOALS)))
Makefile: tools
endif

%.o: dep = $(shell tools/scan_includes $(@D)/$*.asm)
%.o: %.asm $$(dep)
	rgbasm -h -o $@ $<

$(ROM): $(OBJS)
	rgblink -p 0xFF -n $(ROM:.gbc=.sym) -m $(ROM:.gbc=.map) -o $@ $(OBJS)
	rgbfix -jvc -k "70" -l 0x33 -m 0x19 -p 0xFF -r 0 -t "BUGS BUNNY" $@

compare: $(ROM)
	@$(MD5) rom.md5

tools:
	$(MAKE) -C tools

tidy:
	rm -f $(ROM) $(OBJS) $(ROM:.gbc=.sym) $(ROM:.gbc=.map)
	$(MAKE) -C tools clean

# TODO: need to clean up spritesheet artifacts
clean: tidy
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.lz' \) -exec rm {} +

%.interleave.2bpp: %.interleave.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --png $< -o $@ $@

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d1 -o $@ $<

%.lz: %
	tools/rnc q p $< $@ -m=2

%.inc %.spritesheet.interleave.png: %.spritesheet.png %.ms
	tools/metasprite compile $^ $*.spritesheet.interleave.png $*.inc

include graphics_rules.mk
