//
//  ZYImagePickerController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYImageController.h"
#import "ZYClipViewController.h"
#import "ZYImageReusableView.h"
#import <Photos/Photos.h>
#import "ZYImageTopBar.h"
#import "ZYImageCell.h"
#import "ZYPhoto.h"

@interface ZYImageController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) ZYImageTopBar *topBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ZYImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self requestImagesForSystemAlbum];
            }
        }];
    } else {
        [self requestImagesForSystemAlbum];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUp {
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.collectionView];
}

- (void)showActivity {
    [self.view addSubview:self.activityIndicatorView];
    if (![self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView startAnimating];
    }
}

- (void)hiddenActivity {
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
}

#pragma mark -requestData

- (void)requestImagesForSystemAlbum {
    [self showActivity];
    dispatch_queue_t queue = dispatch_queue_create("albumQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSMutableArray *comparatorAssets = [NSMutableArray arrayWithCapacity:0];
        //    /// 1. 获取自定义相册的照片
        //    // 1.1  获得所有的自定义相簿
        //    PHFetchResult<PHAssetCollection *> *albumAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        //    // 1.2 遍历所有的自定义相簿
        //    for (PHAssetCollection *albumAssetCollection in albumAssetCollections) {
        //        [self enumerateAssetsInAssetCollection:albumAssetCollection comparatorAssets:comparatorAssets];
        //    }
        
        /// 2. 获得相机胶卷中的照片
        PHAssetCollection *smartAlbumAssetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        /// 3. 按日期排序
        [self enumerateAssetsInAssetCollection:smartAlbumAssetCollection comparatorAssets:comparatorAssets];
        /// 4. 遍历排序后数组，按日期分组
        [self enumerateComparatorAssets:[self comparatorAssets:comparatorAssets]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hiddenActivity];
            [self.collectionView reloadData];
            NSInteger section =  [self.collectionView numberOfSections];
            if (section > 0) {
                NSInteger row = [self.collectionView numberOfItemsInSection:section - 1];
                if (row > 0) {
                    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:section - 1] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }
            }
        });
    });
}

- (void)enumerateComparatorAssets:(NSArray *)comparatorAssets {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    /// 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    for (PHAsset *asset in comparatorAssets) {
        ZYPhoto *photo = [[ZYPhoto alloc]init];
        photo.asset = asset;
        /// 从asset中获得图片
        ///获取缩略图
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageW = ([UIScreen mainScreen].bounds.size.width - 3) / 4 * scale;
        CGSize thumbnailSize = CGSizeMake(imageW, imageW);
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:thumbnailSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            photo.thumbnailImage = result;
            photo.thumbnailInfo = info;
        }];
        BOOL isContain = NO;
        for (NSMutableArray *sectionArray in self.photos) {
            ZYPhoto *sectionPhoto = sectionArray.firstObject;
            if ([photo.creatTime isEqualToString:sectionPhoto.creatTime]) {
                [sectionArray addObject:photo];
                isContain = YES;
                break;
            }
        }
        if (!isContain) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:0];
            [sectionArray addObject:photo];
            [self.photos addObject:sectionArray];
        }
    }
}

/// 按日期排序
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection comparatorAssets:(NSMutableArray *)comparatorAssets {
    ///NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    /// 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        [comparatorAssets addObject:asset];
    }
}

- (NSArray *)comparatorAssets:(NSMutableArray *)assets {
    NSArray *sortAssets = [assets sortedArrayUsingComparator:^NSComparisonResult(PHAsset *obj1, PHAsset *obj2) {
        return [obj1.creationDate compare:obj2.creationDate];
    }];
    return sortAssets;
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
    clipViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:clipViewController animated:NO completion:nil];
}

#pragma mark - 保存

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
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if(error){
        NSLog(@"保存图片失败");
    }else{
        NSLog(@"保存图片成功");
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.photos.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZYImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    ZYPhoto *photo = self.photos[indexPath.section][indexPath.row];
    cell.imageView.image = photo.thumbnailImage;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZYPhoto *photo = self.photos[indexPath.section][indexPath.row];
    /// 获取原图
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    /// 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    CGSize originalSize = CGSizeMake(photo.asset.pixelWidth, photo.asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:originalSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        photo.originalImage = result;
        photo.originalInfo = info;
        [self clipImage:photo.originalImage];
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZYImageReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ImageReusableView" forIndexPath:indexPath];
    ZYPhoto *photo = [self.photos[indexPath.section] firstObject];
    supplementaryView.titleText = photo.creatTime;
    return supplementaryView;
}

#pragma mark - getter

- (ZYImageTopBar *)topBar {
    if (_topBar == nil) {
        _topBar = [[ZYImageTopBar alloc]initWithFrame:CGRectZero];
        __weak typeof(self)weakSelf = self;
        _topBar.cancelClickedBlock = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
    }
    return _topBar;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumLineSpacing = 1;
        flowLayout.minimumInteritemSpacing = 1;
        CGFloat itemW = ([UIScreen mainScreen].bounds.size.width - 3) / 4;
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        flowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 32);
        flowLayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 4);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topBar.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.topBar.frame)) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ZYImageCell class] forCellWithReuseIdentifier:@"imageCell"];
        [_collectionView registerClass:[ZYImageReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ImageReusableView"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSMutableArray *)photos {
    if (_photos == nil) {
        _photos = [NSMutableArray arrayWithCapacity:0];
    }
    return _photos;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.frame = CGRectMake(0, 0, 50, 50);
        _activityIndicatorView.center = self.view.center;
    }
    return _activityIndicatorView;
}

@end
