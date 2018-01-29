#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CGImageManager.h"
#import "CIImage+YSExtension.h"
#import "YSQRCode.h"
#import "YSQRCodeGenerator.h"
#import "YSQRCodeRecognizer.h"
#import "YSUIntPixel.h"

FOUNDATION_EXPORT double YSQRCodeGeneratorVersionNumber;
FOUNDATION_EXPORT const unsigned char YSQRCodeGeneratorVersionString[];

