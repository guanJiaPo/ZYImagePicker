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

@property (nonatomic, assign) BOOL isGifImage;

@end

@implementation ZYImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUp {
    self.delegate = self;
    self.allowsEditing = NO;
}

#pragma mark - 相册

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
        } else if (weakSelf.isGifImage) {
            [weakSelf popViewControllerAnimated:YES];
        }
    };
    clipViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:clipViewController animated:NO completion:nil];
}

- (void)clipped:(UIImage *)image {
    if (self.clippedBlock) {
        self.clippedBlock(image);
    }
    if (self.saveClipedImage) {
        [self saveImageToPhotoAlbum:image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

///MARK: 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage {
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if(error){
        NSLog(@"保存图片失败");
    }else{
        NSLog(@"保存图片成功");
    }
}

- (BOOL)isGifWithImageData: (NSData *)data {
    if ([[self imageTypeWithImageData:data] isEqualToString:@"gif"]) {
        return YES;
    }
    return NO;
}

- (NSString *)imageTypeWithImageData: (NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
            case 0xFF:
            return @"jpeg";
            case 0x89:
            return @"png";
            case 0x47:
            return @"gif";
            case 0x49:
            case 0x4D:
            return @"tiff";
            case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

- (void)isGifImage:(NSURL *)imageUrl {
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    __block NSData *imageData = nil;
    void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
        if (asset != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc(rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
            imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            if (imageData && [self isGifWithImageData:imageData]) {
                self.isGifImage = YES;
            } else {
                self.isGifImage = NO;
            }
        } else {
            self.isGifImage = NO;
        }
    };
    [assetLibrary assetForURL:imageUrl resultBlock:ALAssetsLibraryAssetForURLResultBlock failureBlock:^(NSError *error) {
        self.isGifImage = NO;
    }];
}

#pragma mark - UIImagePickerControllerDelegate

// 选择照片之后
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 11.0) {
        [self isGifImage:[info objectForKey:UIImagePickerControllerReferenceURL]];
    }
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

#pragma mark - setter

- (void)setImageSorceType:(SourceType)imageSorceType {
    _imageSorceType = imageSorceType;
    if (imageSorceType == sourceType_camera) {
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
}

@end
