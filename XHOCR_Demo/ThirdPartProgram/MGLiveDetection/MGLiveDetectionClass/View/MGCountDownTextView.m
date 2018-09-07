//
//  CircularRing.m
//  LivenessDetection
//
//  Created by megvii on 15/1/13.
//  Copyright (c) 2015Year megvii. All rights reserved.
//

#import "MGCountDownTextView.h"
#import <MGBaseKit/MGBaseKit.h>
#import <CoreText/CoreText.h>

@implementation MGCountDownTextView

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_numLabel setTextAlignment:NSTextAlignmentRight];
        [_numLabel setFont:[UIFont systemFontOfSize:20]];
        [_numLabel setTextColor:[UIColor whiteColor]];
    }
    return _numLabel;
}

- (void)creatCountDownView {
    [self addSubview:self.numLabel];
}

- (void)timerChangeAndViewAnimation:(CGFloat)lastTime {
    NSString *tempString = [NSString stringWithFormat:@"倒计时: %.0f 秒", lastTime];
    NSInteger numCount = lastTime >= 10 ? 2 : 1;
    self.numLabel.attributedText = [self changeWithString:tempString timeSize:numCount];
}

- (NSMutableAttributedString *)changeWithString:(NSString *)string timeSize:(NSInteger)timeSize {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange boldRange = NSMakeRange(0, 5);
    NSRange strikeRange = NSMakeRange(5, timeSize);
    NSRange threeRange =NSMakeRange(5 + timeSize, 2);
    UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:16];
    UIFont *strikeSystemFont = [UIFont boldSystemFontOfSize:27];
    CTFontRef boldfont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
    CTFontRef strikefont = CTFontCreateWithName((__bridge CFStringRef)strikeSystemFont.fontName, strikeSystemFont.pointSize, NULL);
    
    if (strikefont) {
        [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldfont range:boldRange];
        //            [mutableAttributedString addAttributes:@{(NSString *)kCTFontAttributeName value:(__bridge id)strikefont range:strikeRange];
        // kCTForegroundColorFromContextAttributeName
        [attributedString addAttributes:@{(NSString *)kCTFontAttributeName:(__bridge id)strikefont,
                                          (NSString *)kCTForegroundColorAttributeName:(__bridge id)(MGColorWithRGB(55, 174, 217, 1)).CGColor}
                                  range:strikeRange];
        
        [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldfont range:threeRange];
    }
    
    CFRelease(strikefont);
    CFRelease(boldfont);
    
    return attributedString;
}

@end
