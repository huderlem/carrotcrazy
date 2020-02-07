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

gfx/treasure_island/boss_level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/treasure_island/boss_ship_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/treasure_island/boss_ship_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/treasure_island/boss_level_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 7 -o $@ $<

gfx/crazy_town/level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/crazy_town/level_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 14 -o $@ $<

gfx/crazy_town/boss_ground_tar.2bpp: %.2bpp: %.png
	rgbgfx -x 19 -o $@ $<

gfx/crazy_town/boss_level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/crazy_town/boss_ground_tar_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 19 -o $@ $<

gfx/crazy_town/boss_level_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 11 -o $@ $<

gfx/taz_zoo/taz_head.interleave.2bpp: %.2bpp: %.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --remove-whitespace --png $< -o $@ $@

gfx/space_station/marvin_martian_head.interleave.2bpp: %.2bpp: %.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --remove-whitespace --png $< -o $@ $@

gfx/fudd_forest/elmer_fudd_head.interleave.2bpp: %.2bpp: %.png
	rgbgfx -o $@ $<
	tools/gfx --interleave --remove-whitespace --png $< -o $@ $@

gfx/taz_zoo/level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/taz_zoo/level_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 2 -o $@ $<

gfx/taz_zoo/boss_level_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 14 -o $@ $<

gfx/taz_zoo/boss_stampede_tiles.2bpp: %.2bpp: %.png
	rgbgfx -x 1 -o $@ $<

gfx/taz_zoo/boss_level_tiles_gbc.2bpp: %.2bpp: %.png
	rgbgfx -x 5 -o $@ $<
