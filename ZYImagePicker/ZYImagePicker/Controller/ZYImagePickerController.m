//
//  ZYImagePickerController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/25.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImagePickerController.h"
#import "ZYClipViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZYImagePickerController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ZYImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUp];
}

- (void)setUp {
    self.delegate = self;
    self.allowsEditing = NO;
    
    if (self.imageSorceType == sourceType_camera) {
        if (![self isAppCameraAccessAuthorized]) {
            [self dismissViewControllerAnimated:NO completion:nil];
        };
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        if (![self isAppPhotoLibraryAccessAuthorized]) {
            [self dismissViewControllerAnimated:NO completion:nil];
        };
        self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
}

#pragma mark - 相册

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

- (BOOL)isAppPhotoLibraryAccessAuthorized {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        return NO;
    } else {
        return YES;
    }
}

- (void)clipImage:(UIImage *)image {
    if (self.didSelectedImageBlock) {
        if (!self.didSelectedImageBlock(image)) {
            return;
        }
    }
    ZYClipViewController *clipViewController = [[ZYClipViewController alloc]init];
    clipViewController.resizableClipArea = self.resizableClipArea;
    clipViewController.clipSize = self.clipSize;
    clipViewController.originalImage = image;
    clipViewController.borderColor = self.borderColor;
    clipViewController.borderWidth = self.borderWidth;
    clipViewController.slideColor = self.slideColor;
    clipViewController.slideWidth = self.slideWidth;
    clipViewController.slideLength = self.slideLength;
    __weak typeof(self)weakSelf = self;
    clipViewController.clippedBlock = ^(UIImage *clippedImage) {
        [weakSelf clipped:clippedImage];
    };
    clipViewController.cancelClipBlock = ^{
        if (weakSelf.sourceType == UIImagePickerControllerSourceTypeCamera) {

            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [self presentViewController:clipViewController animated:NO completion:nil];
}

- (void)clipped:(UIImage *)image {
    if (self.clippedBlock) {
        self.clippedBlock(image);
    }
    [self saveImageToPhotoAlbum:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

///MARK: 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage {
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if(error){
        NSLog(@"保存图片失败");
    }else{
        NSLog(@"保存图片成功");
    }
}

#pragma mark - UIImagePickerControllerDelegate

// 选择照片之后
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [self clipImage:originalImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.000 alpha:1.000], NSFontAttributeName : [UIFont systemFontOfSize:20]};
    navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

@end
