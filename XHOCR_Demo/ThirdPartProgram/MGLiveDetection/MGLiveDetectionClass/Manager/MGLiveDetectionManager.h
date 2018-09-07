//
//  MGLiveDetectionManager.h
//  MGLivenessDetection
//
//  Created by megvii on 16/3/29.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "MGLiveDetectionDelegate.h"
#import "MGLiveConfig.h"

@class MGLiveErrorManager;
@class MGLiveActionManager;

@protocol MGLiveDetectionDelegate;

/**
 *  活体检测管理器，需要配置 动作管理器，错误提示管理器
 */
@interface MGLiveDetectionManager : NSObject

@property (nonatomic, assign) id <MGLiveDetectionDelegate> delegate;

/**
 *  活体检测线程，外部指定，否则随机生成（目前该方法无效）
 */
@property (nonatomic, strong) dispatch_queue_t detectionQueue;

/**
 *  在质量检测阶段，根据每一帧错误，显示该提示的信息
 */
@property (nonatomic, strong, readonly) MGLiveErrorManager *errorManager;

/**
 *  活体检测模式，默认 全部流程。
 */
@property (nonatomic, assign) MGLiveDetectionType detectionType;

/**
 *  活体检测当前步骤
 */
@property (nonatomic, assign, readonly) MGLiveStep currentLiveStep;

/**
 *  初始化方法 不推荐使用
 *
 *  @param timeOut       每个活体动作超时时间
 *  @param actionManager 动作管理器
 *
 *  @return 实例化对象
 */
- (instancetype)initWithActionTimeOut:(NSUInteger)timeOut
                     andActionManager:(MGLiveActionManager *)actionManager DEPRECATED_ATTRIBUTE;

/**
 *  初始化方法，请使用该方法初始化
 *
 *  @param timeOut       每个活体动作超时时间  
 *  @param actionManager 动作管理器
 *  @param errorManager  错误提示管理器
 *
 *  @return 实例化对象
 */
- (instancetype)initWithActionTime:(NSUInteger)timeOut
                     actionManager:(MGLiveActionManager *)actionManager
                      errorManager:(MGLiveErrorManager *)errorManager;

/**
 *  检测每一帧 CMSampleBufferRef
 *
 *  @param buffer      CMSampleBufferRef
 *  @param orientation 图片旋转信息
 */
- (void)detectionWithSampleBuffer:(CMSampleBufferRef)buffer
                      orientation:(UIImageOrientation)orientation;

/**
 *  开启检测
 */
- (void)starDetection;

/**
 *  停止检测，只有在照镜子模式下有用
 */
- (void)stopDetectionQuality;

/**
 *  停止活体检测
 */
- (void)stopDetection;

#pragma mark - 活体结束后获取数据
/**
 *  当活体检测结束后获得过程中间采集的高质量图片样本
 *
 *  @return 活体检测过程中，每个动作产生一张人脸。其中如果一个动作过程中有质量合格的人脸，则输出质量合格的。否则就输出质量相对最好的一张。
 */
- (NSArray*)getValidFrame;
- (FaceIDData*)getFaceIDDataWithMaxImageSize:(int)maxSize;
- (FaceIDData*)getFaceIDData;

/**
 *  获取照镜子阶段最好的图片(目前只在 只有照镜子的模式有用)
 *
 *  @return 人脸frame
 */
- (MGLivenessDetectionFrame *)getBestQualityFrame;

/**
 *  获取算法日志（如有需要可调用）
 *
 *  @return 活体检测算法日志
 */
- (NSString*)getAlgorithmLog;

@end
