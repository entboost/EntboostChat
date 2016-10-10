//
//  NSArray+Utility.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "NSArray+Utility.h"

@implementation NSArray (Utility)

+ (NSSortDescriptor*)gbkSortDescriptionWithFieldName:(NSString*)fieldName ascending:(BOOL)ascending
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //中文字符编码；注意gb2312字符集，ASCII字符排在中文字符前面；gbk则相反
    return [[NSSortDescriptor alloc] initWithKey:fieldName ascending:ascending comparator:^NSComparisonResult(id obj1, id obj2) {
        const char* chs1 = [obj1 cStringUsingEncoding:enc];
        const char* chs2 = [obj2 cStringUsingEncoding:enc];
        
        int result = strcmp(chs1, chs2);
        if (result<0)
            return NSOrderedAscending;
        else if (result >0)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

@end
