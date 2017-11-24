//
//  ZYImage.h
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface ZYPhoto : NSObject

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, copy) NSDictionary *thumbnailInfo;
@property (nonatomic, copy) NSDictionary *originalInfo;
@property (nonatomic, copy) NSString *creatTime;

- (NSArray *)comparatorAssets:(NSMutableArray *)assets;

@end
