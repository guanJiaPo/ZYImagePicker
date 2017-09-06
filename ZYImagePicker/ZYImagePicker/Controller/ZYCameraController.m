//
//  ZYCameraController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/8/25.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZYClipViewController.h"

@interface ZYCameraController ()

/**
*  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
*/
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;

/**
 * 最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;

/**
 * 拍照获取的图片数据
 */
@property (nonatomic, strong) NSData  *jpegData;

@property (nonatomic, strong) UIToolbar *topBar;
@property (nonatomic, strong) UIToolbar *bottomBar;

/**
 * 闪光灯
 */
@property (nonatomic, strong) UIButton  *flashStatusButton;
@property (nonatomic, strong) UIButton  *flashAutoButton;
@property (nonatomic, strong) UIButton  *flashOnButton;
@property (nonatomic, strong) UIButton  *flashOffButton;


@end

@implementation ZYCameraController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initAVCaptureSession];
    [self setUpGesture];
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    
    if (self.session) {
        [self.session stopRunning];
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    self.effectiveScale = 1.0;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self changeFlashStatusWithType:2];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.previewLayer.frame = CGRectMake(0, 40,kScreen_Width, KScreen_Height - 116);
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self resetFocusAndExposureModes];
}

//添加手势
- (void)setUpGesture
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinch];
}

//自动聚焦、曝光
- (BOOL)resetFocusAndExposureModes {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    }
    else{
        NSLog(@"%@", error);
        return NO;
    }
}

///MARK: 聚焦
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    }
}

// 根据前后置位置拿到相应的摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (void)changeCamera {
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[self.videoInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }
        //生成新的输入
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.videoInput = newInput;
                
            } else {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (BOOL)cameraSupportsTapToFocus {
    return [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] isFocusPointOfInterestSupported];
}

// 获取设备方向
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft)
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight)
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

// 裁剪图片完成
- (void)clipped:(UIImage *)image {
    if (self.clippedBlock) {
        self.clippedBlock(image);
    }
    [self saveImageToPhotoAlbum:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

///MARK: 拍照之后跳到裁剪页面
-(void)jumpImageView:(NSData *)data {
    
    UIImage *image = [UIImage imageWithData:data];
    ZYClipViewController *clipViewController = [[ZYClipViewController alloc]init];
    clipViewController.resizableClipArea = self.resizableClipArea;
    clipViewController.clipSize = self.clipSize;
    clipViewController.originalImage = image;
    clipViewController.borderColor = self.borderColor;
    clipViewController.borderWidth = self.borderWidth;
    clipViewController.slideColor = self.slideColor;
    clipViewController.slideWidth = self.slideWidth;
    clipViewController.slideLength = self.slideLength;
    clipViewController.originalImage = image;
    __weak typeof(self)weakSelf = self;
    clipViewController.clippedBlock = ^(UIImage *clippedImage) {
        [weakSelf clipped:clippedImage];
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:clipViewController animated:NO completion:nil];
    });
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

#pragma mark - event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    [self focusAtPoint:point];
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.beginGestureScale = self.effectiveScale;
    }
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches];
    for (NSInteger i = 0; i < numTouches; ++i) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    if ( allTouchesAreOnThePreviewLayer ) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0) {
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        [self resetFocusAndExposureModes];
    }
}

- (void)cancleCamera
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///MARK: 照相
- (void)takePhotoButtonClicked {
    
    _stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [_stillImageConnection setVideoOrientation:avcaptureOrientation];
    [_stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        [self jumpImageView:jpegData];
        
    }];
}

///MARK: 闪光灯 0: 关闭, 1: 打开, 2: 自动
- (void)changeFlashStatusWithType:(NSInteger)type {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        //修改前必须先锁定
        [device lockForConfiguration:nil];
        if (type == 0) {
            device.flashMode = AVCaptureFlashModeOff;
            [self.flashStatusButton setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
        } else if (type == 1) {
            device.flashMode = AVCaptureFlashModeOn;
            [self.flashStatusButton setImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
        } else if (type == 2) {
            device.flashMode = AVCaptureFlashModeAuto;
            [self.flashStatusButton setImage:[UIImage imageNamed:@"flashAuto"] forState:UIControlStateNormal];
        }
        [device unlockForConfiguration];
    }
}

///MARK: 切换摄像头
- (void)changePositionClicked:(UIButton *)sender {
    [self changeCamera];
}

- (void)flashStatusButtonClicked {
    self.flashStatusButton.selected = !self.flashStatusButton.selected;
    self.flashAutoButton.hidden = self.flashStatusButton.selected;
    self.flashOnButton.hidden = self.flashStatusButton.selected;
    self.flashOffButton.hidden = self.flashStatusButton.selected;
}

- (void)changeFlashStatusClicked:(UIButton *)sender {
    self.flashOffButton.selected = NO;
    self.flashOnButton.selected = NO;
    self.flashAutoButton.selected = NO;
    sender.selected = YES;
    if ([sender isEqual:self.flashAutoButton]) {
        [self changeFlashStatusWithType:2];
    } else if ([sender isEqual:self.flashOnButton]) {
        [self changeFlashStatusWithType:1];
    } else if ([sender isEqual:self.flashOffButton]) {
        [self changeFlashStatusWithType:0];
    }
}

#pragma mark - getter

- (UIToolbar *)bottomBar {
    if (_bottomBar == nil) {
        _bottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, KScreen_Height - 76, kScreen_Width, 76)];
        _bottomBar.barTintColor = [UIColor clearColor];
        _bottomBar.tintColor = [UIColor whiteColor];

        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake(0, 0, 38, 34);
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleCamera) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithCustomView:cancleButton];
        
        UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        takePhotoButton.frame = CGRectMake(0, 0, 68, 68);
        [takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
        [takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhoto_highlighted"] forState:UIControlStateHighlighted];
        [takePhotoButton addTarget:self action:@selector(takePhotoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *takePhotoItem = [[UIBarButtonItem alloc]initWithCustomView:takePhotoButton];
        
        UIButton *positionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        positionButton.frame = CGRectMake(0, 0, 34, 26);
        [positionButton setBackgroundImage:[UIImage imageNamed:@"changePosition"] forState:UIControlStateNormal];
        [positionButton setBackgroundImage:[UIImage imageNamed:@"changePosition_highLighted"] forState:UIControlStateHighlighted];
        [positionButton addTarget:self action:@selector(changePositionClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *positionItem = [[UIBarButtonItem alloc]initWithCustomView:positionButton];
        _bottomBar.items = @[cancelItem,flexibleSpace,takePhotoItem,flexibleSpace,positionItem];
    }
    return _bottomBar;
}

- (UIToolbar *)topBar {
    if (_topBar == nil) {
        _topBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        _topBar.barTintColor = [UIColor clearColor];
        _topBar.tintColor = [UIColor whiteColor];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = -16;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *flashStatusItem = [[UIBarButtonItem alloc]initWithCustomView:self.flashStatusButton];
        UIBarButtonItem *flashAutoItem = [[UIBarButtonItem alloc]initWithCustomView:self.flashAutoButton];
        UIBarButtonItem *flashOnItem = [[UIBarButtonItem alloc]initWithCustomView:self.flashOnButton];
        UIBarButtonItem *flashOffItem = [[UIBarButtonItem alloc]initWithCustomView:self.flashOffButton];
        
        _topBar.items = @[fixedSpace,flashStatusItem,flexibleSpace,flashAutoItem,flexibleSpace,flashOnItem,flexibleSpace,flashOffItem,flexibleSpace];
    }
    return _topBar;
}

- (UIButton *)flashStatusButton {
    if (_flashStatusButton == nil) {
        _flashStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashStatusButton.frame = CGRectMake(0, 0, 40, 40);
        [_flashStatusButton addTarget:self action:@selector(flashStatusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashStatusButton;
}

- (UIButton *)flashAutoButton {
    if (_flashAutoButton == nil) {
        _flashAutoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashAutoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashAutoButton setTitleColor:[UIColor colorWithRed:247/255.0 green:205/255.0 blue:70/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_flashAutoButton setTitle:@"自动" forState:UIControlStateNormal];
        _flashAutoButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashAutoButton sizeToFit];
        [_flashAutoButton addTarget:self action:@selector(changeFlashStatusClicked:) forControlEvents:UIControlEventTouchUpInside];
        _flashAutoButton.selected = YES;
        _flashAutoButton.hidden = YES;
    }
    return _flashAutoButton;
}

- (UIButton *)flashOnButton {
    if (_flashOnButton == nil) {
        _flashOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashOnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashOnButton setTitleColor:[UIColor colorWithRed:247/255.0 green:205/255.0 blue:70/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_flashOnButton setTitle:@"打开" forState:UIControlStateNormal];
        _flashOnButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashOnButton sizeToFit];
        [_flashOnButton addTarget:self action:@selector(changeFlashStatusClicked:) forControlEvents:UIControlEventTouchUpInside];
        _flashOnButton.hidden = YES;
    }
    return _flashOnButton;
}

- (UIButton *)flashOffButton {
    if (_flashOffButton == nil) {
        _flashOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashOffButton setTitleColor:[UIColor colorWithRed:247/255.0 green:205/255.0 blue:70/255.0 alpha:1.0] forState:UIControlStateSelected];
        [_flashOffButton setTitle:@"关闭" forState:UIControlStateNormal];
        _flashOffButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashOffButton sizeToFit];
        [_flashOffButton addTarget:self action:@selector(changeFlashStatusClicked:) forControlEvents:UIControlEventTouchUpInside];
        _flashOffButton.hidden = YES;
    }
    return _flashOffButton;
}

@end
