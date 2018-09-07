//
//  MGImage.m
//  MGBankCard
//
//  Created by megvii on 15/12/11.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGImage.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation MGImage

UIImage* MGImageFromSampleBuffer(CMSampleBufferRef sampleBuffer, UIImageOrientation orientation) {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CGImageRef copyedImage = CGImageCreateWithImageInRect(quartzImage, CGRectMake(0, 0, width, height));
    UIImage *image = [UIImage imageWithCGImage:copyedImage scale:1.0 orientation:orientation];
    CGImageRelease(copyedImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGImageRelease(quartzImage);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

UIImage* MGCroppedImage(UIImage *image, CGRect bounds) {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

UIImage* MGFixOrientationWithImage(UIImage *image) {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             image.size.width,
                                             image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage),
                                             0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored: {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        }
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

CGFloat MGAngleOffsetFromPortraitOrientationToOrientation(AVCaptureVideoOrientation orientation) {
    CGFloat angle = 0.0;
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

@end
