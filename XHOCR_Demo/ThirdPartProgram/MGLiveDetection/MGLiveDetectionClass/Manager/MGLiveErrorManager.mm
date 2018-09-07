//
//  MGFaceError.m
//  MGFaceDetection
//
//  Created by megvii on 15/12/23.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGLiveErrorManager.h"
#import "MGLiveBundle.h"
#import "MGLiveConfig.h"

@interface MGLiveErrorManager ()

@property (nonatomic, strong) NSArray *errorArray;
@property (nonatomic, strong) NSMutableArray *tempArray;

@end

@implementation MGLiveErrorManager

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _qualityManager = [[MGFaceQualityManager alloc] initWithFaceCenter:KMGDEFAULTFACECENTER];
        self.holdingErrorCount = 10;
        
        [self resetErrorList];
    }
    return self;
}

- (instancetype)initWithFaceCenter:(CGPoint)center {
    self = [super init];
    if (self) {
        _qualityManager = [[MGFaceQualityManager alloc] initWithFaceCenter:center];
        self.holdingErrorCount = 10;
        
        [self resetErrorList];
    }
    return self;
}

#pragma mark - Setter and Getter
- (NSArray *)errorArray {
    if (!_errorArray) {
        _errorArray = @[[MGLiveBundle LiveBundleString:@"face_check_error1"],
                        [MGLiveBundle LiveBundleString:@"face_check_error2"],
                        [MGLiveBundle LiveBundleString:@"face_check_error3"],
                        [MGLiveBundle LiveBundleString:@"face_check_error4"],
                        [MGLiveBundle LiveBundleString:@"face_check_error5"],
                        [MGLiveBundle LiveBundleString:@"face_check_error6"],
                        [MGLiveBundle LiveBundleString:@"face_check_error7"],
                        [MGLiveBundle LiveBundleString:@"face_check_error8"],
                        [MGLiveBundle LiveBundleString:@"face_check_error9"],
                        [MGLiveBundle LiveBundleString:@"face_check_error10"],
                        [MGLiveBundle LiveBundleString:@"face_check_error11"],
                        [MGLiveBundle LiveBundleString:@"face_check_error12"],
                        [MGLiveBundle LiveBundleString:@"face_check_error13"]];
    }
    return _errorArray;
}

#pragma mark - Error message
- (NSString *)errprStringWithType:(NSInteger)type {
    if (type < 0 || type >= self.errorArray.count) {
        return @"";
    }
    NSString *tempStr = [self.errorArray objectAtIndex:type];
    return tempStr;
}

//  计算错误出现频率最多的一个
- (NSString *)getMaxType:(NSMutableArray *)errorArray {
    if (errorArray.count < self.holdingErrorCount) {
        return nil;
    }
    
    const int errorCount = 13;
    int count[errorCount] = {0,0,0,0,0,0,0,0,0,0,0,0,0};
    
    for (int i = 0; i < errorArray.count; i++){
        int tempint = [errorArray[i] intValue];
        count[tempint] ++;
    }
    [errorArray removeAllObjects];
    
    int idx = 1;
    for (int i = 0; i < errorCount; i++){
        if (count[idx] < count[i]) {
            idx = i;
        }
    }

    NSString *errorString = [self errprStringWithType:idx];
    return errorString;
}

- (NSString *)checkImgWithMGFrame:(MGLivenessDetectionFrame *)frame motionY:(CGFloat)motionY {
    NSString *returnString = nil;
    
    if (fabs(motionY) < 0.90) {
        int errortype = 0;
        [self.tempArray addObject:@(errortype)];
        returnString = [self getMaxType:self.tempArray];
    } else if (frame.attr.eye_left_occlusion > 0.5 || frame.attr.eye_right_occlusion > 0.5) {
        int errortype = 11;
        [self.tempArray addObject:@(errortype)];
        returnString = [self getMaxType:self.tempArray];
    } else if (frame.attr.mouth_occlusion > 0.5) {
        int errortype = 12;
        [self.tempArray addObject:@(errortype)];
        returnString = [self getMaxType:self.tempArray];
    } else {
        NSArray *errorArray = [self.qualityManager feedFrame:frame];
        if (errorArray.count >= 1) {
            MGFaceQualityErrorType tempError = (MGFaceQualityErrorType)[[errorArray firstObject] integerValue];
            switch (tempError) {
                case MGFaceQualityErrorFrameNeedHolding: {
                    returnString = [MGLiveBundle LiveBundleString:@"face_check_title2"];
                }
                    break;
                case MGFaceQualityErrorNone: {
                    returnString = MGFaceFinishKey;
                }
                    break;
                default: {
                    [self.tempArray addObject:@(tempError)];
                    returnString = [self getMaxType:self.tempArray];
                }
                    break;
            }
        } else {
            returnString = MGFaceFinishKey;
        }
    }
    return returnString;
}

- (void)resetErrorList {
    if (!self.tempArray) {
        self.tempArray = [NSMutableArray arrayWithCapacity:self.holdingErrorCount];
    } else {
        [self.tempArray removeAllObjects];
    }
}

@end
