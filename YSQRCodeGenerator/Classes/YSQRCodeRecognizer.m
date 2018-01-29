//
//  YSQRCodeRecognizer.m
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import "YSQRCodeRecognizer.h"

#import <CoreImage/CoreImage.h>
#import "CIImage+YSExtension.h"
#import "CGImageManager.h"

@interface YSQRCodeRecognizer ()

@property (nonatomic, strong) NSArray   *contentArray;

@end

@implementation YSQRCodeRecognizer

+ (NSArray *)recognizeWithImage:(UIImage *)image {
    YSQRCodeRecognizer *recongnizer = [[super alloc] init];
    recongnizer.image = image;
    return [recongnizer recognize];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _contentArray = nil;
}

- (NSArray *)recognize {
    if (!_contentArray) {
        _contentArray = [self getQRString];
    }
    return _contentArray;
}

- (NSArray *)getQRString {

    CIImage *inputImage = [CIImage imageWithCGImage:_image.CGImage];
    NSArray *result = [inputImage recognizeQRCode:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    if (result.count <= 0) {
        
        inputImage = [CIImage imageWithCGImage:[CGImageManager grayscale:_image.CGImage].CGImage];
        result = [inputImage recognizeQRCode:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    }
    return result;

}

@end
