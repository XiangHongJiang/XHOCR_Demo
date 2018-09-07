//
//  MGVideoDelegate.h
//  MGBaseKit
//
//  Created by Megvii on 2017/4/18.
//  Copyright © 2017Year megvii. All rights reserved.
//

#ifndef MGVideoDelegate_h
#define MGVideoDelegate_h
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    MGVideoErrorNOPermission        = 100,
    MGVideoErrorNOSessionPreset,
    MGVideoErrorNODevice,
} MGVideoErrorType;

@protocol MGVideoDelegate <NSObject>

@required
- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput
  didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection *)connection;

@optional
- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput error:(MGVideoErrorType)error;

@end

#endif /* MGVideoDelegate_h */
