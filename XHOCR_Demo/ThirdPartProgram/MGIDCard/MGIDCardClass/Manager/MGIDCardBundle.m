//
//  MGIDCardBundle.m
//  MGIDCard
//
//  Created by 张英堂 on 15/12/28.
//  Copyright © 2015年 megvii. All rights reserved.
//

#import "MGIDCardBundle.h"

static NSString *const IDCardBundleKey  = @"MGIDCardResource.bundle";
static NSString *const IDCardBundleName = @"MGIDCardResource";
static NSString *const IDCardBundleType = @"bundle";
static NSString *const IDCardStringKey  = @"MGIDCard";

@implementation MGIDCardBundle

+ (NSString *)IDCardPathForResource:(NSString *)name ofType:(NSString *)type {
    return  [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:IDCardBundleKey];
}

+ (NSString *)MGIDBundleString:(NSString *)key {
    NSBundle *mgBundel = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:IDCardBundleName ofType:IDCardBundleType]];
    NSString *testString = NSLocalizedStringFromTableInBundle(key, IDCardStringKey, mgBundel, nil);
    return testString;
}

+ (UIImage *)IDCardImageWithName:(NSString *)name {
    NSString *imagePath = [MGIDCardBundle IDCardPathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

@end
