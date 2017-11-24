//
//  ZYImageTopBar.h
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYImageTopBar : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) void (^cancelClickedBlock)(void);

@end
