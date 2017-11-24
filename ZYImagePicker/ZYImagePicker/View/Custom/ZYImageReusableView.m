//
//  ZYImageReusableView.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImageReusableView.h"

@interface ZYImageReusableView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZYImageReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark - setter

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    self.titleLabel.text = titleText;
}


#pragma mark - geter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 6, [UIScreen mainScreen].bounds.size.width, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

@end
