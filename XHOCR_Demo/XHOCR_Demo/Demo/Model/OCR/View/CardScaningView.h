//
//  CardScaningView.h
//
//
//  Created by  on 08/01/2018.
//  Copyright © 2018 . All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TBOCRType){
    TBOCRTypeFace = 1,
    TBOCRTypeNation = 2,//人像采集
    TBOCRTypeBank = 3,
    TBOCRTypeImage = 5
};

@interface CardScaningView : UIView
- (instancetype)initWithOcrType:(TBOCRType)ocrType;

@property (nonatomic,assign) CGRect facePathRect;
@end
