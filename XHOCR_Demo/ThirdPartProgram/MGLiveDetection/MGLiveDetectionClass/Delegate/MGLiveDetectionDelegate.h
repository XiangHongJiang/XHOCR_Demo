//
//  MGLiveDetectionDelegate.h
//  MGLivenessDetection
//
//  Created by Megvii on 2017/5/10.
//  Copyright © 2017Year megvii. All rights reserved.
//

#import "LivenessEnumType.h"
@class MGLiveDetectionManager;
@class MGLivenessDetectionFrame;

/**
 *  活体检测步骤
 */
typedef enum : NSUInteger {
    /**  活体照镜子准备阶段 */
    MGLiveStepQuality = 0,
    /**  活体检测步骤 */
    MGLiveStepDetection,
} MGLiveStep;

/**
 *  活体检测模式
 */
typedef enum : NSUInteger {
    /** 只做照镜子 */
    MGLiveDetectionTypeQualityOnly = 0,
    /** 照镜子步骤+ 活体步骤 */
    MGLiveDetectionTypeAll,
} MGLiveDetectionType;

@protocol MGLiveDetectionDelegate <NSObject>

@required
/**
 *  活体流程某个步骤结束
 *
 *  @param manager 实例化对象
 *  @param step    结束的活体步骤
 */
- (void)detectionManager:(MGLiveDetectionManager *)manager finishWithStep:(MGLiveStep)step;

/**
 *  活体检测完全结束
 *
 *  @param manager 实例化对象
 */
- (void)detectionManagerSucessLiveDetection:(MGLiveDetectionManager *)manager liveDetectionType:(MGLiveDetectionType)detectionType;

/**
 *  每一张图片的检测结果
 *
 *  @param manager 实例化对象
 *  @param frame   每一帧的结果
 */
- (void)detectionManager:(MGLiveDetectionManager *)manager frameWithImage:(MGLivenessDetectionFrame *)frame;

/**
 *  活体检测失败
 *
 *  @param manager    实例化对象
 *  @param failedType 错误类型
 */
- (void)detectionManager:(MGLiveDetectionManager *)manager finishWithError:(MGLivenessDetectionFailedType)failedType;

/**
 *  活体检测每一次动作更新（动作切换既触发该方法）
 *
 *  @param manager    实例化对象
 *  @param actionType 活体动作类型
 *  @param timeOut    该动作超时时间
 *  @param step       当前第几个动作
 */
- (void)detectionManager:(MGLiveDetectionManager *)manager liveChangeAction:(MGLivenessDetectionType)actionType timeOut:(NSUInteger)timeOut currentActionStep:(NSUInteger)step;

/**
 *  照镜子阶段错误返回
 *
 *  @param manager 实例化对象
 *  @param error   错误信息（中文转码）
 */
- (void)detectionManager:(MGLiveDetectionManager *)manager checkError:(NSString *)error;

@end
