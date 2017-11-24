//
//  ZYImageTopBar.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImageTopBar.h"

@interface ZYImageTopBar ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation ZYImageTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIApplication sharedApplication].statusBarFrame.size.height + 44)];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.titleLabel];
        [self addSubview:self.cancelLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.center = CGPointMake(self.center.x, (self.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) * 0.5);
}

#pragma mark - event

- (void)cancelButtonClicked {
    if (self.cancelClickedBlock) {
        self.cancelClickedBlock();
    }
}

#pragma mark - setter

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

#pragma mark - geter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"相册";
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UIButton *)cancelLabel {
    if (_cancelButton == nil) {
        CGFloat y = (self.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height) * 0.5;
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(self.frame.size.width - 52, y, 44, 44);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
