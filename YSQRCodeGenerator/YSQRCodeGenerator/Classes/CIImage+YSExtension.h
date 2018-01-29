//
//  CIImage+YSExtension.h
//  YSQRCodeTest
//
//  Created by yu on 2018/1/26.
//  Copyright © 2018年 yu. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIImage (YSExtension)

+ (CIImage *)generatorQRCode:(NSString *)string level:(NSInteger)level;

- (CGImageRef)toCGImage;

// Get QRCode from image
- (NSArray<NSString *> *)recognizeQRCode:(NSDictionary *)options;

@end
