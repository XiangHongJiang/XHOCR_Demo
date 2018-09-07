//
//  UIImage+AD.m
//  autoHomeFinance
//
//  Created by 杜林伟 on 16/7/11.
//  Copyright © 2016年 adu. All rights reserved.


#import "UIImage+AD.h"

@implementation UIImage (AD)
+ (instancetype)captureWithView:(UIView *)view
{
    // 1.开启上下文
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    
    // 2.将控制器view的layer渲染到上下文
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // 3.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage*)imageWithColor:(UIColor*)color frame:(CGRect)frame
{
    CGRect rect=frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage*) BgImageFromColors:(NSArray*)colors withFrame: (CGRect)frame
{
    
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        
        [ar addObject:(id)c.CGColor];
        
    }
    
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    
    CGPoint start;
    
    CGPoint end;
    
    
    start = CGPointMake(0.0, 0);
    end = CGPointMake(0, frame.size.height);
    
    
    
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(colorSpace);
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

+(NSData *)imageScaleToData:(UIImage *)myimage
{
    // 已60K 为标准. 根据比例调整分辨率
    
    NSData *data = [self compressImageWithImage:myimage aimWidth:480 aimLength:60 * 1024 accuracyOfLength:1024];
#ifdef DEBUG
    NSLog(@"-----------------------------");
    NSLog(@"图片的大小---%f", data.length/1024.0);
    NSLog(@"-----------------------------");
#endif
    return data;
}

- (NSData *)imageSmallestToSize:(int)sizeLength {

    NSInteger aimLength = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    
    NSData *data = [UIImage compressImageWithImage:self
                                          aimWidth:aimLength
                                         aimLength:sizeLength * 1024
                                  accuracyOfLength:1024];
#ifdef DEBUG
    NSLog(@"-----------------------------");
    NSLog(@"最后图片---%f", data.length/1024.0);
    NSLog(@"-----------------------------");
#endif
    return data;
}



/**
 * size: with > height
 */
- (UIImage *)compressWithMaxWithResolution:(CGSize)size diskLength:(int)diskLength{
    if (self.size.width > self.size.height) {
        NSData *data = [UIImage compressImageWithImage:self aimWidth:size.height aimLength:diskLength * 1024 accuracyOfLength:1024];
        NSLog(@"diskLength %.2fM",data.length / 1024.0 / 1024.0);
        return [UIImage imageWithData:data];
    }
    NSData *data = [UIImage compressImageWithImage:self aimWidth:size.width aimLength:diskLength * 1024 accuracyOfLength:1024];
    NSLog(@"diskLength %.2fM",data.length / 1024.0 / 1024.0);
    return [UIImage imageWithData:data];
}

+ (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy{
    NSData *compressdata = UIImageJPEGRepresentation(image, 1);
    if (compressdata.length < length && length > 40 * 1024) {
        return compressdata;
    }
         UIImage * newImage = [self imageScaleWithImage:image newSize:CGSizeMake(width, width * image.size.height / image.size.width)];
    
         NSData  * data = UIImageJPEGRepresentation(newImage, 1);
         NSInteger imageDataLen = [data length];
    
         if (imageDataLen <= length + accuracy) {
                 return data;
             }else{
                     NSData * imageData = UIImageJPEGRepresentation( newImage, 0.99);
                     if (imageData.length < length + accuracy) {
                             return imageData;
                        }
            
                     CGFloat maxQuality = 1.0;
                     CGFloat minQuality = 0.0;
                     int flag = 0;
            
                     while (1) {
                             CGFloat midQuality = (maxQuality + minQuality)/2;
                
                            if (flag == 6) {
                                //                                     NSLog(@"************* %ld ******** %f *************",UIImageJPEGRepresentation(newImage,%ldnQuality).length,minQua(long)lity);
                                     return UIImageJPEGRepresentation(newImage, minQuality);
                                 }
                             flag ++;
                
                             NSData * imageData = UIImageJPEGRepresentation(newImage, midQuality);
                             NSInteger len = imageData.length;
                
                             if (len > length+accuracy) {
                                     NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                                     maxQuality = midQuality;
                                     continue;
                                 }else if (len < length-accuracy){
                                          NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                                         minQuality = midQuality;
                                         continue;
                                     }
                                 else
                                     {
                                              NSLog(@"-----%d------%f------%ld--end",flag,midQuality,len);
                                return imageData;
                                break;
                            }
                }
            }
}



#pragma mark - 给图片加水印

+ (UIImage *)IDC_imageWithLogoText:(UIImage *)img
{
    //    timeFormat *timeT = [timeFormat share];
    //
    //    NSString *astring = [[NSString alloc] initWithString:[NSString stringWithFormat:@"仅供办理业务使用 %@",[timeT getCurrentDate]]];
    CGSize imgSize = CGSizeMake(640, 640 * (img.size.height/img.size.width));
    //    CGSize size = CGSizeMake(img.size.width, img.size.height);          //设置上下文（画布）大小
    //    UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
    //    CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
    //    CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
    //    CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
    //    CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
    //    CGContextTranslateCTM(contextRef, 0, img.size.height);
    //    CGContextScaleCTM(contextRef, 1.0, -1.0);
    //
    //    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    //    paragraphStyle.alignment                = NSTextAlignmentCenter;
    //    NSDictionary *attr = @{
    //                           NSParagraphStyleAttributeName : paragraphStyle, // 文字对齐方式
    //                           NSFontAttributeName: [UIFont boldSystemFontOfSize:50],  //设置字体
    //                           NSForegroundColorAttributeName : [UIColor redColor]   //设置字体颜色
    //                           };
    //
    //    [astring drawInRect:CGRectMake(0, img.size.height / 2, img.size.width, 80)
    //         withAttributes:attr];
    //
    //    UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
    
    //    UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
    UIImage *newImg = [self IDC_imageWithImage:img scaledToSize:imgSize];
    NSData *imageData =  UIImageJPEGRepresentation(newImg, 0.5);
    UIImage *image = [UIImage imageWithData: imageData];
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    return [[self class] imageWithColor:color andRect:rect];
}

+ (UIImage *)imageWithColor:(UIColor *)color andRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)IDC_imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}


+ (UIImage *)imageScaleWithImage:(UIImage*)image newSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    
    [image drawInRect:CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



- (UIImage *)imageStretch:(CGSize)size{
    
    // 设置端盖的值
    CGFloat top = self.size.height * 0.5;
    CGFloat left = self.size.width * 0.8;
    CGFloat bottom = self.size.height * 0.5 ;
    CGFloat right = self.size.width * 0.2 ;
    
    // 设置端盖的值
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    // 设置拉伸的模式
    UIImageResizingMode mode = UIImageResizingModeStretch;
    
    // 拉伸图片
    return [self resizableImageWithCapInsets:edgeInsets resizingMode:mode];
    
}


- (NSData *)smallestImgToData {
    
    NSData *data = [self compressImageWithImage:self
                                       aimWidth:1200
                                      aimLength:1024 * 1024 * 2
                               accuracyOfLength:1024];
    NSLog(@"最后图片---------%f---------", data.length/1024.0);
    return data;
}

// 大小压缩
- (NSData *)compressImageWithImage:(UIImage *)image aimWidth:(CGFloat)width aimLength:(NSInteger)length accuracyOfLength:(NSInteger)accuracy {
    
    UIImage * newImage = image;
    
    if (image.size.width > width) {
        newImage = [self imageWithImage:image scaledToSize:CGSizeMake(width, width * image.size.height / image.size.width)];
    }
    
    NSData  * data = UIImageJPEGRepresentation(newImage, 1);
    NSLog(@"最后图片---------%f---------", data.length/1024.0);
    NSInteger imageDataLen = [data length];
    
    if (imageDataLen <= length + accuracy) {
        return data;
    }
    else {
        NSData * imageData = UIImageJPEGRepresentation( newImage, 0.99);
        if (imageData.length < length + accuracy){
            return imageData;
        }
        
        CGFloat maxQuality = 1.0;
        CGFloat minQuality = 0.0;
        int flag = 0;
        
        while (1) {
            CGFloat midQuality = (maxQuality + minQuality)/2;
            
            if (flag == 6) {
                return UIImageJPEGRepresentation(newImage, minQuality);
            }
            flag ++;
            
            NSData * imageData = UIImageJPEGRepresentation(newImage, midQuality);
            NSInteger len = imageData.length;
            
            if (len > length+accuracy) {
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                maxQuality = midQuality;
                continue;
            }else if (len < 1024 * 10){
                NSLog(@"-----%d------%f------%ld-----",flag,midQuality,len);
                minQuality = midQuality;
                continue;
            }
            else{
                NSLog(@"-----%d------%f------%ld--end",flag,midQuality,len);
                return imageData;
                break;
            }
        }
    }
}

// 尺寸压缩
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    
    CGImageRelease(videoImage);
    return image;
}

+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage*)image {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

-(UIImage *)originalImage {
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
