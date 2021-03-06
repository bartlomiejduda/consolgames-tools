#pragma once

void unswizzle4as8(const void* source, void* dest, int width, int height);
void unswizzle8(const void* source, void* dest, int width, int height);
void swizzle4as8(const void* source, void* dest, int width, int height);
void swizzle8(const void* source, void* dest, int width, int height);

void rotatePalette16(void* palette);
void rotatePalette24(void* palette);
void rotatePalette32(void* palette);

void pspUnswizzle4(const void* source, void* dest, int width, int height);
void pspUnswizzle8(const void* source, void* dest, int width, int height);
void pspSwizzle4(const void* source, void* dest, int width, int height);
void pspSwizzle8(const void* source, void* dest, int width, int height);