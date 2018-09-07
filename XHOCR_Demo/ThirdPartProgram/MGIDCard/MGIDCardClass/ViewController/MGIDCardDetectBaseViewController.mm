//
//  MGIDCardDetectBaseViewController.m
//  MGIDCard
//
//  Created by 张英堂 on 16/8/10.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDCardDetectBaseViewController.h"
#import "MGRBDMuteSwitch.h"

@interface MGIDCardDetectBaseViewController () <MGVideoDelegate, MGIDCardDetectDelegate>

@end

@implementation MGIDCardDetectBaseViewController

#pragma mark - Init and Dealloc
-(void)dealloc {
    self.videoManager = nil;
    self.cardCheckManager = nil;
}

- (instancetype)initWithDefaultSetting{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.screenOrientation = MGIDCardScreenOrientationLandscapeLeft;
        [self defaultSetting];
    }
    return self;
}

#pragma mark - ViewLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    if (self.videoManager.videoDelegate != self) {
        [self.videoManager setVideoDelegate:self];
    }
    
    if (self.cardCheckManager.delegate != self) {
        [self.cardCheckManager setDelegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Default
- (void)defaultSetting{
    if (!self.cardCheckManager) {
        _cardCheckManager = [MGIDCardDetectManager idCardManagerWithCardSide:self.IDCardSide
                                                           screenOrientation:self.screenOrientation];
        
        NSString *sessionFrame = [MGAutoSessionPreset autoSessionPreset];
        self.videoManager = [MGVideoManager videoPreset:sessionFrame
                                         devicePosition:AVCaptureDevicePositionBack
                                            videoRecord:NO
                                             videoSound:NO];
        [self.videoManager setVideoDelegate:self];
        [self.cardCheckManager setDelegate:self];
    }
}

#pragma mark - Detect Result
- (void)detectFrameError:(NSArray *)errorArray {
}

- (void)detectFrameErrorDetail:(MGIDCardQualityResult *)result {
}

- (void)detectSucess:(MGIDCardQualityResult *)result {
    [self.cardCheckManager stopDetect];
}

#pragma makr - MGVideoDelegate
- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        UIImage *tempImage = nil;
        if (self.screenOrientation == MGIDCardScreenOrientationPortrait) {
            UIImage *newImage = MGImageFromSampleBuffer(sampleBuffer, UIImageOrientationRight);
            tempImage = MGFixOrientationWithImage(newImage);
        } else {
            tempImage = MGImageFromSampleBuffer(sampleBuffer, UIImageOrientationUp);
        }
        
        [self.cardCheckManager detectWithImage:tempImage];
    }
}

#pragma mark - MGIDCardDetectDelegate
- (void)cardCheck:(MGIDCardDetectManager *)manager finish:(MGIDCardQualityResult *)result {
    if (result.isValid == YES) {
        [[MGRBDMuteSwitch sharedInstance] detectMuteSwitch];
        [self detectSucess:result];
    } else {
        if (result.fails.count > 0) {
            [self detectFrameErrorDetail:result];
        }
    }
}

@end
