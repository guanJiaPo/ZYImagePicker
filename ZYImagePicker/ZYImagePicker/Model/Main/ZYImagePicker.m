//
//  ZYImagePicker.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/25.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImagePicker.h"
#import "ZYCameraController.h"
#import "ZYImageController.h"
#import <Photos/Photos.h>
//#import <AVFoundation/AVFoundation.h>

@interface ZYImagePicker ()

/// 是否支持选择的媒体类型
@property (nonatomic, assign) BOOL isSupportSelectedType;

@end

@implementation ZYImagePicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isCustomImagePicker = YES;
        self.isCustomCamera = YES;
        self.saveClipedImage = NO;
        self.resizableClipArea = NO;
    }
    return self;
}

#pragma mark - private

- (void)clipped:(UIImage *)image {
    if (self.clippedBlock) {
        self.clippedBlock(image);
    }
}

// 相机是否授权
- (BOOL)isAppCameraAccessAuthorized {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
        return NO;
    } else {
        return YES;
    }
}

// 相册是否授权
- (BOOL)isAppPhotoLibraryAccessAuthorized {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        return NO;
    } else {
        return YES;
    }
}

- (ZYImagePickerController *)systemPickerController {
    ZYImagePickerController *pickerController = [[ZYImagePickerController alloc]init];
    pickerController.resizableClipArea = self.resizableClipArea;
    pickerController.clipSize = self.clipSize;
    pickerController.saveClipedImage = self.saveClipedImage;
    pickerController.borderColor = self.borderColor;
    pickerController.borderWidth = self.borderWidth;
    pickerController.slideColor = self.slideColor;
    pickerController.slideWidth = self.slideWidth;
    pickerController.slideLength = self.slideLength;
    pickerController.imageSorceType = self.imageSorceType;
    __weak typeof(self)weakSelf = self;
    pickerController.clippedBlock = ^(UIImage *clippedImage) {
        [weakSelf clipped:clippedImage];
    };
    return pickerController;
}

#pragma mark - setter

- (void)setImageSorceType:(SourceType)imageSorceType {
    _imageSorceType = imageSorceType;
    if (imageSorceType == sourceType_camera) {
        self.isSupportSelectedType = [self isAppCameraAccessAuthorized];
    } else {
        self.isSupportSelectedType = [self isAppPhotoLibraryAccessAuthorized];
    }
}

#pragma mark - getter

- (UIViewController *)pickerController {
    if (self.imageSorceType == sourceType_camera) {
        if (self.isCustomCamera) {
            ZYCameraController *pickerController = [[ZYCameraController alloc]init];
            pickerController.resizableClipArea = self.resizableClipArea;
            pickerController.saveClipedImage = self.saveClipedImage;
            pickerController.clipSize = self.clipSize;
            pickerController.borderColor = self.borderColor;
            pickerController.borderWidth = self.borderWidth;
            pickerController.slideColor = self.slideColor;
            pickerController.slideWidth = self.slideWidth;
            pickerController.slideLength = self.slideLength;
            pickerController.didSelectedImageBlock = self.didSelectedImageBlock;
            __weak typeof(self)weakSelf = self;
            pickerController.clippedBlock = ^(UIImage *clippedImage) {
                [weakSelf clipped:clippedImage];
            };
            _pickerController = pickerController;
        } else {
            ZYImagePickerController *pickerController = [self systemPickerController];
            _pickerController = pickerController;
        }
    } else {
        if (self.isCustomImagePicker) {
            ZYImageController *pickerController = [[ZYImageController alloc]init];
            pickerController.resizableClipArea = self.resizableClipArea;
            pickerController.saveClipedImage = self.saveClipedImage;
            pickerController.clipSize = self.clipSize;
            pickerController.borderColor = self.borderColor;
            pickerController.borderWidth = self.borderWidth;
            pickerController.slideColor = self.slideColor;
            pickerController.slideWidth = self.slideWidth;
            pickerController.slideLength = self.slideLength;
            pickerController.didSelectedImageBlock = self.didSelectedImageBlock;
            __weak typeof(self)weakSelf = self;
            pickerController.clippedBlock = ^(UIImage *clippedImage) {
                [weakSelf clipped:clippedImage];
            };
            _pickerController = pickerController;
        } else {
            ZYImagePickerController *pickerController = [self systemPickerController];
            _pickerController = pickerController;
        }
    }
    return _pickerController;
}

@end
