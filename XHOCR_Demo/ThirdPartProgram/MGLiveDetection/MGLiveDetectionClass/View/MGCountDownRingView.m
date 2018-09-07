//
//  MGCountDownViewTwo.m
//  MGLivenessDetection
//
//  Created by megvii on 16/4/13.
//  Copyright © 2016Year megvii. All rights reserved.
//

#import "MGCountDownRingView.h"
#import <MGBaseKit/MGBaseKit.h>

@implementation MGCountDownRingView

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [_numLabel setFont:[UIFont systemFontOfSize:28]];
        [_numLabel setTextColor:[UIColor whiteColor]];
    }
    return _numLabel;
}

- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        CGFloat lineWidth = 5.f;
        CGFloat radius = self.bounds.size.width/2 - lineWidth;
        CGRect rect = CGRectMake(lineWidth, lineWidth, radius * 2, radius * 2);
        _circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                           cornerRadius:radius].CGPath;
        
        _circleLayer.strokeColor = MGColorWithRGB(74, 232, 217, 1).CGColor;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.lineWidth = lineWidth;
        _circleLayer.lineCap = kCALineCapButt;
        _circleLayer.lineJoin = kCALineJoinRound;
    }
    return _circleLayer;
}

- (void)creatCountDownView {
    [self addSubview:self.numLabel];
    [self.layer addSublayer:self.circleLayer];
}

/* 以下方法为 子类重写，每次倒计时改变都会被调用 */

/**
 *  倒计时改变
 *
 *  @param lastTime 剩余倒计时时间
 */
- (void)timerChangeAndViewAnimation:(CGFloat)lastTime {
    NSString *tempString = [NSString stringWithFormat:@"%.0f", lastTime];
    if (lastTime != 0 && self.maxTime != 0) {
        self.circleLayer.strokeEnd = lastTime / self.maxTime;
    } else {
        self.circleLayer.strokeEnd = 1.0f;
    }
    self.numLabel.text = tempString;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, rect.size.width/2-5, 0, M_PI*2, 0);
    CGContextSetLineWidth(ctx, 5.0f);
    CGContextSetRGBStrokeColor(ctx, 41/255.0, 129/255.0, 178/255.0, 1);
    CGContextStrokePath(ctx);
}

@end
