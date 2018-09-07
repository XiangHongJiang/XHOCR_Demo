//
//  NSString+Extension.h
//  XH_MultiFunction_Demo
//
//  Created by MrYeL on 2018/9/5.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (UIImage *)stringToImage;

+ (NSString *)getBankNameByBin:(char *)numbers count:(int)nCount;

+(CGFloat)rangeMaxWithValueMax:(CGFloat)valueMax;

@end
