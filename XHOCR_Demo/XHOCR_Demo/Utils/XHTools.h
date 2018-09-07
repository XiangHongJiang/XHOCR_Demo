//
//  XHTools.h
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHTools : NSObject
/**
 *  二代身份证校验算法
 */
+ (BOOL)isIdentityNumValid:(NSString *)identityNum;
/** 根据身份证号获取生日 */
+(NSString *)birthdayStr:(NSString *)dataStr;
@end
