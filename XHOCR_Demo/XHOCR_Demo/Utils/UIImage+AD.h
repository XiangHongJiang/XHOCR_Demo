//
//  UIImage+AD.h

//  autoHomeFinance
//
//  Created by 杜林伟 on 16/7/11.
//  Copyright © 2016年 adu. All rights reserved.



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface UIImage (AD)

+ (instancetype)captureWithView:(UIView *)view;
+ (UIImage*)imageWithColor:(UIColor*)color frame:(CGRect)frame;
+ (UIImage*)BgImageFromColors:(NSArray*)colors withFrame: (CGRect)frame;

+(NSData *)imageScaleToData:(UIImage *)myimage;

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer;
+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage*)image;

-(UIImage *)originalImage;



- (NSData *)imageSmallestToSize:(int)sizeLength;


- (UIImage *)compressWithMaxWithResolution:(CGSize)size diskLength:(int)diskLength;


/**根据size拉伸没图片*/
- (UIImage *)imageStretch:(CGSize)size;

+ (UIImage *)IDC_imageWithLogoText:(UIImage *)img;

+ (UIImage *)imageWithColor:(UIColor *)color;

// 压缩图片
- (NSData *)smallestImgToData;

@end
