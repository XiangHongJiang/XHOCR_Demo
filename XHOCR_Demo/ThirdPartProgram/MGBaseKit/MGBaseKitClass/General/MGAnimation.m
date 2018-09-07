//
//  MGAnimation.m
//  MGBankCard
//
//  Created by megvii on 15/12/11.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGAnimation.h"

#define KOpacityKey @"opacity"

@implementation MGAnimation

+ (CABasicAnimation *)animationWithOpacity {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:KOpacityKey];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.01f];
    animation.autoreverses = NO;
    animation.duration = 0.5f;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}

@end
