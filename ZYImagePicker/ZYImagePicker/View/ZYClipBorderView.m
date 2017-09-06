//
//  ZYClipView.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYClipBorderView.h"
#import "UIView+Frame.h"

static CGFloat kSlideWith = 40;

typedef enum : NSUInteger {
    layerStyle_topLeft = 0,
    layerStyle_topRight,
    layerStyle_bottomLeft,
    layerStyle_bottomRight,
    layerStyle_topMid,
    layerStyle_leftMid,
    layerStyle_bottomMid,
    layerStyle_rightMid,
    layerStyle_border,
} LayerStyle;

@interface ZYClipBorder : NSObject

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, retain) UIColor     *lineColor;
@property (nonatomic, assign) CGFloat     lineWidth;
@property (nonatomic, assign) LayerStyle   layerStyle;

@end

@implementation ZYClipBorder

@end

#pragma mark - ZYClipBorderView

@interface ZYClipBorderView ()

@property (nonatomic, assign) LayerStyle startTouchStyle; // 第一次触摸的位置
@property (nonatomic, strong) UIView *borderWithinView;

@property (nonatomic, assign) CGFloat padding; // borderWith + slideWith

@property (nonatomic, strong) NSMutableArray *clipBorders;

@end

@implementation ZYClipBorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)initData {
    self.slideWidth = 4;
    self.slideLength = 40;
    self.slideColor = [UIColor whiteColor];
    self.borderColor = [UIColor whiteColor];
    self.borderWidth = 1;
    self.padding = self.slideWidth + self.borderWidth;
    [self addSubview:self.borderWithinView];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self drawClipBorderWithContextRef:contextRef];
}

#pragma mark - 边框

- (void)drawClipBorderWithContextRef:(CGContextRef)contextRef {
    
    if (self.resizableClipArea) {
        [self resetClipBorders];
        
        for (ZYClipBorder *clipBorder in self.clipBorders) {
            // 添加路径
            CGContextAddPath(contextRef, clipBorder.path.CGPath);
            // 设置颜色
            [clipBorder.lineColor setStroke];
            [[UIColor clearColor] setFill];
            // 设置线宽
            CGContextSetLineWidth(contextRef, clipBorder.lineWidth);
            // 渲染
            CGContextDrawPath(contextRef, kCGPathStroke);
        }
    } else {
        [self resetForResizableClipAreaWithContextRef:contextRef];
    }
}

- (void)resetClipBorders {
    
    if (self.clipBorders.count) {
        for (ZYClipBorder *clipBorder in self.clipBorders) {
            [clipBorder.path removeAllPoints];
            [self addbezierPath:clipBorder.path style:clipBorder.layerStyle];
            if (clipBorder.layerStyle == layerStyle_border) {
                clipBorder.lineColor = self.borderColor;
                clipBorder.lineWidth = self.borderWidth;
            } else {
                clipBorder.lineColor = self.slideColor;
                clipBorder.lineWidth = self.slideWidth;
            }
        }
    } else {
        for (NSInteger i = 0; i<= layerStyle_border; i++) {
            ZYClipBorder *clipBorder = [[ZYClipBorder alloc]init];
            if (i == layerStyle_border) {
                clipBorder.lineColor = self.borderColor;
                clipBorder.lineWidth = self.borderWidth;
            } else {
                clipBorder.lineColor = self.slideColor;
                clipBorder.lineWidth = self.slideWidth;
            }
            clipBorder.layerStyle = i;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [self addbezierPath:path style:i];
            clipBorder.path = path;
            [self.clipBorders addObject:clipBorder];
        }
    }
    
    self.borderWithinView.frame = CGRectMake(self.padding, self.padding, CGRectGetWidth(self.frame) - self.padding * 2, CGRectGetHeight(self.frame) - self.padding * 2);
}

- (void)resetForResizableClipAreaWithContextRef:(CGContextRef)contextRef {
    
    [[UIColor colorWithRed:0. green:0. blue:0. alpha:0.5] set];
    UIRectFill(self.bounds);
    
    [self.borderColor setStroke];
    [[UIColor clearColor] setFill];
    CGContextSetLineWidth(contextRef, self.borderWidth);
    UIRectFill(CGRectMake(self.visibleRect.origin.x, self.visibleRect.origin.y, self.visibleRect.size.width, self.visibleRect.size.height));
    UIRectFrame(CGRectMake(self.visibleRect.origin.x - self.borderWidth, self.visibleRect.origin.y - self.borderWidth, self.visibleRect.size.width + self.borderWidth * 2, self.visibleRect.size.height + self.borderWidth * 2));
    
    self.borderWithinView.frame = CGRectMake(CGRectGetMinX(self.visibleRect), CGRectGetMinY(self.visibleRect), CGRectGetWidth(self.visibleRect), CGRectGetHeight(self.visibleRect));
}

- (void)addbezierPath:(UIBezierPath *)layerPath style:(LayerStyle)style {
    CGFloat selfW = CGRectGetWidth(self.frame);
    CGFloat selfH = CGRectGetHeight(self.frame);
    CGFloat slidePadding = self.slideWidth / 2.0;
    CGFloat borderPadding = self.borderWidth / 2.0;

    switch (style) {
        case layerStyle_topLeft: {
            [layerPath moveToPoint:CGPointMake(slidePadding, self.slideLength)];
            [layerPath addLineToPoint:CGPointMake(slidePadding, slidePadding)];
            [layerPath addLineToPoint:CGPointMake(self.slideLength, slidePadding)];
        } break;
        case layerStyle_topRight:{
            [layerPath moveToPoint:CGPointMake(selfW - self.slideLength, slidePadding)];
            [layerPath addLineToPoint:CGPointMake(selfW - slidePadding, slidePadding)];
            [layerPath addLineToPoint:CGPointMake(selfW - slidePadding, self.slideLength)];
        } break;
        case layerStyle_bottomLeft: {
            [layerPath moveToPoint:CGPointMake(slidePadding, selfH - self.slideLength)];
            [layerPath addLineToPoint:CGPointMake(slidePadding, selfH - slidePadding)];
            [layerPath addLineToPoint:CGPointMake(self.slideLength, selfH - slidePadding)];
        } break;
        case layerStyle_bottomRight: {
            [layerPath moveToPoint:CGPointMake(selfW - self.slideLength, selfH - slidePadding)];
            [layerPath addLineToPoint:CGPointMake(selfW - slidePadding, selfH - slidePadding)];
            [layerPath addLineToPoint:CGPointMake(selfW - slidePadding, selfH - self.slideLength)];
        } break;
        case layerStyle_topMid: {
            [layerPath moveToPoint:CGPointMake((selfW - self.slideLength) / 2, slidePadding)];
            [layerPath addLineToPoint:CGPointMake((selfW + self.slideLength) / 2, slidePadding)];
        } break;
        case layerStyle_leftMid: {
            [layerPath moveToPoint:CGPointMake(slidePadding, (selfH - self.slideLength) / 2)];
            [layerPath addLineToPoint:CGPointMake(slidePadding, (selfH + self.slideLength) / 2)];
        } break;
        case layerStyle_bottomMid: {
            [layerPath moveToPoint:CGPointMake((selfW - self.slideLength) / 2, selfH - slidePadding)];
            [layerPath addLineToPoint:CGPointMake((selfW + self.slideLength) / 2, selfH - slidePadding)];
        } break;
        case layerStyle_rightMid: {
            [layerPath moveToPoint:CGPointMake(selfW - slidePadding, (selfH - self.slideLength) / 2)];
            [layerPath addLineToPoint:CGPointMake(selfW - slidePadding, (selfH + self.slideLength) / 2)];
        } break;
        case layerStyle_border: {
            [layerPath moveToPoint:CGPointMake(self.slideWidth + borderPadding, self.slideWidth + borderPadding)];
            [layerPath addLineToPoint:CGPointMake(self.slideWidth + borderPadding, selfH - self.slideWidth)];
            [layerPath addLineToPoint:CGPointMake(selfW - self.slideWidth,selfH - self.slideWidth - borderPadding)];
            [layerPath addLineToPoint:CGPointMake(selfW - self.slideWidth - borderPadding,self.slideWidth + borderPadding)];
            [layerPath addLineToPoint:CGPointMake(self.slideWidth, self.slideWidth + borderPadding)];
        } break;
        default:
            break;
    }
}

#pragma mark - move

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];

    CGPoint startPoint = [touch locationInView:self];
    [self getStartTouchStyleWithStartPoint:startPoint];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    // 当前手指的位置
    CGPoint curpoint = [touch locationInView:self];
    //上一次手指值
    CGPoint prePoint = [touch previousLocationInView:self];

    [self changeFrameWithCurPoint:curpoint prePoint:prePoint];
}

- (void) getStartTouchStyleWithStartPoint:(CGPoint)startPoint {
    
    CGRect topLeftRect = CGRectMake(0, 0, kSlideWith, kSlideWith);
    CGRect topRightRect = CGRectMake(self.width - kSlideWith, 0, kSlideWith, kSlideWith);
    CGRect bottomLeftRect = CGRectMake(0, self.height - kSlideWith, kSlideWith, kSlideWith);
    CGRect bottomRightRect = CGRectMake(self.width - kSlideWith, self.height - kSlideWith, kSlideWith, kSlideWith);
    CGRect topMidRect = CGRectMake((self.width - kSlideWith) / 2, 0, kSlideWith, kSlideWith / 2);
    CGRect leftMidRect = CGRectMake(0, (self.height - kSlideWith) / 2, kSlideWith, kSlideWith);
    CGRect bottomMidRect = CGRectMake((self.width - kSlideWith) / 2, self.height - kSlideWith / 2, kSlideWith, kSlideWith / 2);
    CGRect rightMidRect = CGRectMake(self.width - kSlideWith, (self.height - kSlideWith) / 2, kSlideWith, kSlideWith);
    
    if (CGRectContainsPoint(topLeftRect, startPoint)) {
        self.startTouchStyle = layerStyle_topLeft;
        
    } else if (CGRectContainsPoint(topRightRect, startPoint)) {
        self.startTouchStyle = layerStyle_topRight;
        
    } else if (CGRectContainsPoint(bottomLeftRect, startPoint)) {
        self.startTouchStyle = layerStyle_bottomLeft;
        
    } else if (CGRectContainsPoint(bottomRightRect, startPoint)) {
        self.startTouchStyle = layerStyle_bottomRight;
        
    } else if (CGRectContainsPoint(topMidRect, startPoint)) {
        self.startTouchStyle = layerStyle_topMid;
        
    } else if (CGRectContainsPoint(leftMidRect, startPoint)) {
        self.startTouchStyle = layerStyle_leftMid;

    } else if (CGRectContainsPoint(bottomMidRect, startPoint)) {
        self.startTouchStyle = layerStyle_bottomMid;
        
    } else if (CGRectContainsPoint(rightMidRect, startPoint)) {
        self.startTouchStyle = layerStyle_rightMid;
    } else {
        self.startTouchStyle = layerStyle_border;
    }
}

- (void)changeFrameWithCurPoint:(CGPoint)curpoint prePoint:(CGPoint)prePoint {

    CGFloat subX = curpoint.x - prePoint.x;
    CGFloat subY = curpoint.y - prePoint.y;
    CGRect newFrame = CGRectMake(0, 0, kSlideWith * 2, kSlideWith * 2);
    switch (self.startTouchStyle) {
        case layerStyle_topLeft:
            newFrame = CGRectMake(self.left + subX, self.top + subY, self.width - subX, self.height - subY);
            break;
        case layerStyle_topRight:
            newFrame = CGRectMake(self.left, self.top + subY, self.width + subX, self.height - subY);
            break;
        case layerStyle_bottomLeft:
            newFrame = CGRectMake(self.left + subX, self.top, self.width - subX, self.height + subY);
            break;
        case layerStyle_bottomRight:
            newFrame = CGRectMake(self.left, self.top, self.width + subX, self.height + subY);
            break;
        case layerStyle_topMid:
            newFrame = CGRectMake(self.left, self.top + subY, self.width, self.height - subY);
            break;
        case layerStyle_leftMid:
            newFrame = CGRectMake(self.left + subX, self.top, self.width - subX, self.height);
            break;
        case layerStyle_bottomMid:
            newFrame = CGRectMake(self.left, self.top, self.width, self.height + subY);
            break;
        case layerStyle_rightMid:
            newFrame = CGRectMake(self.left, self.top, self.width + subX, self.height);
            break;
        case layerStyle_border: {
            //让View移动
            self.transform = CGAffineTransformTranslate(self.transform, subX, subY);
            //设置边界
            if (self.top < CGRectGetMinY(self.visibleRect) - self.padding) {
                self.top = CGRectGetMinY(self.visibleRect) - self.padding;
            }else if (self.bottom > CGRectGetMaxY(self.visibleRect) + self.padding) {
                self.bottom = CGRectGetMaxY(self.visibleRect) + self.padding;
            }
            if (self.left < CGRectGetMinX(self.visibleRect) - self.padding) {
                self.left = CGRectGetMinX(self.visibleRect) - self.padding;
            }else if (self.right > CGRectGetMaxX(self.visibleRect) + self.padding){
                self.right = CGRectGetMaxX(self.visibleRect) + self.padding;
            }
            newFrame = self.frame;
        } break;
        default:
            break;
    }
//    NSLog(@"curpointX: %f, curpointY: %f\nprePointX: %f, prePointY: %f",curpoint.x,curpoint.y,prePoint.x,prePoint.y);

    [self resetClipViewFrame:newFrame];
}

- (void)resetClipViewFrame:(CGRect)newFrame {

    if (CGRectGetMinX(newFrame) < CGRectGetMinX(self.visibleRect) - self.padding || CGRectGetMaxX(newFrame) > CGRectGetMaxX(self.visibleRect) + self.padding) { return; }
    
    if (CGRectGetMinY(newFrame) < CGRectGetMinY(self.visibleRect) - self.padding || CGRectGetMaxY(newFrame) > CGRectGetMaxY(self.visibleRect) + self.padding) { return; }
    
    if (CGRectGetWidth(newFrame) < kSlideWith * 3 || CGRectGetWidth(newFrame) > CGRectGetWidth(self.visibleRect) + self.padding * 2) { return; }
    
    if (CGRectGetHeight(newFrame) < kSlideWith * 3 || CGRectGetHeight(newFrame) > CGRectGetHeight(self.visibleRect) + self.padding * 2) { return; }
  
    self.frame = newFrame;
    [self setNeedsDisplay];
}

#pragma mark - public

- (CGRect)convertBoardWithinRectWithToView:(UIView *)toView {
    CGRect boardWithinRect = [self.borderWithinView convertRect:self.borderWithinView.bounds toView:toView];
    return boardWithinRect;
}

#pragma mark - setter

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.padding = self.slideWidth + self.borderWidth;
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setSlideWidth:(CGFloat)slideWidth {
    _slideWidth = slideWidth;
    self.padding = self.slideWidth + self.borderWidth;
    [self setNeedsDisplay];
}

- (void)setSlideLength:(CGFloat)slideLength {
    _slideLength = slideLength;
    [self setNeedsDisplay];
}

- (void)setSlideColor:(UIColor *)slideColor {
    _slideColor = slideColor;
    [self setNeedsDisplay];
}

- (void)setResizableClipArea:(BOOL)resizableClipArea {
    _resizableClipArea = resizableClipArea;
    [self setNeedsDisplay];
}

#pragma mark - getter

- (UIView *)borderWithinView {
    if (_borderWithinView == nil) {
        _borderWithinView = [[UIView alloc]initWithFrame:CGRectMake(self.padding, self.padding, CGRectGetWidth(self.frame) - self.padding * 2, CGRectGetHeight(self.frame) - self.padding * 2)];
        _borderWithinView.userInteractionEnabled = NO;
    }
    return _borderWithinView;
}

- (NSMutableArray *)clipBorders {
    if (_clipBorders == nil) {
        _clipBorders = [NSMutableArray arrayWithCapacity:0];
    }
    return _clipBorders;
}

@end
