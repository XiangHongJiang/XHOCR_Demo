//
//  MGFaceManager.m
//  MGFaceDetection
//
//  Created by megvii on 15/12/22.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGLiveManager.h"
#import <MGBaseKit/MGBaseKit.h>
#import "MGLiveDetectViewController.h"
#import "MGLiveActionManager.h"
#import "MGLiveDetectionManager.h"
#import "MGLiveDefaultDetectVC.h"

@implementation MGLiveManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.randomAction = YES;
        self.actionCount = 3;
        self.actionTimeOut = 10.0f;
        self.detectionWithMovier = NO;
        self.detectionWithSound = NO;
        
        self.detectionType = MGLiveDetectionTypeAll;
    }
    return self;
}

- (void)startFaceDecetionViewController:(UIViewController *)viewController
                                 finish:(void(^)(FaceIDData *faceData, UIViewController *viewController))finish
                                  error:(void(^)(MGLivenessDetectionFailedType errorType, UIViewController *vc))error {
    if (NO == [self checkSetting]) {
        if (error) {
            error(DETECTION_FAILED_TYPE_NOTVIDEO, nil);
        }
        return;
    }
    
    MGVideoManager *videoManager = [MGVideoManager videoPreset:AVCaptureSessionPreset640x480
                                                devicePosition:AVCaptureDevicePositionFront
                                                   videoRecord:self.detectionWithMovier
                                                    videoSound:self.detectionWithSound];
    [videoManager setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    MGLiveActionManager *ActionManager = [MGLiveActionManager LiveActionRandom:self.randomAction
                                                                   actionArray:self.actionArray
                                                                   actionCount:self.actionCount];
    
    MGLiveErrorManager *errorManager = [[MGLiveErrorManager alloc] initWithFaceCenter:KMGDEFAULTFACECENTER];
    
    MGLiveDetectionManager *liveManager = [[MGLiveDetectionManager alloc] initWithActionTime:self.actionTimeOut
                                                                               actionManager:ActionManager
                                                                                errorManager:errorManager];
    [liveManager setDetectionType:self.detectionType];
    
    MGLiveDefaultDetectVC *detectVC = [[MGLiveDefaultDetectVC alloc] initWithNibName:nil bundle:nil];
    [detectVC setLiveManager:liveManager];
    [detectVC setVideoManager:videoManager];
    [detectVC setQualityfinish:self.Qualityfinish];
    
    [detectVC setDetectFinish:finish];
    [detectVC setDetectError:error];
    
    UINavigationController *detectNavC = [[UINavigationController alloc] initWithRootViewController:detectVC];
    [viewController presentViewController:detectNavC animated:YES completion:nil];
}

/* 简单的配置检测 */
- (BOOL)checkSetting {
    if (self.actionCount > 4) {
        return NO;
    }
    if (self.actionArray.count > 4) {
        return NO;
    }
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Version
+ (NSString *)LiveDetectionVersion {
    return [MGLivenessDetector getVersion];
}

#pragma mark - Livense
+ (BOOL)getLicense {
    NSString *sdkVersion = [MGLiveManager LiveDetectionVersion];
    MGLog(@"version : %@", sdkVersion);
    NSArray *sdkInfo = [sdkVersion componentsSeparatedByString:@","];
    if (sdkInfo.count > 1) {
        return YES;
    }
    
    NSDate *nowDate = [NSDate date];
    NSDictionary *licenseDic = [MGLivenessDetector checkCachedLicense];
    NSDate *sdkDate = [licenseDic valueForKey:[self LiveDetectionVersion]];
    MGLog(@"faceSDK licenes:%@ -- %@", sdkDate, nowDate);
    if ([sdkDate compare:nowDate] == NSOrderedDescending) {
        return YES;
    }
    
    return NO;
}

+ (NSDate *)getLicenseDate {
    NSDictionary *licenseDic = [MGLivenessDetector checkCachedLicense];
    
    NSDate *sdkDate = [licenseDic valueForKey:[self LiveDetectionVersion]];
    return sdkDate;
}

@end
