//
//  VideViewController.m
//  KoalaPad
//
//  Created by 张英堂 on 15/2/10.
//  Copyright (c) 2015年 megvii. All rights reserved.
//

#import "MGIDCardViewController.h"
#import <MGBaseKit/MGAutoSessionPreset.h>
#if TARGET_IPHONE_SIMULATOR
#else
#import "MGIDCardQualityMessageResult.h"
#endif
#import "MGIDCardBundle.h"
#import "MGIDCardModel.h"

@interface MGIDCardViewController ()
{
    NSUInteger requiredValue;
}
@end

@implementation MGIDCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (MGIDCardScreenOrientationPortrait == self.screenOrientation) {
        self.IDCardScale = MGIDCardScaleMake(0.1, 0.2);
    }else{
        self.IDCardScale = MGIDCardDefaultScale();
    }
    
    self.cardCheckManager.IDCardScaleRect = self.IDCardScale;
    self.IDCardSide = self.cardCheckManager.IDCardSide;
    
    [self creatView];
    [self addDEBUGGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.videoManager startRecording];
    [self setUpCameraLayer];
}

#pragma mark - Header Api
- (void)creatView {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    switch (self.screenOrientation) {
        case MGIDCardScreenOrientationPortrait: {
            [self creatOrientationPortraitView];
        }
            break;
        case MGIDCardScreenOrientationLandscapeLeft: {
            [self creatOrientationLeftView];
        }
            break;
        default: {
            [self creatOrientationLeftView];
        }
            break;
    }
}

- (void)creatOrientationPortraitView {
    self.checkErroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, MG_WIN_WIDTH, 40)];
    [self.checkErroLabel setFont:[UIFont systemFontOfSize:20]];
    [self.checkErroLabel setTextAlignment:NSTextAlignmentCenter];
    [self.checkErroLabel setTextColor:[UIColor whiteColor]];
    self.checkErroLabel.hidden = YES;
    
    self.backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBTN setFrame:CGRectMake(MG_WIN_WIDTH - 70, MG_WIN_HEIGHT - 60, 50, 50)];
    [self.backBTN setImage:[MGIDCardBundle IDCardImageWithName:@"cut_cancel_btn"] forState:UIControlStateNormal];
    [self.backBTN.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backBTN setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backBTN addTarget:self action:@selector(cancelIDCardDetect) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.checkErroLabel];
    [self.view addSubview:self.backBTN];
    
    self.IDCardBoxRect = CGRectMake(MG_WIN_WIDTH * self.IDCardScale.x,
                                    MG_WIN_HEIGHT * self.IDCardScale.y,
                                    MG_WIN_WIDTH * (1 - self.IDCardScale.x * 2),
                                    MG_WIN_WIDTH * (1 - self.IDCardScale.x * 2) / self.IDCardScale.WHScale);
    
    self.boxLayer = [[MGIDBoxLayer alloc] initWithFrame:self.view.bounds];
    self.boxLayer.IDCardSide = self.IDCardSide;
    [self.boxLayer setIDCardBoxRect:self.IDCardBoxRect];
    CGRect cutoutRect = CGRectMake(0,
                                   MG_WIN_HEIGHT * self.IDCardScale.y - 30,
                                   MG_WIN_WIDTH,
                                   self.IDCardBoxRect.size.height + 60);
    [self.boxLayer setImageCutoutRect:cutoutRect];
    [self.view addSubview:self.boxLayer];
    [self.view sendSubviewToBack:self.boxLayer];
}

- (void)creatOrientationLeftView {
    self.checkErroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, MG_WIN_HEIGHT, 30)];
    [self.checkErroLabel setFont:[UIFont systemFontOfSize:20]];
    [self.checkErroLabel setTextAlignment:NSTextAlignmentCenter];
    [self.checkErroLabel setTextColor:[UIColor whiteColor]];
    self.checkErroLabel.hidden = YES;
    
    self.backBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBTN setFrame:CGRectMake(MG_WIN_HEIGHT - 70, MG_WIN_WIDTH - 60, 50, 50)];
    [self.backBTN setImage:[MGIDCardBundle IDCardImageWithName:@"cut_cancel_btn"] forState:UIControlStateNormal];
    [self.backBTN.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backBTN setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.backBTN addTarget:self action:@selector(cancelIDCardDetect) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.checkErroLabel];
    [self.view addSubview:self.backBTN];
    
    CATransform3D transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
    self.view.layer.transform = transform;
    
    CGFloat boxHeight = (1.0 - self.IDCardScale.y * 2) * MG_WIN_WIDTH;
    CGFloat boxWidth = boxHeight * self.IDCardScale.WHScale;
    CGFloat boxY = MG_WIN_WIDTH * self.IDCardScale.y;
    CGFloat boxX = (MG_WIN_HEIGHT - boxWidth) * self.IDCardScale.x;
    
    self.IDCardBoxRect = CGRectMake(boxX, boxY, boxWidth, boxHeight);
    
    self.boxLayer = [[MGIDBoxLayer alloc] initWithFrame:CGRectMake(0, 0, MG_WIN_HEIGHT, MG_WIN_WIDTH)];
    self.boxLayer.IDCardSide = self.IDCardSide;
    [self.boxLayer setIDCardBoxRect:self.IDCardBoxRect];
    CGSize imageSize = [MGAutoSessionPreset autoSessionPresetSize];
    CGRect imageRect = [self.cardCheckManager expandFaceWithImageSize:imageSize];
    CGRect cutoutRect = CGRectMake(imageRect.origin.x / imageSize.width * MG_WIN_HEIGHT,
                                   imageRect.origin.y / imageSize.height * MG_WIN_WIDTH,
                                   imageRect.size.width / imageSize.width * MG_WIN_HEIGHT,
                                   imageRect.size.height / imageSize.height * MG_WIN_WIDTH);
    [self.boxLayer setImageCutoutRect:cutoutRect];
    [self.view addSubview:self.boxLayer];
    [self.view sendSubviewToBack:self.boxLayer];
}

//加载图层预览
- (void)setUpCameraLayer {
    if (!self.previewLayer) {
        self.previewLayer = [self.videoManager videoPreview];
        CALayer * viewLayer = [self.view layer];
        
        if (MGIDCardScreenOrientationPortrait != self.screenOrientation) {
            [self.previewLayer setFrame:CGRectMake(0, 0, MG_WIN_HEIGHT, MG_WIN_WIDTH)];
        } else {
            [self.previewLayer setFrame:CGRectMake(0, 0, MG_WIN_WIDTH, MG_WIN_HEIGHT)];
        }
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
    
    if (MGIDCardScreenOrientationPortrait != self.screenOrientation) {
        self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
}

//显示检查中的错误信息
- (void)showErrorMessage:(NSString *)errorString {
    if (self.checkErroLabel.hidden) {
        __block CGRect lRect = self.checkErroLabel.frame;
        __block CGFloat startY = lRect.origin.y;
        lRect.origin.y = -lRect.size.height;
        [self.checkErroLabel setFrame:lRect];
        [self.checkErroLabel setHidden:NO];
        self.checkErroLabel.text = errorString;
        
        [UIView animateWithDuration:0.25f animations:^{
            lRect.origin.y = fabs(startY);
            self.checkErroLabel.frame = lRect;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25f animations:^{
                    lRect.origin.y = -lRect.size.height;
                    self.checkErroLabel.frame = lRect;
                } completion:^(BOOL finished) {
                    [self.checkErroLabel setHidden:YES];
                }];
            });
        }];
    }
}

#pragma mark - Detect Result
- (void)detectSucess:(MGIDCardQualityResult *)result {
    [super detectSucess:result];
    [self stopIDCardDetect];
    
}

- (void)detectFrameError:(NSArray *)errorArray {
    [super detectFrameError:errorArray];
    NSInteger failedType = [[errorArray objectAtIndex:0] integerValue];
    NSString *showString = [self.cardCheckManager getErrorShowString:(MGIDCardFailedType)failedType];
    [self showErrorMessage:showString];
}

- (void)detectFrameErrorDetail:(MGIDCardQualityResult *)result {
    [super detectFrameErrorDetail:result];
    [self detectFrameError:result.fails];
#if TARGET_IPHONE_SIMULATOR
#else
    MGIDCardQualityMessageResult* resultItem = [[MGIDCardQualityMessageResult alloc] initWithResult:result];
    if (self.boxLayer.isDebug) {
        [self.boxLayer setDetailStr:[resultItem detailMessageStr]];
    }
#endif
    [self.boxLayer setIsQualified:[self.cardCheckManager isQualifiedWithInbound:result.attr.in_bound
                                                                         isCard:result.attr.is_idcard]];
    [self.boxLayer setNeedsDisplay];
}

#pragma mark - GestureRecognizer
- (void)addDEBUGGestureRecognizer {
    requiredValue = 0;
    UISwipeGestureRecognizer* swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(changeDEBUGState:)];
    swipeGR.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:swipeGR];
}

- (void)changeDEBUGState:(UIGestureRecognizer *)sender {
    @synchronized (self) {
        requiredValue++;
        if (requiredValue >= 2) {
            [self.boxLayer setIsDebug:!self.boxLayer.isDebug];
            requiredValue = 0;
        }
    }
}

#pragma mark - Operation
- (void)cancelIDCardDetect{
    [self stopIDCardDetect];
}

- (void)stopIDCardDetect{
    [self.videoManager stopRunning];
    [self.checkErroLabel setHidden:YES];
    self.cardCheckManager.delegate = nil;
}

@end
