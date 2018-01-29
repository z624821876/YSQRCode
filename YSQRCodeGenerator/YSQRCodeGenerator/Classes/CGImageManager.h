//
//  CGImageManager.h
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@class YSUIntPixel;

@interface CGImageManager : NSObject

/**
 将生成的二维码解析 获取像素信息数组
 */
+ (NSMutableArray<NSArray<YSUIntPixel *> *> *)pixels:(CGImageRef)imageRef;


/**
 Grayscale
 */
+ (UIImage *)grayscale:(CGImageRef)imageRef;


/**
 Binarization
 */
+ (UIImage *)binarization:(CGImageRef)imageRef value:(CGFloat)value foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor;


@end
