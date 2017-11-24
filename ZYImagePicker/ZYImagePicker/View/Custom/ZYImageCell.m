//
//  ZYImageCell.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImageCell.h"

@implementation ZYImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end
