//
//  MGLiveBaseDetectViewController.m
//  MGLivenessDetection
//
//  Created by megvii on 16/8/5.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import "MGLiveBaseDetectViewController.h"
#import "MGLiveActionManager.h"
#import "MGLiveErrorManager.h"

@interface MGLiveBaseDetectViewController () 

@property (nonatomic, assign) BOOL tempFaceToLarge;

@end

@implementation MGLiveBaseDetectViewController

#pragma mark - Dealloc and Init
-(void)dealloc {
    self.videoManager = nil;
    self.liveManager = nil;
    MGLog(@"%s", __func__);
}

- (instancetype)initWithDefauleSetting {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.liveManager.delegate != self) {
        self.liveManager.delegate = self;
    }
    if (self.videoManager.videoDelegate != self) {
        self.videoManager.videoDelegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Default Setting
- (void)defaultSetting {
    if (!self.liveManager && !self.videoManager) {
        self.videoManager = [MGVideoManager videoPreset:AVCaptureSessionPreset640x480
                                         devicePosition:AVCaptureDevicePositionFront
                                            videoRecord:NO
                                             videoSound:NO];
        [self.videoManager setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        MGLiveActionManager *ActionManager = [MGLiveActionManager LiveActionRandom:YES
                                                                       actionArray:nil
                                                                       actionCount:3];
        
        MGLiveErrorManager *errorManager = [[MGLiveErrorManager alloc] initWithFaceCenter:KMGDEFAULTFACECENTER];
        self.liveManager = [[MGLiveDetectionManager alloc] initWithActionTime:10.0f
                                                                actionManager:ActionManager
                                                                 errorManager:errorManager];
        
        [self.liveManager setDelegate:self];
        [self.videoManager setVideoDelegate:self];
    }
}

/**  即将启动活体检测，延迟 0.2S */
- (void)willStatLiveness {
    [self liveFaceDetection];
}

/** 完成录像 */
- (void)stopVideoWriter {
    @synchronized (self) {
        [self.videoManager stopRunning];

        [self.videoManager stopRceording];
    }
}

-(void)liveFaceDetection{
}

- (void)cancelDetect {
    [self stopVideoWriter];
    [self.liveManager stopDetection];
    self.liveManager = nil;
}

/** 播放动作提示动画 */
- (void)starAnimation:(MGLivenessDetectionType )type
                 step:(NSInteger)step
              timeOut:(NSUInteger)timeOut{
}

- (void)qualitayErrorMessage:(NSString *)error{
}

- (void)detectionFaceToLarge{
}

- (void)detectionFaceRecover{
}

/** 活体检测结束处理 */
- (void)liveDetectionFinish:(MGLivenessDetectionFailedType)type checkOK:(BOOL)check liveDetectionType:(MGLiveDetectionType)detectionType{
    [self stopVideoWriter];
}

#pragma mark - MGVideoDelegate
-(void)MGCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.isViewLoaded) {
        [self.liveManager detectionWithSampleBuffer:sampleBuffer orientation:UIImageOrientationRight];
    }
}

- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput error:(MGVideoErrorType)error {
    [self detectionManager:self.liveManager finishWithError:DETECTION_FAILED_TYPE_NOTVIDEO];
}

#pragma mark - MGLiveDetectionManager delegate
- (void)detectionManager:(MGLiveDetectionManager *)manager finishWithStep:(MGLiveStep)step {
    if (manager.detectionType == MGLiveDetectionTypeQualityOnly) {
        [self liveDetectionFinish:DETECTION_FAILED_TYPE_MASK
                          checkOK:YES
                liveDetectionType:MGLiveDetectionTypeQualityOnly];
    }
}

- (void)detectionManager:(MGLiveDetectionManager *)manager frameWithImage:(MGLivenessDetectionFrame *)frame {
    if (YES == frame.attr.face_too_large) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self detectionFaceToLarge];
            });
    } else {
        if (frame.attr.face_too_large != self.tempFaceToLarge) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self detectionFaceRecover];
            });
        }
    }
    self.tempFaceToLarge = frame.attr.face_too_large;
}

- (void)detectionManager:(MGLiveDetectionManager *)manager finishWithError:(MGLivenessDetectionFailedType)failedType {
    [self liveDetectionFinish:failedType
                      checkOK:NO
            liveDetectionType:MGLiveDetectionTypeAll];
}

- (void)detectionManager:(MGLiveDetectionManager *)manager liveChangeAction:(MGLivenessDetectionType)actionType timeOut:(NSUInteger)timeOut currentActionStep:(NSUInteger)step {
    [self starAnimation:actionType step:step timeOut:timeOut];
}

- (void)detectionManager:(MGLiveDetectionManager *)manager checkError:(NSString *)error {
    [self qualitayErrorMessage:error];
}

-(void)detectionManagerSucessLiveDetection:(MGLiveDetectionManager *)manager liveDetectionType:(MGLiveDetectionType)detectionType {
    [self liveDetectionFinish:DETECTION_FAILED_TYPE_MASK
                      checkOK:YES
            liveDetectionType:detectionType];
}

@end
