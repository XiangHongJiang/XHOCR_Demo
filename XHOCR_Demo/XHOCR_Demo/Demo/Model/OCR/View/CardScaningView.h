//
//  CardScaningView.h
//  XHOCR_Demo
//
//  Created by MrYeL on 2018/9/7.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, XHOCRType){
    XHOCRTypeFace = 1,
    XHOCRTypeNation = 2,//人像采集
    XHOCRTypeBank = 3,
    XHOCRTypeImage = 5
};

@interface CardScaningView : UIView
- (instancetype)initWithOcrType:(XHOCRType)ocrType;

@property (nonatomic,assign) CGRect facePathRect;
@end
