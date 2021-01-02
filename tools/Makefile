.PHONY: all clean

CC := gcc
CFLAGS := -std=c99 -Wall -Wextra
CPP := g++
CPPFLAGS = -Wall -std=c++11 -O2

tools := \
	gfx \
	metasprite \
	scan_includes \
	rnc

all: $(tools)
	@:

clean:
	rm -f $(tools)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

metasprite: metasprite.cpp metasprite.h
	$(CPP) $(CPPFLAGS) metasprite.cpp -lpng -o $@
