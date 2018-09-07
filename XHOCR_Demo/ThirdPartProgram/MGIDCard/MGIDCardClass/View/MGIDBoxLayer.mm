//
//  MGIDBoxLayer.m
//  MGIDCard
//
//  Created by 张英堂 on 16/8/11.
//  Copyright © 2016年 megvii. All rights reserved.
//

#import "MGIDBoxLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "MGIDCardBundle.h"
#import "MGIDCardConfig.h"

@interface MGIDBoxLayer ()

@property (nonatomic, strong) UIImage *messageImage;
@property (nonatomic, strong) UIImageView *messageImageView;
@property (nonatomic, strong) UITextView* errorMessageTextView;

@end

@implementation MGIDBoxLayer

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Setter and Getter
- (void)setIsDebug:(BOOL)isDebug {
    dispatch_async(dispatch_get_main_queue(), ^{
        _isDebug = isDebug;
        [self.errorMessageTextView setHidden:!isDebug];
        [self setNeedsDisplay];
    });
}

- (UIImage *)messageImage {
    if (!_messageImage) {
        NSString *imageName = (self.IDCardSide == IDCARD_SIDE_FRONT ? @"idcard_bg_front@2x" : @"idcard_bg_back@2x");
        _messageImage = [MGIDCardBundle IDCardImageWithName:imageName];
    }
    return _messageImage;
}

- (UIImageView *)messageImageView {
    if (!_messageImageView) {
        _messageImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_messageImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_messageImageView setClipsToBounds:YES];
        
        [self addSubview:_messageImageView];
    }
    return _messageImageView;
}

- (UITextView *)errorMessageTextView {
    if (!_errorMessageTextView) {
        _errorMessageTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.frame.size.width - 150,
                                                                             self.frame.size.height - 150,
                                                                             150,
                                                                             150)];
        [_errorMessageTextView setBackgroundColor:[UIColor clearColor]];
        [_errorMessageTextView setFont:[UIFont systemFontOfSize:14.0f]];
        [_errorMessageTextView setTextColor:[UIColor whiteColor]];
        [_errorMessageTextView setHidden:YES];
        [_errorMessageTextView setUserInteractionEnabled:NO];
        [self addSubview:_errorMessageTextView];
    }
    return _errorMessageTextView;
}

#pragma mark - Draw
- (void)drawImage:(UIImage *)image rect:(CGRect)rect {
    [self.messageImageView setFrame:rect];
    [self.messageImageView setImage:image];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    
    [self drawBox:self.IDCardBoxRect cutout:self.imageCutoutRect context:ctx];
//    [self drawLayerCornerFrame:self.IDCardBoxRect Context:ctx];
    [self drawImage:self.messageImage rect:self.IDCardBoxRect];
}

/**
 *  绘制一块区域，该区域为透明色，其余位置为半透明
 *
 *  @param box 区域
 *  @param ctx contextref
 */
- (void)drawBox:(CGRect)boxRect cutout:(CGRect)cutoutRect context:(CGContextRef)ctx {
    if (_isQualified) {
        CGColorRef bgColor = CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.5f);
        CGContextSetFillColorWithColor(ctx, bgColor);
        CGContextFillRect(ctx, self.bounds);
        CGContextClearRect(ctx, boxRect);
        CGColorRelease(bgColor);
    }
    
    if (_isDebug) {
        UIBezierPath *borderBezierP = [UIBezierPath bezierPathWithRect:cutoutRect];
        borderBezierP.lineWidth = 2.0f;
        [[UIColor greenColor] setStroke];
        [borderBezierP stroke];
        [self.errorMessageTextView setText:self.detailStr];
    }
}

/**
 *  绘制一个长方形的四个边角
 *
 *  @param ctx  CGContextRef
 *  @param rect 长方形区域
 */
- (void)drawLayerCornerFrame:(CGRect)rect Context:(CGContextRef )ctx {
    CGContextSetStrokeColorWithColor(ctx, MGColorWithRGB(51, 207, 255, 1).CGColor);
    CGContextSetLineWidth(ctx, 1.5f);
    
    CGFloat cHeight = 15.0f;
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect)+cHeight);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+cHeight, CGRectGetMinY(rect));
    
    CGContextMoveToPoint(ctx, CGRectGetMaxX(rect)-cHeight, CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect)+cHeight);
    
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect)-cHeight);
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+cHeight, CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(ctx, CGRectGetMaxX(rect)-cHeight, CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-cHeight);
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end
