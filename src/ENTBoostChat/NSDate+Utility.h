//
//  NSDate+Utility.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utility)

///获取灵活格式化字符串
- (NSString*)stringByFlexibleFormat;

///秒数转换为时间字符串(mm:ss)
+ (NSString*)timeStringWithSecond:(uint32_t)second;

@end
