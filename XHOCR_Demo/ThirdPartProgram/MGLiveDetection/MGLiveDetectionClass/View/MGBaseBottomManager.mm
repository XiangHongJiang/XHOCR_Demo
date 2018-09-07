//
//  BottomAnimationView.m
//  LivenessDetection
//
//  Created by megvii on 15/1/8.
//  Copyright (c) 2015Year megvii. All rights reserved.
//

#import "MGBaseBottomManager.h"
#import "UIImageView+MGReadImage.h"
#import "MGPlayAudio.h"

@implementation MGBaseBottomManager

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame andCountDownType:(MGCountDownType)countDownType {
    self = [super initWithFrame:frame];
    if (self) {
        _countDownType = countDownType;
        [self creatBottomView];
        [self creatAniamtionView];
        [self recovery];
    }
    return self;
}

#pragma mark - CreateView
- (void)creatBottomView {
    [self setBackgroundColor:MGColorWithRGB(51, 56, 70, 1)];
}

- (void)creatAniamtionView {
}

#pragma mark - MessageView
- (void)showMessageView:(NSString *)message {
    if (!message) {
        [self.messageLabel setText:[MGLiveBundle LiveBundleString:@"face_check_title1"]];
    } else {
        [self.messageLabel setText:message];
    }
}

- (void)recovery {
    _stopAnimaiton = YES;
    [[MGPlayAudio sharedAudioPlayer] cancelAllPlay];
    
    [self recoveryView];
}

- (void)recoveryView {
    [self.countDownView stopAnimation];
}

- (void)recoveryWithTitle:(NSString *)title {
    [self recovery];
    [self showMessageView:title];
}

- (void)willChangeAnimation:(MGLivenessDetectionType)state
                    outTime:(CGFloat)time
                currentStep:(NSInteger)step{
    _stopAnimaiton = NO;
    [self outTime:time];
}

- (void)outTime:(CGFloat)time {
    [self.countDownView setMaxTime:time];
}

- (void)startRollAnimation {
    [self.countDownView startAnimation];
}

- (void)addSubview:(UIView *)view {
    if (view.superview == self) {
        return;
    }
    [super addSubview:view];
}

@end
