//
//  XHOCRVC.m
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "XHOCRVC.h"

#import "XHOCRVC.h"
#import <AVFoundation/AVFoundation.h>
#import "RectManager.h"
#import "exbankcard.h"
#import "excards.h"


@interface XHOCRVC ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic , assign)XHOCRType ocrType;

// 摄像头设备
@property (nonatomic,strong) AVCaptureDevice *device;

// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureSession *session;

// 输出格式
@property (nonatomic,strong) NSNumber *outPutSetting;

// 出流对象
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;

// 元数据（用于人脸识别）
@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;

// 预览图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

// 人脸检测框区域
@property (nonatomic,assign) CGRect faceDetectionFrame;

// 队列
@property (nonatomic,strong) dispatch_queue_t queue;

// 是否打开手电筒
@property (nonatomic,assign,getter = isTorchOn) BOOL torchOn;

@end

@implementation XHOCRVC


- (instancetype)initWithOcrType:(XHOCRType)type{
    if ([super init]) {
        self.ocrType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSession) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSession) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 初始化rect
#if TARGET_IPHONE_SIMULATOR
    
#else
    const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
    int ret = EXCARDS_Init(thePath);
    if (ret != 0) {
        NSLog(@"初始化失败：ret=%d", ret);
    }
#endif
    [self initSubViews];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s dealloc",object_getClassName(self));
}

- (void)initSubViews{
    //    [super initSubViews];
    CardScaningView *scanView = [[CardScaningView alloc] initWithOcrType:self.ocrType];
    [self.view.layer addSublayer:self.previewLayer];
    [self.view addSubview:scanView];
    self.faceDetectionFrame = scanView.facePathRect;
    self.navigationItem.title = self.ocrType != XHOCRTypeBank ? @"扫描身份证" : @"扫描银行卡";
    [self addCloseButton];
}

#pragma mark device
-(AVCaptureDevice *)device {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            if ([_device isSmoothAutoFocusSupported]) {// 平滑对焦
                _device.smoothAutoFocusEnabled = YES;
            }
            
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                _device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            //            NSError *error1;
            //            CMTime frameDuration = CMTimeMake(1, 30); // 默认是1秒30帧
            //            NSArray *supportedFrameRateRanges = [_device.activeFormat videoSupportedFrameRateRanges];
            //            BOOL frameRateSupported = NO;
            //            for (AVFrameRateRange *range in supportedFrameRateRanges) {
            //                if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            //                    frameRateSupported = YES;
            //                }
            //            }
            //
            //            if (frameRateSupported && [self.device lockForConfiguration:&error1]) {
            //                [_device setActiveVideoMaxFrameDuration:frameDuration];
            //                [_device setActiveVideoMinFrameDuration:frameDuration];
            ////                [self.device unlockForConfiguration];
            //            }
            
            [_device unlockForConfiguration];
        }
    }
    
    return _device;
}

#pragma mark outPutSetting
-(NSNumber *)outPutSetting {
    if (_outPutSetting == nil) {
        _outPutSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    
    return _outPutSetting;
}

#pragma mark metadataOutput
-(AVCaptureMetadataOutput *)metadataOutput {
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
    
    return _metadataOutput;
}

#pragma mark videoDataOutput
-(AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outPutSetting};
        
        [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
    }
    
    return _videoDataOutput;
}

#pragma mark session
-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        // 2、设置输入：由于模拟器没有摄像头，因此最好做一个判断
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
        if (error) {
            [self showAuthorizationRestricted];
        }else {
            if ([_session canAddInput:input]) {
                [_session addInput:input];
            }
            
            if ([_session canAddOutput:self.videoDataOutput]) {
                [_session addOutput:self.videoDataOutput];
            }
            if (self.ocrType == XHOCRTypeFace) {
                if ([_session canAddOutput:self.metadataOutput]) {
                    [_session addOutput:self.metadataOutput];
                    // 输出格式要放在addOutPut之后，否则奔溃
                    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
                }
            }
        }
    }
    
    return _session;
}

#pragma mark previewLayer
-(AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        
        _previewLayer.frame = self.view.frame;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

#pragma mark queue
-(dispatch_queue_t)queue {
    if (_queue == nil) {
        _queue = dispatch_queue_create("AVCaptureSession_Start_Running_Queue", DISPATCH_QUEUE_SERIAL);
        //        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _queue;
}

#pragma mark - 运行session
// session开始，即输入设备和输出设备开始数据传递
- (void)runSession {
    if (![self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
    }
}

#pragma mark - 停止session
// session停止，即输入设备和输出设备结束数据传递
-(void)stopSession {
    if ([self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session stopRunning];
        });
    }
}

#pragma mark - 打开／关闭手电筒
-(void)turnOnOrOffTorch {
    self.torchOn = !self.isTorchOn;
    
    if ([self.device hasTorch]){ // 判断是否有闪光灯
        [self.device lockForConfiguration:nil];// 请求独占访问硬件设备
        
        if (self.isTorchOn) {
            //            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_on"] originalImage];
            [self.device setTorchMode:AVCaptureTorchModeOn];
        } else {
            //            self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] originalImage];
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }
        [self.device unlockForConfiguration];// 请求解除独占访问硬件设备
    }else {
        //        [TBAlert showWithTitle:@"提示" message:@"您的设备没有闪光设备，不能提供手电筒功能，请检查"];
    }
}

#pragma mark - view即将出现时
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 将AVCaptureViewController的navigationBar调为透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    // 每次展现AVCaptureViewController的界面时，都检查摄像头使用权限
    [self checkAuthorizationStatus];
    // rightBarButtonItem设为原样
    self.torchOn = NO;
    //    self.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"nav_torch_off"] originalImage];
}

#pragma mark - view即将消失时
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 将AVCaptureViewController的navigationBar调为不透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    [self stopSession];
}
#pragma mark - 添加关闭按钮
-(void)addCloseButton {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [closeBtn setImage:[UIImage imageNamed:@"ic_alert_close"] forState:UIControlStateNormal];
    CGFloat closeBtnWidth = 50;
    CGFloat closeBtnHeight = closeBtnWidth;
    CGRect viewFrame = self.view.frame;
    closeBtn.frame = (CGRect){CGRectGetMaxX(viewFrame) - closeBtnWidth, CGRectGetMaxY(viewFrame) - closeBtnHeight - 15, closeBtnWidth, closeBtnHeight};
    
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:closeBtn];
}

#pragma mark 绑定“关闭按钮”的方法
-(void)close {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - 检测摄像头权限
-(void)checkAuthorizationStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break; // 请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权。
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break; // 拒绝授权
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备。
    }
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak __typeof__(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        granted? [weakSelf runSession]: [weakSelf showAuthorizationDenied];
    }];
}

-(void)showAuthorizationAuthorized {
    [self runSession];
}

-(void)showAuthorizationDenied {
    //    [self showAlertWithSureTitle:@"前往" cancleTitle:@"取消" alertTitle:@"" message:@"请您设置允许APP访问您的相机\n设置>隐私>相机" sureAction:^{
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    //    }];
}

- (void)showAuthorizationRestricted{
    //    [TBAlert showWithTitle:@"提示" message:@"您的手机不支持摄像"];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
#pragma mark 从输出的元数据中捕捉人脸
// 检测人脸是为了获得“人脸区域”，做“人脸区域”与“身份证人像框”的区域对比，当前者在后者范围内的时候，才能截取到完整的身份证图像
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        
        AVMetadataObject *transformedMetadataObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        CGRect faceRegion = transformedMetadataObject.bounds;
        
        if (metadataObject.type == AVMetadataObjectTypeFace) {
            //            NSLog(@"是否包含头像：%d, facePathRect: %@, faceRegion: %@",CGRectContainsRect(self.faceDetectionFrame, faceRegion),NSStringFromCGRect(self.faceDetectionFrame),NSStringFromCGRect(faceRegion));
            
            if (CGRectContainsRect(self.faceDetectionFrame, faceRegion)) {// 只有当人脸区域的确在小框内时，才再去做捕获此时的这一帧图像
                // 为videoDataOutput设置代理，程序就会自动调用下面的代理方法，捕获每一帧图像
                if (!self.videoDataOutput.sampleBufferDelegate) {
                    [self.videoDataOutput setSampleBufferDelegate:self queue:self.queue];
                }
            }
        }
    }
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
// AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.ocrType == XHOCRTypeBank)
    {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVBufferRetain(imageBuffer);
        if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
            [self parseBankImageBuffer:imageBuffer];
        }
        CVBufferRelease(imageBuffer);
        
        return;
    }
    
    if ([self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if ([captureOutput isEqual:self.videoDataOutput]) {
            // 身份证信息识别
            
            // 身份证信息识别完毕后，就将videoDataOutput的代理去掉，防止频繁调用AVCaptureVideoDataOutputSampleBufferDelegate方法而引起的“混乱”
            if (self.ocrType == XHOCRTypeFace) {
                if (self.videoDataOutput.sampleBufferDelegate) {
                    [self.videoDataOutput setSampleBufferDelegate:nil queue:self.queue];
                }
            }
            [self IDCardRecognit:imageBuffer];
        }
    } else {
        NSLog(@"输出格式不支持");
    }
}

#pragma mark - 身份证信息识别

- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer {
#if TARGET_IPHONE_SIMULATOR
#else
    CVBufferRetain(imageBuffer);
    
    // Lock the image buffer
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
        
        CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
        size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
        unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        unsigned char* pixelAddress = baseAddress + offset;
        
        static unsigned char *buffer = NULL;
        if (buffer == NULL) {
            buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        }
        
        memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
        
        unsigned char pResult[1024];
        int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
        if (ret <= 0) {
            //            NSLog(@"ret=[%d]", ret);
        } else {
            NSLog(@"ret=[%d]", ret);
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            if ([self.session isRunning]) {
                [self.session stopRunning];
            }
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            XHOCRInfo *iDInfo = [XHOCRInfo new];
            
            ctype = pResult[i++];
            
            iDInfo.type = self.ocrType;
            while(i < ret){
                ctype = pResult[i++];
                for(xlen = 0; i < ret; ++i){
                    if(pResult[i] == ' ') { ++i; break; }
                    content[xlen++] = pResult[i];
                }
                
                content[xlen] = 0;
                
                if(xlen) {
                    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    if(ctype == 0x21) {
                        iDInfo.idCardNumber = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                        
                        if ([XHTools isIdentityNumValid:iDInfo.idCardNumber]) {
                            iDInfo.birthday = [XHTools birthdayStr:iDInfo.idCardNumber];
                        }
                        
                    } else if(ctype == 0x22) {
                        iDInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x23) {
                        iDInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x24) {
                        iDInfo.race = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x25) {
                        iDInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x26) {
                        iDInfo.issuedBy = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x27) {
                        iDInfo.validDate = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    }
                }
            }
            
            if (iDInfo) {// 读取到身份证信息，实例化出IDInfo对象后，截取身份证的有效区域，获取到图像
                NSLog(@"\n正面\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",iDInfo.name,iDInfo.gender,iDInfo.race,iDInfo.address,iDInfo.idCardNumber,iDInfo.issuedBy,iDInfo.validDate);
                CGRect effectRect = [RectManager getEffectImageRect:CGSizeMake(width, height)];
                CGRect rect = [RectManager getGuideFrame:effectRect];
                
                UIImage *image = [UIImage getImageStream:imageBuffer];
                UIImage *subImage = [UIImage getSubImage:rect inImage:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 扫描完成
                    iDInfo.cropImage = subImage;
                    [self didScanSucActionWithIdInfo:iDInfo];
                });
            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    
    CVBufferRelease(imageBuffer);
#endif
}


- (void)parseBankImageBuffer:(CVImageBufferRef)imageBuffer
{
#if TARGET_IPHONE_SIMULATOR
#else
    size_t width_t= CVPixelBufferGetWidth(imageBuffer);
    size_t height_t = CVPixelBufferGetHeight(imageBuffer);
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    if (!planar) {
        NSLog(@"1111111111");
        return;
    }
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    
    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;
    
    size_t cbCrOffset = NSSwapBigIntToHost(planar->componentInfoCbCr.offset);
    uint8_t *cbCrBuffer = baseAddress + cbCrOffset;
    
    CGSize size = CGSizeMake(width_t, height_t);
    CGRect effectRect = [RectManager getEffectImageRect:size];
    CGRect rect = [RectManager getGuideFrame:effectRect];
    
    int width = ceilf(width_t);
    int height = ceilf(height_t);
    
    unsigned char result [512];
    int resultLen = BankCardNV12(result, 512, pixelAddress, cbCrBuffer, width, height, rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    if(resultLen > 0) {
        
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
        
        
        int charCount = [RectManager docode:result len:resultLen];
        if(charCount > 0) {
            
            //            CGRect subRect = [WYRectManager getCorpCardRect:width height:height guideRect:rect charCount:charCount];
            //            UIImage *image = [UIImage getImageStream:imageBuffer];
            //            __block UIImage *subImg = [UIImage getSubImage:subRect inImage:image];
            
            
            char *numbers = [RectManager getNumbers];
            
            NSString *numberStr = [NSString stringWithCString:numbers encoding:NSASCIIStringEncoding];
            NSString *bank = [NSString getBankNameByBin:numbers count:charCount];
            
            XHOCRInfo *model = [XHOCRInfo new];
            
            model.bankNo = numberStr;
            model.bankName = bank;
            
            CGSize size = CGSizeMake(width, height);
            CGRect effectRect = [RectManager getEffectImageRect:size];
            CGRect rect = [RectManager getGuideFrame:effectRect];
            UIImage *image = [UIImage getImageStream:imageBuffer];
            UIImage *subImg = [UIImage getSubImage:rect inImage:image];
            
            model.cropImage = subImg;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [self didScanSucActionWithIdInfo:model];
            });
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
#endif
}


- (void)didScanSucActionWithIdInfo:(XHOCRInfo *)iDInfo{
    switch (self.ocrType) {
        case XHOCRTypeFace:
        {
            //            if (iDInfo.idCardNumber.isBlankString == false) {
            //                [TBProgressHUD showErrorWithtitle:@"身份证信息错误"];
            //                return;
            //            }
        }
            break;
        case XHOCRTypeNation:
        {
            //            if (iDInfo.issuedBy.isBlankString == false) {
            //                [TBProgressHUD showErrorWithtitle:@"身份证信息错误"];
            //                return;
            //            }
        }
            break;
        case XHOCRTypeBank:
        {
            //            if (iDInfo.bankNo.isBlankString == false) {
            //                [TBProgressHUD showErrorWithtitle:@"银行卡信息错误"];
            //                return;
            //            }
        }
            break;
        default:
            break;
    }
    
    if (self.didScanSuc) {
        self.didScanSuc(iDInfo);
    }
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation XHOCRInfo

@end
