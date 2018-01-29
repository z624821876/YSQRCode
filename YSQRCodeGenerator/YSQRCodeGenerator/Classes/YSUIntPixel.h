//
//  YSUIntPixel.h
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YSUIntPixel : NSObject

@property (nonatomic, assign) UInt8 red;

@property (nonatomic, assign) UInt8 green;

@property (nonatomic, assign) UInt8 blue;

@property (nonatomic, assign) UInt8 alpha;

- (instancetype)initWithRed:(UInt8)red green:(UInt8)green blue:(UInt8)blue alpha:(UInt8)alpha;

- (instancetype)initWithColor:(UIColor *)color;

@end
