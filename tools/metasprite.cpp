// Metasprite (.ms) files are a description of how to turn a single spritesheet PNG file
// into a series of metasprite definitions.
// 
// Lines that start with '#' character are treated as comments.
// 
// The file is composed of statements, one on each line.
//
// The 'name' statement designates the base label for the defined metasprites. This name will
// apply to all subsequent metasprites until a new 'name' statement occurs.
//
// The 'metasprite' statement begins a metasprite definition block. All subsequent statements
// make up a single metasprite definition until the next 'metasprite' statement occurs, or the
// end of the file. It takes no parameters.
//
// The 'palettes' statement defines which palette the metasprite uses for both GBC and GB. The
// first parameter is for GBC, and the second for GB.
//
// The 'origin' statement defines the origin pixel for the metasprite within the spritesheet PNG.
// This ultimately corresponds to where the sprite is drawn around in the game's rendering. It
// takes two parameters, the X and Y pixel coordinates.
//
// The 'mirrorx' statement defines the horizontal flipping point for the metasprite. The game
// draws metasprites flipped or not, so this defines the reference for flipping.
//
// The 'slice' statement defines a single 8x16 slice of the spritesheet PNG file. A metasprite is
// composed of one or many 8x16 slices. Each slice takes two parameters, the X and Y pixel
// coordinates in the spritesheet PNG.
//
// The 'slice_ignore_pixels' statement is similar to the 'slice' statement, but its extra parameters
// are pixels coordinates from the spritesheet that the slice should omit. This is to accomodate
// matching the origin game ROM. Some metasprite tiles overlap each other, and because the original
// data was built by hand by VD-dev, the order of resolution is not entirely predictable.
//
// The 'slice_with_pixels' statement is similar to the 'slice' statement, but its extra parameters
// are pixels that are absent from the spritesheet that the slice should omit. This is to accomodate
// matching the origin game ROM. Some metasprite tiles overlap each other, and because the original
// data was built by hand by VD-dev, the order of resolution is not entirely predictable.
//
// The 'reverse' statement is used to render the tileset in a reverse order. This is to accomodate
// matching the original game ROM. Some metasprite tiles overlap each other, and because the original
// data was built by hand by VD-dev, the order of resolution is not entirely predictable.
//
// Example:
//
// name BugsHovership
// metasprite
// palettes 5 0
// origin 10 11
// mirrorx 18.5
// slice -1   1
// slice  7   1
// slice 15   1
// slice -4  -6
// slice  4 -15
//

#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <list>
#include <queue>
#include <set>
#include <sstream>
#include <string>
#include <stdint.h>
#include <stdbool.h>
#include <png.h>
#include <unordered_map>
#include "metasprite.h"

const char *const USAGE = "Usage: metasprite compile SPRITESHEET_PATH METASPRITE_DEFINITION_PATH OUTPUT_TILES_PATH OUTPUT_SPRITES_PATH\n";

// Borrowed from http://www.cplusplus.com/forum/beginner/208971/#msg983685
std::string trim(std::string str)
{
    // remove trailing white space
    while (!str.empty() && std::isspace(str.back()))
        str.pop_back();

    // return residue after leading white space
    std::size_t pos = 0 ;
    while (pos < str.size() && std::isspace(str[pos]))
        ++pos;

    return str.substr(pos);
}

// Borrowed from https://www.systutorials.com/how-to-split-and-iterate-a-string-separated-by-another-string-in-c/
std::vector<std::string> split(const std::string str, char delim)
{
    std::vector<std::string> result;
    std::istringstream ss{str};
    std::string token;
    while (std::getline(ss, token, delim)) {
        if (!token.empty()) {
            result.push_back(token);
        }
    }

    return result;
}


std::vector<Metasprite> parseMetasprites(std::string metaspritesFile) {
    std::ifstream f(metaspritesFile);
    if (!f.is_open()) {
        FATAL_ERROR("Failed to open metasprites definition file for reading: '%s'", metaspritesFile.c_str());
    }

    std::vector<Metasprite> metasprites;
    std::string line;
    Metasprite curMetasprite;
    std::string name;
    while (std::getline(f, line)) {
        std::string trimmedLine = trim(line);
        // Ignore comments and empty lines.
        if (trimmedLine.length() == 0 || trimmedLine.find_first_of("#") == 0) {
            continue;
        }
        
        size_t statementEnd = trimmedLine.find_first_of(" ");
        if (statementEnd == std::string::npos) {
            if (trimmedLine == "metasprite" || trimmedLine == "reverse") {
                statementEnd = trimmedLine.length();
            } else {
                FATAL_ERROR("line is missing parameters: '%s'", line.c_str());
            }
        }

        // Parse and sanitize parameters.
        std::string statement = trimmedLine.substr(0, statementEnd);
        std::string rest = trimmedLine.substr(statementEnd);
        std::vector<std::string> params = split(rest, ' ');
        for (unsigned int i = 0; i < params.size(); i++)
            params[i] = trim(params[i]);

        if (curMetasprite.name.length() == 0 && statement != "metasprite" && statement != "name")
            FATAL_ERROR("%s statement came before any metasprite statement!", statement.c_str());

        if (statement == "name") {
            name = params[0];
        } else if (statement == "metasprite") {
            if (curMetasprite.name.length() != 0)
                metasprites.push_back(curMetasprite);
            curMetasprite = Metasprite();
            curMetasprite.name = name;
        } else if (statement == "palettes") {
            curMetasprite.gbcPal = std::stoi(params[0]);
            curMetasprite.gbPal = std::stoi(params[1]);
        } else if (statement == "origin") {
            curMetasprite.origin.x = std::stoi(params[0]);
            curMetasprite.origin.y = std::stoi(params[1]);
        } else if (statement == "mirrorx") {
            curMetasprite.mirrorX = std::stof(params[0]);
        } else if (statement == "slice") {
            curMetasprite.slices.push_back(Slice{
                point: Point{
                    x: std::stoi(params[0]),
                    y: std::stoi(params[1]),
                },
            });
        } else if (statement == "slice_ignore_pixels") {
            Slice s = Slice{
                point: Point{
                    x: std::stoi(params[0]),
                    y: std::stoi(params[1]),
                },
            };
            for (unsigned int i = 2; i < params.size(); i += 2) {
                s.ignoredPixels.push_back(Point{
                    x: std::stoi(params[i]),
                    y: std::stoi(params[i + 1]),
                });
            }
            curMetasprite.slices.push_back(s);
        } else if (statement == "slice_with_pixels") {
            Slice s = Slice{
                point: Point{
                    x: std::stoi(params[0]),
                    y: std::stoi(params[1]),
                },
            };
            for (unsigned int i = 2; i < params.size(); i += 3) {
                s.extraPixels.push_back(Pixel{
                    point: Point{
                        x: std::stoi(params[i]),
                        y: std::stoi(params[i + 1]),
                    },
                    value: std::stoi(params[i + 2])
                });
            }
            curMetasprite.slices.push_back(s);
        } else if (statement == "reverse") {
            curMetasprite.reverse = true;
        }
    }

    if (curMetasprite.name.length() > 0)
        metasprites.push_back(curMetasprite);

    return metasprites;
}

static FILE *PngReadOpen(std::string path, png_structp *pngStruct, png_infop *pngInfo)
{
    FILE *fp = fopen(path.c_str(), "rb");

    if (fp == NULL)
        FATAL_ERROR("Failed to open \"%s\" for reading.\n", path.c_str());

    unsigned char sig[8];

    if (fread(sig, 8, 1, fp) != 1)
        FATAL_ERROR("Failed to read PNG signature from \"%s\".\n", path.c_str());

    if (png_sig_cmp(sig, 0, 8))
        FATAL_ERROR("\"%s\" does not have a valid PNG signature.\n", path.c_str());

    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

    if (!png_ptr)
        FATAL_ERROR("Failed to create PNG read struct.\n");

    png_infop info_ptr = png_create_info_struct(png_ptr);

    if (!info_ptr)
        FATAL_ERROR("Failed to create PNG info struct.\n");

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Failed to init I/O for reading \"%s\".\n", path.c_str());

    png_init_io(png_ptr, fp);
    png_set_sig_bytes(png_ptr, 8);
    png_read_info(png_ptr, info_ptr);

    *pngStruct = png_ptr;
    *pngInfo = info_ptr;

    return fp;
}

static unsigned char *ConvertBitDepth(unsigned char *src, int srcBitDepth, int destBitDepth, int numPixels)
{
    // Round the number of bits up to the next 8 and divide by 8 to get the number of bytes.
    int srcSize = ((numPixels * srcBitDepth + 7) & ~7) / 8;
    int destSize = ((numPixels * destBitDepth + 7) & ~7) / 8;
    unsigned char *output = (unsigned char *)calloc(destSize, 1);
    unsigned char *dest = output;
    int i;
    int j;
    int destBit = 8 - destBitDepth;

    for (i = 0; i < srcSize; i++)
    {
        unsigned char srcByte = src[i];

        for (j = 8 - srcBitDepth; j >= 0; j -= srcBitDepth)
        {
            unsigned char pixel = (srcByte >> j) % (1 << srcBitDepth);

            if (pixel >= (1 << destBitDepth))
                FATAL_ERROR("Image exceeds the maximum color value for a %ibpp image.\n", destBitDepth);
            *dest |= pixel << destBit;
            destBit -= destBitDepth;
            if (destBit < 0)
            {
                dest++;
                destBit = 8 - destBitDepth;
            }
        }
    }

    return output;
}

void ReadPng(std::string path, struct Image *image)
{
    png_structp png_ptr;
    png_infop info_ptr;

    FILE *fp = PngReadOpen(path, &png_ptr, &info_ptr);

    int bit_depth = png_get_bit_depth(png_ptr, info_ptr);

    int color_type = png_get_color_type(png_ptr, info_ptr);

    if (color_type != PNG_COLOR_TYPE_GRAY && color_type != PNG_COLOR_TYPE_PALETTE)
        FATAL_ERROR("\"%s\" has an unsupported color type.\n", path.c_str());

    // Check if the image has a palette so that we can tell if the colors need to be inverted later.
    // Don't read the palette because it's not needed for now.
    image->hasPalette = (color_type == PNG_COLOR_TYPE_PALETTE);

    image->width = png_get_image_width(png_ptr, info_ptr);
    image->height = png_get_image_height(png_ptr, info_ptr);

    int rowbytes = png_get_rowbytes(png_ptr, info_ptr);

    image->pixels = (unsigned char *)malloc(image->height * rowbytes);

    if (image->pixels == NULL)
        FATAL_ERROR("Failed to allocate pixel buffer.\n");

    png_bytepp row_pointers = (png_bytepp)malloc(image->height * sizeof(png_bytep));

    if (row_pointers == NULL)
        FATAL_ERROR("Failed to allocate row pointers.\n");

    for (int i = 0; i < image->height; i++)
        row_pointers[i] = (png_bytep)(image->pixels + (i * rowbytes));

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Error reading from \"%s\".\n", path.c_str());

    png_read_image(png_ptr, row_pointers);

    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

    free(row_pointers);
    fclose(fp);

    if (bit_depth != image->bitDepth && image->tilemap.data.affine == NULL)
    {
        unsigned char *src = image->pixels;

        if (bit_depth != 1 && bit_depth != 2 && bit_depth != 4 && bit_depth != 8)
            FATAL_ERROR("Bit depth of image must be 1, 2, 4, or 8.\n");
        image->pixels = ConvertBitDepth(image->pixels, bit_depth, image->bitDepth, image->width * image->height);
        free(src);
        image->bitDepth = bit_depth;
    }
}

void ReadPngPalette(char *path, struct Palette *palette)
{
    png_structp png_ptr;
    png_infop info_ptr;
    png_colorp colors;
    int numColors;

    FILE *fp = PngReadOpen(path, &png_ptr, &info_ptr);

    if (png_get_color_type(png_ptr, info_ptr) != PNG_COLOR_TYPE_PALETTE)
        FATAL_ERROR("The image \"%s\" does not contain a palette.\n", path);

    if (png_get_PLTE(png_ptr, info_ptr, &colors, &numColors) != PNG_INFO_PLTE)
        FATAL_ERROR("Failed to retrieve palette from \"%s\".\n", path);

    if (numColors > 256)
        FATAL_ERROR("Images with more than 256 colors are not supported.\n");

    palette->numColors = numColors;
    for (int i = 0; i < numColors; i++) {
        palette->colors[i].red = colors[i].red;
        palette->colors[i].green = colors[i].green;
        palette->colors[i].blue = colors[i].blue;
    }

    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

    fclose(fp);
}

void SetPngPalette(png_structp png_ptr, png_infop info_ptr, struct Palette *palette)
{
    png_colorp colors = (png_colorp)malloc(palette->numColors * sizeof(png_color));

    if (colors == NULL)
        FATAL_ERROR("Failed to allocate PNG palette.\n");

    for (int i = 0; i < palette->numColors; i++) {
        colors[i].red = palette->colors[i].red;
        colors[i].green = palette->colors[i].green;
        colors[i].blue = palette->colors[i].blue;
    }

    png_set_PLTE(png_ptr, info_ptr, colors, palette->numColors);

    free(colors);
}

void WritePng(std::string path, struct Image *image)
{
    FILE *fp = fopen(path.c_str(), "wb");

    if (fp == NULL)
        FATAL_ERROR("Failed to open \"%s\" for writing.\n", path.c_str());

    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

    if (!png_ptr)
        FATAL_ERROR("Failed to create PNG write struct.\n");

    png_infop info_ptr = png_create_info_struct(png_ptr);

    if (!info_ptr)
        FATAL_ERROR("Failed to create PNG info struct.\n");

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Failed to init I/O for writing \"%s\".\n", path.c_str());

    png_init_io(png_ptr, fp);

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Error writing header for \"%s\".\n", path.c_str());

    int color_type = image->hasPalette ? PNG_COLOR_TYPE_PALETTE : PNG_COLOR_TYPE_GRAY;

    png_set_IHDR(png_ptr, info_ptr, image->width, image->height,
        image->bitDepth, color_type, PNG_INTERLACE_NONE,
        PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

    if (image->hasPalette) {
        SetPngPalette(png_ptr, info_ptr, &image->palette);

        if (image->hasTransparency) {
            png_byte trans = 0;
            png_set_tRNS(png_ptr, info_ptr, &trans, 1, 0);
        }
    }

    png_write_info(png_ptr, info_ptr);

    png_bytepp row_pointers = (png_bytepp)malloc(image->height * sizeof(png_bytep));

    if (row_pointers == NULL)
        FATAL_ERROR("Failed to allocate row pointers.\n");

    int rowbytes = png_get_rowbytes(png_ptr, info_ptr);

    for (int i = 0; i < image->height; i++)
        row_pointers[i] = (png_bytep)(image->pixels + (i * rowbytes));

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Error writing \"%s\".\n", path.c_str());

    png_write_image(png_ptr, row_pointers);

    if (setjmp(png_jmpbuf(png_ptr)))
        FATAL_ERROR("Error ending write of \"%s\".\n", path.c_str());

    png_write_end(png_ptr, NULL);

    fclose(fp);

    png_destroy_write_struct(&png_ptr, &info_ptr);
    free(row_pointers);
}

void FreeImage(struct Image *image)
{
    if (image->tilemap.data.affine != NULL)
    {
        free(image->tilemap.data.affine);
        image->tilemap.data.affine = NULL;
    }
    free(image->pixels);
    image->pixels = NULL;
}

void renderSpriteDefinitions(std::vector<Metasprite> metasprites, std::string outSpritesFile) {
    std::string result = "";
    unsigned int tilesOffset = 0;
    for (unsigned int i = 0; i < metasprites.size(); i++) {
        Metasprite metasprite = metasprites[i];
        result += metasprite.name + "Sprite" + std::to_string(i) + ":\n";
        result += "\tdynamic_sprite " + std::to_string(metasprite.slices.size()) + ", "
                    + metasprite.name + "Tiles + " + std::to_string(tilesOffset) + ", "
                    + std::to_string(metasprite.gbcPal) + ", " + std::to_string(metasprite.gbPal) + "\n";
        for (unsigned int j = 0; j < metasprite.slices.size(); j++) {
            Slice slice = metasprite.slices[j];
            int xOffset = slice.point.x - metasprite.origin.x;
            int yOffset = slice.point.y - metasprite.origin.y;
            int mirrorXOffset = metasprite.mirrorX - (slice.point.x - metasprite.mirrorX) - metasprite.origin.x;
            result += "\tdynamic_sprite_offsets " + std::to_string(xOffset) + ", "
                    + std::to_string(yOffset) + ", " + std::to_string(mirrorXOffset) + "\n";
        }

        result += "\n";
        tilesOffset += 0x20 * metasprite.slices.size();
    }

    std::ofstream f(outSpritesFile);
    f << result << std::endl;
    f.close();
}

int getPixelIndex(int x, int y, int width) {
    return (y * width + x) / 4;
}

int getPixel(unsigned char *pixels, int x, int y, int width) {
    int pixelIndex = getPixelIndex(x, y, width);
    int pair = x % 4;
    int pixel = 0;
    switch (pair) {
        case 3:
            pixel = pixels[pixelIndex] & 0x3;
            break;
        case 2:
            pixel = (pixels[pixelIndex] & 0xC) >> 2;
            break;
        case 1:
            pixel = (pixels[pixelIndex] & 0x30) >> 4;
            break;
        case 0:
            pixel = (pixels[pixelIndex] & 0xC0) >> 6;
            break;
    }
    return pixel;
}

void setPixel(int pixel, unsigned char *pixels, int x, int y, int width) {
    int pixelIndex = getPixelIndex(x, y, width);
    int pair = x % 4;
    switch (pair) {
        case 3:
            pixels[pixelIndex] = (pixels[pixelIndex] & 0xFC) | pixel;
            break;
        case 2:
            pixels[pixelIndex] = (pixels[pixelIndex] & 0xF3) | (pixel << 2);
            break;
        case 1:
            pixels[pixelIndex] = (pixels[pixelIndex] & 0xCF) | (pixel << 4);
            break;
        case 0:
            pixels[pixelIndex] = (pixels[pixelIndex] & 0x3F) | (pixel << 6);
            break;
    }
}

void renderMetaspriteTiles(std::string spritesheetFile, std::string outTilesFile, std::vector<Metasprite> metasprites) {
    struct Image img;
    img.bitDepth = 2;
    img.tilemap.data.affine = NULL;

    ReadPng(spritesheetFile, &img);
    int numTiles = 0;
    for (auto metasprite : metasprites)
        numTiles += metasprite.slices.size();

    struct Image outImg;
    outImg.palette.numColors = 4;
    outImg.palette.colors[0] = Color {
        red: 224,
        green: 248,
        blue: 208,
    };
    outImg.palette.colors[1] = Color {
        red: 136,
        green: 192,
        blue: 112,
    };
    outImg.palette.colors[2] = Color {
        red: 52,
        green: 104,
        blue: 86,
    };
    outImg.palette.colors[3] = Color {
        red: 9,
        green: 24,
        blue: 32,
    };
    outImg.hasTransparency = false;
    outImg.hasPalette = true;
    outImg.tilemap.data.affine = NULL;
    outImg.bitDepth = 2;
    outImg.width = numTiles * 8;
    outImg.height = 16;
    int numPixels = outImg.width * outImg.height / 4;
    outImg.pixels = (unsigned char *)calloc(numPixels, 1);

    std::unordered_map<int, bool> usedPixels;
    std::unordered_map<std::string, bool> usedSlices;
    
    int metaspriteX = 0;
    for (auto metasprite : metasprites) {
        for (unsigned int k = 0; k < metasprite.slices.size(); k++) {
            auto slice = metasprite.reverse ? metasprite.slices[metasprite.slices.size() - k - 1] : metasprite.slices[k];
            std::string sliceKey = std::to_string(slice.point.x) + "," + std::to_string(slice.point.y);
            for (int i = 0; i < 8; i++) {
                for (int j = 0; j < 16; j++) {
                    int srcX = slice.point.x + i;
                    int srcY = slice.point.y + j;
                    bool ignorePixel = false;
                    for (auto p : slice.ignoredPixels) {
                        if (p.x == srcX && p.y == srcY) {
                            ignorePixel = true;
                            break;
                        }
                    }
                    if (ignorePixel)
                        continue;

                    int pixel = getPixel(img.pixels, srcX, srcY, img.width);
                    int destX = metaspriteX + i;
                    if (metasprite.reverse) {
                        destX += 8 * (metasprite.slices.size() - k - 1);
                    } else {
                        destX += 8 * k;
                    }
                    int destY = j;
                    int pixelKey = srcY * outImg.width + srcX;
                    if (usedPixels.find(pixelKey) == usedPixels.end() || usedSlices.find(sliceKey) != usedSlices.end()) {
                        // Pixel isn't used already.
                        setPixel(pixel, outImg.pixels, destX, destY, outImg.width);
                        usedPixels[pixelKey] = true;
                    }
                }
            }
            for (auto extraPixel : slice.extraPixels) {
                int destX = metaspriteX + extraPixel.point.x;
                if (metasprite.reverse) {
                    destX += 8 * (metasprite.slices.size() - k - 1);
                } else {
                    destX += 8 * k;
                }
                int destY = extraPixel.point.y;
                setPixel(extraPixel.value, outImg.pixels, destX, destY, outImg.width);
            }
            usedSlices[sliceKey] = true;
        }
        metaspriteX += metasprite.slices.size() * 8;
    }

    WritePng(outTilesFile, &outImg);
    FreeImage(&img);
    FreeImage(&outImg);
}

void processLayout(std::string layoutFilepath, std::string outTilesPath) {
    std::ifstream f(layoutFilepath);
    if (!f.is_open()) {
        FATAL_ERROR("Failed to open layouts file for reading: '%s'", layoutFilepath.c_str());
    }

    std::string line;
    std::getline(f, line);
    std::vector<std::string> dimensions = split(line, ' ');
    int width = std::stoi(dimensions[0]);
    int height = std::stoi(dimensions[1]);

    struct Image outImg;
    outImg.palette.numColors = 4;
    outImg.palette.colors[0] = Color {
        red: 224,
        green: 248,
        blue: 208,
    };
    outImg.palette.colors[1] = Color {
        red: 136,
        green: 192,
        blue: 112,
    };
    outImg.palette.colors[2] = Color {
        red: 52,
        green: 104,
        blue: 86,
    };
    outImg.palette.colors[3] = Color {
        red: 9,
        green: 24,
        blue: 32,
    };
    outImg.hasTransparency = false;
    outImg.hasPalette = true;
    outImg.tilemap.data.affine = NULL;
    outImg.bitDepth = 2;
    outImg.width = width;
    outImg.height = height;
    int numPixels = outImg.width * outImg.height / 4;
    outImg.pixels = (unsigned char *)calloc(numPixels, 1);

    while (std::getline(f, line)) {
        std::string trimmedLine = trim(line);
        if (trimmedLine.length() == 0)
            continue;

        size_t firstSpaceIndex = trimmedLine.find_first_of(" ");
        std::string tilesPath = trimmedLine.substr(0, firstSpaceIndex);
        std::string rest = trimmedLine.substr(firstSpaceIndex+1);
        std::vector<std::string> rawSlices = split(rest, ',');
        std::vector<std::vector<int>> slices;
        for (unsigned int i = 0; i < rawSlices.size(); i++) {
            std::vector<std::string> parts = split(trim(rawSlices[i]), ' ');
            std::vector<int> vals;
            for (unsigned int j = 0; j < parts.size(); j++) {
                vals.push_back(std::stoi(parts[j]));
            }
            slices.push_back(vals);
        }

        struct Image img;
        img.bitDepth = 2;
        img.tilemap.data.affine = NULL;
        ReadPng(tilesPath, &img);

        for (unsigned int k = 0; k < slices.size(); k++) {
            auto slice = slices[k];
            for (int i = 0; i < 8; i++) {
                for (int j = 0; j < 16; j++) {
                    int srcX = slice[0] + i;
                    int srcY = slice[1] + j;
                    int pixel = getPixel(img.pixels, srcX, srcY, img.width);
                    int destX = slice[2] + i;
                    int destY = slice[3] + j;
                    int existingPixel = getPixel(outImg.pixels, destX, destY, outImg.width);
                    if (existingPixel == 0) {
                        setPixel(pixel, outImg.pixels, destX, destY, outImg.width);
                    }
                }
            }
        }

        FreeImage(&img);
    }

    WritePng(outTilesPath, &outImg);
}

int main(int argc, char **argv) {
    std::string cmd = argv[1];
    if (cmd == "compile") {
        if (argc != 6) {
            FATAL_ERROR(USAGE);
        }

        std::string spritesheetFile = argv[2];
        std::string metaspritesFile = argv[3];
        std::string outTilesFile = argv[4];
        std::string outSpritesFile = argv[5];
        std::vector<Metasprite> metasprites = parseMetasprites(metaspritesFile);
        renderSpriteDefinitions(metasprites, outSpritesFile);
        renderMetaspriteTiles(spritesheetFile, outTilesFile, metasprites);
    } else {
        if (argc != 4) {
            FATAL_ERROR(USAGE);
        }

        std::string layoutFilepath = argv[2];
        std::string outTilesFile = argv[3];
        processLayout(layoutFilepath, outTilesFile);
    }
}