//
//  YSQRCodeGenerator.m
//  YSQRCodeTest
//
//  Created by yu on 2018/1/26.
//  Copyright © 2018年 yu. All rights reserved.
//

#import "YSQRCodeGenerator.h"
#import "YSUIntPixel.h"

#import <CoreImage/CoreImage.h>
#import "CIImage+YSExtension.h"
#import "CGImageManager.h"

@interface YSQRCodeGenerator ()

/** QRCodes */
@property (nonatomic, strong) NSMutableArray    *imageCodes;

/** 最小合适尺寸 */
@property (nonatomic, assign) CGSize    minSuitableSize;

/** 背景色 */
@property (nonatomic, strong) UIColor   *backgroundColor;

/** 前景色 */
@property (nonatomic, strong) UIColor   *foregroundColor;

/** 生成的二维码图片 */
@property (nonatomic, readwrite, strong) UIImage   *imageQRCode;

@end

@implementation YSQRCodeGenerator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.size = CGSizeMake(256, 256);
        self.magnification = CGSizeZero;
        self.binarizationThreshold = 0.5;
    }
    return self;
}

#pragma mark - Public
/**
 * 生成二维码 入口方法
 * 先获取缓存 如果没有在去生成
 */
- (UIImage *)generate {
    if (!_imageQRCode) {
        _imageQRCode = [self createImageQRCode];
    }
    return _imageQRCode;
}

/**
 生成GIF 二维码
 */
- (UIImage *)generateWithGIFCodeWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self frameDurationAtIndex:i source:source];
            
            UIImage *outputImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            [self setWatermark:outputImage];
            [images addObject:[self generate]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

/**
 根据gif名字 获取gif二维码
 */
- (UIImage *)generateWithGIFCodeWithGIFNamed:(NSString *)name {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0f) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (data) {
            return [self generateWithGIFCodeWithData:data];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [self generateWithGIFCodeWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [self generateWithGIFCodeWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
}

#pragma mark - Draw

/**
 生成二维码 实际创建方法
 */
- (UIImage *)createImageQRCode {
    
    // 初始化数据
    CGSize finalSize = self.size;
    UIImage *finalWatermark = self.watermark;
    UIImage *finalIcon = self.icon;
    CGSize finalIconSize = self.iconSize;
    UIColor *finalBackgroundColor = self.backgroundColor;
    UIColor *finalForegroundColor = self.foregroundColor;
    UIViewContentMode finalWatermarkMode = self.watermarkMode;
    
    // 生成二维码 -> 转化为像素数组 -> 获取其中二维码相关信息数组
    NSMutableArray *codes = [self generateCodes];
    if (codes.count <= 0) {
        return nil;
    }
    
    if (!CGSizeEqualToSize(self.magnification, CGSizeZero)) {
        finalSize = CGSizeMake(self.magnification.width * codes.count, self.magnification.height * codes.count);
    }
    
    // 开始画图
    CGContextRef codeContext = [self createContext:finalSize];
    
    // 计算合适的尺寸
    int minSuitableWidth = [self minSuitableSizeGreaterThanOrEqualTo:finalSize.width];
    minSuitableWidth = minSuitableWidth == -1 ? finalSize.width : minSuitableWidth;
    
    int minSuitableHeight = [self minSuitableSizeGreaterThanOrEqualTo:finalSize.height];
    minSuitableHeight = minSuitableHeight == -1 ? finalSize.height : minSuitableHeight;
    // Cache size
    _minSuitableSize = CGSizeMake(minSuitableWidth, minSuitableHeight);
    
    // 画水印或背景
    if (finalWatermark) {
        // Draw background with watermark
        [self drawWatermarkImage:codeContext image:finalWatermark colorBack:finalBackgroundColor mode:finalWatermarkMode size:finalSize];
        
        // Draw QR Code
        CGImageRef imageRef = [self createQRCodeImageTransparent:codes colorBack:finalBackgroundColor colorFront:finalForegroundColor size:_minSuitableSize];
        
        if (imageRef) {
            CGContextDrawImage(codeContext, CGRectMake(0, 0, finalSize.width, finalSize.height), imageRef);
            CFRelease(imageRef);
        }
    }else {
        // Draw background without watermark
        CGContextSetFillColorWithColor(codeContext, finalBackgroundColor.CGColor);
        CGContextFillRect(codeContext, CGRectMake(0, 0, finalSize.width, finalSize.height));
        
        // Draw QR Code
        CGImageRef imageRef = [self createQRCodeImage:codes colorBack:finalBackgroundColor colorFront:finalForegroundColor size:_minSuitableSize];
        
        if (imageRef) {
            CGContextDrawImage(codeContext, CGRectMake(0, 0, finalSize.width, finalSize.height), imageRef);
            CFRelease(imageRef);
        }
    }
    
    // Add icon
    if (finalIcon) {
        CGFloat finalIconSizeWidth = (CGFloat)finalSize.width * 0.2;
        CGFloat finalIconSizeHeight = (CGFloat)finalSize.width * 0.2;
        if (!CGSizeEqualToSize(finalIconSize, CGSizeZero)) {
            finalIconSizeWidth = (CGFloat)finalIconSize.width;
            finalIconSizeHeight = (CGFloat)finalIconSize.height;
        }
        
        float levels[4] = {0.2, 0.3, 0.4, 0.5};
        CGFloat maxLength = levels[_inputCorrectionLevel] * finalSize.width;
        
        if (finalIconSizeWidth > maxLength) {
            finalIconSizeWidth = maxLength;
            NSLog(@"Warning: icon width too big, it has been changed.");
        }
        if (finalIconSizeHeight > maxLength) {
            finalIconSizeHeight = maxLength;
            NSLog(@"Warning: icon height too big, it has been changed.");
        }
        CGSize iconSize = CGSizeMake((int)finalIconSizeWidth, (int)finalIconSizeHeight);
        
        [self drawIcon:codeContext icon:finalIcon size:iconSize];
    }
    
    CGImageRef outputImageRef = CGBitmapContextCreateImage(codeContext);
    
    CFRelease(codeContext);
    
    // Mode apply
    switch (_mode) {
        case YSQRCodeModeGrayscale: {
            UIImage *image = [CGImageManager grayscale:outputImageRef];
            if (image) {
                CFRelease(outputImageRef);
                return image;
            }
        }
            break;
        case YSQRCodeModeBinarization: {
            UIImage *image = [CGImageManager binarization:outputImageRef value:_binarizationThreshold foregroundColor:_foregroundColor backgroundColor:_backgroundColor];
            if (image) {
                CFRelease(outputImageRef);
                return image;
            }
        }
            break;
        default:
            break;
    }
    
    UIImage *result = [UIImage imageWithCGImage:outputImageRef];
    CFRelease(outputImageRef);
    
    return result;
}

/**
 create Context
 */
- (CGContextRef)createContext:(CGSize)size {
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpaceRef, kCGImageAlphaPremultipliedFirst | kCGImageByteOrder32Little);
    CFRelease(colorSpaceRef);
    return context;
}


/**
 Draw QR code
 */
- (CGImageRef)createQRCodeImageTransparent:(NSMutableArray *)codes colorBack:(UIColor *)colorBack colorFront:(UIColor *)colorFront size:(CGSize)size {
    
    CGFloat scaleX = (CGFloat)size.width / (CGFloat)codes.count;
    CGFloat scaleY = (CGFloat)size.height / (CGFloat)codes.count;
    if (scaleX < 1.0 || scaleY < 1.0) {
        NSLog(@"Warning: Size too small");
    }
    
    NSInteger codeSize = codes.count;
    CGFloat pointMinOffsetX = scaleX / 3;
    CGFloat pointMinOffsetY = scaleY / 3;
    CGFloat pointWidthOriX = scaleX;
    CGFloat pointWidthOriY = scaleY;
    CGFloat pointWidthMinX = scaleX - 2 * pointMinOffsetX;
    CGFloat pointWidthMinY = scaleY - 2 * pointMinOffsetY;
    
    // Get AlignmentPatternLocations first
    NSMutableArray *points = [NSMutableArray array];
    NSArray *locations = [self getAlignmentPatternLocations:[self getVersion:codeSize - 2]];
    if (locations.count > 0) {
        for (NSNumber *indexX in locations) {
            for (NSNumber *indexY in locations) {
                NSInteger finalX = indexX.integerValue + 1;
                NSInteger finalY = indexY.integerValue + 1;
                if (!((finalX == 7 && finalY == 7)
                      || (finalX == 7 && finalY == (codeSize - 8))
                      || (finalX == (codeSize - 8) && finalY == 7))) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(finalX, finalY)]];
                }
            }
        }
    }
    
    CGImageRef imageRef = NULL;
    CGContextRef context = [self createContext:size];
    if (context) {
        // Back point
        CGContextSetFillColorWithColor(context, colorBack.CGColor);
        for (NSInteger indexY = 0; indexY < codeSize; indexY ++) {
            for (NSInteger indexX = 0; indexX < codeSize; indexX ++) {
                if (![codes[indexX][indexY] integerValue]) {
                    // CTM-90
                    NSInteger indexXCTM = indexY;
                    NSInteger indexYCTM = codeSize - indexX - 1;
                    
                    if ([self isStatic:indexX y:indexY size:codeSize points:points]) {
                        [self drawPoint:context rect:(CGRect){
                            (CGFloat)indexXCTM * scaleX,
                            (CGFloat)indexYCTM * scaleY,
                            pointWidthOriX,
                            pointWidthOriY
                        }];
                    }else {
                        [self drawPoint:context rect:(CGRect){
                            (CGFloat)indexXCTM * scaleX + pointMinOffsetX,
                            (CGFloat)indexYCTM * scaleY + pointMinOffsetY,
                            pointWidthMinX,
                            pointWidthMinY
                        }];
                    }
                }
            }
        }
        
        
        // Front point
        CGContextSetFillColorWithColor(context, colorFront.CGColor);
        
        for (NSInteger indexY = 0; indexY < codeSize; indexY ++) {
            for (NSInteger indexX = 0; indexX < codeSize; indexX ++) {
                if ([codes[indexX][indexY] integerValue]) {
                    // CTM-90
                    NSInteger indexXCTM = indexY;
                    NSInteger indexYCTM = codeSize - indexX - 1;
                    if ([self isStatic:indexX y:indexY size:codeSize points:points]) {
                        
                        [self drawPoint:context rect:(CGRect){
                            (CGFloat)indexXCTM * scaleX + _foregroundPointOffset,
                            (CGFloat)indexYCTM * scaleY + _foregroundPointOffset,
                            pointWidthOriX - 2 * _foregroundPointOffset,
                            pointWidthOriY - 2 * _foregroundPointOffset
                            
                        }];
                    } else {
                        [self drawPoint:context rect:(CGRect){
                            (CGFloat)indexXCTM * scaleX + pointMinOffsetX,
                            (CGFloat)indexYCTM * scaleY + pointMinOffsetY,
                            pointWidthMinX,
                            pointWidthMinY
                        }];
                        
                    }
                }
            }
        }
        
        imageRef = CGBitmapContextCreateImage(context);
    }
    
    return imageRef;
}

/**
 生成二维码图片
 */
- (CGImageRef)createQRCodeImage:(NSMutableArray *)codes colorBack:(UIColor *)colorBack colorFront:(UIColor *)colorFront size:(CGSize)size {
    
    CGFloat scaleX = (CGFloat)size.width / (CGFloat)codes.count;
    CGFloat scaleY = (CGFloat)size.height / (CGFloat)codes.count;
    if (scaleX < 1.0 || scaleY < 1.0) {
        NSLog(@"Warning: Size too small.");
    }

    NSInteger codeSize = codes.count;
    CGContextRef context = [self createContext:size];
    CGContextSetFillColorWithColor(context, colorFront.CGColor);
    for (NSInteger indexY = 0; indexY < codeSize; indexY ++) {
        for (NSInteger indexX = 0; indexX < codeSize; indexX ++) {
            if ([codes[indexX][indexY] boolValue]) {
                // CTM-90
                NSInteger indexXCTM = indexY;
                NSInteger indexYCTM = codeSize - indexX - 1;
                
                [self drawPoint:context rect:(CGRect){
                    (CGFloat)indexXCTM * scaleX + _foregroundPointOffset,
                    (CGFloat)indexYCTM * scaleY + _foregroundPointOffset,
                    scaleX - 2 * _foregroundPointOffset,
                    scaleY - 2 * _foregroundPointOffset,
                }];
            }
        }
    }

    CGImageRef ref = CGBitmapContextCreateImage(context);

    return ref;
    
}

/**
 draw point
 */
- (void)drawPoint:(CGContextRef)context rect:(CGRect)rect {
    if (_pointShape == YSPointShapeCircle) {
        CGContextFillEllipseInRect(context, rect);
    }else {
        CGContextFillRect(context, rect);
    }
}

/**
 Draw icon
 */
- (void)drawIcon:(CGContextRef)context icon:(UIImage *)icon size:(CGSize)size {
    
    size_t width = CGBitmapContextGetWidth(context);
    size_t height = CGBitmapContextGetHeight(context);
    CGRect rect = (CGRect){
        ((CGFloat)width - size.width) / 2.0,
        ((CGFloat)height - size.height) / 2.0,
        size.width,
        size.height
    };
    CGContextDrawImage(context, rect, icon.CGImage);
}

/**
 Draw watermark
 */
- (void)drawWatermarkImage:(CGContextRef)context image:(UIImage *)image colorBack:(UIColor *)colorBack mode:(UIViewContentMode)mode size:(CGSize)size {
    
    if (colorBack) {
        CGContextSetFillColorWithColor(context, colorBack.CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    }

    if (_allowTransparent) {
        
        NSMutableArray *codes = [self generateCodes];
        if (codes.count <= 0) {
            return;
        }
        
        CGImageRef imageRef = [self createQRCodeImage:codes colorBack:self.backgroundColor colorFront:self.foregroundColor size:_minSuitableSize];
        if (imageRef) {
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
        }
    }
    
    // Image
    CGSize finalSize = size;
    CGPoint finalOrigin = CGPointZero;
    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);

    switch (mode) {
        case UIViewContentModeBottom: {
            finalSize = imageSize;
            finalOrigin = CGPointMake((size.width - imageSize.width) / 2.0, 0);
        }
            break;
        case UIViewContentModeBottomLeft: {
            finalSize = imageSize;
            finalOrigin = CGPointMake(0, 0);
        }
            break;
        case UIViewContentModeBottomRight: {
            finalSize = imageSize;
            finalOrigin = CGPointMake(size.width - imageSize.width, 0);
        }
            break;
        case UIViewContentModeCenter: {
            finalSize = imageSize;
            finalOrigin = CGPointMake((size.width - imageSize.width) / 2.0, (size.height - imageSize.height) / 2.0);
        }
            break;
        case UIViewContentModeLeft: {
            finalSize = imageSize;
            finalOrigin = CGPointMake(0, (size.height - imageSize.height) / 2.0);
        }
            break;
        case UIViewContentModeRight: {
            finalSize = imageSize;
            CGPointMake(size.width - imageSize.width, (size.height - imageSize.height) / 2.0);
        }
            break;
        case UIViewContentModeTop: {
            finalSize = imageSize;
            finalOrigin = CGPointMake((size.width - imageSize.width) / 2.0, size.height - imageSize.height);
        }
            break;
        case UIViewContentModeTopLeft: {
            finalSize = imageSize;
            finalOrigin = CGPointMake(0, size.height - imageSize.height);
        }
            break;
        case UIViewContentModeTopRight: {
            finalSize = imageSize;
            finalOrigin = CGPointMake(size.width - imageSize.width, size.height - imageSize.height);
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            CGFloat scale = MAX(size.width / imageSize.width, size.height / imageSize.height);
            finalSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
            finalOrigin = CGPointMake((size.width - finalSize.width) / 2.0, (size.height - finalSize.height) / 2.0);
        }
            break;
        case UIViewContentModeScaleAspectFit: {
            CGFloat scale = MAX(imageSize.width / size.width, imageSize.height / size.height);
            finalSize = CGSizeMake(imageSize.width / scale, imageSize.height / scale);
            finalOrigin = CGPointMake((size.width - finalSize.width) / 2.0, (size.height - finalSize.height) / 2.0);
        }
            break;
        default:
            break;
    }
    CGContextDrawImage(context, CGRectMake(finalOrigin.x, finalOrigin.y, finalSize.width, finalSize.height), image.CGImage);
}

#pragma mark  Draw END

#pragma mark - 生成二维码 并获取二维码像素信息

/**
 生成二维码 并获取到 二维码数据
 - generateCodes
 |- getPixels 生成二维码图片 获取二维码像素信息
 |- pixels 获取二维码像素信息
 |- getCodes: 根据二维码像素信息 获取二维码codes数据
 */
- (NSMutableArray *)generateCodes {
    if (_imageCodes) {
        return _imageCodes;
    }
    
    // 第一步 获取二维码 像素数组
    NSMutableArray *pixels = [self getPixels];
    if (pixels.count <= 0) {
        return nil;
    }
    
    // 第二步 根据像素数组信息获取 二维码信息
    _imageCodes = [self getCodes:pixels];
    
    return _imageCodes;
}

/**
 第一步 根据要编码字符串生成二维码  并解析二维码  返回像素信息数组
 */
- (NSMutableArray<NSArray<YSUIntPixel *> *> *)getPixels {
    //如果没有要编码的 字符串 则返回
    if (!_content || _content.length <= 0) {
        return nil;
    }
    
    YSInputCorrectionLevel finalInputCorrectionLevel = _inputCorrectionLevel;
    
    CGImageRef imageRef = [CIImage generatorQRCode:_content level:finalInputCorrectionLevel].toCGImage;
    
    NSMutableArray *array = [CGImageManager pixels:imageRef];
    if (array.count <= 0) {
        NSLog(@"Warning: Content too large");
        return nil;
    }
    return array;
}

/**
 第二步 根据前面生成像素信息 筛选出 二维码信息数组
 */
- (NSMutableArray<NSMutableArray<NSNumber *> *> *)getCodes:(NSMutableArray<NSArray<YSUIntPixel *> *> *)pixels {
    NSMutableArray<NSMutableArray<NSNumber *> *> *codes = [NSMutableArray array];
    for (NSInteger y = 0; y < pixels.count; y ++) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger x = 0; x < pixels[0].count; x ++) {
            YSUIntPixel *pixel = pixels[y][x];
            BOOL isCode = (pixel.red == 0 && pixel.green == 0 && pixel.blue == 0);
            [array addObject:@(isCode)];
        }
        [codes addObject:array];
    }
    return codes;
}

#pragma mark 获取二维码像素信息 结束

#pragma mark -

// Alignment Pattern Locations
// http://stackoverflow.com/questions/13238704/calculating-the-position-of-qr-code-alignment-patterns
- (NSArray *)getAlignmentPatternLocations:(NSInteger)version {
    if (version == 1) {
        return nil;
    }
    
    NSInteger divs = 2 + version / 7;
    NSInteger size = [self getSize:version];
    NSInteger total_dist = size - 7 - 6;
    NSInteger divisor = 2 * (divs - 1);
    
    // Step must be even, for alignment patterns to agree with timing patterns
    NSInteger step = (total_dist + divisor / 2 + 1) / divisor * 2; // Get the rounding right
    NSMutableArray *coords = [NSMutableArray array];
    
    // divs-2 down to 0, inclusive
    for (NSInteger i = 0; i <= (divs - 2); i ++) {
        [coords addObject:@(size - 7 - (divs - 2 - i) * step)];
    }
    return [coords copy];
}

// Special Points of QRCode
- (BOOL)isStatic:(NSInteger)x y:(NSInteger)y size:(NSInteger)size points:(NSArray *)points {
    // Empty border
    if (x == 0 || y == 0 || x == (size - 1) || y == (size - 1)) {
        return YES;
    }
    
    // Finder Patterns
    if ((x <= 8 && y <= 8) || (x <= 8 && y >= (size - 9)) || (x >= (size - 9) && y <= 8)) {
        return YES;
    }
    
    // Timing Patterns
    if (x == 7 || y == 7) {
        return YES;
    }
    
    // Alignment Patterns
    for (NSValue *pointValue in points) {
        CGPoint point = pointValue.CGPointValue;
        if (x >= (point.x - 2) && x <= (point.x + 2) && y >= (point.y - 2) && y <= (point.y + 2)) {
            return YES;
        }
        
    }
    return NO;
}

// QRCode version
- (NSInteger)getVersion:(NSInteger)size {
    return (size - 21) / 4 + 1;
}

// QRCode size
- (NSInteger)getSize:(NSInteger)version {
    return 17 + 4 * version;
}

    // Calculate suitable size
- (int)minSuitableSizeGreaterThanOrEqualTo:(CGFloat)value {
    if (!_imageCodes) {
        return -1;
    }
    
    int baseSuitableSize = (int)value;
    for (int offset = 0; offset <= _imageCodes.count; offset ++) {
        int tempSuitableSize = baseSuitableSize + offset;
        if ((tempSuitableSize % _imageCodes.count) == 0) {
            return tempSuitableSize;
        }
    }
    
    return -1;
}

/**
 获取 gif 每一帧 的时间
 */
- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

#pragma mark - Properties

- (void)setContent:(NSString *)content {
    _content = content;
    _imageQRCode = nil;
    _imageCodes = nil;
}

- (UIColor *)backgroundColor {
    if (_mode == YSQRCodeModeBinarization) {
        return [UIColor whiteColor];
    }
    return _backgroundColor;
}

- (UIColor *)foregroundColor {
    if (_mode == YSQRCodeModeBinarization) {
        return [UIColor blackColor];
    }
    return _foregroundColor;
}

- (void)setColorWithBackColor:(UIColor *)backColor foregroundColor:(UIColor *)foregroundColor {
    _backgroundColor = backColor;
    _foregroundColor = foregroundColor;
    _imageQRCode = nil;
}

- (void)setWatermark:(UIImage *)watermark {
    _watermark = watermark;
    _imageQRCode = nil;
}

- (void)setWatermarkMode:(UIViewContentMode)watermarkMode {
    _watermarkMode = watermarkMode;
    _imageQRCode = nil;
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    _imageQRCode = nil;
}

- (void)setIconSize:(CGSize)iconSize {
    _iconSize = iconSize;
    _imageQRCode = nil;
}

- (void)setBinarizationThreshold:(CGFloat)binarizationThreshold {
    _binarizationThreshold = binarizationThreshold;
    _imageQRCode = nil;
}

- (void)setForegroundPointOffset:(CGFloat)foregroundPointOffset {
    _foregroundPointOffset = foregroundPointOffset;
   _imageQRCode = nil;
}

- (void)setMode:(YSQRCodeMode)mode {
    _mode = mode;
    _imageQRCode = nil;
}

- (void)setPointShape:(YSPointShape)pointShape {
    _pointShape = pointShape;
    _imageQRCode = nil;
}

- (void)setInputCorrectionLevel:(YSInputCorrectionLevel)inputCorrectionLevel {
    _inputCorrectionLevel = inputCorrectionLevel;
    _imageQRCode = nil;
    _imageCodes = nil;
}

- (void)setSize:(CGSize)size {
    _size = size;
    _imageQRCode = nil;
}

- (void)setMagnification:(CGSize)magnification {
    _magnification = magnification;
    _imageQRCode = nil;
}

- (void)setAllowTransparent:(BOOL)allowTransparent {
    _allowTransparent = allowTransparent;
    _imageQRCode = nil;
}

@end
