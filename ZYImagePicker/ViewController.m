//
//  ViewController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ViewController.h"
#import "ZYImagePickerController.h"
#import "ZYImagePicker.h"

@interface ViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *clipedImageView;

@property (nonatomic, strong) ZYImagePicker *imagePicker;

@property (nonatomic, assign) NSInteger type;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZYImagePicker";
}


- (IBAction)selectPhoto:(UIButton *)sender {
    self.type = sender.tag;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    [actionSheet showInView:self.view];
}

- (void)clipped:(UIImage *)image {
    
    self.clipedImageView.image = image;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) return;
    
    if (self.type == 1) { /// 自定义相机/相册
        self.imagePicker.resizableClipArea = NO;
        if (buttonIndex == 0) {
            //  拍照
            self.imagePicker.isCustomCamera = YES;
            self.imagePicker.imageSorceType = sourceType_camera;
        } else if (buttonIndex == 1) {
            //  相册
            self.imagePicker.isCustomImagePicker = YES;
            self.imagePicker.imageSorceType = sourceType_SavedPhotosAlbum;
        }
        
    } else { /// 使用系统相机/相册
        self.imagePicker.resizableClipArea = YES;
        if (buttonIndex == 0) {
            //  拍照
            self.imagePicker.imageSorceType = sourceType_camera;
            self.imagePicker.isCustomCamera = NO;
        } else if (buttonIndex == 1) {
            //  相册
            self.imagePicker.imageSorceType = sourceType_SavedPhotosAlbum;
            self.imagePicker.isCustomImagePicker = NO;
        }
    }
    
    if (self.imagePicker.isSupportSelectedType) {
        [self presentViewController:self.imagePicker.pickerController animated:YES completion:nil];
    } else {
        if (self.imagePicker.imageSorceType == sourceType_camera) {
            NSLog(@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限");
        } else {
            NSLog(@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限");
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ZYImagePicker *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[ZYImagePicker alloc]init];
        _imagePicker.resizableClipArea = NO;
        _imagePicker.clipSize = self.clipedImageView.frame.size;
        _imagePicker.borderColor = [UIColor orangeColor];
        _imagePicker.borderWidth = 1;
        _imagePicker.slideColor = [UIColor orangeColor];
        _imagePicker.slideWidth = 4;
        _imagePicker.slideLength = 40;
        _imagePicker.didSelectedImageBlock = ^BOOL(UIImage *selectedImage) {
            return YES;
        };
        __weak typeof(self)weakSelf = self;
        _imagePicker.clippedBlock = ^(UIImage *clippedImage) {
            [weakSelf clipped:clippedImage];
        };
    }
    return _imagePicker;
}

@end
