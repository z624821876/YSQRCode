//
//  YSUIntPixel.m
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import "YSUIntPixel.h"

@implementation YSUIntPixel

- (instancetype)initWithRed:(UInt8)red green:(UInt8)green blue:(UInt8)blue alpha:(UInt8)alpha {
    self = [super init];
    if (self) {
        self.red = red;
        self.green = green;
        self.blue = blue;
        self.alpha = alpha;
    }
    return self;
}

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        CGFloat red = 0.0;
        CGFloat green = 0.0;
        CGFloat blue = 0.0;
        CGFloat alpha = 0.0;
        
        BOOL isSuccess = [color getRed:&red green:&green blue:&blue alpha:&alpha];
        if (isSuccess) {
            self.red = red * 255.0;
            self.green = green * 255.0;
            self.blue = blue * 255.0;
            self.alpha = alpha * 255.0;
        }
    }
    return self;
}

@end
