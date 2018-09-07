//
//  MGIDCardModel.m
//  MGIDCard
//
//  Created by 张英堂 on 16/3/28.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardModel.h"
#import "MGIDCardQualityAssessment.h"

@implementation MGIDCardModel

#pragma mark - Init
- (instancetype)initWithResult:(MGIDCardQualityResult *)result{
    self = [super init];
    if (self) {
        self.image = result.image;
        self.result = result;
        self.cardSide = result.attr.side;
    }
    return self;
}

#pragma mark - Return UIImage
- (UIImage *)croppedImageOfIDCard {
#if TARGET_IPHONE_SIMULATOR
    return nil;
#else
    return [self.result croppedImageOfIDCard];
#endif
}

- (UIImage *)croppedImageOfPortrait {
#if TARGET_IPHONE_SIMULATOR
    return nil;
#else
    return [self.result croppedImageOfPortrait];
#endif
}

@end
