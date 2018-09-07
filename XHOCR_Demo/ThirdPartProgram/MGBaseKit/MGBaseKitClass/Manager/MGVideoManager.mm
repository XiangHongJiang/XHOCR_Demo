//
//  MGVideoManager.m
//  MGLivenessDetection
//
//  Created by megvii on 16/3/31.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import "MGVideoManager.h"
#import "MGMovieRecorder.h"

//屏幕宽度 （区别于viewcontroller.view.fream）
#define MG_WIN_WIDTH  [UIScreen mainScreen].bounds.size.width
//屏幕高度 （区别于viewcontroller.view.fream）
#define MG_WIN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MGVideoManager () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MovieRecorderDelegate>
{
    AVCaptureConnection *_audioConnection;
    AVCaptureConnection *_videoConnection;
    NSDictionary        *_audioCompressionSettings;
    AVCaptureDevice     *_videoDevice;
    
    dispatch_queue_t _videoQueue;
}

@property (nonatomic, assign) CMFormatDescriptionRef outputAudioFormatDescription;
@property (nonatomic, assign) CMFormatDescriptionRef outputVideoFormatDescription;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, copy) NSString *tempVideoPath;

@property (nonatomic, strong) MGMovieRecorder *movieRecorder;

@property (nonatomic, assign) BOOL videoRecord;
@property (nonatomic, assign) BOOL videoSound;
@property (nonatomic, assign) BOOL startRecord;

@end

@implementation MGVideoManager

-(void)dealloc {
    [_movieRecorder stopRecording];
    _movieRecorder = nil;
    _audioConnection = nil;
    _videoConnection = nil;
    self.videoDelegate = nil;
    self.sessionPreset = nil;
}

-(instancetype)initWithPreset:(NSString *)sessionPreset
               devicePosition:(AVCaptureDevicePosition)devicePosition
                  videoRecord:(BOOL)record
                   videoSound:(BOOL)sound{
    self = [super init];
    if (self) {
        self.sessionPreset = sessionPreset;
        _devicePosition = devicePosition;
        self.videoRecord = record;
        self.videoSound = sound;
        
        self.startRecord = NO;
        _videoQueue = dispatch_queue_create("com.megvii.face.video", NULL);
        
        NSString *mediaType = AVMediaTypeVideo;
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (NO == granted) {
                [self videoError:MGVideoErrorNOPermission];
                [self stopRunning];
            }
        }];
    }
    return self;
}

+ (instancetype)videoPreset:(NSString *)sessionPreset
             devicePosition:(AVCaptureDevicePosition)devicePosition
                videoRecord:(BOOL)record
                 videoSound:(BOOL)sound{
    
    MGVideoManager *manager = [[MGVideoManager alloc] initWithPreset:sessionPreset
                                                      devicePosition:devicePosition
                                                         videoRecord:record
                                                          videoSound:sound];
    return manager;
}

#pragma mark - Default Video Config
- (NSString *)sessionPreset {
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPreset640x480;
    }
    return _sessionPreset;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (nil == _videoPreviewLayer) {
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoSession];
        [_videoPreviewLayer setFrame:CGRectMake(0, 0, MG_WIN_WIDTH, MG_WIN_HEIGHT)];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _videoPreviewLayer;
}

- (AVCaptureVideoPreviewLayer *)videoPreview{
    return self.videoPreviewLayer;
}

- (CMFormatDescriptionRef)formatDescription{
    return self.outputVideoFormatDescription;
}

- (dispatch_queue_t)getVideoQueue{
    return _videoQueue;
}

- (BOOL)videoSound{
    if (_videoRecord && _videoSound) {
        return YES;
    }
    return NO;
}

#pragma mark - VideoOperation
- (void)startRunning {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted ||
       authStatus == AVAuthorizationStatusDenied) {
        [self videoError:MGVideoErrorNOPermission];
        return;
    }
    [self initialSession];
    
    if (self.videoSession) {
        [self.videoSession startRunning];
    }
}

- (void)stopRunning {
    if (self.videoSession) {
        [self.videoSession stopRunning];
    }
}

- (void)startRecording {
    [self startRunning];
    
    if (!self.videoRecord) {
        return;
    }
    _startRecord = YES;
}

- (NSString *)stopRceording {
    _startRecord = NO;
    
    if (self.movieRecorder) {
        if (self.movieRecorder.status == MovieRecorderStatusRecording) {
            [self.movieRecorder finishRecording];
        }
        [self.movieRecorder stopRecording];
        self.movieRecorder = nil;
    }
    
    return _tempVideoPath ? _tempVideoPath : nil;
}

#pragma mark - Init session
- (void)initialSession {
    if (!self.videoSession) {
        //  session
        _videoSession = [[AVCaptureSession alloc] init];
        //  Camera
        _videoDevice = [self cameraWithPosition:self.devicePosition];
        [self setMaxVideoFrame:60 videoDevice:_videoDevice];
        
        // input
        NSError *DeviceError;
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&DeviceError];
        if (DeviceError) {
            [self videoError:MGVideoErrorNODevice];
            return;
        }
        if ([self.videoSession canAddInput:self.videoInput]) {
            [self.videoSession addInput:self.videoInput];
        }
        
        //  output
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setSampleBufferDelegate:self queue:_videoQueue];
        output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        output.alwaysDiscardsLateVideoFrames = NO;
        
        if ([self.videoSession canAddOutput:output]) {
            [self.videoSession addOutput:output];
        }
        
        //  sessionPreset
        if ([self.videoSession canSetSessionPreset:self.sessionPreset]) {
            [self.videoSession setSessionPreset: self.sessionPreset];
        } else {
            [self videoError:MGVideoErrorNOPermission];
            return;
        }
        
        _videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
        _videoConnection.videoOrientation = self.videoOrientation;
        
        //  Setting Video sound
        if (self.videoSound) {
            AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
            if ([self.videoSession canAddInput:audioIn]) {
                [self.videoSession addInput:audioIn];
            }
            
            AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
            dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.megvii.audio", DISPATCH_QUEUE_SERIAL );
            [audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
            if ([self.videoSession canAddOutput:audioOut]) {
                [self.videoSession addOutput:audioOut];
            }
            _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
            output.alwaysDiscardsLateVideoFrames = YES;
            
            _audioCompressionSettings = [[audioOut recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
        }
    }
}

#pragma mark - InitVideoRecord
- (void)initVideoRecord:(CMFormatDescriptionRef)formatDescription {
    if (!self.movieRecorder) {
        NSString *moveName = [NSString stringWithFormat:@"%@.mov", [[NSDate date] description]];
        _tempVideoPath = [NSString pathWithComponents:@[NSTemporaryDirectory(), moveName]];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:_tempVideoPath];
        dispatch_queue_t callbackQueue = dispatch_queue_create("com.megvii.recordercallback", DISPATCH_QUEUE_SERIAL);
        
        self.movieRecorder = [[MGMovieRecorder alloc] initWithURL:url];
        [self.movieRecorder setDelegate:self callbackQueue:callbackQueue];
        
        CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)UIDeviceOrientationPortrait withAutoMirroring:NO];
        
        [self.movieRecorder addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription
                                                           transform:videoTransform
                                                            settings:nil];
        
        if (self.videoSound) {
            [self.movieRecorder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription
                                                                settings:_audioCompressionSettings];
        }
    }
    [self.movieRecorder prepareToRecord];
}

#pragma mark - Camera Device
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - Toggle Camera
- (void)toggleCamera:(id)sender {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
        } else {
            return;
        }
        
        if (newVideoInput) {
            [self.videoSession beginConfiguration];
            [self.videoSession removeInput:self.videoInput];
            if ([self.videoSession canAddInput:newVideoInput]) {
                [self.videoSession addInput:newVideoInput];
                _videoInput = newVideoInput;
            } else {
                [self.videoSession addInput:self.videoInput];
            }
            [self.videoSession commitConfiguration];
        } else if (error) {
            [self videoError:MGVideoErrorNODevice];
        }
    }
}

#pragma mark - MaxVideoFrame
- (void)setMaxVideoFrame:(NSInteger)frame videoDevice:(AVCaptureDevice *)videoDevice{
    for(AVCaptureDeviceFormat *vFormat in [videoDevice formats]) {
        CMFormatDescriptionRef description= vFormat.formatDescription;
        AVFrameRateRange *rateRange = (AVFrameRateRange*)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0];
        float maxrate = rateRange.maxFrameRate;
        
        if(maxrate >= frame && CMFormatDescriptionGetMediaSubType(description)==kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            if (YES == [videoDevice lockForConfiguration:NULL]) {
                videoDevice.activeFormat = vFormat;
                [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, int32_t(frame / 3))];
                [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, int32_t(frame))];
                [videoDevice unlockForConfiguration];
            }
        }
    }
}

#pragma mark - Video
- (void)appendVideoBuffer:(CMSampleBufferRef)sampleBuffer {
    @synchronized(self) {
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
        if (_startRecord == YES && !self.movieRecorder) {
            [self initVideoRecord:formatDescription];
        }
        
        if (self.movieRecorder) {
            [self.movieRecorder appendVideoSampleBuffer:sampleBuffer];
        }
    }
}

- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer {
    @synchronized(self) {
        if (self.movieRecorder) {
            [self.movieRecorder appendAudioSampleBuffer:sampleBuffer];
        }
    }
}

- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)orientation withAutoMirroring:(BOOL)mirror {
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat orientationAngleOffset = MGAngleOffsetFromPortraitOrientationToOrientation(orientation);
    CGFloat videoOrientationAngleOffset = MGAngleOffsetFromPortraitOrientationToOrientation(self.videoOrientation);
    
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    //    transform = CGAffineTransformRotate(transform, -M_PI);
    
    if (_videoDevice.position == AVCaptureDevicePositionFront) {
        if (mirror) {
            transform = CGAffineTransformScale(transform, -1, 1);
        } else {
            transform = CGAffineTransformRotate(transform, M_PI);
        }
    }
    return transform;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    @autoreleasepool {
        if (connection == _videoConnection) {
            if (!self.outputVideoFormatDescription) {
                CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                self.outputVideoFormatDescription = (CMFormatDescriptionRef)formatDescription;
            }
            if (_videoDelegate && [_videoDelegate respondsToSelector:@selector(MGCaptureOutput:didOutputSampleBuffer:fromConnection:)]) {
                [_videoDelegate MGCaptureOutput:captureOutput
                          didOutputSampleBuffer:sampleBuffer
                                 fromConnection:connection];
            }
            if (self.videoRecord && self.startRecord) {
                [self appendVideoBuffer:sampleBuffer];
            }
        } else if (connection == _audioConnection) {
            if (nil == self.outputAudioFormatDescription) {
                CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                self.outputAudioFormatDescription = (CMFormatDescriptionRef)formatDescription;
            }
            
            //            if (_videoDelegate && [_videoDelegate respondsToSelector:@selector(MGCaptureOutput:didOutputAudioBuffer:fromConnection:)]) {
            //                [self.videoDelegate MGCaptureOutput:captureOutput didOutputAudioBuffer:sampleBuffer fromConnection:connection];
            //            }
            
            if (self.videoRecord && self.startRecord) {
                [self appendAudioBuffer:sampleBuffer];
            }
        }
    }
}

#pragma mark - MovieRecorderDelegate
- (void)movieRecorder:(MGMovieRecorder *)recorder didFailWithError:(NSError *)error {
    NSLog(@"Recorder error:%@", error);
}

- (void)movieRecorderDidFinishPreparing:(MGMovieRecorder *)recorder {
    NSLog(@"Recorder Preparing");
}

-(void)movieRecorderDidFinishRecording:(MGMovieRecorder *)recorder {
    NSLog(@"Recorder finish");
}


#pragma mark - MGVideoDelegate
- (void)videoError:(MGVideoErrorType)error {
    if (_videoDelegate && [_videoDelegate respondsToSelector:@selector(MGCaptureOutput:error:)]) {
        [self.videoDelegate MGCaptureOutput:nil error:error];
    }
}

@end
