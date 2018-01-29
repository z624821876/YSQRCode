//
//  YSQRCodeGenerator.h
//  YSQRCodeTest
//
//  Created by yu on 2018/1/26.
//  Copyright © 2018年 yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YSQRCodeMode) {
    YSQRCodeModeNone = 0,
    YSQRCodeModeGrayscale,
    YSQRCodeModeBinarization,
};

typedef NS_ENUM(NSUInteger, YSInputCorrectionLevel) {
    YSInputCorrectionLevelL = 0,   // L 7%
    YSInputCorrectionLevelM,       // M 15%
    YSInputCorrectionLevelQ,       // Q 25%
    YSInputCorrectionLevelH,       // H 30%
};

typedef NS_ENUM(NSUInteger, YSPointShape) {
    YSPointShapeSquare = 0,
    YSPointShapeCircle,
};

@interface YSQRCodeGenerator : NSObject

/** 生成的二维码图片 */
@property (nonatomic, readonly, strong) UIImage   *imageQRCode;

/** 要编码的字符串 */
@property (nonatomic, copy) NSString    *content;

/** 二维码类型 */
@property (nonatomic, assign) YSQRCodeMode  mode;

/** 背景图 */
@property (nonatomic, strong) UIImage   *watermark;

/** 背景图拉伸模式 */
@property (nonatomic, assign) UIViewContentMode watermarkMode;

@property (nonatomic, strong) UIImage   *icon;

@property (nonatomic, assign) CGSize    iconSize;

/** Threshold for binarization default 0.5 */
@property (nonatomic, assign) CGFloat   binarizationThreshold;

/** 二维码 foreground point 偏移 */
@property (nonatomic, assign) CGFloat   foregroundPointOffset;

/** 二维码 foreground 形状 */
@property (nonatomic, assign) YSPointShape  pointShape;

/** 二维码 容错率 0, 1, 2, 3
 inputCorrectionLevel 是一个单字母（@"L", @"M", @"Q", @"H" 中的一个），表示不同级别的容错率，默认为 @"M"
 QR码有容错能力，QR码图形如果有破损，仍然可以被机器读取内容，最高可以到7%~30%面积破损仍可被读取
 相对而言，容错率愈高，QR码图形面积愈大。所以一般折衷使用15%容错能力。错误修正容量 L水平 7%的字码可被修正
 M水平 15%的字码可被修正
 Q水平 25%的字码可被修正
 H水平 30%的字码可被修正
 所以很多二维码的中间都有头像之类的图片但仍然可以识别出来就是这个原因。
 */
@property (nonatomic, assign) YSInputCorrectionLevel    inputCorrectionLevel;

/** 二维码尺寸 */
@property (nonatomic, assign) CGSize    size;

/** 放大 与size不同时生效 */
@property (nonatomic, assign) CGSize    magnification;

/** 是否允许透明 */
@property (nonatomic, assign) BOOL      allowTransparent;

/**
 config Color
 */
- (void)setColorWithBackColor:(UIColor *)backColor foregroundColor:(UIColor *)foregroundColor;

/**
 * 生成二维码 入口方法
 */
- (UIImage *)generate;

/**
 生成GIF 二维码
 */
- (UIImage *)generateWithGIFCodeWithData:(NSData *)data;

/**
 根据gif名字 获取gif二维码
 */
- (UIImage *)generateWithGIFCodeWithGIFNamed:(NSString *)name;

@end
