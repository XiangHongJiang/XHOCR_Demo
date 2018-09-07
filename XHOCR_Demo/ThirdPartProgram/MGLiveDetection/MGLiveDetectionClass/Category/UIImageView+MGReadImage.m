//
//  UIImageView+ReadImage.m
//  LivenessDetection
//
//  Created by megvii on 15/10/9.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "UIImageView+MGReadImage.h"

@implementation UIImageView (MGReadImage)

- (void)MGSetImageWithBlund:(NSString *)imageName {
    __block  UIImage *returnImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
        returnImage = [UIImage imageWithContentsOfFile:imagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:returnImage];
        });
    });
}

- (void)MGSetImageWithImageName:(NSString *)imageName {
    __block  UIImage *returnImage = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        returnImage = [UIImage imageNamed:imageName];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:returnImage];
        });
    });
}

@end
