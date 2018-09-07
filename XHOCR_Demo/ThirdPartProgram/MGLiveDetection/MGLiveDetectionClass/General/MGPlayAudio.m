//
//  ImhtPlayAudio.m
//  text
//
//  Created by imht-ios on 14-5-21.
//  Copyright (c) 2014Year ymht. All rights reserved.
//

#import "MGPlayAudio.h"
#import <AVFoundation/AVFoundation.h>
#import "MGLiveBundle.h"

@interface MGPlayAudio () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) BOOL nextPlayGod;
@property (nonatomic, copy) NSString *nextPlayName;

@end

@implementation MGPlayAudio

#pragma mark - Init
+ (id)sharedAudioPlayer {
    static MGPlayAudio *audioPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[MGPlayAudio alloc] init];
    });
    return audioPlayer;
}

#pragma mark - Operation
- (void)play {
    [self.audioPlayer stop];
    [self.audioPlayer play];
}

- (void)stop {
    [self.audioPlayer stop];
}

- (void)playWithFileName:(NSString *)name{
    self.nextPlayGod = NO;
    NSString *path = [MGLiveBundle LivePathForResource:name ofType:@"mp3"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self setplayData:data];
}

- (void)playWithFileName:(NSString *)name finishNext:(BOOL)finish {
    self.nextPlayGod = finish;
    NSString *tempName = nil;
    if (finish) {
        tempName = @"meglive_well_done";
        self.nextPlayName = name;
    } else {
        tempName = name;
    }
    
    NSString *path = [MGLiveBundle LivePathForResource:tempName ofType:@"mp3"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self setplayData:data];
}

- (void)setplayData:(NSData *)data {
    NSError *error;
    if (self.audioPlayer != nil) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [self.audioPlayer setDelegate:self];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)setplayURL:(NSURL *)url {
    NSError *error;
    if (self.audioPlayer != nil) {
        self.audioPlayer = nil;
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [self.audioPlayer prepareToPlay];
}

- (void)cancelAllPlay {
    self.nextPlayName = nil;
    self.nextPlayGod = NO;
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag { 
    if (self.nextPlayGod) {
        [self playWithFileName:self.nextPlayName];
    }
}

@end
