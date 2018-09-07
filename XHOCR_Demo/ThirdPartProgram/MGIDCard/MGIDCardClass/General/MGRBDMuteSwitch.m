//
//  MGRBDMuteSwitch.m
//  MGRBDMuteSwitchExample
//
//  Created by Richard Hyland on 18/04/2012.
//  Copyright (c) 2012 RBDSolutions Limited. All rights reserved.
//

#import "MGRBDMuteSwitch.h"
#import "MGIDCardBundle.h"
#import "sys/utsname.h"

@implementation MGRBDMuteSwitch

static MGRBDMuteSwitch *_sharedInstance;
+ (MGRBDMuteSwitch *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

static void soundCompletionCallback (SystemSoundID mySSID, void* myself) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    [[MGRBDMuteSwitch sharedInstance] playbackComplete];
}

- (void)playbackComplete {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if (![deviceString isEqualToString:@"iPhone7,2"]) {
        if (soundDuration >= 0.001) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }

    [playbackTimer invalidate];
    playbackTimer = nil;
}

- (void)incrementTimer {
    soundDuration = soundDuration + 0.001;
}

- (void)detectMuteSwitch {
#if TARGET_IPHONE_SIMULATOR
    // The simulator doesn't support detection and can cause a crash so always return muted
//    if (_delegate && [_delegate respondsToSelector:@selector(isMuted:)]) {
//        [self.delegate isMuted:YES];
//    }
    return;
#endif
    soundDuration = 0.0;
    SystemSoundID	soundFileObject;
    NSString *strSoundFile = [MGIDCardBundle IDCardPathForResource:@"detection" ofType:@"aiff"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile], &soundFileObject);
    AudioServicesAddSystemSoundCompletion (soundFileObject,NULL,NULL,
                                           soundCompletionCallback,
                                           (void*) CFBridgingRetain(self));
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.010 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    AudioServicesPlaySystemSound(soundFileObject);
    return;
}

@end
