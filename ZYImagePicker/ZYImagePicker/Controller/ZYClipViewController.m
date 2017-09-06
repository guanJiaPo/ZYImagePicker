//
//  ZYClipViewController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYClipViewController.h"
#import "ZYClipView.h"

@interface ZYClipViewController ()

@property (nonatomic, strong) ZYClipView *clipView;

@property (nonatomic, strong) UIToolbar *bottomBar;

@end

@implementation ZYClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.clipView];
    [self.view addSubview:self.bottomBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event

- (void)cancelClip {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    if (self.cancelClipBlock) {
        self.cancelClipBlock();
    }
}

- (void)enterClip {
    
    UIImage *clipedImage = [self.clipView clippedImage];
    if (self.clippedBlock) {
        [self dismissViewControllerAnimated:NO completion:nil];
        self.clippedBlock(clipedImage);
    }
}

#pragma mark - setter

- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    self.clipView.originalImage = originalImage;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.clipView.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.clipView.borderColor = borderColor;
}

- (void)setSlideWidth:(CGFloat)slideWidth {
    _slideWidth = slideWidth;
    self.clipView.slideWidth = slideWidth;
}

- (void)setSlideLength:(CGFloat)slideLength {
    _slideLength = slideLength;
    self.clipView.slideLength = slideLength;
}

- (void)setSlideColor:(UIColor *)slideColor {
    _slideColor = slideColor;
    self.clipView.slideColor = slideColor;
}

- (void)setResizableClipArea:(BOOL)resizableClipArea {
    _resizableClipArea = resizableClipArea;
    self.clipView.resizableClipArea = resizableClipArea;
    if (!resizableClipArea) {
        self.clipView.frame = CGRectMake(0, 0, kScreen_Width, KScreen_Height - 64);
    }
}

- (void)setClipSize:(CGSize)clipSize {
    _clipSize = clipSize;
    self.clipView.clipSize = self.clipSize;
}

#pragma mark - getter

- (ZYClipView *)clipView {
    if (_clipView == nil) {
        CGFloat padding = self.slideWidth + self.borderWidth <= 0 ? 5 : self.slideWidth + self.borderWidth;
        _clipView = [[ZYClipView alloc]initWithFrame:CGRectMake(padding, 20, kScreen_Width - padding * 2, KScreen_Height - 84 - padding * 2)];
    }
    return _clipView;
}

- (UIToolbar *)bottomBar {
    if (_bottomBar == nil) {
        _bottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, KScreen_Height - 64, kScreen_Width, 64)];

        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 16;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _bottomBar.barTintColor = [UIColor clearColor];
        
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake(0, 0, 50, 32);
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancelClip) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];
        
        UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        enterButton.frame = CGRectMake(0, 0, 50, 32);
        [enterButton setTitle:@"确认" forState:UIControlStateNormal];
        [enterButton addTarget:self action:@selector(enterClip) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *enterItem = [[UIBarButtonItem alloc]initWithCustomView:enterButton];

        _bottomBar.items = @[fixedSpace,cancelItem,flexibleSpace,enterItem,fixedSpace];
    }
    return _bottomBar;
}

@end
