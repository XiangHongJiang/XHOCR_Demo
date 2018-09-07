//
//  MGIDCardQualityMessageResult.h
//  MGIDCard
//
//  Created by Megvii on 2017/3/22.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MGIDCardQualityResult;

@interface MGIDCardQualityMessageResult : NSObject

- (instancetype)initWithResult:(MGIDCardQualityResult *)result;

- (NSString *)detailMessageStr;

@end
