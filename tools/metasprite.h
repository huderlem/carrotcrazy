#ifndef METASPRITE_H
#define METASPRITE_H

#include <cstdio>
#include <cstdlib>

#ifdef _MSC_VER

#define FATAL_ERROR(format, ...)          \
do {                                      \
    fprintf(stderr, format, __VA_ARGS__); \
    exit(1);                              \
} while (0)

#else

#define FATAL_ERROR(format, ...)            \
do {                                        \
    fprintf(stderr, format, ##__VA_ARGS__); \
    exit(1);                                \
} while (0)

#endif // _MSC_VER

struct Point {
    int x;
    int y;
};

struct Pixel {
    Point point;
    int value;
};

struct Slice {
    Point point;
    std::vector<Point> ignoredPixels;
    std::vector<Pixel> extraPixels;
};

struct Metasprite {
    std::string name;
    int gbcPal;
    int gbPal;
    Point origin;
    float mirrorX;
    std::vector<Slice> slices;
    bool reverse;
};

struct NonAffineTile {
    unsigned short index:10;
    unsigned short hflip:1;
    unsigned short vflip:1;
    unsigned short palno:4;
} __attribute__((packed));

struct Tilemap {
    union {
        struct NonAffineTile *non_affine;
        unsigned char *affine;
    } data;
    int size;
};

struct Color {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
};

struct Palette {
    struct Color colors[256];
    int numColors;
};

struct Image {
    int width;
    int height;
    int bitDepth;
    unsigned char *pixels;
    bool hasPalette;
    struct Palette palette;
    bool hasTransparency;
    struct Tilemap tilemap;
    bool isAffine;
};

#endif // METASPRITE_H
