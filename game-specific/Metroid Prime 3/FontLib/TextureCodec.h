#pragma once
#include <QtCore>

namespace Consolgames
{

typedef unsigned int Rgb;

class TextureCodec
{
public:
	//! http://wiibrew.org/wiki/U16_colors
	static Rgb decodeColor(quint16 color);
	
	static void decodeImage2bpp(const void* src, void* dest, int width, int height, int layerIndex);
	static void decodeImage1bpp(const void* src, void* dest, int width, int height, int layerIndex);

	static void encodeImage2bpp(const void* src, void* dest, int width, int height, int layerIndex);
	static void encodeImage1bpp(const void* src, void* dest, int width, int height, int layerIndex);


};

}