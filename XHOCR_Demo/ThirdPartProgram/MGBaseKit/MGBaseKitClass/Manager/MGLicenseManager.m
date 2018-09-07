//
//  MGBaseManager.m
//  MGKit
//
//  Created by megvii on 15/12/16.
//  Copyright © 2015Year megvii. All rights reserved.
//

#import "MGLicenseManager.h"
#import "MGBaseDefine.h"

#import "LicenseManager.h"

@implementation MGLicenseManager

+ (BOOL)getLicense {
    return [self getLicenseWithDictionary:nil];
}

+ (BOOL)getLicenseWithDictionary:(NSDictionary *)licenseDictionary {
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    NSDictionary *dictionary = licenseDictionary;
    if (!dictionary) {
        dictionary = [LicenseManager checkCachedLicense];
    }
    NSArray *valueArray = [dictionary allValues];
    if (valueArray.count == 0) {
        return NO;
    }
    
    NSDate *nowDate = [NSDate date];
    __block NSInteger licenseSDK = 0;
    [valueArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *sdkDate = obj;
        
        if ([sdkDate compare:nowDate] == NSOrderedDescending) {
            licenseSDK++;
        }
    }];
    if (licenseSDK == valueArray.count) {
        return YES;
    }
#endif
    return NO;
}

+ (void)licenseForNetWokrFinish:(void(^)(bool License))finish {
#if TARGET_IPHONE_SIMULATOR
    if (finish) {
        finish(YES);
    }
#else
    //联网授权代码
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSDictionary *licenseDic = [LicenseManager takeLicenseFromNetworkWithUUID:uuid];
        MGLog(@"\n*************\n expired at: %@ \n*************\n", licenseDic);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finish) {
                finish([MGLicenseManager getLicenseWithDictionary:licenseDic]);
            }
        });
    });
#endif
}

+ (NSDate *)getLicenseDate {
    return [NSDate dateWithTimeIntervalSince1970:0];
}

@end
