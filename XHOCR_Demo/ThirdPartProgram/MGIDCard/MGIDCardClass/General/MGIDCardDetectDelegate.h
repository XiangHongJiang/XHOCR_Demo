//
//  MGIDCardDetectDelegate.h
//  MGIDCard
//
//  Created by Megvii on 2017/4/19.
//  Copyright © 2017年 megvii. All rights reserved.
//

#ifndef MGIDCardDetectDelegate_h
#define MGIDCardDetectDelegate_h
@class MGIDCardDetectManager;
@class MGIDCardQualityResult;

@protocol MGIDCardDetectDelegate <NSObject>

@required
/**
 *  每一张图片检测完成返回信息
 *
 *  @param manager 指针
 *  @param result  检测结果
 */
- (void)cardCheck:(MGIDCardDetectManager *)manager finish:(MGIDCardQualityResult *)result;

@end

#endif /* MGIDCardDetectDelegate_h */
