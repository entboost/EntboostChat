//
//  NSDate+Utility.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "NSDate+Utility.h"

@implementation NSDate (Utility)

- (NSString*)stringByFlexibleFormat
{
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDateComponents *componentsOfNow = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *componentsOfMsg = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    if (componentsOfNow.year == componentsOfMsg.year) { //同年
        if (componentsOfNow.month == componentsOfMsg.month && componentsOfNow.day == componentsOfMsg.day) { //同月同日
            fmt.dateFormat = @"HH:mm";
        } else {
            fmt.dateFormat = @"MMMd日EEE HH:mm";
        }
    } else {
        fmt.dateFormat = @"yyyy年MMMd日";
    }
    
    return [fmt stringFromDate:self];
}

+ (NSString*)timeStringWithSecond:(uint32_t)second
{
    uint32_t effectiveValue = second%(60*60);
    return [NSString stringWithFormat:@"%02i:%02i", effectiveValue/60, effectiveValue%60];
}

@end
