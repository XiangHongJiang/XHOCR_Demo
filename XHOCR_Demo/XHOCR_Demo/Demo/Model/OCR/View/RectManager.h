//
//  RectManager.h
//  
//
//  Created by  on 08/01/2018.
//  Copyright © 2018 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RectManager : UIView


@property (nonatomic, assign)CGRect subRect;

+ (CGRect)getEffectImageRect:(CGSize)size;
+ (CGRect)getGuideFrame:(CGRect)rect;

+ (int)docode:(unsigned char *)pbBuf len:(int)tLen;
+ (CGRect)getCorpCardRect:(int)width  height:(int)height guideRect:(CGRect)guideRect charCount:(int) charCount;

+ (char *)getNumbers;

+ (void)getOCRInfoWithData:(NSData *)imageData type:(TBOCRType)type res:(void (^)(id ocrInfo))res;
@end
