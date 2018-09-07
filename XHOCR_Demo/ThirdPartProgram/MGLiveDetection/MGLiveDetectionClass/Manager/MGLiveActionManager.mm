//
//  MGFaceActionManager.m
//  MGFaceDetection
//
//  Created by megvii on 15/12/24.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGLiveActionManager.h"

@interface MGLiveActionManager ()

@property (nonatomic, strong) NSMutableArray *tempActionArray;

/**
 *  指定活体动作，包括顺序
 */
@property (nonatomic, strong) NSMutableArray *actionArray;

/**
 *  是否动作随机
 */
@property (nonatomic, assign) BOOL randomAction;

/**
 *  活体动作数量 最大设置为 4;
 */
@property (nonatomic, assign) NSUInteger liveActionCount;

@end

@implementation MGLiveActionManager

#pragma mark - Init and Dealloc
- (void)dealloc {
    self.tempActionArray = nil;
    self.actionArray = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.randomAction = YES;
    }
    return self;
}

- (instancetype)initWithActionRandom:(BOOL)actionRandom actionArray:(NSArray *)actionArray actionCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        self.randomAction = actionRandom;
        self.liveActionCount = count;
        
        if (self.randomAction == NO) {
            self.actionArray = [[NSMutableArray alloc] initWithArray:actionArray];
            
            if (self.actionArray == nil || self.actionArray.count < count) {
                NSAssert(NO, @"请检查actionManager 初始化设置");
                NSMutableArray* defaultActionArray = [[NSMutableArray alloc] initWithCapacity:count];
                for (int i = 0; i < count; i++) {
                    [defaultActionArray addObject:[NSNumber numberWithInteger:i + 1]];
                }
                self.actionArray = nil;
                self.actionArray = [[NSMutableArray alloc] initWithArray:defaultActionArray];
            }
        }
    }
    return self;
}

+ (instancetype)LiveActionRandom:(BOOL)actionRandom
                     actionArray:(NSArray *)actionArray
                     actionCount:(NSUInteger)count {
    MGLiveActionManager *manager = [[MGLiveActionManager alloc] initWithActionRandom:actionRandom
                                                                         actionArray:actionArray
                                                                         actionCount:count];
    return manager;
}

#pragma mark - Setter and Getter
- (void)setActionArray:(NSMutableArray *)actionArray {
    _actionArray = actionArray;
    if (_actionArray) {
        [self.tempActionArray removeAllObjects];
        self.tempActionArray = nil;
        self.tempActionArray = [NSMutableArray arrayWithArray:_actionArray];
    }
}

- (NSUInteger)getActionCount {
    return self.liveActionCount;
}

#pragma mark - Header Api
- (void)resetAction {
    self.tempActionArray = nil;

    NSArray *tempArray = self.actionArray;
    if (tempArray && self.randomAction == NO) {
        self.tempActionArray = [NSMutableArray arrayWithArray:tempArray];
    } else {
        self.tempActionArray = [NSMutableArray arrayWithObjects:@1, @2, @3, @4, nil];
    }
}


- (MGLivenessDetectionType)randomActionType {
    NSAssert(self.tempActionArray.count <= 4, @"动作数量超出限制，最多4个。请检查动作检测器设置!");
    
    NSInteger type = self.randomAction ? arc4random() % self.tempActionArray.count : 0;
    MGLivenessDetectionType detectionType = (MGLivenessDetectionType)[self.tempActionArray[type] integerValue];
    [self.tempActionArray removeObjectAtIndex:type];
    
    return detectionType;
}

- (MGLivenessDetectionType)resetAndRandomActionType {
    [self resetAction];
    return [self randomActionType];
}

@end
