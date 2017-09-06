//
//  SystemUtils.m
//  youyi
//
//  Created by f.g.xiaofange on 16/4/11.
//  Copyright © 2016年 xiaofange. All rights reserved.
//

#import "SystemUtils.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#import <net/if_dl.h>
#import <AdSupport/AdSupport.h>
#import "sys/utsname.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation SystemUtils

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (float)systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *)currentDevice
{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)systemName
{
    return [[UIDevice currentDevice] systemName];
}

+ (NSString *)bundleIdentifier
{
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

/* 手机品牌规则：手机型号_系统版本##手机品牌(iPhone 6 plus_9.3.2##iPhone)*/
+ (NSString *)pbrand
{
    return [NSString stringWithFormat:@"%@_%@##%@",[self systemName],[[UIDevice currentDevice] systemVersion],[self currentDevice]];
}

#pragma mark - 远程推送
+ (BOOL)isAllowedRemoteNotification
{
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    }
    return NO;
}

#pragma mark - idfa唯一标识

+ (NSString *)idfaIdentifier
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)MACAddress
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *MACAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                            *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return MACAddress;
}

+ (NSString *)idfaString
{
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    } else {
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        if(asIdentifierMClass == nil){
            return @"";
        } else{
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            } else {
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                } else {
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}


#pragma mark - 系统权限获取
#pragma mark - 摄像头权限+照片权限+打电话权限+短信权限

+ (BOOL)isAppCameraAccessAuthorized
{
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

+ (BOOL)isAppPhotoLibraryAccessAuthorized
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        return NO;
    } else {
        return YES;
    }
}


+ (BOOL)cameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)frontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL)cameraFlashAvailable
{
    return [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)canSendSMS
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]];
}

+ (BOOL)canMakePhoneCall
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

/// 调用打电话功能（此种方法会直接进行拨打电话,电话结束后会留在电话界面）
+ (void)systemOpenTelphone:(NSString *)phone
{
    if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]]];
    }
}
/// 调用打电话功能（此种方法会询问是否拨打电话,电话结束后会返回到应用界面,但是有上架App Store被拒的案例）
+ (void)systemOpenTelpromptPhone:(NSString *)phone
{
    if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",phone]]];
    }
}

/// 调用发短信功能（此种方法会直接跳转到给指定号码发送短信,短信结束后会留在短信界面）
+ (void)systemOpenSendSMSWithPhone:(NSString *)phone
{
    if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",phone]]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",phone]]];
    }
}

/// 调用Safari浏览器功能
+ (void)systemOpenSafari:(NSString *)urlString
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

#pragma mark - 跳转到系统设置
/// 注意：想要实现应用内跳转到系统设置界面功能,需要先在Targets-Info-URL Types-URL Schemes中添加prefs
/// 跳转到WIFI设置
+ (void)systemOpenWIFI
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=WIFI"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}

/// 跳转到蓝牙
+ (void)systemOpenBluetooth
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
    }
}

/// 跳转到通用
+ (void)systemOpenGeneral
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=General"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
    }
}

/// 跳转到关于本机
+ (void)systemOpenGeneralAbountPhone
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=General&path=About"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=About"]];
    }
}

/// 跳转到定位服务
+ (void)systemOpenLocationService
{
    if ([[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationLaunchOptionsLocationKey]])
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationLaunchOptionsLocationKey]];
    }
    
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Prefs:root=LOCATION_SERVICES"]])
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"Prefs:root=LOCATION_SERVICES"]];
//    }
}

/// 跳转到通知
+ (void)systemOpenNotification
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"]];
    }
}

@end
