# Some graphics images have trailing tiles that shouldn't be included in the
# final output. The -x option in rgbgfx trims tiles from the end of the image.

gfx/warner_bros_background.2bpp: %.2bpp: %.png
	rgbgfx -x 17 -o $@ $<

gfx/warner_bros_copyright/logo.interleave.2bpp: %.2bpp: %.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --remove-whitespace --png $< -o $@ $@

gfx/titlescreen/background.2bpp: %.2bpp: %.png
	rgbgfx -x 11 -o $@ $<

gfx/titlescreen/background_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 11 -o $@ $<

gfx/studio/ceiling_floor.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/studio/ceiling_floor_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/treasure_island/level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<
