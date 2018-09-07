//
//  MGDefaultBottomManager.m
//  MGLivenessDetection
//
//  Created by megvii on 16/4/13.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import "MGDefaultBottomManager.h"
#import "UIImageView+MGReadImage.h"
#import <MGBaseKit/MGBaseKit.h>
#import "MGPlayAudio.h"

@interface MGDefaultBottomManager ()
{
    CGFloat _aniViewHeigh, _aniViewWidth;
}
@property (nonatomic, strong) UIImageView *imageViewA;
@property (nonatomic, strong) UIImageView *imageViewB;
@property (nonatomic, assign) CGFloat cencerX;
@property (nonatomic, assign) CGFloat topDistance;

@end

@implementation MGDefaultBottomManager

- (void)creatBottomView {
    [super creatBottomView];
    self.topDistance = MG_WIN_HEIGHT == 320 ? 20.0f:40.0f;
    MGBaseCountdownView *countView = nil;
    switch (self.countDownType) {
        case MGCountDownTypeRing: {
            countView = [[MGCountDownRingView alloc] initWithFrame:CGRectMake(self.frame.size.width-80, self.topDistance*0.7, 60, 60)];
        }
            break;
        case MGCountDownTypeText: {
            countView = [[MGCountDownTextView alloc] initWithFrame:CGRectMake(self.frame.size.width *0.62, 10, self.frame.size.width *0.35, 30)];
        }
            break;
        default:
            break;
    }
    self.countDownView = countView;
    [self addSubview:self.countDownView];
    
    /*CGRectMake(self.frame.size.width-80, _kTopDis*0.7, 60, 60)*/
    
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.topDistance)];
    [self.messageLabel setFont:[UIFont systemFontOfSize:18]];
    [self.messageLabel setTextColor:[UIColor whiteColor]];
    [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:self.messageLabel];
}

- (void)creatAniamtionView {
    [super creatAniamtionView];
    
    self.imageViewA = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageViewB = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.imageViewA setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageViewB setContentMode:UIViewContentModeScaleAspectFit];
    
    _aniViewHeigh = self.frame.size.height-self.topDistance-10;
    _aniViewWidth = self.frame.size.width/2;
    _cencerX = (self.frame.size.width - _aniViewWidth)*0.5;
    
    
    [self.imageViewB setFrame:CGRectMake(self.frame.size.width, self.topDistance, _aniViewWidth, _aniViewHeigh)];
    
    [self addSubview:self.imageViewA];
    [self addSubview:self.imageViewB];
}

- (void)recoveryView {
    [super recoveryView];
    
    [self.imageViewA stopAnimating];
    self.imageViewA.animationImages = nil;
    
    
    CGRect sourceRect = CGRectMake(_cencerX, self.topDistance,  _aniViewWidth, _aniViewHeigh);
    [self.imageViewA setImage:[MGLiveBundle LiveImageWithName:@"header_first"]];
    [self.imageViewA setFrame:sourceRect];
}

- (void)willChangeAnimation:(MGLivenessDetectionType)state outTime:(CGFloat)time currentStep:(NSInteger)step {
    [super willChangeAnimation:state outTime:time currentStep:step];
    
    [self.imageViewA stopAnimating];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    NSString *title = nil;
    NSString *videoName = nil;
    
    switch (state) {
        case DETECTION_TYPE_BLINK: {
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-eye"]];
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-blink"]];
            title = [MGLiveBundle LiveBundleString:@"face_check_eye"];
            videoName = @"meglive_eye_blink2";
            break;
        }
        case DETECTION_TYPE_MOUTH: {
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-blink"]];
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-openMouse"]];
            title = [MGLiveBundle LiveBundleString:@"face_check_mouse"];
            videoName = @"meglive_mouth_open2";
            break;
        }
        case DETECTION_TYPE_POS_YAW: {
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-left"]];
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-right"]];
            title = [MGLiveBundle LiveBundleString:@"face_check_header_3"];
            videoName = @"meglive_yaw1";            
            break;
        }
        case DETECTION_TYPE_POS_PITCH: {
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-up"]];
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-down"]];
            title = [MGLiveBundle LiveBundleString:@"face_check_header_1"];
            videoName = @"meglive_pitch_down";
            break;
        }
        case DETECTION_TYPE_DONE: {
            [array addObject:[MGLiveBundle LiveImageWithName:@"head-blink"]];
            title = [MGLiveBundle LiveBundleString:@"face_check_title"];
            break;
        }
        default:
            break;
    }
    
    if (step == 0) {
        [[MGPlayAudio sharedAudioPlayer] playWithFileName:videoName finishNext:NO];
    } else {
        [[MGPlayAudio sharedAudioPlayer] playWithFileName:videoName finishNext:YES];
    }
    
    if (array.count != 0) {
        CGRect sourceRect = CGRectMake(_cencerX, self.topDistance , _aniViewWidth, _aniViewHeigh);
        CGRect leftHideRect = CGRectMake(-_aniViewHeigh, self.topDistance , _aniViewWidth, _aniViewHeigh);
        CGRect rightHideRect = CGRectMake(self.frame.size.width, self.topDistance , _aniViewWidth, _aniViewHeigh);
        [self showMessageView:title];
        self.imageViewB.image = array[0];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             if (!self.stopAnimaiton) {
                                 [self.imageViewA setFrame:leftHideRect];
                                 [self.imageViewB setFrame:sourceRect];
                             } else {
                                 [self.imageViewA setImage:[MGLiveBundle LiveImageWithName:@"header_first"]];
                             }
                         }
                         completion:^(BOOL finished) {
                             if (!self.stopAnimaiton) {
                                 self.imageViewA.image = self.imageViewB.image;
                                 [self.imageViewA setFrame:sourceRect];
                                 [self.imageViewB setFrame:rightHideRect];
                                 [self.imageViewA setAnimationImages:array];
                                 [self.imageViewA setAnimationRepeatCount:999];
                                 [self.imageViewA setAnimationDuration:1.5f];
                                 [self.imageViewA startAnimating];
                             } else {
                                 self.imageViewA.animationImages = nil;
                                 [self.imageViewA setFrame:sourceRect];
                                 [self.imageViewB setFrame:rightHideRect];
                                 [self.imageViewA setImage:[MGLiveBundle LiveImageWithName:@"header_first"]];
                             }
                         }];
    }
}

@end
