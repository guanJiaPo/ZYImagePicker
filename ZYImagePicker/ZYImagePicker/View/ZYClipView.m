//
//  ZYClipView.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYClipView.h"
#import "ZYClipBorderView.h"

@interface ZYScrollView : UIScrollView
@end

@implementation ZYScrollView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIView *zoomView = [self.delegate viewForZoomingInScrollView:self];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = zoomView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    zoomView.frame = frameToCenter;
}

@end

@interface ZYClipView ()<UIScrollViewDelegate>

@property (nonatomic, strong) ZYScrollView *scrollView;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) ZYClipBorderView *clipBorderView;

@property (nonatomic, assign) CGFloat padding; // borderWith + slideWith

@end

@implementation ZYClipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self initData];
    }
    return self;
}

- (void)initData {
    self.resizableClipArea = NO;
    self.clipSize = CGSizeMake(CGRectGetWidth(self.frame) - 16, (CGRectGetWidth(self.frame) - 16) * 4 / 3);
    self.slideWidth = 4;
    self.slideLength = 40;
    self.slideColor = [UIColor whiteColor];
    self.borderColor = [UIColor whiteColor];
    self.borderWidth = 1;
    self.padding = self.slideWidth + self.borderWidth;
    [self addSubview:self.scrollView];
    [self addSubview:self.clipBorderView];
}


#pragma mark - 裁剪

- (UIImage *)clippedImage {
    //计算需要裁剪的尺寸
    CGRect clipRect = [self withinRectForClipArea]; //!self.resizableClipArea ? [self withinRectForClipArea] : [self visibleRectForClipArea];
    
    // 改变图片方向
    CGAffineTransform rectTransform = [self orientationTransformedRectOfImage:self.originalImage];
    clipRect = CGRectApplyAffineTransform(clipRect, rectTransform);
    
    // 裁剪图片
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.originalImage CGImage], clipRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.originalImage.scale orientation:self.originalImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

- (CGRect)withinRectForClipArea {
    
    CGFloat scale = self.originalImage.size.width / self.originalImageView.frame.size.width;
    scale *= self.scrollView.zoomScale;
    CGRect boardWithinRect = [self.clipBorderView convertBoardWithinRectWithToView:self.originalImageView];
    
    return [self scaleRect:boardWithinRect sacle:scale];
}

- (CGRect)scaleRect:(CGRect)rect sacle:(CGFloat)scale {
    
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

- (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img {
    
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

/// 根据image尺寸更改imageView的frame
- (void)resetImageView {
    
    if (self.originalImage == nil) { return; }
    
    CGFloat containerW = CGRectGetWidth(self.frame);
    CGFloat containerH = CGRectGetHeight(self.frame);
    CGFloat selfAspectRatio = containerW / containerH;
    CGFloat imageAspectRatio = self.originalImage.size.width / self.originalImage.size.height;
    
    if (self.resizableClipArea) {
        if(imageAspectRatio > selfAspectRatio) {
            CGFloat paddingTopBottom = floor((containerH - containerW / imageAspectRatio) / 2.0);
            self.scrollView.frame = CGRectMake(0, paddingTopBottom, containerW, floor(containerW / imageAspectRatio));
            self.scrollView.contentSize = CGSizeMake(containerW, floor(containerW / imageAspectRatio));
            self.originalImageView.frame = self.scrollView.bounds;
        } else {
            CGFloat paddingLeftRight = floor((containerW - containerH * imageAspectRatio) / 2.0);
            self.scrollView.frame = CGRectMake(paddingLeftRight, 0, floor(containerH * imageAspectRatio), containerH);
            self.scrollView.contentSize = CGSizeMake(floor(containerH * imageAspectRatio), containerH);
            self.originalImageView.frame = self.scrollView.bounds;
        }
        self.clipBorderView.visibleRect = self.scrollView.frame;
        self.clipBorderView.frame = CGRectMake(CGRectGetMinX(self.scrollView.frame) - self.padding, CGRectGetMinY(self.scrollView.frame) - self.padding, CGRectGetWidth(self.scrollView.frame) + self.padding * 2, CGRectGetHeight(self.scrollView.frame) + self.padding * 2);
        [self.clipBorderView setNeedsDisplay];
    } else {
        containerW = self.clipSize.width;
        containerH = self.clipSize.height;
        
        if(imageAspectRatio > selfAspectRatio) {
            CGFloat paddingTopBottom = floor((containerH - containerW / imageAspectRatio) / 2.0);
            self.scrollView.frame = CGRectMake(0, 0, containerW, containerH);
            self.scrollView.center = self.center;
            self.scrollView.contentSize = CGSizeMake(containerW, containerH);
            self.originalImageView.frame = CGRectMake(0, paddingTopBottom, containerW, floor(containerW / imageAspectRatio));
        } else {
            CGFloat paddingLeftRight = floor((containerW - containerH * imageAspectRatio) / 2.0);
            self.scrollView.frame = CGRectMake(0, 0, containerW, containerH);
            self.scrollView.center = self.center;
            self.scrollView.contentSize = CGSizeMake(containerW, containerH);
            self.originalImageView.frame = CGRectMake(paddingLeftRight, 0, floor(containerH * imageAspectRatio), containerH);;
        }
        self.clipBorderView.visibleRect = CGRectMake(CGRectGetMidX(self.scrollView.frame) - containerW * 0.5, CGRectGetMidY(self.scrollView.frame) - containerH * 0.5, containerW, containerH);
        self.clipBorderView.frame = self.bounds;
        [self.clipBorderView setNeedsDisplay];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!self.resizableClipArea) {
        return self.scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.originalImageView;
}

#pragma mark - setter

- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    self.originalImageView.image = originalImage;
    [self resetImageView];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.clipBorderView.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.clipBorderView.borderColor = borderColor;
}

- (void)setSlideWidth:(CGFloat)slideWidth {
    _slideWidth = slideWidth;
    self.clipBorderView.slideWidth = slideWidth;
}

- (void)setSlideLength:(CGFloat)slideLength {
    _slideLength = slideLength;
    self.clipBorderView.slideLength = slideLength;
}

- (void)setSlideColor:(UIColor *)slideColor {
    _slideColor = slideColor;
    self.clipBorderView.slideColor = slideColor;
}

- (void)setClipSize:(CGSize)clipSize {
    _clipSize = clipSize;
    [self resetImageView];
}

- (void)setResizableClipArea:(BOOL)resizableClipArea {
    _resizableClipArea = resizableClipArea;
    self.clipBorderView.resizableClipArea = resizableClipArea;
    [self resetImageView];
}

#pragma mark - getter

- (UIImageView *)originalImageView {
    if (_originalImageView == nil) {
        _originalImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _originalImageView;
}

- (ZYClipBorderView *)clipBorderView {
    if (_clipBorderView == nil) {
        _clipBorderView = [[ZYClipBorderView alloc]initWithFrame:CGRectMake(self.padding, self.padding, CGRectGetWidth(self.frame) - self.padding * 2, CGRectGetHeight(self.frame) - self.padding * 2)];
    }
    return _clipBorderView;
}

- (ZYScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[ZYScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.decelerationRate = 0.0;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:self.originalImageView];
        self.scrollView.minimumZoomScale = CGRectGetWidth(self.scrollView.frame) / CGRectGetWidth(self.originalImageView.frame);
        self.scrollView.maximumZoomScale = 20.0;
        [self.scrollView setZoomScale:1.0];
    }
    return _scrollView;
}

@end
