# Output
#
# [pixelWidth] [pixelHeight]
# [filepath] [srcX srcyY destX destY, srcX srcyY destX destY]
# [filepath] [srcX srcyY destX destY, srcX srcyY destX destY]
#
#
#

import argparse
import sys

def get_param_count_error(statement, expected, actual, line):
    param_str = 'parameters' if expected != 1 else 'parameter'
    param_str2 = 'parameters' if actual != 1 else 'parameter'
    return '%s statement requires exactly %d %s. Got %d %s instead. Line: "%s"' % (statement, expected, param_str, actual, param_str2, line)

def validate_params(statement, params, expected, line):
    if len(params) != expected:
        sys.exit(get_param_count_error(statement, expected, len(params), line))

def parse_metasprite_definitions(file):
    tile_files = {}
    metasprites = []
    cur_metasprite = {}
    cur_metasprite['slices'] = []
    cur_metasprite['mirror_x'] = 0
    reading_tiles = True
    cur_label = None
    for line in file.readlines():
        line = line.strip()
        if reading_tiles:
            if len(line) == 0:
                reading_tiles = False
                continue
            if line.startswith('INCBIN'):
                tile_files[cur_label] = line[8:-1].replace('.2bpp', '.png')
            else:
                cur_label = line[:-1]
        else:
            if len(line) == 0:
                metasprites.append(cur_metasprite)
                cur_metasprite = {}
                cur_metasprite['slices'] = []
                cur_metasprite['mirror_x'] = 0
                continue
            if ':' in line:
                cur_metasprite['name'] = line[:-1]
            elif line.startswith('dynamic_sprite_offsets'):
                if 'slices' not in cur_metasprite:
                    cur_metasprite['slices'] = []
                params = [int(x.strip()) for x in line[22:].split(',')]
                cur_metasprite['mirror_x'] = (params[0] + params[2]) / 2.0
                cur_metasprite['slices'].append({'x': params[0], 'y': params[1]})
            else:
                params = [x.strip() for x in line[14:].split(',')]
                cur_metasprite['tiles_label'] = params[1]
                cur_metasprite['gbc_pal'] = params[3]
                cur_metasprite['gb_pal'] = params[4]
    if 'name' in cur_metasprite:
        metasprites.append(cur_metasprite)
    return tile_files, metasprites

def get_max_dimensions(metasprites):
    left = 9999999
    top = 9999999
    right = -9999999
    bottom = -9999999
    for metasprite in metasprites:
        for s in metasprite['slices']:
            if s['x'] < left:
                left = s['x']
            if s['y'] < top:
                top = s['y']
            if s['x'] > right:
                right = s['x']
            if s['y'] > bottom:
                bottom = s['y']
    width = (right + 8) - left
    height = (bottom + 16) - top
    return left, top, width, height

def layout_spritesheet(metasprites, left, top, width, height, tiles):
    num_nonempty_metasprites = 0
    for metasprite in metasprites:
        if len(metasprite['slices']) != 0:
            num_nonempty_metasprites += 1
    spritesheet_width = num_nonempty_metasprites * width
    if spritesheet_width % 8 != 0:
        spritesheet_width += 8 - (spritesheet_width % 8)
    spritesheet_height = height
    if spritesheet_height % 8 != 0:
        spritesheet_height += 8 - (spritesheet_height % 8)
    output = "%d %d\n" % (spritesheet_width, spritesheet_height)
    origin_x = -left
    origin_y = -top
    j = 0
    for metasprite in metasprites:
        metasprite['origin_x'] = j * width + origin_x
        metasprite['origin_y'] = origin_y
        metasprite['final_mirror_x'] = origin_x + j * width + metasprite['mirror_x']
        if len(metasprite['slices']) == 0:
            continue
        output += tiles[metasprite['tiles_label']] + " "
        parts = []
        for i, s in enumerate(metasprite['slices']):
            src_x = i * 8
            src_y = 0
            dest_x = j * width + origin_x + s['x']
            dest_y = origin_y + s['y']
            parts.append("%d %d %d %d" % (src_x, src_y, dest_x, dest_y))
        output += ", ".join(parts)
        output += "\n"
        j += 1
    return output

def render_ms_file(metasprites, name):
    output = "name %s\n\n" % (name)
    for metasprite in metasprites:
        output += "metasprite\n"
        output += "palettes %s %s\n" % (metasprite['gbc_pal'], metasprite['gb_pal'])
        output += "origin %d %d\n" % (metasprite['origin_x'], metasprite['origin_y'])
        output += "mirrorx %s\n" % (metasprite['final_mirror_x'])
        for s in metasprite['slices']:
            x = metasprite['origin_x'] + s['x']
            y = metasprite['origin_y'] + s['y']
            output += "slice %s %s\n" % (x, y)
        output += "\n"
    return output


def main():
    parser = argparse.ArgumentParser(description='Process metasprite data')
    parser.add_argument('inputfile', type=argparse.FileType('r'), nargs='?')
    args = parser.parse_args()
    tiles, metasprites = parse_metasprite_definitions(args.inputfile)
    print metasprites
    name = metasprites[0]['tiles_label'][:metasprites[0]['tiles_label'].find('Tiles')]
    left, top, width, height = get_max_dimensions(metasprites)
    spritesheet_output = layout_spritesheet(metasprites, left, top, width, height, tiles)
    ms_file_content = render_ms_file(metasprites, name)

    with open('tools/spritesheet_layout.txt', "w") as f:
        f.write(spritesheet_output)
    with open('tools/output.ms', "w") as f:
        f.write(ms_file_content)

if __name__ == '__main__':
    main()
