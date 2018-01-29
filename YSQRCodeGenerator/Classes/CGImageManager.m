//
//  CGImageManager.m
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import "CGImageManager.h"
#import "YSQRCodeGenerator.h"
#import "YSUIntPixel.h"

@implementation CGImageManager

/**
 将生成的二维码解析 获取像素信息数组
 */
+ (NSMutableArray<NSArray<YSUIntPixel *> *> *)pixels:(CGImageRef)imageRef {
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGContextRef bitmapRef = CGBitmapContextCreate(calloc(width * height, 4), width, height, 8, 4 * width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(bitmapRef, CGRectMake(0, 0, width, height), imageRef);
    // 获取像素信息
    unsigned char *data = CGBitmapContextGetData(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    NSMutableArray<NSArray<YSUIntPixel *> *> *pixels = [NSMutableArray array];
    for (NSInteger y = 0; y < height; y ++) {
        NSMutableArray<YSUIntPixel *> *array = [NSMutableArray array];
        for (NSInteger x = 0; x < width; x ++) {
            NSInteger offset = 4 * (x + y * width);
            [array addObject:[[YSUIntPixel alloc] initWithRed:data[offset + 0] green:data[offset + 1] blue:data[offset + 2] alpha:data[offset + 3]]];
        }
        [pixels addObject:array];
    }
    
    free(data);
    
    return pixels;
}

// Grayscale
// http://stackoverflow.com/questions/1311014/convert-to-grayscale-too-slow
+ (UIImage *)grayscale:(CGImageRef)imageRef {
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGImageRef outputImageRef = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:outputImageRef];
    
    CFRelease(context);
    CFRelease(colorSpace);
    CFRelease(outputImageRef);
    
    return result;
}

// Binarization
// http://blog.sina.com.cn/s/blog_6b7ba99d0101js23.html
+ (UIImage *)binarization:(CGImageRef)imageRef value:(CGFloat)value foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor {
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpaceref = CGColorSpaceCreateDeviceRGB();
    YSUIntPixel *backgroundPixel = [[YSUIntPixel alloc] initWithColor:backgroundColor];
    YSUIntPixel *foregroundPixel = [[YSUIntPixel alloc] initWithColor:foregroundColor];
    if (!backgroundColor || !foregroundColor) {
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(calloc(width * height, 4), width, height, 8, 4 * width, colorSpaceref, kCGImageAlphaPremultipliedLast);
    if (context) {
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        
        // 获取像素信息
        unsigned char *data = CGBitmapContextGetData(context);
        
        for (NSInteger x = 0; x < height; x ++) {
            for (NSInteger y = 0; y < width; y ++) {
                
                NSInteger offset = 4 * (x + y * width);
                
                // RGBA
                CGFloat alpha = (CGFloat)data[offset + 3] / 255.0;
                CGFloat intensity = ((CGFloat)data[offset + 0] + (CGFloat)data[offset + 1] + (CGFloat)data[offset + 2]) / 3.0 / 255.0 * alpha + (1.0 - alpha);
                YSUIntPixel *finalPixel = intensity > value ? backgroundPixel : foregroundPixel;
                
                data[offset + 0] = finalPixel.red;
                data[offset + 1] = finalPixel.green;
                data[offset + 2] = finalPixel.blue;
                data[offset + 3] = finalPixel.alpha;
            }
        }
        CGImageRef outputImageRef = CGBitmapContextCreateImage(context);
        UIImage *result = [UIImage imageWithCGImage:outputImageRef];
        
        CFRelease(context);
        CFRelease(colorSpaceref);
        CFRelease(outputImageRef);
        free(data);
        
        return result;
    }
    return nil;
}


@end

