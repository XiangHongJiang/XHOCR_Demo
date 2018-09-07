//
//  MGAnimation.h
//  MGBankCard
//
//  Created by megvii on 15/12/11.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MGAnimation : NSObject

/**
 *  一闪一闪的动画
 *
 *  @return 动画
 */
+ (CABasicAnimation *)animationWithOpacity;

@end
