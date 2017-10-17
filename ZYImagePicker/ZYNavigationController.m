//
//  ZYNavigationController.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/10/17.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYNavigationController.h"

@interface ZYNavigationController ()

@end

@implementation ZYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationBar.backIndicatorTransitionMaskImage = [UIImage new];
    [self.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:18]}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
