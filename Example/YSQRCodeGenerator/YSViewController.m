//
//  YSViewController.m
//  YSQRCodeGenerator
//
//  Created by z624821876 on 01/29/2018.
//  Copyright (c) 2018 z624821876. All rights reserved.
//

#import "YSViewController.h"

#import "YSQRCode.h"

@interface YSViewController ()

@end

@implementation YSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor redColor];

    /*Normal */
//    YSQRCodeGenerator *generator = [YSQRCodeGenerator new];
//    generator.content = @"123123";
//    [generator setColorWithBackColor:[UIColor whiteColor] foregroundColor:[UIColor blackColor]];
//    UIImage *image = [generator generate];

    /*背景图 + icon */
//    YSQRCodeGenerator *generator = [YSQRCodeGenerator new];
//    generator.content = @"123123";
//    [generator setColorWithBackColor:[UIColor whiteColor] foregroundColor:[UIColor blackColor]];
//    generator.watermark = [UIImage imageNamed:@"Miku.jpg"];
//    generator.watermarkMode = UIViewContentModeScaleAspectFill;
//    generator.icon = [UIImage imageNamed:@"github"];
//    generator.iconSize = CGSizeMake(40, 40);
//    UIImage *image = [generator generate];
    
    YSQRCodeGenerator *generator = [YSQRCodeGenerator new];
    generator.content = @"123123";
    [generator setColorWithBackColor:[UIColor whiteColor] foregroundColor:[UIColor blackColor]];
    UIImage *image = [generator generateWithGIFCodeWithGIFNamed:@"74766_811947_358458"];
    
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(100, 100, 256, 256);
    imageView.image = image;
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
