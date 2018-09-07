//
//  MGRBDMuteSwitch.h
//  MGRBDMuteSwitchExample
//
//  Created by Richard Hyland on 18/04/2012.
//  Copyright (c) 2012 RBDSolutions Limited. All rights reserved.
//

/** This class detects whether the device is muted including under iOS 5.
 You should use the sharedInstance to get an instance and implement the isMuted: delegate method.
 
 Example
 [[MGRBDMuteSwitch sharedInstance] setDelegate:self];
 [[MGRBDMuteSwitch sharedInstance] detectMuteSwitch];
 
 - (void)isMuted:(BOOL)muted {
 }
 */

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol MGRBDMuteSwitchDelegate
@optional
- (void)isMuted:(BOOL)muted;
@end

@class MGRBDMuteSwitch;

@interface MGRBDMuteSwitch : NSObject
{
    float soundDuration;
    NSTimer *playbackTimer;
}

@property (nonatomic, assign) id <MGRBDMuteSwitchDelegate> delegate;

+ (MGRBDMuteSwitch *)sharedInstance;

- (void)detectMuteSwitch;

@end
