#ifndef ELLOAPP_FAST_BLUR_h
#define ELLOAPP_FAST_BLUR_h

#import <Foundation/Foundation.h>

#import <FastBlur/ApplyScreenshotEffect.h>

void imageFastBlur(int imageWidth, int imageHeight, int imageStride, void * _Nonnull pixels);
void elloappFastBlurMore(int imageWidth, int imageHeight, int imageStride, void * _Nonnull pixels);
void stickerThumbnailAlphaBlur(int imageWidth, int imageHeight, int imageStride, void * _Nonnull pixels);
void elloappBrightenImage(int imageWidth, int imageHeight, int imageStride, void * _Nonnull pixels);

#endif // ELLOAPP_FAST_BLUR_h
