//
//  ZYImage.m
//  ZYImagePicker
//
//  Created by 石志愿 on 2017/11/23.
//  Copyright © 2017年 石志愿. All rights reserved.
//

#import "ZYPhoto.h"
#import <Photos/Photos.h>

@implementation ZYPhoto

#pragma mark - public

- (NSArray *)comparatorAssets:(NSMutableArray *)assets {
    NSArray *sortAssets = [assets sortedArrayUsingComparator:^NSComparisonResult(PHAsset *obj1, PHAsset *obj2) {
        return [obj1.creationDate compare:obj2.creationDate];
    }];
    return sortAssets;
}

#pragma mark - private

- (NSString *)formatCreationDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    // 2.获得creationDate的年月日
    NSDateComponents *creationDateCmps = [calendar components:unit fromDate:self.asset.creationDate];
    BOOL isToday = (creationDateCmps.year == nowCmps.year) && (creationDateCmps.month == nowCmps.month) && (creationDateCmps.day == nowCmps.day);
    BOOL isThisYear = nowCmps.year == creationDateCmps.year;

    // 3. 格式化
    NSString *formatString = @"";
    if (isToday) {
        formatString = @"今天";
    } else if (isThisYear) {
         formatString = [NSString stringWithFormat:@"%tu月%tu日",creationDateCmps.month,creationDateCmps.day]; //@"MM月dd日";
    } else {
        formatString = [NSString stringWithFormat:@"%tu年%tu月%tu日",creationDateCmps.year,creationDateCmps.month,creationDateCmps.day]; // @"yyyy年MM月dd日";
    }
    return formatString;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
//    NSLog(@"creationDate:%f", [asset.creationDate timeIntervalSince1970]);
    self.creatTime = [self formatCreationDate];
}

@end
