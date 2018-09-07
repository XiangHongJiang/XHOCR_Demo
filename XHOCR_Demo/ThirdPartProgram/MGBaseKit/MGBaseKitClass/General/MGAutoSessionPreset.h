//
//  MGAutoSessionPreset.h
//  MGBaseKit
//
//  Created by megvii on 16/8/2.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGAutoSessionPreset : NSObject

/**
 *  获取与屏幕尺寸比例相同的视频流
 *
 *  @return SessionPreset
 */
+ (NSString *)autoSessionPreset;

+ (CGSize)autoSessionPresetSize;

@end
