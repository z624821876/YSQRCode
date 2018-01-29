//
//  YSQRCodeRecognizer.h
//  YSQRCodeTest
//
//  Created by yu on 2018/1/29.
//  Copyright © 2018年 yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YSQRCodeRecognizer : NSObject

@property (nonatomic, strong) UIImage   *image;

+ (NSArray *)recognizeWithImage:(UIImage *)image;

- (NSArray *)recognize;

@end
