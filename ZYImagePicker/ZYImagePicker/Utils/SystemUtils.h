//
//  SystemUtils.h
//  youyi
//
//  Created by f.g.xiaofange on 16/4/11.
//  Copyright © 2016年 xiaofange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemUtils : NSObject
/// app版本
+ (NSString *)appVersion;
/// 系统版本
+ (float)systemVersion;
/// 手机型号
+ (NSString *)currentDevice;
/// bundle id
+ (NSString *)bundleIdentifier;
/// 系统名称
+ (NSString *)systemName;
/// 品牌规则
+ (NSString *)pbrand;
/// iOS 8 以上是否开启通知
+ (BOOL)isAllowedRemoteNotification;
/// 相机权限
+ (BOOL)isAppCameraAccessAuthorized;
/// 照片(相册)权限
+ (BOOL)isAppPhotoLibraryAccessAuthorized;
/// 跳转到定位服务
+ (void)systemOpenLocationService;
@end
