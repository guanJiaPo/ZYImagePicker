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

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES];
//    [UIApplication sharedApplication].statusBarHidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
        self.clipView.frame = CGRectMake(0, 0, [UIScreen  mainScreen].bounds.size.width, [UIScreen  mainScreen].bounds.size.height);
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
        _clipView = [[ZYClipView alloc]initWithFrame:CGRectMake(padding, padding, [UIScreen  mainScreen].bounds.size.width - padding * 2, [UIScreen  mainScreen].bounds.size.height - 64 - padding * 2)];
    }
    return _clipView;
}

- (UIToolbar *)bottomBar {
    if (_bottomBar == nil) {
        _bottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen  mainScreen].bounds.size.height - 64, [UIScreen  mainScreen].bounds.size.width, 64)];
        _bottomBar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        cancleButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cancleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancleButton sizeToFit];
        [cancleButton addTarget:self action:@selector(cancelClip) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];
        
        UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [enterButton setTitle:@"确认" forState:UIControlStateNormal];
        enterButton.titleLabel.font = [UIFont systemFontOfSize:18];
        enterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [enterButton sizeToFit];
        [enterButton addTarget:self action:@selector(enterClip) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *enterItem = [[UIBarButtonItem alloc]initWithCustomView:enterButton];

        _bottomBar.items = @[cancelItem,flexibleSpace,enterItem];
    }
    return _bottomBar;
}

@end
