//
//  MGIDCardModel.h
//  MGIDCard
//
//  Created by 张英堂 on 16/3/28.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardQualityAssessment.h"

@interface MGIDCardModel : NSObject

@property (nonatomic, strong) MGIDCardQualityResult *result;
@property (nonatomic, assign) MGIDCardSide cardSide;

@property (nonatomic, strong) UIImage *image;

- (instancetype)initWithResult:(MGIDCardQualityResult *)result;

- (UIImage *)croppedImageOfIDCard;
- (UIImage *)croppedImageOfPortrait;

@end
