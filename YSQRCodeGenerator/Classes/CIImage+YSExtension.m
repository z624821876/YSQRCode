//
//  CIImage+YSExtension.m
//  YSQRCodeTest
//
//  Created by yu on 2018/1/26.
//  Copyright © 2018年 yu. All rights reserved.
//

#import "CIImage+YSExtension.h"

#import <CoreImage/CoreImage.h>

@implementation CIImage (YSExtension)

+ (CIImage *)generatorQRCode:(NSString *)string level:(NSInteger)level {
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    // 数据
    [filter setValue:data forKey:@"inputMessage"];
    // 精度
    [filter setValue:@[@"L", @"M", @"Q", @"H"][level] forKey:@"inputCorrectionLevel"];

    return filter.outputImage;
}

- (CGImageRef)toCGImage {
    return [[CIContext new] createCGImage:self fromRect:self.extent];
}

    // Get QRCode from image
- (NSArray<NSString *> *)recognizeQRCode:(NSDictionary *)options {
    NSMutableArray *result = [NSMutableArray array];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];
    NSArray *features = [detector featuresInImage:self];
    for (CIQRCodeFeature *feature in features) {
        NSString *message = feature.messageString;
        [result addObject:message];
    }
    return result;
}

@end
