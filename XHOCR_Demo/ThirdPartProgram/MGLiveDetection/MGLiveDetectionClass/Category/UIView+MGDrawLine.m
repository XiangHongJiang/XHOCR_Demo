//
//  UIView+DreawLine.m
//  text
//
//  Created by imht-ios on 14-5-20.
//  Copyright (c) 2014Year ymht. All rights reserved.
//

#import "UIView+MGDrawLine.h"

@implementation UIView (MGDrawLine)

- (void)MGDrawRoundBoderWidth:(CGFloat)width andColor:(UIColor*)color andRadius:(CGFloat)radius {
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:radius];            //  设置矩圆角半径
    [self.layer setBorderWidth:width];              //  边框宽度
    [self.layer setBorderColor:color.CGColor];      //  边框颜色
}

-(UIImage *)MGChangeToImage {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
