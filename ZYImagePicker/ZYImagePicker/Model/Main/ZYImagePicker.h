//
//  ZYImagePicker.h
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/25.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYImagePickerController.h"

@interface ZYImagePicker : NSObject

@property (nonatomic, strong) UIViewController *pickerController;

/// 媒体类型
@property (nonatomic, assign) SourceType imageSorceType;

/// 拍照时是否使自定义系统相机 默认YES
@property (nonatomic, assign) BOOL isCustomCamera;

/// 选择图片时是否跳转到自定义相册列表 默认YES
@property (nonatomic, assign) BOOL isCustomImagePicker;

/// 裁剪框大小是否可变 默认: NO
@property (nonatomic, assign) BOOL resizableClipArea;

/// 裁剪框尺寸, resizableClipArea为YES时 此属性无效
@property (nonatomic, assign) CGSize clipSize;

/// 是否保存裁剪后的图片 默认NO
@property (nonatomic, assign) BOOL saveClipedImage;

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

/// 是否支持选择的媒体类型
@property (nonatomic, assign, readonly) BOOL isSupportSelectedType;

/**
 * 点击了图片
 * return  yes: 跳转下一步, 进行裁剪; no: 不跳转
 */
@property (nonatomic, copy) BOOL (^didSelectedImageBlock)(UIImage *selectedImage);

/// 裁剪完成的回调
@property (nonatomic, copy) void (^clippedBlock)(UIImage *clippedImage);

@end
