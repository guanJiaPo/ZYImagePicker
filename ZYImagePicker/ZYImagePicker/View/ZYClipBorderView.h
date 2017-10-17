//
//  ZYClipView.h
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYClipBorderView : UIView

/// 裁剪框大小是否可变 默认: NO
@property (nonatomic, assign) BOOL resizableClipArea;

/// 裁剪框边框宽度, 默认1
@property (nonatomic, assign) CGFloat borderWidth;

/// 裁剪框边框颜色, 默认白色
@property (nonatomic, strong) UIColor *borderColor;

/// 裁剪框滑块宽度, 默认4, resizableClipArea为NO时 此属性无效
@property (nonatomic, assign) CGFloat slideWidth;

/// 裁剪框滑块长度, 默认40, resizableClipArea为NO时 此属性无效
@property (nonatomic, assign) CGFloat slideLength;

/// 裁剪框滑块颜色, 默认白色, resizableClipArea为NO时 此属性无效
@property (nonatomic, strong) UIColor *slideColor;

/**
 * resizableClipArea = YES : imageView的frame
 * resizableClipArea = NO  : 裁剪框的frame
 */
@property (nonatomic, assign) CGRect visibleRect;

/**
 * 转换边框内裁剪区的frame
 * @param toView 参考View
 * @return 转换后的frame
 */
- (CGRect)convertBoardWithinRectWithToView:(UIView *)toView;

@end
