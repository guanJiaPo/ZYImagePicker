//
//  ZYImagePicker.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/25.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImagePicker.h"
#import "ZYCameraController.h"


@implementation ZYImagePicker

- (void)clipped:(UIImage *)image {
    if (self.clippedBlock) {
        self.clippedBlock(image);
    }
}

- (UIViewController *)imgaePickerController {
    
    if (self.imageSorceType == sourceType_camera) {
        ZYCameraController *cameraController = [[ZYCameraController alloc]init];
        cameraController.resizableClipArea = self.resizableClipArea;
        cameraController.clipSize = self.clipSize;
        cameraController.borderColor = self.borderColor;
        cameraController.borderWidth = self.borderWidth;
        cameraController.slideColor = self.slideColor;
        cameraController.slideWidth = self.slideWidth;
        cameraController.slideLength = self.slideLength;
        __weak typeof(self)weakSelf = self;
        cameraController.clippedBlock = ^(UIImage *clippedImage) {
            [weakSelf clipped:clippedImage];
        };
        _imgaePickerController = cameraController;
    } else {
        ZYImagePickerController *pickerController = [[ZYImagePickerController alloc]init];
        pickerController.resizableClipArea = self.resizableClipArea;
        pickerController.clipSize = self.clipSize;
        pickerController.borderColor = self.borderColor;
        pickerController.borderWidth = self.borderWidth;
        pickerController.slideColor = self.slideColor;
        pickerController.slideWidth = self.slideWidth;
        pickerController.slideLength = self.slideLength;
        pickerController.imageSorceType = sourceType_SavedPhotosAlbum;
        __weak typeof(self)weakSelf = self;
        pickerController.clippedBlock = ^(UIImage *clippedImage) {
            [weakSelf clipped:clippedImage];
        };
        _imgaePickerController = pickerController;
    }
    
    return _imgaePickerController;
}

@end
