//
//  MGIDCardQualityMessageResult.m
//  MGIDCard
//
//  Created by Megvii on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGIDCardQualityMessageResult.h"
#import "MGIDCardQualityAssessment.h"

#define kIDCardDetectIsCard         0.5f
#define kIDCardDetectInBound        0.5f

@interface MGIDCardQualityMessageResult ()
#if TARGET_IPHONE_SIMULATOR
#else
@property (nonatomic, strong) MGIDCardQualityResult* result;
#endif
@end

@implementation MGIDCardQualityMessageResult

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
#if TARGET_IPHONE_SIMULATOR
#else
        _result = [[MGIDCardQualityResult alloc] init];
#endif
    }
    return self;
}

- (instancetype)initWithResult:(MGIDCardQualityResult *)result {
    self = [super init];
    if (self) {
#if TARGET_IPHONE_SIMULATOR
#else
        _result = result;
#endif
    }
    return self;
}

#pragma mark - Header Api
- (NSString *)detailMessageStr {
    @autoreleasepool {
        NSMutableString* messageStr = [[NSMutableString alloc] init];
#if TARGET_IPHONE_SIMULATOR
#else
        [messageStr appendFormat:@"%@", [NSString stringWithFormat:@"清晰度 %.3f\n", self.result.attr.low_quality]];
        [messageStr appendFormat:@"%@", [NSString stringWithFormat:@"是否为身份证 %.3f\n", self.result.attr.is_idcard]];
        [messageStr appendFormat:@"%@", [NSString stringWithFormat:@"是否在框中 %.3f\n", self.result.attr.in_bound]];
        [messageStr appendFormat:@"%@", [NSString stringWithFormat:@"光斑数量 %d\n", self.result.attr.specular_highlight_count]];
        [messageStr appendFormat:@"%@", [NSString stringWithFormat:@"阴影数量 %d\n ", self.result.attr.shadow_count]];
#endif
        return messageStr;
    }
}

@end
