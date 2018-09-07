//
//  MGAutoSessionPreset.m
//  MGBaseKit
//
//  Created by megvii on 16/8/2.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import "MGAutoSessionPreset.h"
#import "MGBaseDefine.h"

@implementation MGAutoSessionPreset

+ (NSString *)autoSessionPreset {
    return AVCaptureSessionPresetiFrame1280x720;
}

+ (CGSize)autoSessionPresetSize {
    return CGSizeMake(1280, 720);
}

@end
