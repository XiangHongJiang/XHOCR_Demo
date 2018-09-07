//
//  MGIDCardManager.m
//  MGIDCard
//
//  Created by 张英堂 on 15/12/28.
//  Copyright © 2015年 megvii. All rights reserved.
//

#import "MGIDCardManager.h"
#import "MGIDCardDefaultViewController.h"

@implementation MGIDCardManager

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.screenOrientation = MGIDCardScreenOrientationLandscapeLeft;
    }
    return self;
}

#pragma mark - Start Detect
- (void)IDCardStartDetection:(UIViewController *)ViewController
                  IdCardSide:(MGIDCardSide)CardSide
                      finish:(void(^)(MGIDCardModel *model))finish
                        errr:(void(^)(MGIDCardError errorType))error{
#if TARGET_IPHONE_SIMULATOR
    if (error) {
        error(MGIDCardErrorSimulator);
    }
#else
    MGIDCardDetectManager *cardCheckManager = [MGIDCardDetectManager idCardManagerWithCardSide:CardSide
                                                                             screenOrientation:self.screenOrientation];
    
    NSString *sessionFrame = [MGAutoSessionPreset autoSessionPreset];
    MGVideoManager *videoManager = [MGVideoManager videoPreset:sessionFrame
                                     devicePosition:AVCaptureDevicePositionBack
                                        videoRecord:NO
                                         videoSound:NO];
    
    MGIDCardDefaultViewController *idcardDetectVC = [[MGIDCardDefaultViewController alloc] initWithNibName:nil bundle:nil];
    [idcardDetectVC setVideoManager:videoManager];
    [idcardDetectVC setCardCheckManager:cardCheckManager];
    
    [idcardDetectVC setFinishBlock:finish];
    [idcardDetectVC setErrorBlcok:error];
    
    if (MG_WIN_WIDTH <= 320 && MG_WIN_HEIGHT <= 480) {
        [idcardDetectVC setScreenOrientation:MGIDCardScreenOrientationLandscapeLeft];
    } else {
        [idcardDetectVC setScreenOrientation:self.screenOrientation];
    }
    
    [ViewController presentViewController:idcardDetectVC animated:YES completion:nil];
#endif
}

#pragma mark - License
+ (NSDate *)getLicenseDate {
#if TARGET_IPHONE_SIMULATOR
    return [NSDate date];
#else
    NSDictionary *licenseDic = [MGIDCardQualityAssessment checkCachedLicense];
    NSDate *sdkDate = [licenseDic valueForKey:[self IDCardVersion]];
    return sdkDate;
#endif
}

+ (BOOL)getLicense {
#if TARGET_IPHONE_SIMULATOR
#else
    NSString *sdkVersion = [self IDCardVersion];
    MGLog(@"version : %@", sdkVersion);
    NSArray *sdkInfo = [sdkVersion componentsSeparatedByString:@","];
    if (sdkInfo.count > 1) {
        return YES;
    }
    
    NSDate *nowDate = [NSDate date];
    NSDictionary *licenseDic = [MGIDCardQualityAssessment checkCachedLicense];
    NSDate *sdkDate = [licenseDic valueForKey:[self IDCardVersion]];
    MGLog(@"idCardSDK licenes:%@", sdkDate);

    if ([sdkDate compare:nowDate] == NSOrderedDescending) {
        return YES;
    }
#endif

    return NO;
}

#pragma mark - Version
+ (NSString *)IDCardVersion{
#if TARGET_IPHONE_SIMULATOR
    return @"1.0.0";
#else
    return [MGIDCardQualityAssessment getVersion];
#endif
}

@end
