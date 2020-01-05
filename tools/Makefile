.PHONY: all clean

CC := gcc
CFLAGS := -std=c99 -Wall -Wextra

tools := \
	gfx \
	scan_includes \
	rnc

all: $(tools)
	@:

clean:
	rm -f $(tools)

%: %.c
	$(CC) $(CFLAGS) -o $@ $<
