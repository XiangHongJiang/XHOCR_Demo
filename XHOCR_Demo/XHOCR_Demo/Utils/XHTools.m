//
//  XHTools.m
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "XHTools.h"

@implementation XHTools
/**
 *  二代身份证校验算法
 */
+ (BOOL)isIdentityNumValid:(NSString *)identityNum {
    
    //先正则匹配位数
    NSString *IdentityNum = identityNum;
    NSString *id_num = @"^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$|^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$";
    BOOL is_idthere = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", id_num];
    is_idthere = [predicate evaluateWithObject:IdentityNum];
    
    if (!is_idthere) return NO;
    return YES;
}
/** 根据身份证号获取生日 */
+(NSString *)birthdayStr:(NSString *)dataStr {
    
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSString *year = nil;
    NSString *month = nil;
    
    BOOL isAllNumber = YES;
    NSString *day = nil;
    if([dataStr length]<14)
        return result;
    
    //**截取前14位
    NSString *fontNumer = [dataStr substringWithRange:NSMakeRange(0, 13)];
    
    //**检测前14位否全都是数字;
    const char *str = [fontNumer UTF8String];
    const char *p = str;
    while (*p!='\0') {
        if(!(*p>='0'&&*p<='9'))
            isAllNumber = NO;
        p++;
    }
    
    if(!isAllNumber)
        return result;
    
    year = [dataStr substringWithRange:NSMakeRange(6, 4)];
    month = [dataStr substringWithRange:NSMakeRange(10, 2)];
    day = [dataStr substringWithRange:NSMakeRange(12,2)];
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    return result;
}

@end
